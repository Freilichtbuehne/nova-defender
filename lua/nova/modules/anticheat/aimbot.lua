local translationTable = {
    ["anticheat_aimbot_snap"] = "anticheat_aimbot_check_snap",
    ["anticheat_aimbot_move"] = "anticheat_aimbot_check_move",
    ["anticheat_aimbot_contr"] = "anticheat_aimbot_check_contr",
}

local aimbotLoadPayload = [[
    local entityMeta = FindMetaTable("Entity")
    local playerMeta = FindMetaTable("Player")
    local oldSetAngles = entityMeta.SetAngles
    local olsSetEyeAngles = playerMeta.SetEyeAngles
    local localPlayer = LocalPlayer()
    local clientChanged = false
    local function ValidSource(src)
        if not src then return false end

        // localted in addons
        if string.StartWith(src, "addons/") then return true end

        return false
    end

    local hookName = %q
    local scc, err = pcall(function() localPlayer:SetAngles("unload") end)
    if not scc then
        function entityMeta:SetAngles(ang, ...)
            if ang == "unload" then return oldSetAngles, hookName end
            if self != localPlayer then oldSetAngles(self, ang) return end
            local callerSrc = debug.getinfo(2).short_src
            //debug.Trace()
            //print("Angles set from: " .. callerSrc)
            if ValidSource(callerSrc) then
                --clientChanged = true
                --oldSetAngles(self, ang, ...)
            end
        end
    end

    scc, err = pcall(function() localPlayer:SetEyeAngles("unload") end)
    if not scc then
        function playerMeta:SetEyeAngles(ang, ...)
            if ang == "unload" then return olsSetEyeAngles, hookName end
            if self != localPlayer then olsSetEyeAngles(self, ang) return end
            local callerSrc = debug.getinfo(2).short_src
            //debug.Trace()
            //print("Eye angles set from: " .. callerSrc)
            if ValidSource(callerSrc) then
                --clientChanged = true
                --olsSetEyeAngles(self, ang, ...)
            end
        end
    end

    hook.Add("CreateMove", hookName, function(cmd)
        // max: 32767
        if clientChanged then
            clientChanged = false
            cmd:SetMouseX(%d)
            cmd:SetMouseY(%d)
        end
    end)
]]

local aimbotUnloadPayload = [[
    local entityMeta = FindMetaTable("Entity")
    local playerMeta = FindMetaTable("Player")
    local localPlayer = LocalPlayer()
    local scc, err = pcall(function() localPlayer:SetAngles("unload") end)
    if scc then
        local oldSetAngles, hookName = localPlayer:SetAngles("unload")
        if oldSetAngles then entityMeta.SetAngles = oldSetAngles end
        if hookName then hook.Remove("CreateMove", hookName) end
    end
    
    scc, err = pcall(function() localPlayer:SetEyeAngles("unload") end)
    if scc then
        local olsSetEyeAngles, hookName = localPlayer:SetEyeAngles("unload")
        if olsSetEyeAngles then playerMeta.SetEyeAngles = olsSetEyeAngles end
        if hookName then hook.Remove("CreateMove", hookName) end
    end
]]

Nova.registerAction("anticheat_aimbot", "anticheat_aimbot_action", {
    ["add"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.addDetection(
            steamID,
            identifier,
            Nova.lang("notify_aimbot_detection", humanIdentifier, Nova.playerName(steamID), reason)
        )
    end,
    ["nothing"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("i", string.format("Aimbot detection %q on %s. Reason: %q. But no action was taken.", humanIdentifier, Nova.playerName(steamID), reason))
    end,
    ["notify"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Aimbot detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "anticheat",
            ["message"] = Nova.lang("notify_aimbot_detection", humanIdentifier, Nova.playerName(steamID), reason),
            ["ply"] = Nova.convertSteamID(steamID),
        })
    end,
    ["kick"] = function(steamID, identifier, reason)
        Nova.kickPlayer(steamID, Nova.getSetting("anticheat_aimbot_reason"), identifier)
    end,
    ["ban"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.banPlayer(
            steamID,
            Nova.getSetting("anticheat_aimbot_reason"),
            string.format("Aimbot detection: %q Reason: %q", humanIdentifier, reason),
            identifier
        )
    end,
    ["allow"] = function(steamID, identifier, reason, admin)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        // check if identifier is in the translation table
        if not translationTable[identifier] then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Aimbot detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // check if setting exists
        if Nova.getSetting(translationTable[identifier], "unknown") == "unknown" then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Aimbot detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // disable the aimbot check
        Nova.setSetting(translationTable[identifier], false)
        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(steamID, identifier, reason, actionKey, _actions)
        steamID = Nova.convertSteamID(steamID)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Aimbot detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))

        Nova.askAction({
            ["identifier"] = identifier,
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_aimbot_detection_action", humanIdentifier),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format("Aimbot detection: %q Reason: %q", humanIdentifier, reason),
                    reason = Nova.getSetting("anticheat_aimbot_reason"),
                    internal_reason = identifier
                })
                Nova.startAction("anticheat_aimbot", "nothing", steamID, identifier, reason)
                return
            end
            Nova.startAction("anticheat_aimbot", answer, steamID, identifier, reason, admin)
        end)
    end,
})

