Nova.expressEnabled = Nova.expressEnabled or false

local playersEnabled = {}

Nova.isPlayerExpressEnabled = function(ply_or_steamid, net_name)
    if not ply_or_steamid then return end
    if not Nova.expressEnabled then return false end

    local steamID = Nova.convertSteamID(ply_or_steamid)
    // check if any message exist
    if not playersEnabled[steamID] then return false end

    if net_name then
        return playersEnabled[steamID][net_name]
    end

    return true
end

// We will receive a callback if a client successfully runs "express.Receive"
// We have to confirm, that the network of the client does not block HTTPS communication to the specified server
hook.Add( "ExpressPlayerReceiver", "nova_base_express", function( ply, net_name )
    if not Nova.isInternalNetmessage(net_name) then return end

    local steamID = Nova.convertSteamID(ply)
    if not playersEnabled[steamID] then
        playersEnabled[steamID] = {}
    end

    if not playersEnabled[steamID][net_name] then
        playersEnabled[steamID][net_name] = true
        Nova.log("d", string.format("Received gm_express confirmation for message %q by player %s", Nova.getNetmessage(net_name), Nova.playerName(steamID)))
    end
end )

local expressInitialized = false

local function LoadConfig()
    local enabled = Nova.getSetting("networking_sendlua_gm_express", false)

    Nova.expressEnabled = expressInitialized and enabled

    if Nova.expressEnabled then
        Nova.log("s", "gm_express loaded and enabled")
    end
end

hook.Add( "ExpressLoaded", "nova_networking_express", function()
    if not express or not isfunction(express.Send) then
        Nova.log("e", "Couldn't enable gm_express: Loaded but missing function 'express.Send'.")
        return
    end
    expressInitialized = true
    LoadConfig()
end )

hook.Add("nova_config_setting_changed", "networking_gm_express", function(key, value, oldValue)
    if key != "networking_sendlua_gm_express" then return end

    // Only enable 
    if value == true and not expressInitialized then
        Nova.log("e", "Couldn't enable gm_express: not installed on the server.")
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_issue_gm_express_not_installed"),
        }, "protected")
    end

    Nova.expressEnabled = expressInitialized and value
end)

if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "networking_gm_express", LoadConfig)
end

// Remove quarantine info when player disconnects
hook.Add("nova_base_playerdisconnect", "networking_gm_express", function(steamID)
    Nova.log("d", string.format("Removing gm_express info from %s", Nova.playerName(steamID)))
    playersEnabled[steamID] = nil
end)

concommand.Add("nova_gm_express", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(playersEnabled)
end)