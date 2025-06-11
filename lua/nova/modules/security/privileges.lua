/*
    User group protection prevents the removal or unauthorized 
    acquisition of admin rights. If an unprivileged user finds a 
    bug that allows them to set and remove groups, they may be able 
    to gain admin rights themselves or remove the group from existing admins.
*/

/* 
    As we constantly validate usergroups we want to prevent 
    the same debug message from being printed to console over and over.
    So if no condition has changed, we will only take action once.
*/

local ignore  = {}

local function ShouldIgnore(steamID, group, action)
    local newAction = {["sid"] = steamID, ["group"] = group, ["action"] = action}
    local oldAction = ignore[steamID]

    // no actions have been taken yet (don't ignore)
    if not oldAction then
        ignore[steamID] = newAction
        return false
    // identical action has been taken before (ignore)
    elseif
        oldAction.sid == newAction.sid
        and oldAction.group == newAction.group
        and oldAction.action == newAction.action then
        return true
    // different action has been taken before (don't ignore)
    else
        ignore[steamID] = newAction
        return false
    end
end

local function SetUserGroup(ply_or_steamid, group)
    ply_or_steamid = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(ply_or_steamid)

    // check if player is offline
    if not ply or not IsValid(ply) then
        Nova.log("w", string.format("Could not set group for %s: offline", ply_or_steamid))
        return
    end
    local plySteamID = ply:SteamID()
    //local plySteamID64 = ply:SteamID64()

    local oldGroup = ply:GetUserGroup()

    // default group is "user"
    if not group then group = "user" end

    if ulx then
        RunConsoleCommand("ulx", "adduserid", plySteamID, group)
    /*elseif xAdmin and xAdmin.SetUserRank then
        xAdmin.SetUserRank(ply, group)
    elseif xAdmin then
        RunConsoleCommand("xadmin_setgroup", plySteamID, group) // found this in old official xAdmin documentation
        RunConsoleCommand("xadmin", "setgroup", plySteamID, group) // for xAdmin 2
    elseif sAdmin then
        RunConsoleCommand("sa", "setrank", plySteamID64, group)
    elseif SAM then
        RunConsoleCommand("sam", "setrankid", plySteamID, group)*/
    else
        ply:SetUserGroup(group)
    end

    Nova.log("i", string.format("Setting %s's group from %s to %s", Nova.playerName(ply), oldGroup, group))
end

local function RemoveUserGroup(ply_or_steamid)
    ply_or_steamid = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(ply_or_steamid)

    // check if player is offline
    if not ply or not IsValid(ply) then
        Nova.log("w", string.format("Could not remove group from %s: offline", ply_or_steamid))
        return
    end

    local plySteamID = ply:SteamID()
    //local plySteamID64 = ply:SteamID64()

    local oldGroup = ply:GetUserGroup()

    if ulx then
        RunConsoleCommand("ulx", "removeuserid", plySteamID)
    // If you have a code snippet for all of those admin mods, please send it to me :)
    /*elseif serverguard then
        serverguard.player:SetRank(ply, group)
    elseif xAdmin and xAdmin.SetUserRank then
        xAdmin.SetUserRank(ply)
    elseif xAdmin then
        RunConsoleCommand("xadmin_setgroup", plySteamID) // found this in old official xAdmin documentation
        RunConsoleCommand("xadmin", "setgroup", plySteamID) // for xAdmin 2
    elseif sAdmin then
        RunConsoleCommand("sa", "setrank", plySteamID64)
    elseif SAM then
        RunConsoleCommand("sam", "setrankid", plySteamID)*/
    else
        ply:SetUserGroup("user")
    end

    Nova.log("i", string.format("Removing %s's group %s", Nova.playerName(ply), oldGroup))
end

Nova.registerAction("security_privilege_escalation", "security_privileges_group_protection_escalation_action", {
    ["add"] = function(ply, group)
        Nova.addDetection(ply, "security_privilege_escalation", Nova.lang("notify_security_privesc", Nova.playerName(ply), group))
    end,
    ["nothing"] = function(ply, group)
        Nova.log("i", string.format("%s was set usergroup %q that is whitelist only, but no action was taken.", Nova.playerName(ply), group))
    end,
    ["notify"] = function(ply, group)
        Nova.log("w", string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "security",
            ["message"] = Nova.lang("notify_security_privesc", Nova.playerName(ply), group),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["kick"] = function(ply, group)
        Nova.log("i", string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group))
        RemoveUserGroup(ply)
        Nova.kickPlayer(ply, Nova.getSetting("security_privileges_group_protection_escalation_reason", "Privilege Escalation"), "security_privilege_escalation")
    end,
    ["ban"] = function(ply, group)
        Nova.log("i", string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group))
        RemoveUserGroup(ply)
        Nova.banPlayer(
            ply,
            Nova.getSetting("security_privileges_group_protection_escalation_reason", "Privilege Escalation"),
            string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group),
            "security_privilege_escalation"
        )
    end,
    ["allow"] = function(ply, group, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s was set usergroup %q that is whitelist only, but no action was taken.", Nova.playerName(ply), group))
    end,
    ["ask"] = function(ply, group, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group))
        Nova.askAction({
            ["identifier"] = "security_privilege_escalation",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_security_privesc_action", group),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format("%s was set usergroup %q that is whitelist only.", Nova.playerName(ply), group),
                    reason = Nova.getSetting("security_privileges_group_protection_escalation_reason", "Privilege Escalation"),
                    internal_reason = "security_privilege_escalation"
                })
                Nova.startAction("security_privilege_escalation", "nothing", steamID, group)
                return
            end
            Nova.startAction("security_privilege_escalation", answer, steamID, group, admin)
        end)
    end,
})

