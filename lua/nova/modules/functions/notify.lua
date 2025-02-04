/*
    Notifications are sent to connected staff or protected clients.
*/

/*
    Example notify:
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "ban",
            ["message"] = string.format("Cannot secure ban %s for %q: protected", Nova.playerName(ply_or_steamid), internalReason),
            ["ply"] = Nova.convertSteamID(ply_or_steamid)
        }, "protected")

    Example ask:
        Nova.askAction({
            ["identifier"] = "network_spam",
            ["action_key"] = "networking_netcollector_spam_action",
            ["reason"] = "Reason for punishment",
            ["ply"] = Nova.convertSteamID(ply_or_steamid)
        }, function(answer) end)
*/

/*
    Sends a notification to specific players
    Possible values for recipient 'rec':
        - "staff"       - sends to all staff
        - "protected"   - sends to all protected players
        - [SteamID32]   - sends to a specific player
        - [Player]      - sends to a specific player
        - other         - sends to all staff
*/

Nova.notify = function(notify, rec)
    local recipients = RecipientFilter()
    // protected players
    if rec == "protected" then
        for k, v in ipairs(player.GetHumans() or {}) do
            if IsValid(v) and v:IsPlayer() and Nova.isProtected(v) then
                recipients:AddPlayer(v)
            end
        end
    // single player
    elseif type(rec) == "Player" and IsValid(rec) and rec:IsPlayer() then
        recipients:AddPlayer(rec)
    // single SteamID32
    elseif type(rec) == "string" and Nova.convertSteamID(rec) != "" and rec != "staff" then
        rec = Nova.convertSteamID(rec)
        local ply = Nova.fPlayerBySteamID(rec)
        if IsValid(ply) and ply:IsPlayer() then
            recipients:AddPlayer(ply)
        end
    // staff (default)
    else
        for k, v in ipairs(player.GetHumans() or {}) do
            if IsValid(v) and v:IsPlayer() and Nova.isStaff(v) then
                recipients:AddPlayer(v)
            end
        end
    end

    if recipients:GetCount() == 0 then return end

    // uppercase module name
    notify["module"] = notify["module"] and string.upper(notify["module"]) or nil
    notify["timeopen"] = Nova.getSetting("menu_notify_timeopen", 15)

    // ensure ply is a steamid
    if notify["ply"] then
        notify["ply"] = Nova.convertSteamID(notify["ply"])
    end

    net.Start(Nova.netmessage("functions_sendnotify"))
        net.WriteString(util.TableToJSON(notify))
    net.Send(recipients)
end

// lua_run Nova.notify({["severity"] = "w",["module"] = "ban",["message"] = "Cannot secure ban......",["ply"] = Entity(1):SteamID()},"protected")
// lua_run Nova.askAction({["identifier"] = "networking_spam",["action_key"] = "networking_netcollector_spam_action",["reason"] = "Reason for punishment",["ply"] = Entity(1):SteamID()}, function() end)
// lua_run if CLIENT then return end Nova.askAction({["identifier"] = "network_spam",["action_key"] = "networking_netcollector_spam_action",["reason"] = "Reason t",["ply"] = Entity(1):SteamID()}, function(action) print(action) end)
local pendingActions = {}

Nova.askAction = function(notify, callback)
    if not isfunction(callback) or not notify or not notify["ply"] then return end

    notify["ply"] = Nova.convertSteamID(notify["ply"])

    // player already has a pending action
    if pendingActions[notify["ply"]] then
        Nova.log("d", string.format("Player %s already has a pending action: Empty callback", Nova.playerName(notify["ply"])))
        callback(nil)
        return
    end

    local showStaff = Nova.getSetting("menu_notify_showstaff", true)
    local protectedAFK = false

    // first add all protected players to the recipients
    local recipientsStaff = RecipientFilter()
    local recipientsProtected = RecipientFilter()
    for k, v in ipairs(player.GetHumans() or {}) do
        if not IsValid(v) or not v:IsPlayer() then continue end
        if not Nova.isProtected(v) then continue end
        // if we want to show staff, skip afk protected players
        if showStaff and Nova.isAFK(v) then protectedAFK = true end
        recipientsProtected:AddPlayer(v)
    end

    // if no protected players are online/active, add all staff
    if recipientsProtected:GetCount() == 0 and protectedAFK and showStaff then
        for k, v in ipairs(player.GetHumans() or {}) do
            if not IsValid(v) or not v:IsPlayer() then continue end
            if not Nova.isStaff(v) or Nova.isProtected(v) then continue end
            // check that v is not the attacker
            if notify["ply"] == Nova.convertSteamID(v) then continue end
            recipientsStaff:AddPlayer(v)
        end
    end

    local totalStaff = recipientsStaff:GetCount() + recipientsProtected:GetCount()
    // we still have no recipients, abort
    if totalStaff == 0 then
        Nova.log("d", string.format("No recipients found for action %q on player %s: Empty callback", notify["identifier"], Nova.playerName(notify["ply"])))
        callback(nil)
        return
    end

    // get all possible actions
    local options = Nova.getOptions(notify["action_key"])
    if not options or table.IsEmpty(options) then
        Nova.log("e", string.format("No options found for action key %q", notify["action_key"] or "nil"))
        callback(nil)
        return
    end

    // remove 'ask' to prevent loop
    table.RemoveByValue(options, "ask")
    // remove 'notify' because it is unnecessary (the person already got notified by this)
    table.RemoveByValue(options, "notify")

    notify["options"] = options
    notify["message"] = Nova.lang("notify_functions_action", Nova.playerName(notify["ply"]), notify["reason"])
    notify["severity"] = "a"
    notify["timeopen"] = Nova.getSetting("menu_action_timeopen", 60)
    notify["uuid"] = Nova.generateUUID()

    pendingActions[notify["ply"]] = {
        ["callback"] = callback,
        ["actionkey"] = notify["action_key"],
        ["identifier"] = notify["identifier"],
        ["uuid"] = notify["uuid"],
        ["recipientsStaff"] = recipientsStaff,
        ["recipientsProtected"] = recipientsProtected,
    }

    Nova.log("d", string.format("Sending action request for %q to %d player(s) and wait %d seconds", notify["message"], totalStaff, notify["timeopen"]))

    // send the notification to all staff
    net.Start(Nova.netmessage("functions_sendnotify"))
        net.WriteString(util.TableToJSON(notify))
    net.Send(recipientsStaff)

    // if player is protected, add extra options
    table.insert(options, "allow")
    notify["options"] = options

    // send the notification to all protected players
    net.Start(Nova.netmessage("functions_sendnotify"))
        net.WriteString(util.TableToJSON(notify))
    net.Send(recipientsProtected)

    // if notify is not anwered, return empty callback
    timer.Simple(notify["timeopen"], function()
        // check if action was answered, else return empty callback
        if pendingActions[notify["ply"]] and isfunction(pendingActions[notify["ply"]].callback) then
            pendingActions[notify["ply"]].callback(nil)
        end
        pendingActions[notify["ply"]] = nil
    end)
