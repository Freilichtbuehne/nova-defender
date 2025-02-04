/*
    This module gives you a simple way to get basic metrics of players.
*/

// https://steamcommunity.com/dev/apikey

local indicatorCache = {}

// each indicator has a score as how critical it is from 1 to 10
local allowedIndicators = {
    ["indicator_install_fresh"] = 1,
    ["indicator_install_reinstall"] = 2,
    ["indicator_advanced"] = 1,
    ["indicator_first_connect"] = 2,
    ["indicator_cheat_hotkey"] = 2,
    ["indicator_cheat_menu"] = 3,
    ["indicator_lua_binaries"] = 5,
    ["indicator_bhop"] = 5,
    ["indicator_memoriam"] = 10,
    ["indicator_multihack"] = 10,
    ["indicator_fenixmulti"] = 10,
    ["indicator_interstate"] = 10,
    ["indicator_exechack"] = 10,
    ["indicator_banned"] = 7,
    ["indicator_profile_familyshared"] = 3,
    ["indicator_profile_friend_banned"] = 3,
    ["indicator_profile_recently_created"] = 5,
    ["indicator_profile_nogames"] = 4,
    ["indicator_profile_new_player"] = 6,
    ["indicator_profile_vac_banned"] = 5,
    ["indicator_profile_vac_bannedrecent"] = 7,
    ["indicator_profile_community_banned"] = 5,
    ["indicator_profile_not_configured"] = 8,
    ["dummy"] = 1,
}

// specific scenarios
local function Any(c, t)
    for _, v in pairs(t or c) do
        if type(v) == "boolean" then
            if v then return true end
        else
            if c[v] then return true end
        end
    end
    return false
end
local function All(c, t)
    for _, v in pairs(t or c) do
        if type(v) == "boolean" then
            if not v then return false end
        else
            if not c[v] then return false end
        end
    end
end

// we create scenarios to connect multiple indicators
local scenarios = {
    ["indicator_scenario_bypass_account"] = function(cache)
        local install = Any(cache, {
            "indicator_install_fresh",
            "indicator_install_reinstall",
        })
        local steam = Any(cache, {
            "indicator_profile_recently_created",
            "indicator_profile_not_configured",
        })
        return All({install, steam})
    end,
    ["indicator_scenario_cheatsuspect"] = function(cache)
        local otherGame = Any(cache, {
            "indicator_profile_vac_bannedrecent",
        })
        local thisGame = Any(cache, {
            "indicator_memoriam",
            "indicator_multihack",
            "indicator_fenixmulti",
            "indicator_interstate",
            "indicator_exechack",
            "indicator_banned",
            "indicator_lua_binaries",
        })
        local suspicious = Any(cache, {
            "indicator_bhop",
            "indicator_cheat_hotkey",
            "indicator_cheat_menu",
        })
        return thisGame or All({otherGame, suspicious})
    end,
    ["indicator_scenario_sum"] = function(cache)
        local sum = 0
        for k, v in pairs(cache) do sum = sum + v end
        return sum > 10
    end,
}
local scenarioCache = {}