Nova.registerAction("security_privilege_removal", "security_privileges_group_protection_removal_action", {
    ["add"] = function(ply, group) end,
    ["nothing"] = function(ply, group)
        local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
        local steamID = Nova.convertSteamID(ply)
        local expectedGroup = protectedPlayers[steamID].group or "MISSING"
        Nova.log("i", string.format("%s protected group was set from %q to %q, but no action was taken.", Nova.playerName(ply), expectedGroup, group))
    end,
    ["set"] = function(ply, group)
        local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
        local steamID = Nova.convertSteamID(ply)
        local expectedGroup = protectedPlayers[steamID].group or "MISSING"
        Nova.log("w", string.format("%s protected group was set from %q to %q. Reverting change...", Nova.playerName(ply), expectedGroup, group))
        SetUserGroup(ply, expectedGroup)
    end,
    // unnecessary?
    ["allow"] = function(ply, group, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s protected group was set from %q to %q, but no action was taken.", Nova.playerName(ply), expectedGroup, group))
    end,
})

local groupCache = {}

local function CreateTimer()
    timer.Create("nova_privileges_group_protection", Nova.getSetting("security_privileges_group_protection_timer_interval", 5), 0, function()
        if not Nova.getSetting("security_privileges_group_protection_enabled", false) then return end

        local players = player.GetHumans()
        for k, v in ipairs(players or {}) do
            if not IsValid(v) or not v:IsPlayer() then continue end

            local steamID = v:SteamID() if not steamID then continue end
            local userGroup = v:GetUserGroup()
            local isProtected = Nova.isProtected(steamID)

            // player has no cached group yet
            if not groupCache[steamID] then
                groupCache[steamID] = {
                    ["group"] = userGroup,
                    ["isStaff"] = Nova.isStaff(steamID),
                    ["isProtected"] = Nova.isProtected(steamID),
                }
            // check if group changed
            elseif groupCache[steamID] and groupCache[steamID] != userGroup then
                local isStaff = Nova.isStaff(steamID)

                local newGroup = {
                    ["group"] = userGroup,
                    ["isStaff"] = isStaff,
                    ["isProtected"] = isProtected,
                }

                hook.Run("nova_security_privileges_groupchange", steamID, groupCache[steamID], newGroup)
                groupCache[steamID] = newGroup
            end

            local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
            local protectedGroups = Nova.getSetting("security_permissions_groups_protected", {})
            // player is protected but his group mismatch
            if isProtected
                and protectedPlayers[steamID]
                and protectedPlayers[steamID].group != userGroup then

                local action = Nova.getSetting("security_privileges_group_protection_removal_action", "set")
                local func_name = "removal_" .. action

                if ShouldIgnore(steamID, userGroup, func_name) then continue end

                Nova.startDetection("security_privilege_removal", v, userGroup)
                continue
            end

            // player has protected group but is not whitelisted
            if not isProtected and table.HasValue(protectedGroups, userGroup) then
                local action = Nova.getSetting("security_privileges_group_protection_escalation_action", "ask")
                local func_name = "escalation_" .. action

                if ShouldIgnore(steamID, userGroup, func_name) then continue end

                Nova.startDetection("security_privilege_escalation", v, userGroup, "security_privileges_group_protection_escalation_action")
                continue
            end
        end
    end)
end

if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "privileges_group_protection", CreateTimer)
else
    CreateTimer()
end

// if a protected player is added or removed
hook.Add("nova_config_setting_changed", "privileges_group_protection", function(key, value, oldValue)
    if key != "security_privileges_group_protection_protected_players" then return end
    if not oldValue then return end
    if not Nova.getSetting("security_privileges_group_protection_enabled", false) then return end

    // check if a player was removed
    for k, v in pairs(oldValue or {}) do
        if not value[k] then
            local ply = Nova.fPlayerBySteamID(k)
            if not IsValid(ply) then continue end
            RemoveUserGroup(ply)
            Nova.setQuarantine(ply, true)
            // we delay the kick as removing the usergroup (depending on the admin system) can take some time
            timer.Simple(1, function()
                Nova.kickPlayer(ply, Nova.getSetting("security_privileges_group_protection_kick_reason", "Protected Usergroup Removed"), "admin_manual")
            end)
            Nova.log("i", string.format("%s was removed from the protected players list. Setting his usergroup to default and kick him.", Nova.playerName(ply)))
        end
    end

    // check if a player was added
    for k, v in pairs(value or {}) do
        if not oldValue[k] then
            local ply = Nova.fPlayerBySteamID(k)
            if not IsValid(ply) then continue end
            SetUserGroup(ply, v.group)
            Nova.log("i", string.format("%s was added to the protected players list. Setting his usergroup to %q.", Nova.playerName(ply), v.group))
            hook.Run("nova_base_initplayer", ply)
        end
    end

    // check if a player was changed
    for k, v in pairs(value or {}) do
        if oldValue[k] and oldValue[k].group != v.group then
            local ply = Nova.fPlayerBySteamID(k)
            if not IsValid(ply) then continue end
            SetUserGroup(ply, v.group)
            Nova.log("i", string.format("%s was changed in the protected players list. Setting his usergroup to %q.", Nova.playerName(ply), v.group))
        end
    end
end)

hook.Add("nova_base_playerdisconnect", "security_privileges_clearactions", function(steamID)
    // if a player disconnects, clear his actions
    ignore[steamID] = nil
    groupCache[steamID] = nil
end)