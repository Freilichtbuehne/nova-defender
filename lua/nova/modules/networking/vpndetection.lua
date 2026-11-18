local ipCache = {}
local ipCacheTime = {}

// VPNDetection needs no API key: https://vpndetection.io/terms#no-key
local function Normalize(data)
    local location = istable(data.location) and data.location or {}
    local asn = istable(data.asn) and data.asn or {}
    local asnNumber = tonumber(asn.asn)
    local isVPN = data.is_vpn == true
    local isTor = data.is_tor == true
    local isRelay = data.is_relay == true
    return {
        ["ip"] = data.ip,
        ["is_vpn"] = isVPN,
        ["is_tor"] = isTor,
        ["is_relay"] = isRelay,
        // the fingerprint reads active_vpn, as IPQualityScore names it
        ["active_vpn"] = isVPN or isTor or isRelay,
        ["country_code"] = location.country or "",
        ["country"] = location.country_name or "",
        ["timezone"] = location.timezone or "",
        ["ASN"] = (asnNumber and asnNumber > 0) and asnNumber or nil,
        ["ISP"] = asn.name or "",
        ["network_type"] = asn.type or "",
    }
end

Nova.queryVPNDetection = function(ip, ply, callback)
    Nova.log("d", string.format("Starting VPNDetection lookup for %s", ip))

    local cacheTTL = 86400 // 24h
    if ipCache[ip] and ipCacheTime[ip] and os.time() - ipCacheTime[ip] < cacheTTL then
        if isfunction(callback) then callback(ipCache[ip]) end
        return
    elseif ipCache[ip] then
        ipCache[ip] = nil
        ipCacheTime[ip] = nil
    end

    local url = "https://api.vpndetection.io/" .. ip
    http.Fetch(url,
        function(json, _, _, code)
            local data = util.JSONToTable(json or "")
            if code == 200 and istable(data) and data.ip then
                ipCache[ip] = Normalize(data)
                ipCacheTime[ip] = os.time()
                if isfunction(callback) then callback(ipCache[ip]) end
            else
                Nova.log("e", string.format("VPNDetection lookup failed for %s: %s", ip, istable(data) and tostring(data.error) or tostring(code)))
                if isfunction(callback) then callback(nil) end
            end
        end,
        function(err)
            Nova.log("e", string.format("VPNDetection lookup failed: %q | URL: %q", err or "", url))
            if isfunction(callback) then callback(nil) end
        end
    )
end

Nova.getVPNDetectionInfo = function(ply_or_steamid)
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