local indicatorPayload = [[
    local serverUID = %q
    local indicators = {["dummy"] = true}

    local seed, mod = 0, 2 ^ 32
    local bls = bit.lshift
    local brs = bit.rshift
    local function blr(x, disp) return bls(x, disp) + brs(x, 32 - disp) end
    local function brr(x, disp) return brs(x, disp) + bls(x, 32 - disp) end
    local function xrshft() seed = blr(seed, 13) + brr(seed, 17) + blr(seed, 5) + seed return seed %% 256 end

    local function enc(input)
        seed = tonumber(string.upper(string.sub(util.SHA1(%q), 1, 8)),16) %% mod
        local out = {}
        for i = 1, string.len(input) do
            local b = string.byte(input, i)
            local c = xrshft()
            local e = bit.bxor(c, b)
            out[i] = string.format("\\%%03d", e)
        end
        return table.concat(out)
    end

    local function StartupScan()
        local function GetOldestFileTime(_search, path)
            local files, _ = file.Find(_search, path)
            local oldest
            for _, _file in pairs(files) do
                if not string.find(_file, "/") then 
                    local t = file.Time(_file, path)
                    if t and (not oldest or (oldest and t < oldest and t ~= 0)) then
                        oldest = t
                    end
                end
            end
            return oldest
        end
        
        if GetOldestFileTime("*", "base_path") > os.time() - 2 * 24 * 60 * 60 then
            indicators["indicator_install_fresh"] = true
        end
        
        if not indicators["indicator_fresh_install"] and GetOldestFileTime("gameinfo.txt", "GAME") > os.time() - 1 * 24 * 60 * 60 then
            indicators["indicator_install_reinstall"] = true
        end
        
        if GetConVar("net_graph"):GetInt() ~= 0 or
            GetConVar("developer"):GetInt() ~= 0 or
            GetConVar("cl_showpos"):GetInt() ~= 0
        then
            indicators["indicator_advanced"] = true
        end

        local filePaths = {"vcmod_download_data.txt"}
        for i = 1, #filePaths do if file.Exists(filePaths[i], "DATA") then
            indicators["indicator_banned"] = true
        end end
    
        if not cookie.GetString("nova_server_" .. serverUID) and not indicators["indicator_install_reinstall"] then
            indicators["indicator_first_connect"] = true
            cookie.Set("nova_server_" .. serverUID, "1")
        end

        local bhopBind = "+jump"
        if input.LookupKeyBinding( MOUSE_WHEEL_UP ) == bhopBind
            or input.LookupKeyBinding( MOUSE_WHEEL_DOWN ) == bhopBind then
            indicators["indicator_bhop"] = true
        end

        if file.Exists("garrysmod/lua/bin", "base_path") then
            local files, _ = file.Find("garrysmod/lua/bin/*", "base_path")
            for _, _file in pairs(files) do
                if string.EndsWith(_file, ".dll") then
                    indicators["indicator_lua_binaries"] = true
                    break
                end
            end
        end
    end

    local function S()
        StartupScan()
        net.Start(%q)
            net.WriteString(enc(util.TableToJSON(indicators)))
        net.SendToServer()
    end

    local keys = {KEY_INSERT, KEY_HOME, KEY_PAGEUP, KEY_PAGEDOWN}
    local hookName = %q
    local oldCursor = vgui.CursorVisible()
    hook.Add( "Think", hookName, function()
        for k, v in ipairs(keys) do
            if input.IsKeyDown(v) and not input.LookupKeyBinding(v) then
                if not indicators["indicator_cheat_hotkey"] then
                    indicators["indicator_cheat_hotkey"] = true
                    S()
                end
                if not oldCursor and vgui.CursorVisible() then
                    indicators["indicator_cheat_menu"] = true
                    S()
                    hook.Remove("Think", hookName)
                end
                break
            end
        end
        oldCursor = vgui.CursorVisible()
    end )

    S()
]]

local function Set(steamID, key)
    if not indicatorCache[steamID] then indicatorCache[steamID] = {} end
    indicatorCache[steamID][key] = allowedIndicators[key]

    // check scenarios and send notifiy
    local cache = indicatorCache[steamID]

    for k, v in pairs(scenarios) do
        if not v(cache) then continue end
        if not scenarioCache[steamID] then scenarioCache[steamID] = {} end
        if scenarioCache[steamID][k] then continue end
        scenarioCache[steamID][k] = true
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "indicators",
            ["message"] = Nova.lang(k),
            ["ply"] = Nova.convertSteamID(steamID),
        })
    end
end

local function SendPayload(ply, encryptionKey)
    local payload = Nova.extensions["anticheat"] and Nova.getExtendedIndicatorPayload() or indicatorPayload
    Nova.sendLua(
        ply,
        string.format(payload,
            Nova.getSetting("uid", nil),
            encryptionKey,
            Nova.netmessage("banbypass_indicator"),
            Nova.generateString(8,15)
        ),
        {
            protected = true,
            cache = true,
            disable_express = true
        }
    )
    Nova.log("d", string.format("Sent indicator payload to %s", Nova.playerName(ply)))
end

Nova.getIndicators = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    return indicatorCache[steamID]
end