// weapon classes that cannot hurt other players
local blacklistWeapons = {
    ["gmod_camera"] = true,
    ["gmod_tool"] = true,
    ["weapon_crowbar"] = true,
    ["weapon_physcannon"] = true,
    ["weapon_physgun"] = true,
}

local function TicksToSeconds(ticks)
    return ticks * engine.TickInterval()
end

local function SecondsToTicks(seconds, ceiled)
    return ceiled and math.ceil(seconds / engine.TickInterval()) or seconds / engine.TickInterval()
end

// convert seconds to ticks (1 second = ticks per second)
local maxNoMouseCount =             SecondsToTicks(0.8)
local maxMouseContradictions =      SecondsToTicks(0.2)
local maxNoMouseAngleDiff =         10
local maxNoMouseSnapAngle =         20

// Hooks like StartCommand are called hundreds of times per second
// Therefore, only as few calculations as possible should be performed within these hooks
// We do this by precomputing non-time critical information in a slower timer
local playerStatus = {}
local commandStats = {}
local slowTimerInterval = 0.3
timer.Create("nova_anticheat_aimbot", slowTimerInterval, 0, function()
    // refresh tick count
    maxNoMouseCount = SecondsToTicks(0.8)

    for _, ply in ipairs(player.GetHumans()) do
        if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then continue end

        local steamID = ply:SteamID()
        local stats = playerStatus[steamID] or {}

        // alter command stats
        local cmdStats = commandStats[steamID]
        if cmdStats then
            cmdStats["totalMouseContradictions"] = math.floor(math.max(0, cmdStats["totalMouseContradictions"] - SecondsToTicks(0.1)))
        end

        // is moving
        stats["is_moving"] = ply:GetVelocity():Length() > 0

        // position
        local pos = ply:GetPos()
        // angle
        local angle = ply:EyeAngles()

        // check if player is 'afk'
        if stats["pos"] and stats["angle"] then
            local lastPos = stats["pos"]
            local lastAngleP, lastAngleY = stats["angle"].p, stats["angle"].y
            if lastPos == pos and lastAngleP == angle.p and lastAngleY == angle.y then
                stats["no_move_time"] = (stats["no_move_time"] or 0) + slowTimerInterval
            else
                stats["no_move_time"] = 0
            end
        end
        stats["pos"] = pos
        stats["angle"] = angle

        // get the player's weapon
        local wep = ply:GetActiveWeapon()
        local class = IsValid(wep) and wep:GetClass() or nil
        if class and not blacklistWeapons[class] then
            stats["weapon"] = wep
            stats["weapon_class"] = class
        else
            stats["weapon"] = nil
            stats["weapon_class"] = nil
        end

        // observer mode to prevent false positives in spectator mode
        local observerMode = ply:GetObserverMode()
        stats["is_observer"] = observerMode != OBS_MODE_NONE

        // is player frozen
        stats["is_frozen"] = ply:IsFrozen()

        // is authenticated
        stats["is_authenticated"] = Nova.isPlayerAuthenticated(ply)

        // is able to shoot
        stats["can_shoot"] =
            stats["weapon_class"] and
            not stats["is_frozen"] and
            not stats["is_observer"] and
            not ply:InVehicle() and
            observerMode == OBS_MODE_NONE and
            movetype != MOVETYPE_NOCLIP

        playerStatus[steamID] = stats
    end
end)