end

hook.Add("nova_init_loaded", "functions_notify", function()
    Nova.log("d", "Creating notify netmessages")
    Nova.netmessage("functions_sendnotify")
    Nova.netmessage("functions_answer_action", "staff")

    Nova.netReceive(Nova.netmessage("functions_answer_action", "staff"), function(len, ply)
        // first of all exclude non staff for security reasons
        if not Nova.isStaff(ply) then return end

        local showStaff = Nova.getSetting("menu_notify_showstaff", true)
        local isStaff = Nova.isStaff(ply)
        local isProtected = Nova.isProtected(ply)

        // if staff is allowed to see the action, but player is not staff, return
        if showStaff and not isStaff then return end

        // if staff is not allowed to see the action, but player is not protected, return
        if not showStaff and not isProtected then return end

        // response is empty, return
        if len == 0 then return end

        // get the response
        local action = net.ReadString() or ""
        local victim = net.ReadString() or ""
        action = string.lower(action)

        // no pending action for this player
        if not pendingActions[victim] then return end

        // prevent endless loops
        if action == "ask" then return end

        // custom action only for protected players
        if action == "allow" and not isProtected then return end

        // log decision
        Nova.log("i", string.format("Admin %s chose %q for detection %q on %s", Nova.playerName(ply), action, pendingActions[victim].identifier or "unknown", Nova.playerName(victim)))

        // notify all staff about the decision
        local humanIdentifier = Nova.lang("config_detection_" .. pendingActions[victim].identifier or "unknown")
        Nova.notify({
            ["severity"] = "i",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_action_notify", Nova.playerName(ply), humanIdentifier, Nova.playerName(victim), action),
            ["ply"] = Nova.convertSteamID(ply),
        }, showStaff and "staff" or "protected")

        // call the callback
        if pendingActions[victim] and isfunction(pendingActions[victim].callback) then
            pendingActions[victim].callback(action, ply)
        end

        // close action on all clients
        // staff
        net.Start(Nova.netmessage("functions_sendnotify"))
            net.WriteString(util.TableToJSON({
                ["uuid"] = pendingActions[victim].uuid,
                ["close"] = true,
            }))
        net.Send(pendingActions[victim].recipientsStaff)

        // protected
        net.Start(Nova.netmessage("functions_sendnotify"))
            net.WriteString(util.TableToJSON({
                ["uuid"] = pendingActions[victim].uuid,
                ["close"] = true,
            }))
        net.Send(pendingActions[victim].recipientsProtected)

        pendingActions[victim] = nil
    end)
end)

// Notify protected and staff about Nova Defender existence
hook.Add("nova_banbypass_cookieloaded", "notify_hello", function(ply)
    local isStaff = Nova.isStaff(ply)
    if not isStaff then return end

    local isProtected = Nova.isProtected(ply)

    local playerAccess = Nova.getSetting("menu_access_player", false)
    local detectionAccess = Nova.getSetting("menu_access_detections", false)
    local banAccess = Nova.getSetting("menu_access_bans", false)
    local healthAccess = Nova.getSetting("menu_access_health", false)
    local inspectionAccess = Nova.getSetting("menu_access_inspection", false)
    local ddosAccess = Nova.extensions["priv_ddos_protection"]["enabled"] and Nova.getSetting("menu_access_ddos", false)
    local menuAccess = playerAccess or detectionAccess or banAccess or healthAccess or inspectionAccess or ddosAccess or isProtected

    local message = "%s %s"
    if isProtected then
        message = string.format(message, Nova.lang("menu_notify_hello_protected"), Nova.lang("menu_notify_hello_menu"))
    elseif isStaff and menuAccess then
        message = string.format(message, Nova.lang("menu_notify_hello_staff"), Nova.lang("menu_notify_hello_menu"))
    elseif isStaff then
        message = string.format(message, Nova.lang("menu_notify_hello_staff"), "")
    end

    Nova.notify({
        ["severity"] = "i",
        ["module"] = "general",
        ["message"] = message,
    }, ply)
end)

concommand.Add("nova_actions", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(pendingActions)
end)