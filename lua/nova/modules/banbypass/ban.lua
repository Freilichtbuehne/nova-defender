local databaseCache = {}
local databaseLookupCache = {}
local banInProgress = {}

local conVarSize = 2^32
local conVarOffset = 2^16
local function GetConvarFromSecret(secret)
    if not secret then return false end

    local crc = tonumber(util.CRC( secret ))
    if not crc then return false end

    // this should not be any shitty obfuscation, just a (half) reliable way to get a deterministic number
    // modulo 2^32 too get a number between 0 and 4294967296 (util.CRC returns a 32 bit number anyway)
    // + conVarOffset to avoid small numbers that a client could choose by accident
    return tostring((crc % conVarSize) + conVarOffset)
end

local function IsBanInProgress(ply_or_steamid)
    local steamid = Nova.convertSteamID(ply_or_steamid)

    // check if no ban is in progress
    return banInProgress[steamid] != nil
end

local function AddBanToDatabase(ban)
    Nova.log("d", string.format("Adding ban to database for steamid: %q", tostring(ban.steamid)))

    // convert steamID32 to steamID64
    local steamid64 = util.SteamIDTo64(ban.steamid)
    databaseLookupCache[tostring(steamid64)] = true

    // check if a ban for this player already exists
    if databaseCache[ban.steamid] then
        local isBanned =  databaseCache[ban.steamid].is_banned == 1
        local isBanOnSight = databaseCache[ban.steamid].ban_on_sight == 1
        local isUnBanOnSight = databaseCache[ban.steamid].unban_on_sight == 1
        local alreadyOnlineBanned = databaseCache[ban.steamid].secret_key != ""

        // player is already banned (let him connect an ban him again)
        if isBanned and not isBanOnSight then
            Nova.log("d", string.format("Player %s is already banned: Set him to ban on sight again", Nova.playerName(ban.steamid)))
            // if player is unban on sight, set it back to ban on sight
            Nova.query("UPDATE nova_bans SET is_banned = 0, unban_on_sight = 0, ban_on_sight = 1 WHERE steamid = " .. Nova.sqlEscape(ban.steamid) .. ";")
            databaseCache[ban.steamid].is_banned = 0
            databaseCache[ban.steamid].unban_on_sight = 0
            databaseCache[ban.steamid].ban_on_sight = 1
            return
        // player is not banned and ban on sight (player came online)
        elseif not isBanned and isBanOnSight then
            Nova.log("d", string.format("Player %s is ban on sight: Set him to banned", Nova.playerName(ban.steamid)))
            // if player is unban on sight, set it back to ban on sight
            Nova.query("UPDATE nova_bans SET is_banned = 1, unban_on_sight = 0, ban_on_sight = 0 WHERE steamid = " .. Nova.sqlEscape(ban.steamid) .. ";")
            Nova.query("UPDATE nova_bans SET fingerprint = " .. Nova.sqlEscape(ban.fingerprint) .. ", ip = '" .. ban.ip .. "', secret_key = '" .. ban.secret_key .. "' WHERE steamid = " .. Nova.sqlEscape(ban.steamid) .. ";")

            databaseCache[ban.steamid].is_banned = 1
            databaseCache[ban.steamid].unban_on_sight = 0
            databaseCache[ban.steamid].ban_on_sight = 0
            databaseCache[ban.steamid].fingerprint = ban.fingerprint
            databaseCache[ban.steamid].ip = ban.ip
            databaseCache[ban.steamid].secret_key = ban.secret_key
            return
        // player is unban on sight an was already online banned (revert unban and set to banned)
        elseif not isBanned and isUnBanOnSight and alreadyOnlineBanned then
            Nova.log("d", string.format("Player %s is unban on sight: Set him to banned again", Nova.playerName(ban.steamid)))
            // if player is unban on sight, set it back to ban on sight
            Nova.query("UPDATE nova_bans SET is_banned = 1, unban_on_sight = 0, ban_on_sight = 0 WHERE steamid = " .. Nova.sqlEscape(ban.steamid) .. ";")

            databaseCache[ban.steamid].is_banned = 1
            databaseCache[ban.steamid].unban_on_sight = 0
            databaseCache[ban.steamid].ban_on_sight = 0
            return
        // player is unban on sight an was not online banned (revert unban and set to ban on sight)
        elseif not isBanned and isUnBanOnSight and not alreadyOnlineBanned then
            Nova.log("d", string.format("Player %s is unban on sight: Set him to ban on sight again as we still wait for a online ban", Nova.playerName(ban.steamid)))
            // if player is unban on sight, set it back to ban on sight
            Nova.query("UPDATE nova_bans SET is_banned = 0, unban_on_sight = 0, ban_on_sight = 1 WHERE steamid = " .. Nova.sqlEscape(ban.steamid) .. ";")

            databaseCache[ban.steamid].is_banned = 0
            databaseCache[ban.steamid].unban_on_sight = 0
            databaseCache[ban.steamid].ban_on_sight = 1
            return
        end
    end

    databaseCache[ban.steamid] = ban

    Nova.query("INSERT INTO nova_bans VALUES (" ..
        Nova.sqlEscape(ban.steamid) .. ", " ..
        "'" .. ban.ip .. "', " ..
        Nova.sqlEscape(ban.comment) .. ", " ..
        Nova.sqlEscape(ban.reason) .. ", " ..
        Nova.sqlEscape(ban.internal_reason) .. ", " ..
        "'" .. ban.time .. "', " ..
        "'" .. ban.ban_on_sight .. "', " ..
        "'" .. ban.unban_on_sight .. "', " ..
        "'" .. ban.secret_key .. "', " ..
        "'" .. ban.is_banned .. "', " ..
        Nova.sqlEscape(ban.fingerprint) ..
    ");")
