/*
    Collection of all types of detections that can be made by the system.
*/

// prevent spam and duplicates
local playerDetections = {}
local playerDetectionHistory = {}
local detectionCooldown = 1 * 60 * 60 // 1 hour

local actions = {}

Nova.registerAction = function(identifier, action_setting, actionTable)
    if not identifier or type(identifier) != "string" then return end
    if not actionTable or type(actionTable) != "table" then return end

    actions[identifier] = {
        action_table = actionTable,
        action_setting = action_setting,
    }
end

Nova.startAction = function(identifier, action, ...)
    if not identifier or type(identifier) != "string" then
        Nova.log("e", string.format("Action %q on ignored: identifier is not a string", tostring(identifier)))
        return
    end
    if not actions[identifier] then
        Nova.log("e", string.format("Action %q on ignored: action does not exist", identifier))
        return
    end

    // player or steamid is first argument in the vararg
    local args = {...}
    local ply_or_steamid = args[1]

    local actionTable = actions[identifier].action_table
    if not actionTable then
        Nova.log("e", string.format("Action %q on ignored: action table %q does not exist", identifier, identifier))
        return
    end

    // check detection cooldown
    local detection_id = string.format("%s_%s_%s", identifier, ply_or_steamid, action)
    // That could be an awesome vulnerability, if the steamid would get appended at the end of the detection_id
    // Do you know why?
    // So we put it in the middle ;)
    for k, v in pairs(args) do
        v = tostring(v)
        detection_id = string.format("%s_%s", detection_id, v)
    end
    // first detection
    if not playerDetections[detection_id] then
        playerDetections[detection_id] = os.time()
    // check if cooldown is over
    elseif playerDetections[detection_id] + detectionCooldown > os.time() then
        Nova.log("i", string.format("Detection %q on %s ignored: cooldown not over", identifier, Nova.playerName(ply_or_steamid)))
        return
    // cooldown is over
    else
        playerDetections[detection_id] = os.time()
    end

    // always add a detection first
    local addDetectionFunc = actionTable["add"]
    if not isfunction(addDetectionFunc) then
        Nova.log("e", string.format("Detection could not be added: detection %q does not have an 'add' function", identifier))
        return
    end
    // ask calls this functiona again, so we don't want to add a detection twice
    if action != "ask" then addDetectionFunc(...) end

    // call the action function
    local actionFunc = actionTable[action]
    if not isfunction(actionFunc) then
        Nova.log("e", string.format("Action %q on ignored: action %q does not exist", identifier, action))
        return
    end
    actionFunc(...)
end

Nova.logDetection = function(details)
    local query = [[
        INSERT INTO nova_detections (
            id,
            steamid,
            comment,
            reason,
            internal_reason,
            time,
            action_taken,
            action_taken_at,
            action_taken_by
        ) 
        VALUES (%q, %s, %s, %s, %s, %q, %q, %q, %s);
    ]]
    query = string.format(query,
        Nova.generateUUID(),
        Nova.sqlEscape(Nova.convertSteamID(details.steamid)),
        Nova.sqlEscape(details.comment),
        Nova.sqlEscape(details.reason or Nova.getSetting("banbypass_ban_default_reason", "Server Security")),
        Nova.sqlEscape(details.internal_reason),
        details.time or os.time(),
        details.action_taken or 0,
        details.action_taken_at or 0,
        Nova.sqlEscape(details.action_taken_by or "")
    )
    Nova.query(query)
end

Nova.addDetection = function(ply_or_steamid, identifier, description)
    if not ply_or_steamid or ply_or_steamid == NULL then return end

     // we never block admin_manual
    if identifier == "admin_manual" then return end

    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not steamID or steamID == "" then return end
    Nova.log("d", string.format("Adding detection %q on %s", identifier, Nova.playerName(ply_or_steamid)))

    timer.Simple(0, function()
        hook.Run("nova_config_detection", steamID, Nova.fPlayerBySteamID(steamID), identifier, description)
    end)

    if not playerDetectionHistory[steamID] then
        playerDetectionHistory[steamID] = {}
    end

    if not description or type(description) != "string" then
        description = ""
    end

    table.insert(playerDetectionHistory[steamID], {
        time = os.time(),
        identifier = identifier,
        description = description,
    })
