Nova.overrides = Nova.overrides or {}


/*
	Analyze all netmessages received by clients
    This is done by overriding the net.Receive function
    See: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/net.lua
*/

if not Nova.overrides["net.Incoming"] then
    Nova.overrides["net.Incoming"] = net.Incoming

    function net.Incoming(len, client, ...)
        local header = net.ReadHeader()
        local messageName = util.NetworkIDToString(header)
        if not messageName then return end

        local res = hook.Run("nova_networking_incoming", client, client:SteamID(), messageName, len)
        if res == false then return end

        // remove header from length
        len = len - 16

        // since net.Receivers only uses lowercase strings as keys
        // we transform the name to lowercase to avoid a bypass by string mismatches
        messageName = messageName:lower()

        local func = net.Receivers[messageName]
        if not func then return end

        // calculate the time it took to process the message
        local startTime = SysTime()
        local succ, err = pcall(func, len, client, ...)
        if not succ and err then
            if type(err) == "vararg" then
                ErrorNoHaltWithStack(err)
            else
                print(err)
            end
        end
        local endTime = SysTime()
        hook.Run("nova_networking_incoming_post", client, messageName, endTime - startTime)
    end
end

/*
	All netmessage-names are randomly generated
    This fixes the most trivial bypass for sadly most of all existing anti-cheat-systems
    A client could easily type in his console "net_blockmsg 'hey_i_am_cheating_please_ban_me'"
    By randomizing the netmessage-name, the client can't easily find out which netmessage is blocked
    A skilled person can still find out which netmessage corresponds to the netmessage-name

    We pass the 'restricted' parameter to the Nova.netmessage function.
    This is done for messages only a protected player should send. 
    A client can only send these messages if he injected his own code into his game. 
*/

// create our little netmessage pool with a mapping
local netMessages = {}
local translationTable = {}

// create a new netmessage or return an existing one
Nova.netmessage = function(name, restricted)
    // this is only for testing. netmessages are not randomized anymore
    local _debug = false

    // if message has already been created, return it
    if netMessages[name] then return netMessages[name].randomized end

    // if debug is enabled we don't want to randomize the name
    local randomizedMessage = _debug and name or Nova.generateString(16, 32)

    // check if you won in lottery and this message is already in use
    if not _debug and util.NetworkStringToID(randomizedMessage) != 0 then
        randomizedMessage = Nova.generateString(16, 32)
    end

    netMessages[name] = {
        ["randomized"] = randomizedMessage,
        ["name"] = name,
        ["restricted"] = type(restricted) == "string" and string.lower(restricted) or false,
    }

    // this is used to later translate the randomized message back to the original name faster
    translationTable[netMessages[name].randomized] = name

    util.AddNetworkString(netMessages[name].randomized)

    Nova.log("d", string.format("Created netmessage %q (%q) Restricted to: %s", netMessages[name].name, netMessages[name].randomized, type(netMessages[name].restricted) == "string" and netMessages[name].restricted or "nobody"))

    return netMessages[name].randomized
end

// function that returns the original name of a netmessage
Nova.getNetmessage = function(name)
    return translationTable[name] or name
end

// we need this in the netcollector to prevent dropping a netmessage by Nova Defender
Nova.isInternalNetmessage = function(name)
    return (translationTable[name] or netMessages[name]) and true or false
end

local rateLimit = {}
local hooks = {
    [1] = function(len, ply, messageName, options)
        local checkInterval = options and options.interval or nil
        local messageLimit = options and options.limit or nil

        // no ratelimit defined
        if not checkInterval or not messageLimit then
            return true
        end

        local steamID = ply:SteamID()
        local curTime = CurTime()

        if not rateLimit[steamID] then rateLimit[steamID] = {} end
        if not rateLimit[steamID][messageName] then
            rateLimit[steamID][messageName] = {
                last_execution = curTime,
                total_executions = 0
            }
        elseif curTime - rateLimit[steamID][messageName].last_execution > checkInterval then
            rateLimit[steamID][messageName].last_execution = curTime
            rateLimit[steamID][messageName].total_executions = 0
        end

        local total = rateLimit[steamID][messageName].total_executions
        rateLimit[steamID][messageName].total_executions = total + 1

        // only notify once if client exceed limit to prevent log spam
        if total == (messageLimit + 1) then
            local originalName = Nova.getNetmessage(messageName)
            Nova.log("w", string.format("Player %s sent netmessage %q %d times within %d second(s). Limit is %d.", steamID, originalName, total, checkInterval, messageLimit))
            return false
        elseif total > messageLimit then
            return false
        end

        return true
    end,
    [2] = function(len, ply, messageName, options)
        local authOnly = options and options.auth or nil
        if authOnly and not Nova.isPlayerAuthenticated(ply) then
            local originalName = Nova.getNetmessage(messageName)
            Nova.log("i", string.format("Received netmessage %q from unauthenticated player %s", originalName, Nova.playerName(ply)))
            return false
        end

        return true
    end
}