end

// only remove a ban if the player is on the server
local function RemoveBanFromDatabase(ply)
    Nova.log("d", string.format("Removing ban from database for %s", Nova.playerName(ply)))
    local steamid = ply:SteamID()
    databaseCache[steamid] = nil
    Nova.query("DELETE FROM nova_bans WHERE steamid = '" .. steamid .. "';")
    // convert steamID32 to steamID64
    local steamid64 = util.SteamIDTo64(steamid)
    databaseLookupCache[tostring(steamid64)] = nil
end

// ban with extra banbypass protection
// if the ban is automated we generally don't want to make the exact reason public to the player, so we store it as an internal reason
// therefor the field 'reason' can just be set to nil
Nova.banPlayer = function(ply_or_steamid, reason, comment, internalReason, force)
    if not ply_or_steamid then return false end
    internalReason = internalReason or "no_reason"
    local humanIdentifier = Nova.lang("config_detection_" .. internalReason or "")
    local isManualBan = internalReason == "admin_manual"

    // if no reason is give, use default reason
    if not reason then reason = Nova.getSetting("banbypass_ban_default_reason", "Server Security") end

    // we don't add a reason suffix here yet

    // check if the ban is already in progress
    if IsBanInProgress(ply_or_steamid) then
        Nova.log("w", string.format("Cannot secure ban %s for %q: ban in progress", Nova.playerName(ply_or_steamid), internalReason))
        return false
    end

    // exclude protected players from the ban
    if Nova.isProtected(ply_or_steamid) then
        Nova.log("w", string.format("Cannot secure ban %s for %q: protected", Nova.playerName(ply_or_steamid), humanIdentifier))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "ban",
            ["message"] = Nova.lang("notify_banbypass_ban_fail", Nova.playerName(ply_or_steamid), humanIdentifier, "protected"),
            ["ply"] = Nova.convertSteamID(ply_or_steamid)
        }, "protected")
        return false
    end

    // exclude staff from the ban (if enabled in settings and ban is not manual)
    if Nova.isStaff(ply_or_steamid)
        and not Nova.getSetting("banbypass_ban_banstaff", false)
        and not isManualBan
    then
        Nova.log("w", string.format("Cannot secure ban %s for %q: staff", Nova.playerName(ply_or_steamid), humanIdentifier))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "ban",
            ["message"] = Nova.lang("notify_banbypass_ban_fail", Nova.playerName(ply_or_steamid), humanIdentifier, "staff"),
            ["ply"] = Nova.convertSteamID(ply_or_steamid)
        }, "protected")
        return false
    end

    local function OnlineBan(ply)
        Nova.log("i", string.format("Starting secure online ban for %s", Nova.playerName(ply)))
        // set ban in progress to prevent other secure bans from being started at the same time
        local steamID = ply:SteamID()
        banInProgress[steamID] = true

        // we need to first generate his secret key
        local secret = Nova.generateString(15, 30)
        local secret_convar = GetConvarFromSecret(secret)
        Nova.sendLua(ply, Nova.getBanClientPayload(secret, secret_convar), {protected = true, disable_express = true})

        local ban = {
            steamid = steamID,
            ip = Nova.extractIP(ply:IPAddress()) or "",
            comment = comment or "",
            reason = reason or "",
            internal_reason = internalReason or "no_reason",
            time = os.time(),
            ban_on_sight = 0,
            unban_on_sight = 0,
            secret_key = secret,
            _temp_secret_convar = secret_convar,
            is_banned = 1,
            fingerprint = Nova.getFingerprint(ply_or_steamid)
                            and util.TableToJSON(Nova.getFingerprint(ply_or_steamid))
                            or "",
        }
        AddBanToDatabase(ban)

        // convert fingerprint back to table
        if ban.fingerprint != "" then ban.fingerprint = util.JSONToTable(ban.fingerprint) end

        // player needs some time to receive lua code
        // if the player disconnects before the delay is received, the ban is already fully in place
        timer.Simple(10, function()
            // we check if player should get banned by a custom banning system
            if IsValid(ply) and ply:IsPlayer() then
                // append suffix to reason 
                local reasonSuffix = Nova.getSetting("server_general_suffix", "")
                local kickReason = string.format("%s %s", ban.reason, reasonSuffix)
                ply:Kick(kickReason)
            end
            banInProgress[steamID] = nil
        end)

        hook.Run("nova_banbypass_onplayerban", steamID, ban, true)
    end

    local function OfflineBan(steamid32)
        Nova.log("i", string.format("Starting secure offline ban for %s", Nova.playerName(steamid32)))

        local ban = {
            steamid = steamid32,
            ip = "",
            comment = comment or "",
            reason = reason or "",
            internal_reason = internalReason or "",
            time = os.time(),
            ban_on_sight = 1,
            unban_on_sight = 0,
            // we generate secrets if he joins the server the next time
            secret_key = "",
            _temp_secret_convar = "",
            is_banned = 0,
            fingerprint = Nova.getFingerprint(ply_or_steamid)
                            and util.TableToJSON(Nova.getFingerprint(ply_or_steamid))
                            or "",
        }
        AddBanToDatabase(ban)
        hook.Run("nova_banbypass_onplayerban", steamid32, ban, false)
    end

    // check online ban
    if type(ply_or_steamid) == "Player" then
        if not ply_or_steamid:IsPlayer() then return false end
        OnlineBan(ply_or_steamid)
    // check offline ban
    elseif type(ply_or_steamid) == "string" then
        local steamID32 = Nova.convertSteamID(ply_or_steamid)
        local ply = Nova.fPlayerBySteamID(steamID32)
        // doublecheck if the player is online
        if IsValid(ply) then OnlineBan(ply) else OfflineBan(steamID32) end
    end
