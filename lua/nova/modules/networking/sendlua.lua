/*
    Nova Defender is fileless for the client. So no code is visible via a conventional filestealer.
    Every code gets send over netmessages and is then run via RunString on the client.
    Of course a good filestealer can dump every code passed to RunString, but this is nothing we can prevent.
    Security by obscurity is the dumbest idea ever made, so we don't make use of it.

    For bandwith and performance reasons, we compress all data we send to the client.
    This is because we don't want to send huge payloads over netmessages which can cause lags for some clients.

    Optionally we can enable gm_express (https://github.com/CFC-Servers/gm_express/) that transfers data via HTTP.

    We don't use Garry's Mod's built in SendLua function because it has a limit of 254 bytes.
    Additionaly we want to check if the client has really received the code and ran it or not.

    Practically, we can never be completely sure that the client really executed the code and did not manipulated it.
    But this is out of scope for Nova.

    Afterwards we can just use the function Nova.sendLua to run arbitrary code on the client.
*/

local playerStatus = {}

Nova.registerAction("networking_authentication", "networking_sendlua_authfailed_action", {
    ["add"] = function(ply)
        Nova.addDetection(ply, "networking_authentication", Nova.lang("notify_networking_auth_failed", Nova.playerName(ply)))
    end,
    ["nothing"] = function(ply)
        Nova.log("i", string.format("%s couldn't authenticate, but no action was taken.", Nova.playerName(ply)))
    end,
    ["notify"] = function(ply)
        Nova.log("w", string.format("%s couldn't authenticate.", Nova.playerName(ply)))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_auth_failed", Nova.playerName(ply)),
            ["ply"] = Nova.convertSteamID(ply)
        })
    end,
    ["kick"] = function(ply)
        Nova.kickPlayer(ply, Nova.getSetting("networking_sendlua_authfailed_reason", "Authentication Error"), "networking_authentication")
    end,
    ["ban"] = function(ply)
        Nova.banPlayer(ply, Nova.getSetting("networking_sendlua_authfailed_reason", "Authentication Error"), "Failed to authenticate with Nova. This may indicate manipulation.", "networking_authentication")
    end,
    ["allow"] = function(ply, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s couldn't authenticate, but no action was taken.", Nova.playerName(ply)))
    end,
    ["ask"] = function(ply, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s couldn't authenticate.", Nova.playerName(ply)))
        Nova.askAction({
            ["identifier"] = "networking_authentication",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_auth_failed_action"),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = "Failed to authenticate with Nova. This may indicate manipulation, but could also be caused by a slow connection.",
                    reason = Nova.getSetting("networking_sendlua_authfailed_reason", "Authentication Error"),
                    internal_reason = "networking_authentication"
                })
                Nova.startAction("networking_authentication", "nothing", steamID)
                return
            end
            Nova.startAction("networking_authentication", answer, steamID, admin)
        end)
    end,
})

Nova.registerAction("networking_validation", "networking_sendlua_validationfailed_action", {
    ["add"] = function(ply)
        Nova.addDetection(ply, "networking_validation", Nova.lang("notify_networking_sendlua_failed", Nova.playerName(ply)))
    end,
    ["nothing"] = function(ply)
        Nova.log("i", string.format("%s couldn't validate sendlua, but no action was taken.", Nova.playerName(ply)))
    end,
    ["notify"] = function(ply)
        Nova.log("w", string.format("%s couldn't validate Lua execution.", Nova.playerName(ply)))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_sendlua_failed", Nova.playerName(ply)),
            ["ply"] = Nova.convertSteamID(ply)
        })
    end,
    ["kick"] = function(ply)
        Nova.kickPlayer(ply, Nova.getSetting("networking_sendlua_validationfailed_reason", "Validation Error"), "networking_validation")
    end,
    ["ban"] = function(ply)
        Nova.banPlayer(ply, Nova.getSetting("networking_sendlua_validationfailed_reason", "Validation Error"), "Couldn't validate Lua execution. This may indicate manipulation.", "networking_validation")
    end,
    ["allow"] = function(ply, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s couldn't validate sendlua, but no action was taken.", Nova.playerName(ply)))
    end,
    ["ask"] = function(ply, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s  couldn't validate Lua execution.", Nova.playerName(ply)))
        Nova.askAction({
            ["identifier"] = "networking_validation",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_sendlua_failed_action"),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = "Couldn't validate Lua execution. This may indicate manipulation.",
                    reason = Nova.getSetting("networking_sendlua_validationfailed_reason", "Validation Error"),
                    internal_reason = "networking_validation"
                })
                Nova.startAction("networking_validation", "nothing", steamID)
                return
            end
            Nova.startAction("networking_validation", answer, steamID, admin)
        end)
    end,
})

