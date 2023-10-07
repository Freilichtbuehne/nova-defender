hook.Add( "nova_banbypass_cookieloaded", "server_lockdown_checkplayer", function(ply)
    if not Nova.getSetting("server_lockdown_enabled", false) then return end
    Nova.log("d", string.format("Checking lockdown access for %s", Nova.playerName(ply)))

    // Player has been assigned a cookie, check if they are allowed to join.
    // isTrusted includes staff and protected players.
    if Nova.isTrusted(ply) then return end

    // Player is not trusted, kick them.
    Nova.log("i", string.format("%s was kicked from server: Lockdown mode is enabled", Nova.playerName(ply)))
    Nova.kickPlayer(ply, Nova.getSetting("server_lockdown_reason", "You are not allowed to play at the moment"), "admin_manual")
end)