// Overwrite SetPos and SetAngles to prevent false positives
local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")
/*local shortSrcP = debug.getinfo(entityMeta.SetPos).short_src
local shortSrcA = debug.getinfo(entityMeta.SetAngles).short_src
local shortSrcEA = debug.getinfo(playerMeta.SetEyeAngles).short_src
not string.find(shortSrcEA, "nova_defender_")
*/

Nova.overrides = Nova.overrides or {}
//Nova.overrides["SetPos"] = Nova.overrides["SetPos"] or entityMeta.SetPos
Nova.overrides["SetAngles"] = Nova.overrides["SetAngles"] or entityMeta.SetAngles
Nova.overrides["SetEyeAngles"] = Nova.overrides["SetEyeAngles"] or playerMeta.SetEyeAngles

/*function entityMeta:SetPos(pos)
    // if not player
    if not IsValid(self) then return end
    if not self:IsPlayer() then Nova.overrides["SetPos"](self, pos) return end
    // if player has command stats
    local steamID = self:SteamID()
    if commandStats[steamID] then commandStats[steamID]["serverChanged"] = true end
    Nova.overrides["SetPos"](self, pos)
end*/

function entityMeta:SetAngles(ang)
    // if not player
    if not IsValid(self) then return end
    if not self:IsPlayer() then Nova.overrides["SetAngles"](self, ang) return end
    // if player has command stats
    local steamID = self:SteamID()
    if commandStats[steamID] then commandStats[steamID]["serverChanged"] = true end
    Nova.overrides["SetAngles"](self, ang)
end

function playerMeta:SetEyeAngles(ang)
    // if player has command stats
    local steamID = self:SteamID()
    if commandStats[steamID] then commandStats[steamID]["serverChanged"] = true end
    Nova.overrides["SetEyeAngles"](self, ang)
end

local timeoutPlayers = {}
local timeout = 120 // seconds

local function CheckTimeout(steamID, identifier)
    // check if player is already in timeout
    if not timeoutPlayers[steamID] then
        timeoutPlayers[steamID] = {
            [identifier] = CurTime() + timeout
        }
        return true
    end

    // check if player is in timeout for this identifier
    if not timeoutPlayers[steamID][identifier] then
        timeoutPlayers[steamID][identifier] = CurTime() + timeout
        return true
    end

    // check if timeout is over
    if timeoutPlayers[steamID][identifier] < CurTime() then
        timeoutPlayers[steamID][identifier] = CurTime() + timeout
        return true
    end

    return false
end

/*local function FTrace(ply, viewAngle)
    local trace = {}
    trace.start = ply:GetShootPos()
    trace.endpos = trace.start + (viewAngle:Forward() * 10000)
    trace.filter = ply
    trace.mask = MASK_SHOT
    return util.TraceLine(trace)
end*/

local allowedMoveTypes = {
    [MOVETYPE_NONE] = true,
    [MOVETYPE_WALK] = true,
    [MOVETYPE_VPHYSICS] = true,
    //[MOVETYPE_LADDER] = true,
}