// a client MUST NEVER see the serverSecret
local clientSecret = Nova.generateString(7,13)
local fakeClientSecrets = {}
for i = 1, 40 do fakeClientSecrets[i] = Nova.generateString(7,13) end
local serverSecret = Nova.generateString(32)
local playerKeys = {}

local function GenerateKey(steamID)
    local fixedSize = 128
    local LOGIN = steamID
    local NONCE = Nova.generateString(20)
    local SIGNATURE = Nova.hmac_sha256(serverSecret, NONCE .. ":" .. LOGIN)
    local key = LOGIN .. "," .. NONCE .. "," .. SIGNATURE

    // append $ padding
    local padding = fixedSize - key:len()
    if padding > 0 then
        for i = 1, padding do
            key = key .. "$"
        end
    end

    return key
end

local function GenerateFakeKey(steamID)
    local fixedSize = 128
    local hash = util.SHA256(Nova.generateString(5))
    local key = steamID .. "," .. Nova.generateString(20) .. "," .. hash

    // append $ padding
    local padding = fixedSize - key:len()
    if padding > 0 then
        for i = 1, padding do
            key = key .. "$"
        end
    end

    return key
end

local function ValidateKey(steamID, key)
    // Step 1: remove $ padding
    key = key:gsub("%$", "")

    // Step 2: validate key format
    local LOGIN, NONCE, SIGNATURE = key:match("([^,]+),([^,]+),([^,]+)")
    if not LOGIN or not NONCE or not SIGNATURE then return false end

    // Step 3: validate key signature
    local EXPECTED_SIGNATURE = Nova.hmac_sha256(serverSecret, NONCE .. ":" .. LOGIN)
    if SIGNATURE != EXPECTED_SIGNATURE then return false end

    // Step 4: validate player
    if steamID != LOGIN then return false end
    return true
end

local function InitKey(steamID32)
    playerKeys[steamID32] = nil
    playerKeys[steamID32] = GenerateKey(steamID32)
    return playerKeys[steamID32]
end

local function NextKey(steamID32)
    local oldKey = playerKeys[steamID32]
    playerKeys[steamID32] = GenerateKey(steamID32)
    return oldKey, playerKeys[steamID32]
end

