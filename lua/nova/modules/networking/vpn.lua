// we don't want to waste API-calls and prevent the users from 
// reconnecting to cause a Denial of Service (when the limit of API-calls is reached)

local ipCache = {}
local playersUsingVPN = {}

/*local vpnASNs = {
    "AS212238",
}*/

// curl https://otx.alienvault.com/api/v1/indicators/IPv4/169.150.197.104/general -H "X-OTX-API-KEY: b58ef12397a9272b882892115fb8e2b15752b30c3ce3b6d06d5b9a179ec7e1e3"


Nova.queryIPScore = function(ip, ply, callback)
    local apiKey = Nova.getSetting("networking_vpn_apikey", "")
    if apiKey == "" or string.len(apiKey) < 32 then
        Nova.log("w", "No VPN lookup possible, because no valid API key is set in the config.")
        if isfunction(callback) then callback() end
        return
    end

    Nova.log("d", string.format("Starting IP lookup for %s", ip))

    if ipCache[ip] then
        callback(ipCache[ip])
        if Nova.getSetting("networking_vpn_dump", false) then
            Nova.log("d", string.format("Dumping IP address info for %s", Nova.playerName(ply)))
            PrintTable(ipCache[ip])
        end
        return
    end

    local url = string.format("https://ipqualityscore.com/api/json/ip/%s/%s?strictness=2", apiKey, ip)
    http.Fetch(url,
        function(json)
            local data = util.JSONToTable(json)
            ipCache[ip] = data
            if isfunction(callback) then callback(data) end
            if Nova.getSetting("networking_vpn_dump", false) then
                Nova.log("d", string.format("Dumping IP address info for %s", Nova.playerName(ply)))
                PrintTable(ipCache[ip])
            end
        end,
        function(err)
            Nova.log("e", string.format("IP lookup failed: %q | URL: %q", err or "", url))
            callback(nil)
        end
    )
end

Nova.registerAction("networking_vpn", "networking_vpn_vpn-action", {
    ["add"] = function(ply, info)
        Nova.addDetection(ply, "networking_vpn", Nova.lang("notify_networking_vpn", Nova.playerName(ply), info))
    end,
    ["nothing"] = function(ply, info)
        Nova.log("i", string.format("%s is using a VPN, but no action was taken.", Nova.playerName(ply)))
    end,
    ["notify"] = function(ply, info)
        Nova.log("w", string.format("%s is using a VPN: %s", Nova.playerName(ply), info))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "vpn",
            ["message"] = Nova.lang("notify_networking_vpn", Nova.playerName(ply), info),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["kick"] = function(ply, info)
        Nova.kickPlayer(ply, Nova.getSetting("networking_vpn_vpn-action_reason", "Usage of a VPN is not permitted"), "networking_vpn")
    end,
    ["ban"] = function(ply, info)
        Nova.banPlayer(
            ply,
            Nova.getSetting("networking_vpn_vpn-action_reason", "Usage of a VPN is not permitted"),
            string.format("Player was using a VPN. %s", info),
            "networking_vpn"
        )
    end,
    ["allow"] = function(ply, info, admin)
        // whitelist asn
        local vpnInfo = Nova.getCachedVPNInfo(ply)
        if not vpnInfo or not vpnInfo.ASN or vpnInfo.ASN == "" then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("%s is using a VPN, but no action was taken.", Nova.playerName(ply)))
            return
        end
        local asn = vpnInfo.ASN
        // add to whitelist
        local whitelist = Nova.getSetting("networking_vpn_whitelist_asns", {})
        if not table.HasValue(whitelist, asn) then
            table.insert(whitelist, asn)
            Nova.setSetting("networking_vpn_whitelist_asns", whitelist)
        end

        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(ply, info, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s is using a VPN: %s", Nova.playerName(ply), info))
        Nova.askAction({
            ["identifier"] = "networking_vpn",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_vpn_action", info),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format("Player was using a VPN. %s", info),
                    reason = Nova.getSetting("networking_vpn_vpn-action_reason", "Usage of a VPN is not permitted"),
                    internal_reason = "networking_vpn"
                })
                Nova.startAction("networking_vpn", "nothing", steamID, info)
                return
            end
            Nova.startAction("networking_vpn", answer, steamID, info, admin)
        end)
    end,
})