end

Nova.unbanPlayer = function(ply_or_steamid)
    if not ply_or_steamid then return end

    local function OnlineUnban(ply)
        Nova.sendLua(ply, Nova.getUnbanClientPayload(), {protected = true, disable_express = true})
        RemoveBanFromDatabase(ply)
        Nova.clearDetections(ply)
        Nova.log("s", string.format("Finished secure online unban for %s", Nova.playerName(ply)))
    end

    local function OfflineUnban(steamID32)
        Nova.query("UPDATE nova_bans SET is_banned = 0, unban_on_sight = 1, ban_on_sight = 0 WHERE steamid = '" .. steamID32 .. "';")
        databaseCache[steamID32].is_banned = 0
        databaseCache[steamID32].unban_on_sight = 1
        databaseCache[steamID32].ban_on_sight = 0
        Nova.log("s", string.format("Finished secure offline unban for %s", Nova.playerName(steamID32)))
    end

    // check online unban
    if type(ply_or_steamid) == "Player" then
        if not ply_or_steamid:IsPlayer() then return end
        OnlineUnban(ply_or_steamid)
    // check offline unban
    elseif type(ply_or_steamid) == "string" then
        local steamID32 = Nova.convertSteamID(ply_or_steamid)
        local ply = Nova.fPlayerBySteamID(steamID32)
        // doublecheck if the player is online
        if IsValid(ply) then OnlineUnban(ply) else OfflineUnban(steamID32) end
    end