local checkSnap = false
local checkMove = false
local checkContr = false
local anyCheck = false
local anticheatEnabled = false
local aimbotEnabled = false
local abs = math.abs
local function AimbotHandler(ply, cmd, steamID)
    // check if we have precomputed stats for the player
    local generalStats = playerStatus[steamID]

    // case if we don't have precomputed stats
    if not generalStats then return end

    local anglep, angley, angler = cmd:GetViewAngles():Unpack()
    local mousex, mousey = cmd:GetMouseX(), cmd:GetMouseY()
    local serverangley = ply:GetAngles().y
    local moveType = ply:GetMoveType()

    /*if not checkSnap and mousex == 0xf00 and mousey == 0xf01 then
        mousex, mousey = 0, 0
    end*/

    local cmdStats = commandStats[steamID]
    if not cmdStats then
        commandStats[steamID] = {
            ["aimCounter"] = 0,
            ["lastTarget"] = nil,
            ["lastX"] = mousex,
            ["lastY"] = mousey,
            ["lastAP"] = anglep,
            ["lastAY"] = angley,
            ["lastSAY"] = serverangley,
            ["lastOnlyAxisChange"] = false,
            ["lastMoveType"] = moveType,
            ["serverChanged"] = nil,
            ["mouseNullCount"] = 0,
            ["totalAngleDiff"] = 0,
            ["totalMouseContradictions"] = 0,
            ["lastMouseContradiction"] = 0,
        }
        return
    end

    local lastx, lasty, lastap, lastay, lastsay, lastMC =
        cmdStats.lastX, cmdStats.lastY, cmdStats.lastAP, cmdStats.lastAY, cmdStats.lastSAY, cmdStats.lastMouseContradiction
    local mouseChanged = (mousex != lastx or mousey != lasty)
    local mouseNull = (mousex == 0 and mousey == 0)
    local lastMouseNull = (lastx == 0 and lasty == 0)
    local pitchDiff = lastap - anglep
    local yawDiff = ((lastay - angley + 180) % 360) - 180
    local angleDiff = abs(pitchDiff) + abs(yawDiff)
    local serverChanged = (lastsay != serverangley) or (cmdStats.serverChanged or false)
    // check if player either only moved his mouse horizontally or vertically (IN_LEFT or IN_RIGHT are set)
    local buttons = cmd:GetButtons()
    local onlyAxisChange = bit.band(buttons, IN_LEFT + IN_RIGHT) != 0
    local altPressed = bit.band(buttons, IN_WALK) != 0
    //local onlyAxisChange = (lastap != anglep and lastay == angley) or (lastap == anglep and lastay != angley)
    local moveTypeChanged = (cmdStats.lastMoveType != moveType)

    commandStats[steamID].lastX = mousex
    commandStats[steamID].lastY = mousey
    commandStats[steamID].lastAP = anglep
    commandStats[steamID].lastAY = angley
    commandStats[steamID].lastSAY = serverangley
    commandStats[steamID].lastMoveType = moveType
    commandStats[steamID].lastOnlyAxisChange = onlyAxisChange
    commandStats[steamID].lastMouseContradiction = false
    commandStats[steamID].serverChanged = nil

    if not generalStats["can_shoot"] then
        cmdStats["totalAngleDiff"] = 0
        cmdStats["mouseNullCount"] = 0
        return
    end

    // Detect false positives when movetype changes
    if moveTypeChanged then
        cmdStats["totalAngleDiff"] = 0
        cmdStats["mouseNullCount"] = 0
        return
    end

    // no need to further check because no checks are enabled
    if not anyCheck then return end

    // Player is not authenticated yet
    if not generalStats["is_authenticated"] then return end

    // Check if player has correct movetype
    if not allowedMoveTypes[moveType] then return end

    // Prevent commands like +right, +left from being detected as aimbot
    if onlyAxisChange then return end

    // only check if something changed
    if not mouseChanged and angleDiff == 0 then return end

    // ignore if player returns from inactivity
    if (generalStats["no_move_time"] or 0) > 8 then return end

    // ignore if player has roll
    if angler != 0 then return end

    // check mouse contradictions
    // Little cheat sheet for dumb me:
    // yaw = x
    // pitch = y
    local mouseContr = 0
    if mousex != 0 and abs(yawDiff) != 0 and mousex * yawDiff < 0 then
        mouseContr = mouseContr + 1
    end
    if mousey != 0 and abs(pitchDiff) != 0 and mousey * pitchDiff >= 0 then
        mouseContr = mouseContr + 1
    end
    if mouseContr != 0 then
        if lastMC then
            cmdStats["totalMouseContradictions"] = cmdStats["totalMouseContradictions"] + mouseContr
            print(string.format("[Nova Defender] Mouse contradiction %s: %d/%d (Alt pressed: %s)", steamID, cmdStats["totalMouseContradictions"], maxMouseContradictions, altPressed and "true" or "false"))
        else
            cmdStats["lastMouseContradiction"] = true
        end
    else
        cmdStats["totalMouseContradictions"] = math.max(0, cmdStats["totalMouseContradictions"] - 1)
    end

    // check if command was forced
    if cmd:IsForced() then
        Nova.log("d", string.format("Forced command detected: %s", steamID))
        return
    end

    // if player moves but mouse doesn't move
    if mouseNull and angleDiff > 0 then
        cmdStats["totalAngleDiff"] = cmdStats["totalAngleDiff"] + angleDiff
        cmdStats["mouseNullCount"] = cmdStats["mouseNullCount"] + 1
    else
        cmdStats["totalAngleDiff"] = 0
        cmdStats["mouseNullCount"] = 0
    end

    // check for instant turn
    if
        checkSnap and
        not serverChanged and
        cmdStats["mouseNullCount"] != 0 and
        angleDiff > maxNoMouseSnapAngle and
        lastMouseNull and
        CheckTimeout(steamID, "anticheat_aimbot_snap")
    then
        // print all necessary information for debugging
        /*PrintTable(cmdStats)
        print("mouse", mousex, mousey)
        print("lastmouse", lastx, lasty)
        print("serverangley", serverangley)
        print("lastsay", lastsay)
        print("anglep", anglep, "lastap", lastap)
        print("angley", angley, "lastay", lastay)
        print("angler", angler)
        print("angleDiff", angleDiff)
        print("maxNoMouseSnapAngle", maxNoMouseSnapAngle)
        print("lastMouseNull", lastMouseNull, "mouseNull", mouseNull)
        print("mouseNullCount", cmdStats["mouseNullCount"])
        print("maxNoMouseCount", maxNoMouseCount)
        print("onlyAxisChange", onlyAxisChange)
        print("lastAxis", lastAxis)
        print("movetype", ply:GetMoveType())
        print("Ping", ply:Ping())
        print("packetloss", ply:PacketLoss())
        print("active weapon", generalStats["weapon_class"])
        print("active weapon", ply:GetActiveWeapon())

        Nova.takeScreenshot(ply, nil, true)*/

        Nova.startDetection(
            "anticheat_aimbot",
            steamID,
            "anticheat_aimbot_snap",
            string.format("Player made a %d° turn within 1 tick without moving his mouse", math.ceil(angleDiff)) .. (altPressed and " while ALT key was pressed." or "."),
            "anticheat_aimbot_action"
        )

    // check for low angle diff over time
    elseif
        checkMove and
        not serverChanged and
        cmdStats["totalAngleDiff"] > maxNoMouseAngleDiff and
        cmdStats["mouseNullCount"] > maxNoMouseCount and
        CheckTimeout(steamID, "anticheat_aimbot_move")
    then
        // print all necessary information for debugging
        /*PrintTable(cmdStats)
        print("mouse", mousex, mousey)
        print("lastmouse", lastx, lasty)
        print("serverangley", serverangley)
        print("lastsay", lastsay)
        print("anglep", anglep, "lastap", lastap)
        print("angley", angley, "lastay", lastay)
        print("angler", angler)
        print("angleDiff", angleDiff, "maxNoMouseAngleDiff", maxNoMouseAngleDiff)
        print("lastMouseNull", lastMouseNull, "mouseNull", mouseNull)
        print("mouseNullCount", cmdStats["mouseNullCount"], "maxNoMouseCount", maxNoMouseCount)
        print("totalAngleDiff", cmdStats["totalAngleDiff"])
        print("onlyAxisChange", onlyAxisChange)
        print("lastAxis", lastAxis)
        print("movetype", ply:GetMoveType())
        print("Ping", ply:Ping())
        print("packetloss", ply:PacketLoss())
        print("active weapon", generalStats["weapon_class"])
        print("active weapon", ply:GetActiveWeapon())

        Nova.takeScreenshot(ply, nil, true)*/

        Nova.startDetection(
            "anticheat_aimbot",
            steamID,
            "anticheat_aimbot_move",
            string.format(
                "Player changed his view angle by %d° within %.1f seconds without moving his mouse",
                math.ceil(cmdStats["totalAngleDiff"]),
                TicksToSeconds(cmdStats["mouseNullCount"])
            ) .. (altPressed and " while ALT key was pressed." or "."),
            "anticheat_aimbot_action"
        )
    // check for contradictions in mouse movement
    elseif
        checkContr and
        cmdStats["totalMouseContradictions"] > maxMouseContradictions and
        CheckTimeout(steamID, "anticheat_aimbot_contr")
    then
        // print all necessary information for debugging
        /*PrintTable(cmdStats)
        print("mouse", mousex, mousey)
        print("lastmouse", lastx, lasty)
        print("serverangley", serverangley)
        print("lastsay", lastsay)
        print("anglep", anglep, "lastap", lastap)
        print("angley", angley, "lastay", lastay)
        print("angler", angler)
        print("angleDiff", angleDiff, "maxNoMouseAngleDiff", maxNoMouseAngleDiff)
        print("lastMouseNull", lastMouseNull, "mouseNull", mouseNull)
        print("mouseNullCount", cmdStats["mouseNullCount"], "maxNoMouseCount", maxNoMouseCount)
        print("totalAngleDiff", cmdStats["totalAngleDiff"])
        print("onlyAxisChange", onlyAxisChange)
        print("lastAxis", lastAxis)
        print("movetype", ply:GetMoveType())
        print("Ping", ply:Ping())
        print("packetloss", ply:PacketLoss())
        print("active weapon", generalStats["weapon_class"])
        print("active weapon", ply:GetActiveWeapon())

        Nova.takeScreenshot(ply, nil, true)*/

        Nova.startDetection(
            "anticheat_aimbot",
            steamID,
            "anticheat_aimbot_contr",
            string.format(
                "Player moved his mouse in a different direction than his view changed %d times within %.1f seconds",
                cmdStats["totalMouseContradictions"],
                TicksToSeconds(cmdStats["totalMouseContradictions"])
            ) .. (altPressed and " while ALT key was pressed." or "."),
            "anticheat_aimbot_action"
        )
    end
