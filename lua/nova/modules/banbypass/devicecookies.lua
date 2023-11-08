/*
    This idea originated from OWASP (https://owasp.org/www-community/Slow_Down_Online_Guessing_Attacks_with_Device_Cookies)
    The basic idea behind this is to place the trust on already trusted clients. A trusted client get's a unique device cookie.
    Whith this cookie he authenticates himself to the server.
    In case of massive account creation (ban bypass), this can only allow trusted users (with a cookie) to join on the server. 
    Thus, each of the regular players is spared.
    Because we are not dealing with online bruteforce attacks and we can rely on the steamid to identify the players.

    The decision if a player is trusted or not is still made by the server.
    So you could say that it is in the end unnecessary, however it provides a good basis to build further features on.
*/

local cookieServerSecret = ""
local cookieName = ""
local playersWithCookies = {}

local function GenerateCookie(ply)
    local LOGIN = ply:SteamID()
    local NONCE = Nova.generateString(32)
    local SIGNATURE = Nova.hmac_sha256(cookieServerSecret, NONCE .. ":" .. LOGIN)
    // be sure NOT to return the server secret in the cookie!
    return LOGIN .. "," .. NONCE .. "," .. SIGNATURE
end

local function GivePlayerCookie(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local _cookie = GenerateCookie(ply)
    playersWithCookies[ply:SteamID()] = true
    Nova.sendLua(ply, [[
        cookie.Set("]] .. cookieName .. [[", "]] .. _cookie .. [[")
    ]])
    Nova.log("i", string.format("Giving %s a device cookie", Nova.playerName(ply)))
end

local function RemovePlayerCookie(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    playersWithCookies[ply:SteamID()] = nil
    Nova.sendLua(ply, [[
        cookie.Delete("]] .. cookieName .. [[", "")
    ]])
    Nova.log("i", string.format("Removing device cookie from %s: not trusted anymore", Nova.playerName(ply)))
end

local function ValidateCookie(ply, _cookie)
    // Step 0: check if string is not empty
    if not _cookie or _cookie == "" then return false end

    // Step 1: validate cookie format
    local LOGIN, NONCE, SIGNATURE = _cookie:match("([^,]+),([^,]+),([^,]+)")
    if not LOGIN or not NONCE or not SIGNATURE then return false end

    // Step 2: validate cookie signature
    local EXPECTED_SIGNATURE = Nova.hmac_sha256(cookieServerSecret, NONCE .. ":" .. LOGIN)
    if SIGNATURE != EXPECTED_SIGNATURE then return false end

    // Step 3: validate player
    if ply:SteamID() != LOGIN then return false end

    return true
end

Nova.playerHasCookie = function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return playersWithCookies[ply:SteamID()] or false
end

local function ShouldPlayerGetACookie(ply)
    // if player is staff or protected, he will allways be trusted
    if Nova.isStaff(ply) then return true end

    // check custom function from settins
    if isfunction(Nova.config["banbypass_is_user_trusted"])
        and Nova.config["banbypass_is_user_trusted"](ply) then
        return true
    end

    // by default, players are not trusted
    return false
end

hook.Add("nova_networking_playerauthenticated", "devicecookies_requestcookie", function(ply)
    Nova.sendLua(ply, [[
        local _cookie = cookie.GetString("]] .. cookieName .. [[", "")
        net.Start("]] .. Nova.netmessage("devicecookies_reqestcookie") .. [[")
        net.WriteString(_cookie)
        net.SendToServer()
    ]])
    Nova.log("d", string.format("Requesting cookie from %s", Nova.playerName(ply)))
end)

hook.Add("nova_init_loaded", "devicecookies_createnetmessage", function()
    Nova.log("d", "Creating devicecookies net message")
    // precache networkstring as soon as possible
    Nova.netmessage("devicecookies_reqestcookie")
end)

local function InitCookies()
    Nova.log("d", "Initializing device cookies")

    // initialize cookie server secret (if not set)
    cookieServerSecret = Nova.getSetting("devicecookie_serverSecret", false)
    if cookieServerSecret == false then
        cookieServerSecret = Nova.setSetting("devicecookie_serverSecret", Nova.generateString(32))
        Nova.log("d", string.format("Create unique device cookie secret for the first time: %q", cookieServerSecret))
    end

    // initialize cookie name (if not set)
    cookieName = Nova.getSetting("devicecookie_name", false)
    if cookieName == false then
        cookieName = Nova.setSetting("devicecookie_name", "nova_devicecookie_" .. Nova.getSetting("uid", nil))
        Nova.log("d", string.format("Create unique device cookie name for the first time: %q", cookieName))
    end

    // client sents us his stored cookie and we check if it is valid
    Nova.netReceive(Nova.netmessage("devicecookies_reqestcookie"), {auth = true}, function(len, ply)
        Nova.log("d", string.format("Received cookie response from %s", Nova.playerName(ply)))

        local _cookie = net.ReadString() or ""
        local shouldGetCookie = ShouldPlayerGetACookie(ply)
        local cookieIsValid = ValidateCookie(ply, _cookie)
        local hasLocalCookie = _cookie != ""

        // player has invalid cookie but should get one
        if not cookieIsValid and shouldGetCookie then
            GivePlayerCookie(ply)
            hook.Run("nova_banbypass_cookieloaded", ply)
            return
        end

        // cookie is empty and player should not get one
        if not hasLocalCookie and not shouldGetCookie then
            Nova.log("d", string.format("Device cookie from %s is empty", Nova.playerName(ply)))
            hook.Run("nova_banbypass_cookieloaded", ply)
            return
        end

        // cookie is invalid and player should not get one
        if not cookieIsValid and not shouldGetCookie then
            Nova.log("i", string.format("Device cookie from %s is invalid", Nova.playerName(ply)))
            hook.Run("nova_banbypass_cookieloaded", ply)
            return
        end

        // cookie is valid but player shouldn't have one
        if cookieIsValid and not shouldGetCookie then
            Nova.log("d", string.format("Device cookie from %s is valid but player shouldn't have one. Removing...", Nova.playerName(ply)))
            RemovePlayerCookie(ply)
            hook.Run("nova_banbypass_cookieloaded", ply)
            return
        end

        // cookie is valid and player should have one
        if cookieIsValid and shouldGetCookie then
            playersWithCookies[ply:SteamID()] = true
            Nova.log("i", string.format("%s has a valid device cookie", Nova.playerName(ply)))
            hook.Run("nova_banbypass_cookieloaded", ply)
            return
        end

        hook.Run("nova_banbypass_cookieloaded", ply)
    end)
end

if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "devicecookies_initialize", InitCookies)
else
    InitCookies()
end

concommand.Add("nova_cookie", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(playersWithCookies)
end)