end

Nova.kickPlayer = function(ply, reason, internalReason)
    if not reason or reason == "" then reason = Nova.getSetting("banbypass_ban_default_reason", "Server Security") end
    local humanIdentifier = Nova.lang("config_detection_" .. internalReason or "")
    local isManualKick = internalReason == "admin_manual"

    if type(ply) == "string" then
        ply = Nova.convertSteamID(ply)
        ply = Nova.fPlayerBySteamID(ply)
    end

    if not IsValid(ply) or not ply:IsPlayer() then
        Nova.log("e", string.format("Cannot kick %s for %q: not online", Nova.playerName(ply), humanIdentifier))
        return
    end

    local reasonSuffix = Nova.getSetting("server_general_suffix", "")
    reason = string.format("%s %s", reason, reasonSuffix)

    if IsBanInProgress(ply) then
        Nova.log("w", string.format("Cannot kick %s for %q: ban in progress", Nova.playerName(ply), humanIdentifier))
        return
    end

    // Exclude protected players from the kick
    if Nova.isProtected(ply) then
        Nova.log("w", string.format("Cannot kick %s for %q: protected", Nova.playerName(ply), humanIdentifier))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "ban",
            ["message"] = Nova.lang("notify_banbypass_kick_fail", Nova.playerName(ply), humanIdentifier, "protected"),
            ["ply"] = ply:SteamID(),
        }, "protected")
        return
    end

    // Exclude staff from the kick (if enabled in settings)
    if Nova.isStaff(ply)
        and not Nova.getSetting("banbypass_ban_banstaff", false)
        and not isManualKick then
        Nova.log("w", string.format("Cannot kick %s for %q: staff", Nova.playerName(ply), humanIdentifier))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "ban",
            ["message"] = Nova.lang("notify_banbypass_kick_fail", Nova.playerName(ply), humanIdentifier, "staff"),
            ["ply"] = ply:SteamID(),
        }, "staff")
        return
    end

    ply:Kick(reason)
end

Nova.isPlayerBanned = function(ply_or_steamid)
    if not ply_or_steamid then return end

    local steamID32 = Nova.convertSteamID(ply_or_steamid)
    if databaseCache[steamID32] and (databaseCache[steamID32].is_banned == 1 or databaseCache[steamID32].ban_on_sight == 1) then
        return true
    end

    return false
end

Nova.getAllBans = function()
    return table.Copy(databaseCache)
end

Nova.getBanLookupTable = function()
    return databaseLookupCache
end

