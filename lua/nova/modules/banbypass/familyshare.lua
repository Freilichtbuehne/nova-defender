/*
    An account is considered 'family shared' if the owner of the game mismatches the player.
    All shared accounts are allowed to play on the server.
    If the owner is banned (by Nova), all shared accounts will get banned as well if they connect to the server.
*/

Nova.isFamilyShared = function(ply)
    if type(ply) != "Player" or not IsValid(ply) then return false end

    // nowadays we don't need to make an api call to get the owner of the game anymore
    // we can just use the (recently) added OwnerSteamID function
    local ownerSteamID64 = ply:OwnerSteamID64()

    // returns "0" in singleplayer (undocumented)
    if not ownerSteamID64 or ownerSteamID64 == "0" then
        return false
    end

    return ply:SteamID64() != ownerSteamID64
end

Nova.getFamilyOwner = function(ply)
    if type(ply) != "Player" or not IsValid(ply) then return false end

    //local steamID = ply:SteamID()
    local owner = ply:OwnerSteamID64()

    if not owner or owner == "0" then return false end

    local ownerSteamID = Nova.convertSteamID(owner)

    if not ownerSteamID then return false end

    return ownerSteamID
end

Nova.isOwnerBanned = function(ply)
    if not IsValid(ply) then return false end

    local owner = ply:OwnerSteamID64()
    if not owner then return false end

    // convert steamid64 to steamid
    owner = Nova.convertSteamID(owner)
    if Nova.isPlayerBanned(owner) then return owner end

    return false
end

Nova.registerAction("banbypass_familyshare", "banbypass_bypass_familyshare_action", {
    ["add"] = function(ply, banned)
        Nova.addDetection(ply, "banbypass_familyshare", Nova.lang("notify_banbypass_familyshare", Nova.playerName(banned)))
    end,
    ["nothing"] = function(ply, banned)
        Nova.log("i", string.format("%s might bypass a ban: Familyshared account of banned SteamID %s. But no action was taken.", Nova.playerName(ply), Nova.playerName(banned)))
    end,
    ["notify"] = function(ply, banned)
        Nova.log("w", string.format("%s might bypass a ban: Familyshared account of banned SteamID %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "banbypass",
            ["message"] = Nova.lang("notify_banbypass_familyshare", Nova.playerName(banned)),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["ban"] = function(ply, banned)
        Nova.log("i", string.format("Banning %s: Familyshared account of banned SteamID %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.banPlayer(
            ply,
            Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
            string.format(
                "Shared account of banned player %s",
                Nova.playerName(banned)
            ),
            "banbypass_familyshare"
        )
    end,
    ["allow"] = function(ply, banned, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s might bypass a ban: Familyshared account of banned SteamID %s", Nova.playerName(ply), Nova.playerName(banned)))
    end,
    ["ask"] = function(ply, banned, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s might bypass a ban: Familyshared account of banned SteamID %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.askAction({
            ["identifier"] = "banbypass_familyshare",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_banbypass_familyshare_action", Nova.playerName(banned)),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format(
                        "Shared account of banned player %s",
                        Nova.playerName(banned)
                    ),
                    reason = Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
                    internal_reason = "banbypass_familyshare"
                })
                Nova.startAction("banbypass_familyshare", "nothing", steamID, banned)
                return
            end
            Nova.startAction("banbypass_familyshare", answer, steamID, banned, admin)
        end)
    end,
})

hook.Add("nova_banbypass_check", "banbypass_familyshare", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    Nova.log("d", string.format("Checking if %s is family shared", Nova.playerName(ply)))

    local bannedOwner = Nova.isOwnerBanned(ply)
    if not bannedOwner then return end

    Nova.startDetection("banbypass_familyshare", ply, bannedOwner, "banbypass_bypass_familyshare_action")
end)