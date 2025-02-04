local dataTypesSave = {
    ["string"] = tostring,
    ["number"] = tostring,
    ["boolean"] = tostring,
    ["table"] = util.TableToJSON,
}

local dataTypesLoad = {
    ["string"] = tostring,
    ["number"] = tonumber,
    ["boolean"] = tobool,
    ["table"] = util.JSONToTable,
}

// Debug command to resend the data to the client
// lua_run Nova.sendLua(Entity(1), Nova.getMenuPayload(Entity(1))) Nova.sendLua(Entity(1), Nova.getNotifyPayload()) Nova.sendLua(Entity(1),Nova.getInspectionPayload()) Nova.sendLua(Entity(1),Nova.getDDoSPayload())
// Debug command to reload this file
// lua_run hook.GetTable()["nova_init_loaded"]["admin_createnetmessages"]()

// if lua refresh is broken:
// lua_refresh_file nova/modules/admin/menupayloads.lua
// lua_refresh_file nova/modules/custom/extension_ddos_protection.lua

// for bandwith and performance reasons, we compress all data we send to the admin
local function SendDataToClient(ply, data, messageName)
    local dataType = type(data)
    if not dataTypesSave[dataType] then
        Nova.log("e", string.format("Attempted to send invalid data type %q to %s", dataType, Nova.playerName(ply)))
        return
    end
    local convertedValue = dataTypesSave[dataType](data)    // convert
    convertedValue = util.Compress(convertedValue)          // compress
    local compressedSize = string.len(convertedValue)

    net.Start(messageName)
            net.WriteString(dataType)           // type of data being sent
            net.WriteUInt(compressedSize, 16)   // size of compressed data
            net.WriteData(convertedValue)       // compressed data
    net.Send(ply)
end

local function SendClientPayload(ply)
    // player is not staff, return
    if not Nova.isStaff(ply) then return end

    // payload for staff + protected players (notifications)
    Nova.sendLua(ply, Nova.getNotifyPayload(), {reliable = true})
    Nova.log("d", string.format("Sent staff payload to %s", Nova.playerName(ply)))

    // payload for specific groups (configuration menu)
    Nova.sendLua(ply, Nova.getMenuPayload(ply), {reliable = true})
    Nova.log("d", string.format("Sent menu payload to %s", Nova.playerName(ply)))
end

hook.Add("nova_networking_playerauthenticated", "admin_sendpayloads", SendClientPayload)

// if a protected player is added or removed
hook.Add("nova_config_setting_changed", "admin_menucontroller_payloads", function(key, value, oldValue)
    // if key starts with "menu_access_"
    if not string.StartWith(key, "menu_access_") then return end

    // resend payload to all staff
    for k, v in ipairs(player.GetHumans() or {}) do
        // we delay the rescan for each player to distribute the load
        timer.Simple(k * 0.2, function()
            if not IsValid(v) or not v:IsPlayer() then return end
            SendClientPayload(v)
        end)
    end
end)

hook.Add("nova_security_privileges_groupchange", "admin_menucontroller_payloads", function(steamID, oldGroup, newGroup)
    // check if player was removed from protected or staff group completely
    // if so we need to remove the clientside menu
    /*
        {
            ["group"] = userGroup,
            ["isStaff"] = isStaff,
            ["isProtected"] = isProtected,
        }
    */
    // staff -> user
    if oldGroup.isStaff and not newGroup.isStaff then
        SendClientPayload(steamID)
    // user -> staff
    elseif not oldGroup.isStaff and newGroup.isStaff and not newGroup.isProtected then
        SendClientPayload(steamID)
    end
end)



local function StaffCheck(setting, ply)
    local isStaff = Nova.isStaff(ply)
    local isProtected = Nova.isProtected(ply)

    // player is not staff, return false
    if not isStaff then return false end

    // protected is always allowed, return true
    if isProtected then return true end

    // player is staff, but has no access to module, return false
    local staffAccessModule = Nova.getSetting(setting, false)
    if not staffAccessModule then return false end

    return true
end