Nova.registerAction("banbypass_clientcheck", "banbypass_bypass_clientcheck_action", {
    ["add"] = function(ply, banned, evidence)
        Nova.addDetection(ply, "banbypass_clientcheck", Nova.lang("notify_banbypass_clientcheck", Nova.playerName(banned), evidence))
    end,
    ["nothing"] = function(ply, banned, evidence)
        Nova.log("i", string.format("%s might bypass a ban: Found evidence for a ban bypass of %s | Evidence: %s. But no action was taken.", Nova.playerName(ply), Nova.playerName(banned), evidence))
    end,
    ["notify"] = function(ply, banned, evidence)
        Nova.log("w", string.format("%s might bypass a ban: Found evidence for a ban bypass of %s | Evidence: %s", Nova.playerName(ply), Nova.playerName(banned), evidence))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "banbypass",
            ["message"] = Nova.lang("notify_banbypass_clientcheck", Nova.playerName(banned), evidence),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["ban"] = function(ply, banned, evidence)
        Nova.log("i", string.format("Banning %s: Found evidence for a ban bypass of %s | Evidence: %s", Nova.playerName(ply), Nova.playerName(banned), evidence))
        Nova.banPlayer(
            ply,
            Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
            Nova.lang("notify_banbypass_clientcheck",
                Nova.playerName(banned),
                evidence
            ),
            "banbypass_clientcheck"
        )
    end,
    ["allow"] = function(ply, banned, evidence, admin)
         // send unban payload to the client
         Nova.sendLua(ply, Nova.getUnbanClientPayload(), {protected = true, disable_express = true})

         Nova.notify({
             ["severity"] = "s",
             ["module"] = "action",
             ["message"] = Nova.lang("notify_functions_allow_success"),
         }, admin)
        Nova.log("i", string.format("Allowed %s to bypass a ban: Removed files from client", Nova.playerName(ply)))
    end,
    ["ask"] = function(ply, banned, evidence, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s might bypass a ban: Found evidence for a ban bypass of %s | Evidence: %s", Nova.playerName(ply), Nova.playerName(banned), evidence))
        Nova.askAction({
            ["identifier"] = "banbypass_clientcheck",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_banbypass_clientcheck_action", Nova.playerName(banned), evidence),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = Nova.lang("notify_banbypass_clientcheck",
                        Nova.playerName(steamID),
                        evidence
                    ),
                    reason = Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
                    internal_reason = "banbypass_clientcheck"
                })
                Nova.startAction("banbypass_clientcheck", "nothing", steamID, banned, evidence)
                return
            end
            Nova.startAction("banbypass_clientcheck", answer, steamID, banned, evidence, admin)
        end)
    end,
})

