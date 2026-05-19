local ipCache = {}
local ipCacheTime = {}
local ipASNCache = {}
local ipASNCacheTime = {}

Nova.queryIPASN = function(ip, callback)
    local cacheTTL = 86400
    if ipASNCache[ip] and ipASNCacheTime[ip] and os.time() - ipASNCacheTime[ip] < cacheTTL then
        if isfunction(callback) then callback(ipASNCache[ip]) end
        return
    elseif ipASNCache[ip] then
        ipASNCache[ip] = nil
        ipASNCacheTime[ip] = nil
    end

    http.Fetch("https://ipinfo.io/" .. ip .. "/org",
        function(body)
            local asnStr = body:match("AS(%d+)")
            ipASNCache[ip] = asnStr and tonumber(asnStr) or nil
            ipASNCacheTime[ip] = os.time()
            if isfunction(callback) then callback(ipASNCache[ip]) end
        end,
        function(err)
            Nova.log("e", string.format("ipinfo.io ASN lookup failed for %s: %s", ip, err or ""))
            if isfunction(callback) then callback(nil) end
        end
    )
end

Nova.getCachedIPASN = function(ip)
    if not ip or not ipASNCache[ip] or not ipASNCacheTime[ip] then return nil end
    local cacheTTL = 86400
    if os.time() - ipASNCacheTime[ip] < cacheTTL then
        return ipASNCache[ip]
    end
    return nil
end

Nova.queryAbuseIPDB = function(ip, ply, callback)
    local apiKey = Nova.getSetting("networking_vpn_abuseipdb_apikey", "")
    if apiKey == "" or string.len(apiKey) < 10 then
        Nova.log("w", "No AbuseIPDB lookup possible, because no valid API key is set.")
        if isfunction(callback) then callback() end
        return
    end

    Nova.log("d", string.format("Starting AbuseIPDB lookup for %s", ip))

    local cacheTTL = 86400 // 24h
    if ipCache[ip] and ipCacheTime[ip] and os.time() - ipCacheTime[ip] < cacheTTL then
        if isfunction(callback) then callback(ipCache[ip]) end
        return
    elseif ipCache[ip] then
        ipCache[ip] = nil
        ipCacheTime[ip] = nil
    end

    local maxAge = Nova.getSetting("networking_vpn_abuseipdb_max_age", 90)
    local url = string.format("https://api.abuseipdb.com/api/v2/check?ipAddress=%s&maxAgeInDays=%d&key=%s&verbose", ip, maxAge, apiKey)
    http.Fetch(url,
        function(json)
            local data = util.JSONToTable(json)
            if data and data.data then
                ipCache[ip] = data.data
                ipCacheTime[ip] = os.time()
                if isfunction(callback) then callback(data.data) end
            else
                if isfunction(callback) then callback(nil) end
            end
        end,
        function(err)
            Nova.log("e", string.format("AbuseIPDB lookup failed: %q | URL: %q", err or "", url))
            if isfunction(callback) then callback(nil) end
        end
    )
end

Nova.reportAbuseIPDB = function(ip, categories, comment)
    local apiKey = Nova.getSetting("networking_vpn_abuseipdb_apikey", "")
    if apiKey == "" or string.len(apiKey) < 10 then return end

    local enabled = Nova.getSetting("networking_vpn_abuseipdb_report_enabled", false)
    if not enabled then return end

    Nova.log("d", string.format("Reporting IP %s to AbuseIPDB (categories: %s)", ip, categories))

    http.Post("https://api.abuseipdb.com/api/v2/report",
        {
            ip = ip,
            categories = categories,
            comment = comment or "Reported by Nova Defender",
            key = apiKey,
        },
        function(json)
            local data = util.JSONToTable(json)
            if data and data.data then
                Nova.log("s", string.format("Successfully reported IP %s to AbuseIPDB. Score: %d", ip, data.data.abuseConfidenceScore or 0))
            elseif data and data.errors then
                Nova.log("e", string.format("Failed to report IP %s to AbuseIPDB: %s", ip, tostring(data.errors[1] and data.errors[1].detail or "unknown error")))
            end
        end,
        function(err)
            Nova.log("e", string.format("HTTP request to report IP %s to AbuseIPDB failed: %s", ip, err or ""))
        end
    )
end

Nova.getAbuseIPDBInfo = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(steamID)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local ip = Nova.extractIP(ply:IPAddress())
    if not ip then return end

    if not ipCache[ip] then return end

    local cacheTTL = 86400 // 24h
    if ipCacheTime[ip] and os.time() - ipCacheTime[ip] >= cacheTTL then
        ipCache[ip] = nil
        ipCacheTime[ip] = nil
        return
    end

    return ipCache[ip]
end

hook.Add("nova_banbypass_onplayerban", "networking_vpn_abuseipdb_report", function(steamID, ban, isOnline)
    if not Nova.getSetting("networking_vpn_abuseipdb_report_enabled", false) then return end
    if not ban or ban.ip == "" then return end

    local internalReason = ban.internal_reason or ""

    local floodReasons = {
        ["networking_spam"] = true,
        ["networking_dos"] = true,
        ["networking_dos_crash"] = true,
    }

    if floodReasons[internalReason] then
        local categories = Nova.getSetting("networking_vpn_abuseipdb_report_flood_categories", "4")
        local comment = string.format("Garry's Mod server: Player %s banned for %s", tostring(ban.steamid or "unknown"), internalReason)
        Nova.reportAbuseIPDB(ban.ip, categories, comment)
    end
end)