end
hook.Add("nova_base_startcommand", "anticheat_aimbot", AimbotHandler)

hook.Add("nova_networking_playerauthenticated", "anticheat_aimbot", function(ply)
    local steamID = ply:SteamID()
    playerStatus[steamID] = {}
end)

// Remove quarantine info when player disconnects
hook.Add("nova_base_playerdisconnect", "anticheat_aimbot", function(steamID)
    Nova.log("d", string.format("Removing aimbot stats for %s", steamID))
    playerStatus[steamID] = nil
    commandStats[steamID] = nil
end)

local function EnableCSPayload(status)
    local payload = ""
    if status then
        payload = string.format(aimbotLoadPayload, Nova.generateString(7,13), 0xf00, 0xf01)
    else
        payload = aimbotUnloadPayload
    end

    Nova.log("d", string.format("Sending clientside aimbot payload to all players: %s", status and "enabled" or "disabled"))
    for i, ply in ipairs(player.GetHumans()) do
        // distribute payload over time to minimize utilization
        timer.Simple(i * 0.1, function()
            if not IsValid(ply) or not ply:IsPlayer() then return end
            // prevent triggering the payload twice
            if not Nova.isPlayerAuthenticated(ply) then return end
            Nova.sendLua(ply, payload, {reliable = true}) // TODO: protected and cache
        end)
    end
