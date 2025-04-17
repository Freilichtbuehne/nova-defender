local quarantinedPlayers = {}

Nova.setQuarantine = function(ply_or_steamid, bool)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    quarantinedPlayers[steamID] = bool == true and true or nil
    Nova.log("i", string.format("Set quarantine for %s to %s", Nova.playerName(steamID), bool == true and "true" or "false"))
end

Nova.isQuarantined = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    return quarantinedPlayers[steamID] == true
end

// We quarantine players when they are banned
hook.Add("nova_banbypass_onplayerban", "networking_quarantine", function(ply_or_steamid, ban)
    // convert steamid into right format
    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not steamID or steamID == "" then return end

    // check if player is online
    local ply = Nova.fPlayerBySteamID(steamID)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    Nova.log("d", string.format("Quarantining %s because he is getting banned", Nova.playerName(steamID)))

    // quarantine the player
    Nova.setQuarantine(ply, true)
end)

// Remove quarantine info when player disconnects
hook.Add("nova_base_playerdisconnect", "networking_quarantine", function(steamID)
    Nova.log("d", string.format("Removing quarantine info from %s", Nova.playerName(steamID)))
    quarantinedPlayers[steamID] = nil
end)


// Effects during quarantine
hook.Add("nova_networking_incoming", "networking_quarantine", function(client, steamID, strName, len)
    // we don't want to intercept messages from Nova Defender
    if Nova.isInternalNetmessage(strName) then return end

    // block all messages from quarantined players
    // we don't use Nova.isQuarantined here because it's faster to check the table directly
    if quarantinedPlayers[steamID] then
        return false
    end
end)

hook.Add("nova_base_startcommand", "networking_quarantine", function(ply, cmd, steamID)
    if quarantinedPlayers[steamID or ""] then
        // block all commands from quarantined players
        // just allow him to walk, so that he doesn't disconnect immediately
        cmd:ClearButtons()
        //cmd:ClearMovement()
    end
end)

hook.Add("nova_networking_concommand_run", "networking_quarantine", function(ply, command, arguments, argstring)
    if IsValid(ply) and ply:IsPlayer() and quarantinedPlayers[ply:SteamID()] then
        return false, "Quarantined players can't run commands"
    end
end)