local function SendAuthPayload(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    // we test if everything works by requesting the client to us a response
    // if the client responds, he is authenticated
    local authenticationPayload = string.format([[
        timer.Simple(0, function()
            net.Start(%q)
                net.WriteString(%q)
            net.SendToServer()
        end)
    ]], Nova.netmessage("functions_sendlua"), util.SHA256( Nova.netmessage("functions_sendlua") ))
    Nova.sendLua(ply, authenticationPayload)
    Nova.log("d", string.format("Sent authentication payload to %s.", Nova.playerName(ply)))
end

local function PlaceRunString(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local steamID = ply:SteamID()
    local initKey = InitKey(steamID)

    // we intialize a key as a global variable which will change every lua execution
    local keys = {string.format("%s = [==[%s]==]", clientSecret, initKey)}
    for i = 1, math.random(5,12) do
        table.insert(keys, string.format("%s = [==[%s]==]", fakeClientSecrets[math.random(1,#fakeClientSecrets)], GenerateFakeKey(steamID)))
    end

    local keyPayload = string.format(Nova.obfuscator.randomOrder(keys), clientSecret, initKey)
    keyPayload = util.Compress(keyPayload)
    net.Start("nova_indentifier_that_sounds_very_technical_to_show_off_how_incredibly_smart_i_am")
        net.WriteData(keyPayload)
    net.Send(ply)

    timer.Simple(1, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        Nova.log("d", string.format("Sending runstring payload to %s.", Nova.playerName(ply)))

        local stager = string.format(
            [[
            net.Receive(%q, function(l)local c=util.Decompress(net.ReadData(l/8)) RunString(c)end)
            if express and express.Receive then
                express.Receive(%q, function(d)RunString(d[1])end)
            end
            ]],
            Nova.netmessage("functions_sendlua"),
            Nova.netmessage("functions_sendlua")
        )
        stager = util.Compress(stager)
        net.Start("nova_indentifier_that_sounds_very_technical_to_show_off_how_incredibly_smart_i_am")
            net.WriteData(stager)
        net.Send(ply)
    end)

    // from now on we can send arbitrary lua code to the client
    timer.Simple(4, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        Nova.log("d", string.format("Sending authentication payload to %s.", Nova.playerName(ply)))
        SendAuthPayload(ply)
    end)
end

//TODO: prevent uncontrolled cache growth
local cacheLookup = {}
local stringReplaceDummy = GenerateKey("STEAM_0:0:0")

// the lua code is sent to the client and executed
Nova.sendLua = function(ply_or_steamid, lua, _options)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(steamID)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local options = _options or {
        // enabled obfuscation (encoding & encryption & virtualisation) for the code
        // this option is computational expensive and should be used in combination with "cache"
        ["protected"] = false,
        // caches obfuscation to only perform once per payload
        ["cache"] = false,
        // specifically disable transmission via the express module
        ["disable_express"] = false,
        // only required if the express module is enabled
        // the reliability cannot be guaranteed, as the service (gmod.express) may time out
        // this option should be enabled when sending payloads that would result in a detection if not received by the client
        ["reliable"] = false,
        // this is set true if transmission via express times out
        // and we have to fall back to regular netmessages
        // we disable all security features and just resend the previous payload
        ["fallback"] = false,
    }

    // check if lua is valid
    if not lua or type(lua) != "string" then
        Nova.log("e", string.format("Nova.sendLua: Lua code is not a string, but a %s.", type(lua)))
        print(debug.traceback())
        return
    end

    // empty lua code will generate an error, so we replace it with 'return'
    if lua == "" then lua = "if true then end" end
    local codeChecksum = options.cache and util.SHA1(lua) or nil

    local oldKey, newKey = NextKey(steamID)

    if options.fallback then
        // we have to revert the key change
        playerKeys[steamID] = oldKey
        options.protected = false
        options.disable_express = true
    end

    if options.protected then
        local stageHead = options.cache and cacheLookup[codeChecksum] or nil
        if not stageHead then
            local netName = Nova.netmessage("functions_authenticate_global")
            local netKeys = {
                "local _ = [==[]==]",
                string.format("local _ = [==[]==]net.Start(%q) net.WriteString(%s) net.SendToServer() local _ = [==[]==]",
                    netName,
                    clientSecret),
            }
            for i = 1, math.random(2,4) do
                table.insert(netKeys,
                    string.format("local _ = [==[net.Start(%q) net.WriteString(%s) net.SendToServer()]==]",
                        netName,
                        clientSecret))
            end
            local keyKeys = { // lol
                "local _ = [==[]==]",
                string.format("%s = [==[%s]==]",
                    clientSecret,
                    options.cache and stringReplaceDummy or newKey),
            }
            for i = 1, math.random(1,3) do
                table.insert(keyKeys, string.format("%s = [==[%s]==]", fakeClientSecrets[math.random(1,#fakeClientSecrets)], GenerateFakeKey(steamID)))
            end
            stageHead = string.format([[
                %s
                %s
            ]], Nova.obfuscator.randomOrder(netKeys), Nova.obfuscator.randomOrder(keyKeys))
            // we cache the stage head, so we don't have to generate it every time
            if options.cache then cacheLookup[codeChecksum] = stageHead end
        end

        lua = Nova.profile(function()
            return Nova.obfuscator.obfuscate(
                string.format([[
            %s
            %s
        ]], stageHead, lua),
                options.cache and {[stringReplaceDummy] = newKey} or {})
        end)

        if not lua or type(lua) != "string" then
            Nova.log("e", "Nova.sendLua: Failed to obfuscate lua code")
            return
        end
    end

    // improve serverperformance by optionally sending large payloads via HTTP
    //TODO: only send via express if above certaint payload size
    local sendViaExpress = not options.disable_express and Nova.isPlayerExpressEnabled(steamID, Nova.netmessage("functions_sendlua"))
    if sendViaExpress then
        express.Send(Nova.netmessage("functions_sendlua"), {lua}, ply)
    else
        lua = util.Compress(lua)

        // check for maximum code length: https://wiki.facepunch.com/gmod/net.WriteString
        // we don't do fragmentation here, because we would have to temporarily store the lua code on the client and unnecessarily complexity
        if string.len(lua) > 65532 then
            // we have to revert the key change
            playerKeys[steamID] = oldKey

            Nova.log("e", string.format("Nova.sendLua: Lua code has exceeded maximum length of 65532 characters. Length: %d ", string.len(lua)))
            return
        end

        net.Start(Nova.netmessage("functions_sendlua"))
            net.WriteData(lua) // compressed lua code
        net.Send(ply)
    end

    if playerStatus[steamID] and options.protected and not options.fallback then
        // if we only have one unvalidated lua execution that is close to expire, we can extend the time
        if table.Count(playerStatus[steamID]) == 1 then
            playerStatus[steamID][next(playerStatus[steamID])[1]]["tries"] = Nova.getSetting("networking_sendlua_maxAuthTries", 20)
        end

        playerStatus[steamID]["runstring_authed"][newKey] = {
            // storing the code will not cause extra memory utilization
            // as lua (by design) only stores strings once
            // if caching is enabled, we do not store a duplicate string
            ["code"] = sendViaExpress and options.reliable and lua or nil,
            ["tries"] = Nova.getSetting("networking_sendlua_maxAuthTries", 20),
            ["express"] = sendViaExpress,
        }
    end
end

Nova.isPlayerAuthenticated = function(ply)
    if not ply then return false end
    local steamID = Nova.convertSteamID(ply)
    if not playerStatus[steamID] then return false end
    if not playerStatus[steamID]["authenticated"] then return false end
    return true
end

hook.Add("nova_base_initplayer", "networking_placelua", function(ply)
    Nova.log("d", string.format("Authenticating player %s", Nova.playerName(ply)))
    // increase amount of time for the client to authenticate for the first time
    // this takes longer because the client may not finish loading yet
    local maxTries = Nova.getSetting("networking_sendlua_maxAuthTries", 20) // TODO: timing check
    playerStatus[ply:SteamID()] = {
        ["authenticated"] = false,
        ["auth_triesLeft"] = maxTries,
        ["runstring_authed"] = {},
    }
    PlaceRunString(ply)
end)

hook.Add("nova_base_playerdisconnect", "networking_removeplayerauth", function(steamID)
    Nova.log("d", string.format("Removing networkstats from %s", Nova.playerName(steamID)))
    playerStatus[steamID] = nil
    playerKeys[steamID] = nil
end)

hook.Add("nova_init_loaded", "networking_sendlua", function()
    Nova.log("d", "Creating network netmessages")
    // precache networkstring as soon as possible
    Nova.netmessage("functions_sendlua")
    Nova.netmessage("functions_authenticate_global")
    // only cleartext netmessage in the whole addon
    util.AddNetworkString("nova_indentifier_that_sounds_very_technical_to_show_off_how_incredibly_smart_i_am")

    Nova.netReceive(Nova.netmessage("functions_sendlua"), function(len, ply)
        local steamID = ply:SteamID()
        // player is already authenticated or not fully initialized
        if not playerStatus[steamID] or playerStatus[steamID]["authenticated"] then return end

        local message = net.ReadString() or ""
        if len != 0 and message == util.SHA256( Nova.netmessage("functions_sendlua") ) then
            playerStatus[steamID]["authenticated"] = true
            Nova.log("s", string.format("Player %s authenticated.", Nova.playerName(ply)))
            hook.Run("nova_networking_playerauthenticated", ply)
            local packetLoss = ply:PacketLoss()
            local isTimingOut = ply:IsTimingOut()
            local ping = ply:Ping()
            Nova.log("d", string.format("Stats for %s: PacketLoss: %s, Is timing out: %s, Ping: %s", Nova.playerName(ply), packetLoss, isTimingOut, ping))
        else
            Nova.log("w", string.format("Player %s sent an invalid authentication message.", Nova.playerName(ply)))
        end
    end)

    // a client is obligated to send a confirmation for each protected lua payload he executes 
    Nova.netReceive(Nova.netmessage("functions_authenticate_global"), function(len, ply)
        local steamID = ply:SteamID()
        local clientKey = net.ReadString() or ""
        if clientKey == "" or not ValidateKey(steamID, clientKey) then
            Nova.log("d", string.format("Player %s sent an empty or invalid runstring authentication message.", Nova.playerName(ply)))
            local action = "validation_" .. Nova.getSetting("networking_sendlua_validationfailed_action", "ask")
            if not isfunction(actions[action]) then return end
            actions[action](ply, "networking_sendlua_validationfailed_action", actions)
            playerStatus[steamID]["runstring_authed"][clientKey] = nil
            return
        end
        playerStatus[steamID]["runstring_authed"][clientKey] = nil
        Nova.log("d", string.format("Player %s authenticated runstring.", Nova.playerName(ply)))
    end)
end)

timer.Create("nova_sendlua_authenticate", 5, 0, function()
    timer.Adjust("nova_sendlua_authenticate", math.random(40, 60) / 10)

    // if express is enabled, we fall back to regular netmessages if we get not response
    local fallbackThreshold = math.floor(Nova.getSetting("networking_sendlua_maxAuthTries", 20) * 0.125)

    for _, v in ipairs(player.GetHumans() or {}) do
        if not IsValid(v) or not v:IsPlayer() then continue end
        if v:IsTimingOut() then
            Nova.log("d", string.format("Player %s is timing out, delay authentication...", Nova.playerName(v)))
            continue
        end
        local steamID = v:SteamID()

        // check for first authentication when player is connected
        if playerStatus[steamID] and not playerStatus[steamID]["authenticated"] then
            // decrement tries left
            playerStatus[steamID]["auth_triesLeft"] = playerStatus[steamID]["auth_triesLeft"] - 1
            // take action if tries left are less than 0
            if playerStatus[steamID]["auth_triesLeft"] == 0 then
                Nova.startDetection("networking_authentication", v, "networking_sendlua_authfailed_action")
            end
            // send authentication message again
            SendAuthPayload(v)
        end

        // check everytime we send a lua code to the authenticated client
        if playerStatus[steamID] and Nova.isPlayerAuthenticated(steamID) and table.Count(playerStatus[steamID]["runstring_authed"] or {}) > 1 then
            for k, count in pairs(playerStatus[steamID]["runstring_authed"] or {}) do
                // decrement tries left (we ignore the latest entry, because it is the current runstring)
                playerStatus[steamID]["runstring_authed"][k]["tries"] = playerStatus[steamID]["runstring_authed"][k]["tries"] - 1
                // take action if tries left are less than 0
                if playerStatus[steamID]["runstring_authed"][k]["tries"] <= 0 then
                    Nova.startDetection("networking_validation", v, "networking_sendlua_validationfailed_action")
                    playerStatus[steamID]["runstring_authed"][k] = nil // to only act once
                    break
                end
                // fallback if express transmission did not worked yet
                if playerStatus[steamID]["runstring_authed"][k]["express"] and
                    playerStatus[steamID]["runstring_authed"][k]["code"] and
                    playerStatus[steamID]["runstring_authed"][k]["tries"] <= fallbackThreshold
                then
                    Nova.log("d", string.format("Fallback to netmessages for player %s: Resending payload...", Nova.playerName(steamID)))
                    Nova.sendLua(steamID, playerStatus[steamID]["runstring_authed"][k]["code"], {fallback = true})
                    playerStatus[steamID]["runstring_authed"][k]["code"] = nil
                    playerStatus[steamID]["runstring_authed"][k]["express"] = false
                end
            end
        end

        // by random chance, we send a dummy lua code to the client
        // this is because we have always one pending message to validate
        if not Nova.isPlayerAuthenticated(v) then continue end
        local tableLen = table.Count(playerStatus[steamID]["runstring_authed"] or {})

        if tableLen == 1 then
            local firstElem = nil
            for _, val in pairs(playerStatus[steamID]["runstring_authed"]) do
                firstElem = val
                break
            end
            if firstElem["code"] then
                Nova.sendLua(v, "", {protected = true, disable_express = true})
                Nova.log("d", string.format("Sent dummy lua code to %s", Nova.playerName(v)))
            end
        elseif tableLen <= 1 and math.random(1, 100) == 1 then
            Nova.sendLua(v, "", {protected = true, disable_express = true})
            Nova.log("d", string.format("Sent dummy lua code to %s", Nova.playerName(v)))
        end
    end
end)

concommand.Add("nova_sendlua", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(playerStatus)
end)