local lookupCache = {}
local playerLookup = {}
local lookupEntries = {
    {
        ["name"] = "PlayerSummaries",
        ["public_only"] = false,
        ["url"] = function(steamID64, apikey)
            return string.format(
                "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s",
                    apikey, steamID64)
        end,
        ["indicators"] = function(steamID, res)
            if not res["response"] or not res["response"]["players"] or not res["response"]["players"][1] then
                return
            end

            // check if profile is confirgured or not
            if not res["response"]["players"][1]["profilestate"] or res["response"]["players"][1]["profilestate"] != 1 then
                local key = "indicator_profile_not_configured"
                Set(steamID, key)
            end

            // if profile is public we set playerLookup["is_public"] to true
            if res["response"]["players"][1]["communityvisibilitystate"] == 3 then
                playerLookup[steamID]["is_public"] = true
            else
                // if the profile is private we don't need any further data
                return
            end

            // check if profile was created in the last 7 days
            if res["response"]["players"][1]["timecreated"] > os.time() - 7 * 24 * 60 * 60 then
                local key = "indicator_profile_recently_created"
                Set(steamID, key)
            end
        end,
    },{
        ["name"] = "GetPlayerBans",
        ["public_only"] = true,
        ["url"] = function(steamID64, apikey)
            return string.format(
                "https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=%s&steamids=%s",
                    apikey, steamID64)
        end,
        ["indicators"] = function(steamID, res)
            if not res or not res["players"] or table.IsEmpty(res["players"]) then
                return
            end
            // check if vac ban in last 5 months exists
            local daysSinceLastBan = res["players"][1]["DaysSinceLastBan"]
            if daysSinceLastBan != 0 and daysSinceLastBan < 5 * 30 then
                local key = "indicator_profile_vac_bannedrecent"
                Set(steamID, key)
            elseif res["players"][1]["VACBanned"] then
                local key = "indicator_profile_vac_banned"
                Set(steamID, key)
            end
            if res["players"][1]["CommunityBanned"] then
                local key = "indicator_profile_community_banned"
                Set(steamID, key)
            end
        end,
    },{
    },{
        ["name"] = "FriendList",
        ["public_only"] = true,
        ["url"] = function(steamID64, apikey)
            return string.format(
                "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=%s&steamid=%s&relationship=friend&format=json",
                    apikey, steamID64)
        end,
        ["indicators"] = function(steamID, res)
            if not res["friendslist"] or not res["friendslist"]["friends"] or table.IsEmpty(res["friendslist"]["friends"]) then
                return
            end
            local allBans = Nova.getBanLookupTable()
            local key = "indicator_profile_friend_banned"
            // iterate over all friends and check if they are banned
            for _, friend in pairs(res["friendslist"]["friends"]) do
                local friendSteamID64 = tostring(friend["steamid"])
                if allBans[friendSteamID64] then
                    Set(steamID, key)
                    break
                end
            end
        end,
    },{
        ["name"] = "OwnedGames",
        ["public_only"] = true,
        ["url"] = function(steamID64, apikey)
            return string.format(
                "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=%s&steamid=%s&format=json",
                    apikey, steamID64)
        end,
        ["indicators"] = function(steamID, res)
            if not res["response"] or not res["response"]["game_count"] then
                return
            end

            // if player has no purchased games
            local key = "indicator_profile_nogames"
            if res["response"]["game_count"] == 0 then
                Set(steamID, key)
            end

            // check if garrysmod was played for not more than 2 hours
            key = "indicator_profile_new_player"
            for _, _game in pairs(res["response"]["games"]) do
                if _game["appid"] == 4000 and _game["playtime_forever"] < 2 * 60 then
                    Set(steamID, key)
                    break
                end
            end
        end,
        // https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=70895E43EA0923823EA1B58F0EC0319D&steamids=76561198137959992
        // 
    }
}

local function ValidAPIKey()
    local apiKey = Nova.getSetting("banbypass_bypass_indicators_apikey", "")
    if apiKey == "" or string.len(apiKey) != 32 then return false end
    return apiKey
end

local function QuerySteamAPI(url, callback)
    if not isfunction(callback) then return end

    // check if we already have the data cached
    if lookupCache[url] then
        callback(lookupCache[url])
        return
    end
    http.Fetch(url,
        function(json)
            local data = util.JSONToTable(json)
            // add data to cache
            lookupCache[url] = data
            callback(data)
        end,
        function(err)
            Nova.log("e", string.format("SteamAPI lookup failed: %q | URL: %q", err or "", url))
            callback(nil)
        end
    )
end