Nova.registerAction("networking_country", "networking_vpn_country-action", {
    ["add"] = function(ply, info)
        Nova.addDetection(ply, "networking_country", Nova.lang("notify_networking_country", Nova.playerName(ply), info))
    end,
    ["nothing"] = function(ply, info)
        Nova.log("i", string.format("%s is from a not allowed country, but no action was taken.", Nova.playerName(ply)))
    end,
    ["notify"] = function(ply, info)
        Nova.log("w", string.format("%s is from a not allowed country. %s", Nova.playerName(ply), info))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "vpn",
            ["message"] = Nova.lang("notify_networking_country", Nova.playerName(ply), info),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["kick"] = function(ply, info)
        Nova.kickPlayer(ply, Nova.getSetting("networking_vpn_country-action_reason", "Your country is blocked on this server"), "networking_country")
    end,
    ["ban"] = function(ply, info)
        Nova.banPlayer(
            ply,
            Nova.getSetting("networking_vpn_country-action_reason", "Your country is blocked on this server"),
            string.format("Player was from not allowed country. %s", info),
            "networking_country"
        )
    end,
    ["allow"] = function(ply, info, admin)
        // whitelist country
        local vpnInfo = Nova.getCachedVPNInfo(ply)
        if not vpnInfo or not vpnInfo.country_code or vpnInfo.country_code == "" then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("%s is from a not allowed country, but no action was taken.", Nova.playerName(ply)))
            return
        end
        local country = string.upper(vpnInfo.country_code or "")
        // add to whitelist
        local whitelist = Nova.getSetting("networking_vpn_countrycodes", {})
        if not table.HasValue(whitelist, country) then
            table.insert(whitelist, country)
            Nova.setSetting("networking_vpn_countrycodes", whitelist)
        end

        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(ply, info, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s is using a VPN: %s", Nova.playerName(ply), info))
        Nova.askAction({
            ["identifier"] = "networking_country",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_country_action", info),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format("Player was from not allowed country. %s", info),
                    reason = Nova.getSetting("networking_vpn_country-action_reason", "Your country is blocked on this server"),
                    internal_reason = "networking_country"
                })
                Nova.startAction("networking_country", "nothing", steamID, info)
                return
            end
            Nova.startAction("networking_country", answer, steamID, info, admin)
        end)
    end,
})

Nova.getCachedVPNInfo = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(steamID)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local ip = Nova.extractIP(ply:IPAddress())
    if not ip then return end

    if not ipCache[ip] or not ipCache[ip].success then return end

    return ipCache[ip]
end

Nova.hasVPN = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not steamID then return end
    return playersUsingVPN[steamID] or false
end

local function CheckVPN(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local steamID = ply:SteamID()

    // Trusted, Staff and Protected players won't be checked for VPN (protected counts as trusted)
    if Nova.isTrusted(ply) then
        Nova.log("d", string.format("Skipped VPN check for %s: Trusted", Nova.playerName(ply)))
        return
    end

    // Check custom rules defined in the config file
    if isfunction( Nova.config["banbypass_should_check_vpn"])
        and not Nova.config["banbypass_should_check_vpn"](ply)
    then
        Nova.log("d", string.format("Skipped VPN check for %s: Custom rule", Nova.playerName(ply)))
        return
    end

    // Check if IP is valid
    local ip = Nova.extractIP(ply:IPAddress(), true)
    if not ip then
        Nova.log("e", string.format("Invalid IP address for VPN lookup: %q", tostring(ply:IPAddress() or "EMPTY")))
        return
    end

    Nova.queryIPScore(ip, ply, function(data)
        if not data or not data.success then return end

        local allowedCountry = true
        local allowedCountries = Nova.getSetting("networking_vpn_countrycodes", {})
        if not table.IsEmpty(allowedCountries) then
            allowedCountry =
                table.HasValue(allowedCountries, string.upper(data.country_code or ""))
                or table.HasValue(allowedCountries, string.lower(data.country_code or ""))
                or false
        end

        local isVPN = /*data.vpn or */data.active_vpn or false
        local isKnownASN = table.HasValue(Nova.getSetting("networking_vpn_whitelist_asns", {}), tostring(data.ASN)) or false

        if not allowedCountry then
            local infoString = string.format("IP: %s, Country: %s, ISP: %q", tostring(ip), tostring(data.country_code), tostring(data.ISP))
            Nova.log("w", string.format("%s is joining from a blocked country. %s", Nova.playerName(ply), infoString))

            Nova.startDetection("networking_country", ply, infoString, "networking_vpn_country-action")
        end

        if not isKnownASN and isVPN then
            local infoString = string.format("IP: %s, Country: %s, ISP: %q, ASN: %q, Region: %s", tostring(ip), tostring(data.country_code), tostring(data.ISP), tostring(data.ASN), tostring(data.region))
            playersUsingVPN[steamID] = true
            Nova.log("w", string.format("%s is using a VPN. %s", Nova.playerName(ply), infoString))

            Nova.startDetection("networking_vpn", ply, infoString, "networking_vpn_vpn-action")
        end
    end)
end

hook.Add("nova_banbypass_cookieloaded", "networking_vpncheck", function(ply)
    Nova.log("d", string.format("Checking VPN status for %s", Nova.playerName(ply)))
    CheckVPN(ply)
end)

hook.Add("nova_base_playerdisconnect", "networking_removeplayervpn", function(steamID)
    Nova.log("d", string.format("Removing VPN info from %s", Nova.playerName(steamID)))
    playersUsingVPN[steamID] = nil
end)

concommand.Add("nova_ip", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(ipCache)
end)