// own net receive to reduce code
Nova.netReceive = function(messageName, options, callback, onError)
    if not messageName then return end

    // in case option field is left empty
    if isfunction(options) and not callback then
        callback = options
        options = nil
    end

    if not isfunction(callback) then return end

    net.Receive(messageName, function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        for _, func in ipairs(hooks or {}) do
            local res = func(len, ply, messageName, options)
            if res == false then
                if isfunction(onError) then onError(len, ply) end
                return
            end
        end

        callback(len, ply)
    end)
end

Nova.registerAction("networking_restricted_message", "networking_restricted_message_action", {
    ["add"] = function(ply, restriction, messagename)
        Nova.addDetection(ply, "networking_restricted_message", Nova.lang("notify_networking_restricted", Nova.playerName(ply), messagename, restriction))
    end,
    ["nothing"] = function(ply, restriction, messagename)
        Nova.log("i", string.format("%s tried to send netmessage %q restricted to %q. This indicates manipulation, but no action was taken.", Nova.playerName(ply), messagename, restriction))
    end,
    ["notify"] = function(ply, restriction, messagename)
        Nova.log("w", string.format("%s tried to send netmessage %q restricted to %q. This indicates manipulation.", Nova.playerName(ply), messagename, restriction))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_restricted", Nova.playerName(ply), messagename, restriction),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["kick"] = function(ply, restriction)
        Nova.kickPlayer(ply, Nova.getSetting("networking_restricted_message_reason", "Exploit Attempt"), "networking_restricted_message")
    end,
    ["ban"] = function(ply, restriction, messagename)
        Nova.banPlayer(ply, Nova.getSetting("networking_restricted_message_reason", "Exploit Attempt"), string.format("Sent netmessage %q that only %q are allowed to. This indicates manipulation.", messagename, restriction), "networking_restricted_message")
    end,
    ["allow"] = function(ply, restriction, messagename, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s tried to send netmessage %q restricted to %q. This indicates manipulation, but no action was taken.", Nova.playerName(ply), messagename, restriction))
    end,
    ["ask"] = function(ply, restriction, messagename, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s tried to send netmessage %q restricted to %q. This indicates manipulation.", Nova.playerName(ply), messagename, restriction))
        Nova.askAction({
            ["identifier"] = "networking_restricted_message",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_restricted_action", messagename, restriction),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format("Sent netmessage %q that only %q are allowed to. This indicates manipulation.", messagename, restriction),
                    reason = Nova.getSetting("networking_restricted_message_reason", "Exploit Attempt"),
                    internal_reason = "networking_restricted_message"
                })
                Nova.startAction("networking_restricted_message", "nothing", steamID, restriction, messagename)
                return
            end
            Nova.startAction("networking_restricted_message", answer, steamID, restriction, messagename, admin)
        end)
    end,
})

hook.Add("nova_networking_incoming", "networking_permission", function(client, steamID, strName, len)
    local messageName = Nova.getNetmessage(strName)
    // if the message is not in our pool, we don't care
    if not netMessages[messageName] then return end
    // if the message is not restricted, we don't care
    if not netMessages[messageName].restricted or netMessages[messageName].restricted == "" then return end

    // if the player is permitted to send the message, we don't care
    if netMessages[messageName].restricted == "staff" and Nova.isStaff(client) then return end
    if netMessages[messageName].restricted == "protected" and Nova.isProtected(client) then return end

    // in the process of removing a protected player, he can by accident still send a restricted message
    // therefore we drop the message if he is in quarantine and not protected
    if Nova.isQuarantined(client) then
        return false
    end

    Nova.log("d", string.format("Player %s sent restricted netmessage: %q. This message is intended for administrators only and cannot be sent by a normal player without manipulation.", Nova.playerName(client), messageName))

    // take action against the player
    Nova.startDetection("networking_restricted_message", client, netMessages[messageName].restricted, messageName, "networking_restricted_message_action")

    // block message
    return false
end)

hook.Add("nova_base_playerdisconnect", "networking_netmessages", function(steamID)
    rateLimit[steamID] = nil
end)