end

local function LoadConfig()
    checkSnap = Nova.getSetting("anticheat_aimbot_check_snap", false)
    checkMove = Nova.getSetting("anticheat_aimbot_check_move", false)
    checkContr = Nova.getSetting("anticheat_aimbot_check_contr", false)
    anyCheck = checkSnap or checkMove or checkContr
    anticheatEnabled = Nova.getSetting("anticheat_enabled", false)
    aimbotEnabled = Nova.getSetting("anticheat_aimbot_enabled", false)

    if anticheatEnabled and aimbotEnabled then
        timer.UnPause("nova_anticheat_aimbot")
        hook.Add("nova_base_startcommand", "anticheat_aimbot", AimbotHandler)
        Nova.log("d", "Enabled aimbot timer and hook due to setting change")
    else
        timer.Pause("nova_anticheat_aimbot")
        hook.Remove("nova_base_startcommand", "anticheat_aimbot")
        Nova.log("d", "Disabled aimbot timer and hook due to setting change")
    end

    // check if payload should be modified
    local shouldEnable = anticheatEnabled and aimbotEnabled and checkSnap
    EnableCSPayload(shouldEnable)
end

// if a protected player is added or removed
hook.Add("nova_config_setting_changed", "anticheat_aimbot", function(key, value, oldValue)
    // if key starts with "menu_access_"
    if not string.StartWith(key, "anticheat_") then return end

    // update config
    LoadConfig()
end)

hook.Add("nova_networking_playerauthenticated", "anticheat_sendaimbotpayload", function(ply)
    if not Nova.getSetting("anticheat_enabled", true) then return end
    if not checkSnap then return end

    Nova.sendLua(ply, string.format(aimbotLoadPayload, Nova.generateString(7,13), 0xf00, 0xf01), {reliable = true})
    Nova.log("d", string.format("Sent anticheat payload to %s", Nova.playerName(ply)))
end)

if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "anticheat_aimbot", LoadConfig)
else
    LoadConfig()
end