hook.Add("nova_init_loaded", "admin_createnetmessages", function()
    Nova.log("d", "Creating admin netmessages")
    // precache networkstring as soon as possible
    Nova.netmessage("admin_change_setting", "protected")
    Nova.netmessage("admin_get_setting", "protected")
    // all messages are also allowed for staff
    // if staff is not allowed to access a specific menu by setting, the message will get ignored either way
    Nova.netmessage("admin_get_bans", "staff")
    Nova.netmessage("admin_set_ban", "staff")
    Nova.netmessage("admin_get_language", "staff")
    Nova.netmessage("admin_get_players", "staff")
    Nova.netmessage("admin_get_detections", "staff")
    Nova.netmessage("admin_get_health", "staff")
    Nova.netmessage("admin_get_inspection", "staff")

    /*
        This is called whenever a admin changes a setting in the admin menu.
    */
    Nova.netReceive(Nova.netmessage("admin_change_setting", "protected"), function(len, ply)
        // only protected players can change settings
        if not Nova.isProtected(ply) then return end

        local key = net.ReadString()            // key of the setting to change
        if not key then return end
        local dataType = net.ReadString()       // type of data being sent
        if not dataType then return end
        local dataSize = net.ReadUInt(16)       // size of compressed data
        if not dataSize then return end
        local data = net.ReadData(dataSize)     // compressed data
        if not data then return end
        local rawData = util.Decompress(data)   // decompressed data
        if not rawData then return end

        // datatype not found, return
        if not dataTypesLoad[dataType] then
            Nova.log("e", string.format("Failed to convert setting %q, because datatype %q is not supported", key, dataType))
            return
        end

        local convertedData = dataTypesLoad[dataType](rawData)
        // data could not be converted, return
        if convertedData == nil then
            Nova.log("e", string.format("Failed to convert setting %q to %q", key, tostring(rawData)))
            return
        end

        local res = Nova.setUISetting(key, convertedData)
        // failed to change setting, return
        if res == nil then
            Nova.log("e", string.format("Failed to change setting %q to %q", key, tostring(convertedData)))
            return
        end

        // if raw data is longer than 100 characters, we truncate it with '...' to prevent large logs
        local truncatedData = Nova.truncate(rawData, 100, "...")
        Nova.log("d", string.format("Player %s changed setting %q to %q", Nova.playerName(ply), key, tostring(truncatedData)))
    end)

    /*
        This is called whenever a admin opens the menu for the first time and all avaliable settings are returned
        or if he requests a specific setting.
    */
    Nova.netReceive(Nova.netmessage("admin_get_setting", "protected"), function(len, ply)
        // only protected players can get settings
        if not Nova.isProtected(ply) then return end

        Nova.log("d", string.format("Admin %s requested Nova settings", Nova.playerName(ply)))

        local setting = net.ReadString()
        if not setting or setting == "" or len == 0 then setting = nil end

        // if setting is not set, we receive all available settings
        local result, _ = Nova.getUISetting(setting)

        // failed to get setting, return
        if not result then return end

        SendDataToClient(ply, result, Nova.netmessage("admin_get_setting", "protected"))
    end)

    /*
        This is called when a admin wants to get a list of banned players, filter them or ban/unban a player.
    */
    local ban_actions = {
        ["search"] = function(bans, searchKey, searchValue)
            searchValue = string.lower(searchValue)
            for k, v in pairs(bans or {}) do
                if string.find(string.lower(v[searchKey]), searchValue) == nil then
                    bans[k] = nil
                end
            end
            return bans
        end,
        ["unban"] = function(bans, steamid, _, ply)
            Nova.unbanPlayer(steamid)
            Nova.log("i", string.format("Admin %s unbanned %s via menu", Nova.playerName(ply), Nova.playerName(steamid)))
            Nova.notify({
                ["severity"] = "s",
                ["module"] = "menu",
                ["message"] = Nova.lang("notify_admin_unban", Nova.playerName(steamid)),
            }, ply)
            return bans
        end,
        ["ban"] = function(bans, steamid, comment, ply)
            Nova.banPlayer(steamid, nil, string.format("Banned by %s | Comment: %q", Nova.playerName(ply), comment), "admin_manual")
            Nova.log("i", string.format("Admin %s banned %s via menu", Nova.playerName(ply), Nova.playerName(steamid)))
            Nova.notify({
                ["severity"] = "s",
                ["module"] = "menu",
                ["message"] = Nova.lang("notify_admin_ban", Nova.playerName(steamid)),
            }, ply)
            return bans
        end,
    }

    Nova.netReceive(Nova.netmessage("admin_get_bans", "staff"), function(len, ply)
        // specific permission check
        if not StaffCheck("menu_access_bans", ply) then return end

        local filteredBans = Nova.getAllBans()
        if not filteredBans then return end

        // Step 1: Prefilter
        for k, v in pairs(filteredBans or {}) do
            // Step 1.1: Simplify ban status
            if v.unban_on_sight == 1 then v.status = "unban_on_sight"
            elseif v.ban_on_sight == 1 then v.status = "ban_on_sight"
            else v.status = "banned" end
            v.status = Nova.lang(v.status)

            // Step 1.2 Remove unnecessary data
            v["unban_on_sight"] = nil
            v["ban_on_sight"] = nil
            v["is_banned"] = nil
            v["_temp_secret_convar"] = nil
            v["secret_key"] = nil
            v["fingerprint"] = nil

            // Step 1.3: Convert UNIX timestamps to human readable
            v.unix = v.time
            v.time = os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", v.time)

            // Step 1.4: Translate internal reason
            v.internal_reason = Nova.lang("config_detection_" .. v.internal_reason)
        end

        local args = len == 0 and {} or (util.JSONToTable(net.ReadString()) or {})

        // Step 2: Filter the bans
        for k, v in pairs(args or {}) do
            local searchMode = k
            if not ban_actions[searchMode] then continue end
            for i = 1, #v do
                local searchKey = v[i].k
                local searchValue = v[i].v

                filteredBans = ban_actions[searchMode](filteredBans, searchKey, searchValue, ply)
            end
        end

        // Step 3: Limit number of results
        local limit = 150
        if table.Count(filteredBans) > limit then
            local tableKeys = table.GetKeys(filteredBans)
            for i = limit + 1, #tableKeys do
                filteredBans[tableKeys[i]] = nil
            end
        end

        // Step 4: Send the bans to the client
        SendDataToClient(ply, filteredBans, Nova.netmessage("admin_get_bans", "staff"))
    end)

    /*
        This is called whenever a admin requests language.
    */
    Nova.netReceive(Nova.netmessage("admin_get_language", "staff"), function(len, ply)
        // only staff players can get settings
        if not Nova.isStaff(ply) then return end

        SendDataToClient(ply, Nova.config["language"], Nova.netmessage("admin_get_language", "staff"))
    end)

    /*
        This is called whenever a admin requests a list of all players, kick/ban or inspect them.
    */
    local player_actions = {
        ["ban"] = function(ply, args)
            local steamID = args.steamID
            local reason = args.reason
            local comment = args.comment
            if not steamID or not reason or not comment then return end
            Nova.banPlayer(steamID, reason, string.format("Banned by %s | Comment: %q", Nova.playerName(ply), comment), "admin_manual")
            Nova.log("i", string.format("Admin %s banned %s via menu", Nova.playerName(ply), Nova.playerName(steamID)))
            Nova.notify({
                ["severity"] = "i",
                ["module"] = "menu",
                ["message"] = Nova.lang("notify_admin_ban_online", Nova.playerName(ply), Nova.playerName(steamID)),
            })
            return {}
        end,
        ["kick"] = function(ply, args)
            local steamID = args.steamID
            local reason = args.reason
            if not steamID or not reason then return end
            Nova.kickPlayer(steamID, reason, "admin_manual")
            Nova.log("i", string.format("Admin %s kicked %s via menu", Nova.playerName(ply), Nova.playerName(steamID)))
            Nova.notify({
                ["severity"] = "i",
                ["module"] = "menu",
                ["message"] = Nova.lang("notify_admin_kick", Nova.playerName(ply), Nova.playerName(steamID)),
            })
            return {}
        end,
        ["reconnect"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local target = Nova.fPlayerBySteamID(steamID)
            if not IsValid(target) or not target:IsPlayer() then return end
            target:ConCommand("retry")
            Nova.log("i", string.format("Admin %s reconnected %s via menu", Nova.playerName(ply), Nova.playerName(steamID)))
            Nova.notify({
                ["severity"] = "i",
                ["module"] = "menu",
                ["message"] = Nova.lang("notify_admin_reconnect", Nova.playerName(ply), Nova.playerName(steamID)),
            })
            return {}
        end,
        ["quarantine"] = function(ply, args)
            local steamID = args.steamID
            local quarantine = args.quarantine
            if not steamID or quarantine == nil then return end
            Nova.setQuarantine(steamID, quarantine)
            Nova.log("i",
                string.format(quarantine and "Admin %s set %s to network quarantine" or "Admin %s removed %s from network quarantine",
                Nova.playerName(ply),
                Nova.playerName(steamID))
            )
            Nova.notify({
                ["severity"] = "i",
                ["module"] = "menu",
                ["message"] = Nova.lang(quarantine and "notify_admin_quarantine" or "notify_admin_unquarantine",
                    Nova.playerName(ply),
                    Nova.playerName(steamID)
                ),
            })
            return {}
        end,
        ["netmessages"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            return Nova.getPlayerNetmessages(steamID) or {}
        end,
        ["commands"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local commands = Nova.getPlayerCommands(steamID) or {}
            //last_execution
            local result = {}
            local count = 1
            for k, v in pairs(commands or {}) do
                result[count] = {
                    ["command"] = k,
                    ["recent_arguments"] = v.recent_arguments,
                    ["total_executions"] = v.total_executions,
                    ["last_execution"] = os.date(Nova.config["language_time_short"] or "%H:%M:%S", v.last_execution),
                    ["last_execution_unix"] = v.last_execution,
                }
                count = count + 1
            end
            return result
        end,
        ["detections"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local detections, _ = Nova.getPlayerDetections(steamID)
            local result = {}
            local count = 1
            for k, v in pairs(detections or {}) do
                result[count] = {
                    ["identifier"] = v.identifier,
                    ["description"] = v.description,
                    ["time"] = os.date(Nova.config["language_time_short"] or "%H:%M:%S", v.time),
                    ["time_unix"] = v.time,
                }
                count = count + 1
            end
            return result or {}
        end,
        ["ip"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local canSeeIP = Nova.getSetting("menu_access_staffseeip", false)
            if not canSeeIP and not Nova.isProtected(ply) then
                // only protected players can request this
                // or staff has specific access
                return {}
            end

            local target = Nova.fPlayerBySteamID(steamID)
            if not IsValid(target) or not target:IsPlayer() then return end
            // first check if we already hav this ip cached
            local cachedValue = Nova.getCachedVPNInfo(target)
            if cachedValue then return cachedValue end

            local ip = Nova.extractIP(target:IPAddress(), false)
            if not ip then
                Nova.log("e", string.format("Invalid IP address for VPN-Lookup: %q", tostring(target:IPAddress() or "EMPTY")))
                Nova.notify({
                    ["severity"] = "e",
                    ["module"] = "VPN",
                    ["message"] = string.format("Invalid IP address for VPN-Lookup: %q", tostring(target:IPAddress() or "EMPTY")),
                    ["ply"] = steamID,
                }, ply)
                return {}
            end

            Nova.queryIPScore(ip, target, function(data)
                if not data or not data.success then data = {} end
                SendDataToClient(ply, data, Nova.netmessage("admin_get_players", "staff"))
            end)

            return "hold" // messy way to delay the api response
        end,
        ["verify_ac"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local target = Nova.fPlayerBySteamID(steamID)
            if not IsValid(target) or not target:IsPlayer() then return end
            Nova.verifyAnticheat(target, function(result)
                SendDataToClient(ply, {["Status"] = result or "unknown"}, Nova.netmessage("admin_get_players", "staff"))
            end)

            return "hold" // messy way to delay the api response
        end,
        ["indicators"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local target = Nova.fPlayerBySteamID(steamID)
            if not IsValid(target) or not target:IsPlayer() then return end
            return Nova.getIndicators(target) or {}
        end,
        ["screenshot"] = function(ply, args)
            local steamID = args.steamID
            if not steamID then return end
            local target = Nova.fPlayerBySteamID(steamID)
            if not IsValid(target) or not target:IsPlayer() then return end
            Nova.takeScreenshot(target, ply)
            return {}
        end,
    }
    Nova.netReceive(Nova.netmessage("admin_get_players", "staff"), function(len, ply)
        // specific permission check
        if not StaffCheck("menu_access_player", ply) then return end

        local args = len == 0 and {} or (util.JSONToTable(net.ReadString()) or {})

        local plySteamID = ply:SteamID()
        local isProtected = Nova.isProtected(ply)

        local action = args.action
        local steamID = args.steamID

        // Option 1: Player wants detailed information about a player
        if type(action) == "string" and action != "" and type(steamID) == "string" and steamID != "" then
            if not player_actions[action] then return end

            // check permission for this action
            if not Nova.canTouch(plySteamID, steamID) then
                Nova.notify({
                    ["severity"] = "e",
                    ["module"] = "menu",
                    ["message"] = Nova.lang("notify_admin_no_permission"),
                }, ply)
                return {}
            end

            local res = player_actions[action](ply, args)
            if res == "hold" then return end
            SendDataToClient(ply, res, Nova.netmessage("admin_get_players", "staff"))
            return
        end

        // Option 2: Player requests a list of all players
        local players = {}
        local canSeeIP = isProtected or Nova.getSetting("menu_access_staffseeip", false)
        for k, v in ipairs(player.GetHumans() or {}) do
            local permission, index = Nova.getPlayerPermission(v)
            local canTouch = Nova.canTouch(ply, v)
            players[k] = {
                ["steamid"] = Nova.convertSteamID(v),
                ["authed"] = Nova.isPlayerAuthenticated(v),
                ["ip"] =  canTouch and canSeeIP and (Nova.extractIP(v:IPAddress()) or Nova.lang("menu_elem_unavailable")) or nil,
                ["family"] = canTouch and Nova.isFamilyShared(v) or false,
                ["familyowner"] = canTouch and Nova.getFamilyOwner(v) or false,
                ["permission"] = permission,
                ["indicators"] = canTouch and Nova.getIndicators(v) or nil,
                ["vpn"] = canTouch and Nova.hasVPN(v) or false,
                ["numdetections"] = canTouch and select(2, Nova.getPlayerDetections(v)) or 0,
                ["quarantine"] = canTouch and Nova.isQuarantined(v) or false,
                ["index"] = index,
            }
        end

        SendDataToClient(ply, players, Nova.netmessage("admin_get_players", "staff"))
    end)

    /*
        This is called whenever a admin requests a list of all detections.
    */
    local detection_actions = {
        ["ban"] = function(ply, args)
            local id = args.id
            local steamID = args.steamID
            if not id then return end
            Nova.treatDetection(id, steamID, ply, function(res, message)
                if not res then
                    Nova.notify({
                        ["severity"] = "e",
                        ["module"] = "menu",
                        ["message"] = Nova.lang("notify_admin_ban_fail", Nova.playerName(steamID), message),
                    }, ply)
                else
                    Nova.notify({
                        ["severity"] = "i",
                        ["module"] = "menu",
                        ["message"] = Nova.lang("notify_admin_ban_offline", Nova.playerName(ply), Nova.playerName(steamID)),
                    })
                end
            end)
            return {}
        end,
        ["delete"] = function(ply, args)
            Nova.query("DELETE FROM `nova_detections` WHERE action_taken = 1;")
            return {}
        end,
        ["delete_id"] = function(ply, args)
            local id = args.id
            if not id then return end
            id = Nova.sqlEscape(id)
            Nova.query(string.format("DELETE FROM `nova_detections` WHERE id = %s;", id))
            return {}
        end,
        ["delete_all"] = function(ply, args)
            Nova.query("DELETE FROM `nova_detections`;")
            return {}
        end,
    }
    Nova.netReceive(Nova.netmessage("admin_get_detections", "staff"), function(len, ply)
        local numEntries = 10

        // specific permission check
        if not StaffCheck("menu_access_detections", ply) then return end

        local args = len == 0 and {} or (util.JSONToTable(net.ReadString()) or {})

        local action = args.action
        local page = args.page or 0

        // Option 1: Player wants detailed information about a player
        if type(action) == "string" and action != "" then
            if not detection_actions[action] then return end
            local res = detection_actions[action](ply, args)
            SendDataToClient(ply, res, Nova.netmessage("admin_get_players", "staff"))
            return
        end

        // Check for filters
        local filter = ""
        if args.steamid and args.steamid != "" then
            local sid = Nova.convertSteamID(args.steamid)
            sid = sid == ""
                and ("%" .. args.steamid .. "%")
                or ("%" .. sid .. "%")
            sid = Nova.sqlEscape(sid)
            filter = "WHERE steamid LIKE " .. sid
        end

        // Option 2: Player requests a list of all detections
        local query = string.format([[
            SELECT 
                *, 
                (SELECT COUNT(*) FROM `nova_detections` %s) AS total_entries
            FROM `nova_detections`
            %s
            ORDER BY time DESC
            LIMIT %s, %s;]],
            filter, filter, page * numEntries, numEntries)
        local detections = {
            ["page"] = page,
            ["numEntries"] = numEntries,
            ["detections"] = {}
        }

        Nova.selectQuery(query, function(data)
            data = data or {}
            for k, v in ipairs(data or {}) do
                detections.totalEntries = v.total_entries
                detections.detections[k] = {
                    ["id"] = v.id,
                    ["steamid"] = v.steamid or "",
                    ["comment"] = v.comment or "",
                    ["reason"] = v.reason or "",
                    ["internal_reason"] = v.internal_reason or "",
                    ["time"] = os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", v.time),
                    ["action_taken"] = tostring(v.action_taken) == "1" and true or false,
                    ["action_taken_at"] = os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", v.action_taken_at),
                    ["action_taken_by"] = v.action_taken_by == "" and "CONSOLE" or v.action_taken_by,
                }
            end
            SendDataToClient(ply, detections, Nova.netmessage("admin_get_detections", "staff"))
        end)
    end)

    /*
        This is called whenever a admin requests the health of the server.
    */
    local health_actions = {
        ["add"] = function(ply, id)
            if not id or id == "" then return end
            local ignoreList = Nova.getSetting("security_health_ignorelist", {})
            ignoreList[id] = true
            Nova.setSetting("security_health_ignorelist", ignoreList)
            Nova.log("i", string.format("Admin %s added health check %q to ignore list", Nova.playerName(ply), Nova.lang(id)))
        end,
        ["reset"] = function(ply)
            Nova.setSetting("security_health_ignorelist", {})
            Nova.log("i", string.format("Admin %s reset the ignore list for health checks", Nova.playerName(ply)))
        end,
    }
    Nova.netReceive(Nova.netmessage("admin_get_health", "staff"), function(len, ply)
        // specific permission check
        if not StaffCheck("menu_access_health", ply) then return end

        local args = len == 0 and {} or (util.JSONToTable(net.ReadString()) or {})
        local id = args.id
        local action = args.action

        // Option: Player wants to ignore a health check or clear the ignore list
        if type(action) == "string" and action != "" then
            if not health_actions[action] then return end
            health_actions[action](ply, id)
        end

        local health = Nova.getHealthCheckResult() or {}
        SendDataToClient(ply, health, Nova.netmessage("admin_get_health", "staff"))
    end)

    /*
        Logic of the inspection feature
    */
    Nova.netReceive(Nova.netmessage("admin_get_inspection", "staff"), function(len, ply)
        // specific permission check
        if not StaffCheck("menu_access_inspection", ply) then
            // TODO
            return
        end

        // if no data is sent, we first sent the inspection payload
        if len == 0 then
            Nova.sendLua(ply, Nova.getInspectionPayload())
            return
        end

        local action = net.ReadString() or ""
        Nova.inspectionRequest(ply, action)
    end)

    /*
        This is called whenever a admin opens the menu.
        Returns a list of all extensions and their versions.
    */
    Nova.netReceive(Nova.netmessage("admin_get_status", "staff"), function(len, ply)
        // only staff players can get settings
        if not Nova.isStaff(ply) then return end

        local isProtected = Nova.isProtected(ply)

        local status = {
            ["extensions"] = Nova.extensions,
            ["version"] = Nova.version,
            ["uid"] = isProtected and Nova.getSetting("uid", "ERROR") or "",
        }

        if isfunction(Nova.getDDoSStatus) then
            local ddosStatus = Nova.getDDoSStatus()
            if ddosStatus then
                status["ddos"] = ddosStatus
            end
        end

        SendDataToClient(ply, status, Nova.netmessage("admin_get_status", "staff"))
    end)

    /*
        Logic of the ddos feature
    */
    Nova.netReceive(Nova.netmessage("admin_get_ddos", "staff"), function(len, ply)
        // specific permission check
        if not StaffCheck("menu_access_ddos", ply) then
            // TODO
            return
        end

        if not Nova.extensions["priv_ddos_protection"]["enabled"] or not isfunction(Nova.getDDoSPayload) then
            Nova.log("e", string.format("Player %s requested DDoS payload, but the extension is not enabled on this server", Nova.playerName(ply)))
            return
        end

        // if no data is sent, we first sent the inspection payload
        Nova.sendLua(ply, Nova.getDDoSPayload())
    end)
end)