local function GetPlayerSteamData(ply_or_steamid)
    // check if we have a valid API key
    local apiKey = ValidAPIKey()
    if not apiKey then
        Nova.log("w", "No SteamAPI lookup possible, because no valid API key is set in the config.")
        return
    end

    local steamID = Nova.convertSteamID(ply_or_steamid)
    local steamID64 = tostring(util.SteamIDTo64(steamID))

    // check if player has an active lookup running
    if playerLookup[steamID] then
        Nova.log("d", string.format("SteamAPI lookup for %s is already running", Nova.playerName(steamID)))
        return
    end

    Nova.log("d", string.format("Starting SteamAPI lookup for %s", Nova.playerName(steamID)))

    if not indicatorCache[steamID] then indicatorCache[steamID] = {} end
    playerLookup[steamID] = {
        ["tasks"] = table.Copy(lookupEntries),
        ["is_public"] = false,
    }

    // start the lookup
    local function Lookup()
        local task = table.remove(playerLookup[steamID]["tasks"], 1)
        // check if we finished all tasks
        if not task or table.IsEmpty(task) then
            playerLookup[steamID] = nil
            Nova.log("s", string.format("Finished SteamAPI lookup for %s", Nova.playerName(steamID)))
            return
        end

        Nova.log("d" ,string.format("Running SteamAPI %q lookup for %s", task["name"], Nova.playerName(steamID)))

        local url = task["url"](steamID64, apiKey)
        QuerySteamAPI(url, function(data)
            if not data or not istable(data) or table.IsEmpty(data) then
                Nova.log("w", string.format("SteamAPI lookup for %s failed", Nova.playerName(steamID)))
                Lookup()
                return
            end

            // check if task should run with profile visibility
            if task["public_only"] and not playerLookup[steamID]["is_public"] then
                Lookup()
                return
            end

            // run indicator check
            task["indicators"](steamID, data)

            Lookup()
        end)
    end

    Lookup()
end

hook.Add("nova_init_loaded", "banbypass_indicator", function()
    Nova.log("d", "Creating indicator netmessages")
    Nova.netmessage("banbypass_indicator")
    local encryptionKey = Nova.generateString(16, 32)

    Nova.netReceive(Nova.netmessage("banbypass_indicator"),
        {
            auth = true,
            limit = 2,
            interval = 30,
        },
    function(len, ply)
        // we ignore the case where the player has already sent us indicators
        // we take into account that the player could potentially overwrite the indicators with fake ones
        local indicator = net.ReadString() or ""
        if not indicator or indicator == "" then
            Nova.log("w", string.format("Indicator response from %s is empty: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        Nova.log("d", string.format("Received indicator check from %s", Nova.playerName(ply)))

        // decrypt the indicators and parse them
        indicator = Nova.cipher.decrypt(Nova.decode(indicator), encryptionKey)
        indicator = util.JSONToTable(indicator)

        // check if the indicators are valid
        if not indicator or not istable(indicator) then
            //TODO: Take action?
            /*
            Nova.startDetection(
                "anticheat_detection",
                steamID,
                "anticheat_manipulate_ac",
                string.format("Player blocked an unknown anticheat detection. This can also be caused by a timeout. Only a backup message was received within %d seconds.", detectionTimeout),
                "anticheat_action"
            )
            */
            Nova.log("w", string.format("Indicator response from %s is invalid: Indicates manipulation", Nova.playerName(ply)))
            return
        elseif not indicator["dummy"] then
            // TODO: Take action?
            Nova.log("w", string.format("Indicator response from %s was manipulated", Nova.playerName(ply)))
            return
        end

        local steamID = ply:SteamID()
        if not indicatorCache[steamID] then indicatorCache[steamID] = {} end

        // remove the pending indicator
        indicatorCache[steamID]["indicator_pending"] = nil
        // remove the dummy indicator
        indicator["dummy"] = nil

        for k, v in pairs(indicator) do
            // only allow whitelisted values
            if not allowedIndicators[k] then
                local capped = Nova.truncate(k, 20, "...")
                Nova.log("w", string.format("Indicator response from %s contains invalid indicator which indicated manipulation: %q", Nova.playerName(ply), capped))
                continue
            end

            // only add new indicators
            if not indicatorCache[steamID][k] then
                Set(steamID, k)
            end
        end
    end)

    hook.Add("nova_networking_playerauthenticated", "banbypass_indicator", function(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        // if player blocks the payload an indicator would still remain
        local steamID = ply:SteamID()
        if not indicatorCache[steamID] then
            indicatorCache[steamID] = {["indicator_pending"] = 1}
        end

        // check familyshare
        if Nova.isFamilyShared(ply) then
            local key = "indicator_profile_familyshared"
            Set(steamID, key)
        end

        SendPayload(ply, encryptionKey)
        GetPlayerSteamData(ply)
    end)
end)

// Remove all indicators for a player when they disconnect
hook.Add("nova_base_playerdisconnect", "banbypass_indicators", function(steamID)
    Nova.log("d", string.format("Removing indicators for %s", Nova.playerName(steamID)))
    indicatorCache[steamID] = nil
end)