Nova.registerAction("banbypass_ipcheck", "banbypass_bypass_ipcheck_action", {
    ["add"] = function(ply, banned)
        Nova.addDetection(ply, "banbypass_ipcheck", Nova.lang("notify_banbypass_ipcheck", Nova.playerName(banned)))
    end,
    ["nothing"] = function(ply, banned)
        Nova.log("i", string.format("%s might bypass a ban: Identical IP to banned player %s", Nova.playerName(ply), Nova.playerName(banned)))
    end,
    ["notify"] = function(ply, banned)
        Nova.log("w", string.format("%s might bypass a ban: Identical IP to banned player %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "banbypass",
            ["message"] = Nova.lang("notify_banbypass_ipcheck", Nova.playerName(banned)),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["ban"] = function(ply, banned)
        Nova.log("i", string.format("Banning %s: Identical IP to banned player %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.banPlayer(
            ply,
            Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
            string.format(
                "Identical IP to banned player %s",
                Nova.playerName(banned)
            ),
            "banbypass_ipcheck"
        )
    end,
    ["allow"] = function(ply, banned, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s might bypass a ban: Identical IP to banned player %s", Nova.playerName(ply), Nova.playerName(banned)))
    end,
    ["ask"] = function(ply, banned, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s might bypass a ban: Identical IP to banned player %s", Nova.playerName(ply), Nova.playerName(banned)))
        Nova.askAction({
            ["identifier"] = "banbypass_ipcheck",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_banbypass_ipcheck_action", Nova.playerName(banned)),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format(
                        "Identical IP to banned player %s",
                        Nova.playerName(banned)
                    ),
                    reason = Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
                    internal_reason = "banbypass_ipcheck"
                })
                Nova.startAction("banbypass_ipcheck", "nothing", steamID, banned)
                return
            end
            Nova.startAction("banbypass_ipcheck", answer, steamID, banned, admin)
        end)
    end,
})

local function CheckServerSideBan(ply)
    // check if player is protected and unban him if he is (however) banned
    if Nova.isProtected(ply) and Nova.isPlayerBanned(ply) then
        Nova.log("i", string.format("Unbanning %s: protected group", Nova.playerName(ply)))
        // we sent him lua code to remove client side ban
        Nova.unbanPlayer(ply)
        return
    end

    local ban = databaseCache[ply:SteamID()]
    if ban then
        // if player is unban on sight
        if ban.unban_on_sight == 1 then
            Nova.log("i", string.format("Unbanning %s: unban on sight", Nova.playerName(ply)))
            // we sent him lua code to remove client side ban
            Nova.unbanPlayer(ply)
            return
        end

        // if player is ban on sight
        if ban.ban_on_sight == 1 then
            Nova.log("i", string.format("Banning %s: ban on sight", Nova.playerName(ply)))
            Nova.banPlayer(ply, ban.reason, ban.comment, ban.internal_reason, true)
            return
        end

        // if player is marked as banned we ban him securely again (however he got here...)
        if ban.is_banned == 1 then
            Nova.log("i", string.format("Banning %s: marked as banned", Nova.playerName(ply)))
            Nova.banPlayer(ply, ban.reason, ban.comment, ban.internal_reason, true)
            return
        end
    end

    // check if player has identical ip to a banned player
    // Remove port from ip
    local ip = Nova.extractIP(ply:IPAddress(), true)
    if ip then
        Nova.log("d", string.format("Checking %s for identical IP to banned player", Nova.playerName(ply)))
        for _, _ban in pairs(databaseCache) do
            if _ban.is_banned != 1 or _ban.ip != ip then continue end

            Nova.startDetection("banbypass_ipcheck", ply, _ban.steamid, "banbypass_bypass_ipcheck_action")
        end
    end

    // Check inside other modules
    hook.Run("nova_banbypass_check", ply)
end

local function CheckClientSideBan(ply)
    local ban = databaseCache[ply:SteamID()]
    // if player is ban/unban on sight we don't need to do anything
    if ban and (ban.unban_on_sight == 1 or ban.ban_on_sight == 1) then return end

    Nova.sendLua(ply, Nova.getCheckClientPayload(), {protected = true, cache = true, reliable = true})
    Nova.log("d", string.format("Checking client side ban for %s", Nova.playerName(ply)))
end

// before client connects to server
hook.Add("nova_base_checkpassword", "banbypass_checkban", function(steamID, ipAddress, svPassword, clPassword, name)
    Nova.log("d", string.format("Checking connection from %q (SteamID: %s IP: %s)", name, steamID, ipAddress))
    if not databaseCache[steamID] then return end

    // if player is protected, we don't need to check anything
    if Nova.isProtected(steamID) then return end

    // if player is ban on sight we let him first connect and later take action
    if databaseCache[steamID].ban_on_sight == 1 then
        Nova.log("i", string.format("Letting %s connect to the server: ban on sight", Nova.playerName(steamID)))
        return
    end

    // if player is unban on sight we let him first connect and later take action
    if databaseCache[steamID].unban_on_sight == 1 then
        Nova.log("i", string.format("Letting %s connect to the server: unban on sight", Nova.playerName(steamID)))
        return
    end

    // if player is banned we don't let him connect
    if databaseCache[steamID].is_banned == 1 then
        local banReason = databaseCache[steamID].reason or Nova.getSetting("banbypass_ban_default_reason", "Server Security")
        local reasonSuffix = Nova.getSetting("server_general_suffix", "")
        banReason = string.format("%s %s", banReason, reasonSuffix)

        Nova.log("d", string.format("Blocking connection of %s: banned", Nova.playerName(steamID)))
        return false, banReason
    end
end)

// if player finished connecting to server AND authenticated
hook.Add("nova_networking_playerauthenticated", "banbypass_checkban", function(ply)
    // we add a little delay here to make sure the client has transfered 
    // all data from other modules to server (e. g. fingerprint)
    timer.Simple(15, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        Nova.log("d", string.format("Checking if %s is bypassing a ban", Nova.playerName(ply)))

        // check if player is banned on client side
        CheckClientSideBan(ply)

        // check if player is e.g. ban on sight or is sharing his account with a banned player
        CheckServerSideBan(ply)
    end)
end)

hook.Add("nova_init_loaded", "banbypass_checkban", function()
    Nova.log("d", "Creating ban bypass database cache and netmessages")
    Nova.netmessage("banbypass_checkclientsideban")

    // client sents us his stored secret and we check if he is banned
    Nova.netReceive(Nova.netmessage("banbypass_checkclientsideban"), {auth = true}, function(len, ply)
        local secretKey = net.ReadString() or ""
        local conVar = net.ReadString() or "30"

        Nova.log("d", string.format("Received client side ban check from %s", Nova.playerName(ply)))
        // we didn't receive a secret key or the convar is not set, return
        if secretKey == "" and conVar == "30" then return end

        local banRelatedTo = ""
        local evidence = ""

        local isBanned = false
        playerSteamID = Nova.convertSteamID(ply)
        for k,v in pairs(databaseCache or {}) do
            // prevent race condition when ban is not completely revoked yet
            if v.steamid == playerSteamID then continue end

            // check if secretKey exists in database
            if string.len(secretKey) > 5 and v.secret_key == secretKey then
                Nova.log("i", string.format("Found ban for %s: secretKey in files", Nova.playerName(ply)))
                isBanned = true
                banRelatedTo = (banRelatedTo == "") and v.steamid or banRelatedTo
                evidence = string.format("%sFile-Check, ", evidence)
            end
            // check if conVar exists in database
            if conVar != "30" and v._temp_secret_convar == conVar then
                Nova.log("i", string.format("Found ban for %s: conVar", Nova.playerName(ply)))
                isBanned = true
                if banRelatedTo == "" then banRelatedTo = v.steamid end
                evidence = string.format("%sConVar-Check, ", evidence)
            end
            if isBanned then break end
        end

        if not isBanned then
            Nova.log("d", string.format("Found no ban for %s", Nova.playerName(ply)))
            return
        end

        banRelatedTo = (banRelatedTo == "") and "UNKNOWN" or banRelatedTo
        evidence = string.sub(evidence, 1, -3)

        // if he was client side banned we also safely ban this account as well
        // with this we also override the existing clientside banprotection with a new one
        Nova.startDetection("banbypass_clientcheck", ply, banRelatedTo, evidence, "banbypass_bypass_clientcheck_action")
    end)
end)

// if a player get's banned we rescan all players if they are linked to this account and ban them as well
hook.Add("nova_banbypass_onplayerban", "banbypass_rescan", function(ply_or_steamid, baninfo)
    if not baninfo then return end

    Nova.log("i", string.format("Initiating a rescan of all players because %s got banned", Nova.playerName(baninfo.steamid)))
    local bannedSteamID = Nova.convertSteamID(ply_or_steamid)
    for k,v in ipairs(player.GetHumans() or {}) do
        // if he is still connected we don't need to rescan him
        if v:SteamID() == bannedSteamID then continue end

        // if ply is ban/unban on sight we don't need to rescan him
        local ban = databaseCache[v:SteamID()]
        if ban and (ban.unban_on_sight == 1 or ban.ban_on_sight == 1) then continue end

        // we delay the rescan for each player to distribute the load
        timer.Simple(k * 0.2, function()
            if not IsValid(v) or not v:IsPlayer() then return end
            CheckServerSideBan(v)
        end)
    end
end)

local function LoadBans()
    Nova.log("i", "Loading bans from database...")
    local query = "SELECT * FROM `nova_bans`;"
    Nova.selectQuery(query, function(data)
        if not data then return end
        for _, v in ipairs(data or {}) do
            local steamid = v.steamid
            local ip = v.ip
            local comment = v.comment
            local reason = v.reason
            local internal_reason = v.internal_reason
            local time = v.time
            local ban_on_sight = tonumber(v.ban_on_sight)
            local unban_on_sight = tonumber(v.unban_on_sight)
            local secret_key = v.secret_key
            local is_banned = tonumber(v.is_banned)
            local fingerprint = v.fingerprint
            local ban = {
                steamid = steamid,
                ip = ip,
                comment = comment,
                reason = reason,
                internal_reason = internal_reason,
                time = time,
                ban_on_sight = ban_on_sight,
                unban_on_sight = unban_on_sight,
                secret_key = secret_key,
                // we need this also in number representation to store in convars on the client
                // for performace reasons we precompute this number here
                _temp_secret_convar = GetConvarFromSecret(secret_key),
                is_banned = is_banned,
                fingerprint = fingerprint != "" and util.JSONToTable(fingerprint) or nil,
            }
            databaseCache[steamid] = ban
            databaseLookupCache[util.SteamIDTo64(steamid)] = true
        end

        Nova.log("s", string.format("Loaded %d bans from database", #data))
    end)
end

// are we already connected to database (hook will never run) or do we need to wait?
// depends on whether setting.lua is loaded before or after mysql.lua
if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "banbypass_loadbans", LoadBans)
else
    LoadBans()
end