end

Nova.startDetection = function(identifier, ...)
    if not identifier or type(identifier) != "string" then
        Nova.log("e", string.format("Detection %q on ignored: identifier is not a string", tostring(identifier)))
        return
    end
    if not actions[identifier] then
        Nova.log("e", string.format("Detection %q on ignored: action does not exist", identifier))
        return
    end

    local action = Nova.getSetting(actions[identifier].action_setting, "ask")
    Nova.startAction(identifier, action, ...)
end

Nova.treatDetection = function(id, steamid, admin, callback)
    if not isfunction(callback) then callback = function() end end

    // is player even allowed to ban?
    if not Nova.canTouch(admin, steamid) then
        callback(false, "NO PERMISSION")
        return
    end

    // check if the player is banned already
    if Nova.isPlayerBanned(steamid) then
        Nova.log("i", string.format("Player %q is already banned", steamid))
        callback(false, "ALREADY BANNED")
        return
    end

    // get all information about the detection
    local query = [[
        SELECT * FROM nova_detections 
        WHERE id = %s;
    ]]
    query = string.format(query, Nova.sqlEscape(id))

    Nova.selectQuery(query, function(data)
        if not data or not data[1] then return end

        local banSuccess = Nova.banPlayer(
            steamid,
            data[1].reason,
            data[1].comment,
            data[1].internal_reason
        )

        if banSuccess == false then
            callback(false, "BAN FAILED")
            return
        end

        // update the detection
        query = [[
            UPDATE nova_detections 
            SET 
                action_taken = 1, 
                action_taken_at = %s, 
                action_taken_by = %s
            WHERE action_taken = 0 AND steamid = %s;
        ]]
        query = string.format(query,
            os.time(),
            Nova.sqlEscape(Nova.playerName(admin)),
            Nova.sqlEscape(steamid)
        )
        Nova.query(query)

        callback(true, "BAN SUCCESS")
    end)
end

local function MitigateAllDetections(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)

    local query = [[
        UPDATE nova_detections 
        SET 
            action_taken = 1, 
            action_taken_at = %s, 
            action_taken_by = %s
        WHERE action_taken = 0 AND steamid = %s;
    ]]
    query = string.format(query,
        os.time(),
        Nova.sqlEscape("CONSOLE"),
        Nova.sqlEscape(steamID)
    )
    Nova.query(query)
end

Nova.getPlayerDetections = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not playerDetectionHistory[steamID] then return nil, 0 end

    return table.Copy(playerDetectionHistory[steamID] or {}), table.Count(playerDetectionHistory[steamID] or {})
end

Nova.clearDetections = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not steamID or steamID == "" then return end
    Nova.log("d", string.format("Clearing detections on %s", Nova.playerName(ply_or_steamid)))
    playerDetections[steamID] = nil
    playerDetectionHistory[steamID] = nil
end

// if detection settings change, clean up playerDetections
hook.Add("nova_config_setting_changed", "config_detections_update", function(key, value, oldValue)
    // check if key end with '_action'
    if not string.EndsWith(key, "_action") then return end

    playerDetections = {}
    Nova.log("d", string.format("Detection %q changed: Clearing detection cache", key))
end)

// we don't want to clear the detections on disconnect, to prevent  clearing the detections by reconnecting

// clear detections on ban
hook.Add("nova_banbypass_onplayerban", "config_detections_clearonban", function(ply)
    Nova.log("d", string.format("Player %s banned: Clearing detections", Nova.playerName(ply)))
    Nova.clearDetections(ply)
    MitigateAllDetections(ply)
end)

concommand.Add("nova_clear_detections", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    playerDetections = {}
    playerDetectionHistory = {}
end)

concommand.Add("nova_detections", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    print("Player Detections:")
    PrintTable(playerDetections)
    print("playerDetectionHistory:")
    PrintTable(playerDetectionHistory)
end)