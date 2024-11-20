/*
    Collection of console commands. Those can be used within your server console or by other scripts.
    Every command can only be executed by the server itself, not a player.
*/

local commands = {}
local categories = {"Help", "Ban", "Privileges", "Server", "Detections"}

local function CanExecuteCommand(ply)
    local isConsole = ply == NULL
    if isConsole then return true end

    local isProtected = Nova.isProtected(ply)
    if isProtected then return true end

    // return false by default
    return false
end

local function BuildArgs(cmd)
    local arg = ""
    if cmd.arguments then
        for _, argument in ipairs(cmd.arguments or {}) do
            arg = string.format("%s <%s>", arg, argument.name)
        end
    end
    return arg
end

local function PrintHelp(command)
    // print the help for specific command
    if command and commands[command] then
        print(commands[command].description)
        if not commands[command].arguments then
            print("   No arguments")
        else
            print(string.format("   Usage: %s%s", command, BuildArgs(commands[command])))
            for _, argument in ipairs(commands[command].arguments or {}) do
                print(string.format("       %s - %s", argument.name, argument.description))
            end
        end
    // print the help for all commands
    else
        // print general information about nova defender
        print(string.format("Nova Defender v%s", Nova.version))
        for _, category in ipairs(categories or {}) do
            print(string.format("\nCategory: %s", category))
            // search all commands for the current category
            for k, v in pairs(commands or {}) do
                if v.category == category then
                    print(string.format("    %s%s - %s", k, BuildArgs(v), v.description))
                end
            end
        end
    end
end

commands = {
    ["help"] = {
        ["category"] = "Help",
        ["description"] = "Obviously prints this help message",
        ["callback"] = function(admin) PrintHelp() end,
    },
    ["ban"] = {
        ["category"] = "Ban",
        ["description"] = "Bans a player from the server",
        ["arguments"] = {
           {
                ["name"] = "SteamID",
                ["description"] = "SteamID32 or SteamID64 IN QUOTES of the player to ban",
                ["validator"] = function(steamID)
                    local converted = Nova.convertSteamID(steamID) or ""
                    if converted == "" then print("Invalid SteamID, forgot quotes?") return end
                    return converted
                end
           },
           {
            ["name"] = "Comment",
                ["description"] = "Internal comment for the ban. (Only visible for admins)",
                ["validator"] = function(comment)
                    if comment and comment != "" and string.len(comment) <= 255 then
                        return comment
                    end
                    return
                end
            },
        },
        ["callback"] = function(admin, steamID, comment)
            Nova.banPlayer(steamID, nil, string.format("Banned by %s | Comment: %q", Nova.playerName(admin), comment), "admin_manual")
            Nova.log("i", string.format("%s banned %s via console", Nova.playerName(admin), Nova.playerName(steamID)))
        end,
    },
    ["unban"] = {
        ["category"] = "Ban",
        ["description"] = "Unbans a player from the server",
        ["arguments"] = {
           {
                ["name"] = "SteamID",
                ["description"] = "SteamID32 or SteamID64 IN QUOTES of the player to unban",
                ["validator"] = function(steamID)
                    local converted = Nova.convertSteamID(steamID) or ""
                    if converted == "" then print("Invalid SteamID, forgot quotes?") return end
                    return converted
                end
           },
        },
        ["callback"] = function(admin, steamID)
            Nova.unbanPlayer(steamID)
            Nova.log("i", string.format("%s unbanned %s via console", Nova.playerName(admin), Nova.playerName(steamID)))
        end,
    },
    ["checkban"] = {
        ["category"] = "Ban",
        ["description"] = "Checks if a player is banned",
        ["arguments"] = {
           {
                ["name"] = "SteamID",
                ["description"] = "SteamID32 or SteamID64 IN QUOTES of the player to check",
                ["validator"] = function(steamID)
                    local converted = Nova.convertSteamID(steamID) or ""
                    if converted == "" then print("Invalid SteamID, forgot quotes?") return end
                    return converted
                end
           },
        },
        ["callback"] = function(admin, steamID)
            local allBans = Nova.getAllBans()
            if not allBans[steamID] then
                print(string.format("Player %q is not banned", steamID))
                return
            end
            local ban = allBans[steamID]
            local status = ""
            if ban.unban_on_sight == 1 then status = "Unban on sight"
            elseif ban.ban_on_sight == 1 then status = "Ban on sight"
            else status = "Banned" end
            print(string.format(
            "SteamID:\t\t\t%s\nStatus:\t\t\t%s\nReason:\t\t\t%s\nInternal comment:\t%s\nBanned by:\t\t%s\nTime:\t\t\t%s\nIP:\t\t\t\t%s",
            steamID, status, ban.reason, ban.comment, ban.admin or "CONSOLE", os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", ban.time), ban.ip == "" and "Unknown" or ban.ip
            ))
        end,
    },
    ["remove"] = {
        ["category"] = "Privileges",
        ["description"] = "Removes protected status from a player",
        ["arguments"] = {
           {
                ["name"] = "SteamID",
                ["description"] = "SteamID32 or SteamID64 IN QUOTES of the player",
                ["validator"] = function(steamID)
                    local converted = Nova.convertSteamID(steamID) or ""
                    if converted == "" then print("Invalid SteamID, forgot quotes?") return end
                    return converted
                end
           },
        },
        ["callback"] = function(admin, steamID)
            local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
            if not protectedPlayers[steamID] then
                print(string.format("Player %q is not protected", steamID))
                return
            end
            protectedPlayers[steamID] = nil
            Nova.setSetting("security_privileges_group_protection_protected_players", protectedPlayers)
            Nova.log("i", string.format("%s removed protected status from %s via console", Nova.playerName(admin), Nova.playerName(steamID)))
        end,
    },
    ["add"] = {
        ["category"] = "Privileges",
        ["description"] = "Adds player to protected status",
        ["arguments"] = {
           {
                ["name"] = "SteamID",
                ["description"] = "SteamID32 or SteamID64 IN QUOTES of the player",
                ["validator"] = function(steamID)
                    local converted = Nova.convertSteamID(steamID) or ""
                    if converted == "" then print("Invalid SteamID, forgot quotes?") return end
                    return converted
                end
           },
           {
                ["name"] = "Group",
                ["description"] = "Name of usergroup (e.g. superadmin, admin, ...)",
                ["validator"] = function(group)
                    if not table.HasValue(Nova.getSetting("security_permissions_groups_protected", {}), group) then
                        print("Group is not protected")
                        return
                    end
                    return group
                end
            },
            {
                ["name"] = "Comment",
                ["description"] = "Name of player or notes",
                ["validator"] = function(comment)
                    if comment and comment != "" and string.len(comment) <= 255 then
                        return comment
                    end
                    return
                end
            },
        },
        ["callback"] = function(admin, steamID, group, comment)
            local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
            if protectedPlayers[steamID] then
                print("Player is already protected")
                return
            end
            protectedPlayers[steamID] = {
                ["group"] = group,
                ["comment"] = comment,
                ["steamid"] = steamID,
            }
            Nova.setSetting("security_privileges_group_protection_protected_players", protectedPlayers)
            Nova.log("i", string.format("%s added protected status to %s via console", Nova.playerName(admin), Nova.playerName(steamID)))
        end,
    },
    ["list"] = {
        ["category"] = "Privileges",
        ["description"] = "List all protected players.",
        ["callback"] = function(admin)
            local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
            if table.IsEmpty(protectedPlayers) then
                print("No protected players found")
                return
            end
            PrintTable(protectedPlayers or {})
        end,
    },
    //TODO: implement
    /*["status"] = {
        ["category"] = "Server",
        ["description"] = "Prints the current status of Nova Defender",
        ["callback"] = function(admin)
            // players online (+ detections)
            // health of the server
            // bans last 24h 7days
            // bans total
        end,
    },*/
    ["detections"] = {
        ["category"] = "Detections",
        ["description"] = "List last 10 detections",
        ["callback"] = function(admin)
            local query = string.format([[
                SELECT *
                    FROM `nova_detections`
                    ORDER BY time DESC
                    LIMIT %d;
                ]], 10)
            local detections = {}

            Nova.selectQuery(query, function(data)
                data = data or {}
                for k, v in ipairs(data or {}) do
                    detections[k] = {
                        ["number"] = k,
                        ["steamid"] = v.steamid or "",
                        ["comment"] = v.comment or "",
                        ["reason"] = v.reason or "",
                        ["time"] = os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", v.time),
                        ["action_taken"] = tostring(v.action_taken) == "1" and "yes" or "no",
                        ["action_taken_at"] = os.date(Nova.config["language_time"] or "%d.%m.%Y %H:%M:%S", v.action_taken_at),
                        ["action_taken_by"] = v.action_taken_by == "" and "CONSOLE" or v.action_taken_by,
                    }
                    if detections[k]["action_taken"] == "no" then
                        detections[k]["action_taken_at"] = nil
                        detections[k]["action_taken_by"] = nil
                    end
                end
                // check if we have any detections
                if table.IsEmpty(detections) then
                    print("No detections found")
                    return
                end
                for k, v in ipairs(detections or {}) do
                    print(string.format(
                        "SteamID:\t\t\t%s\nComment:\t\t\t%s\nReason:\t\t\t%s\nTime:\t\t\t%s\nAction taken:\t\t%s\nAction taken at:\t\t%s\nAction taken by:\t\t%s\n",
                        v.steamid, v.comment, v.reason, v.time, v.action_taken, v.action_taken_at or "N/A", v.action_taken_by or "N/A"
                    ))
                end
            end)
        end,
    },
    ["maintenance"] = {
        ["category"] = "Server",
        ["description"] = "Toggles maintenance mode",
        ["callback"] = function(admin)
            local maintenance = Nova.getSetting("server_access_maintenance_enabled", false)
            // toggle maintenance mode
            maintenance = not maintenance
            Nova.setSetting("server_access_maintenance_enabled", maintenance)
            Nova.log("i", string.format("%s toggled maintenance mode via console: %s", Nova.playerName(admin), maintenance and "on" or "off"))
            // if we turned on maintenance mode, show the password
            if maintenance then
                local allowed = Nova.getSetting("server_access_maintenance_allowed", "protected")
                if allowed == "protected only" then
                    Nova.log("i", "Maintenance mode is protected only, only protected players can join")
                elseif allowed == "password" then
                    Nova.log("i", string.format("Maintenance mode is password protected, password is %q", Nova.getSetting("server_access_maintenance_password", "")))
                end
            end
        end,
    },
    ["lockdown"] = {
        ["category"] = "Server",
        ["description"] = "Toggles lockdown mode",
        ["callback"] = function(admin)
            local lockdown = Nova.getSetting("server_lockdown_enabled", false)
            Nova.setSetting("server_lockdown_enabled", not lockdown)
            Nova.log("i", string.format("%s toggled lockdown mode via console: %s", Nova.playerName(admin), lockdown and "off" or "on"))
        end,
    },
}

concommand.Add("nova", function(ply, cmd, args)
    if not CanExecuteCommand(ply) then return end

    // no arguments given
    if not args or not args[1] then
        PrintHelp()
        return
    end

    // argument is not a valid command
    if not commands[args[1]] then
        PrintHelp()
        return
    end

    // get the command
    local command = commands[args[1]]
    if not command or not command["callback"] then return end

    // command has not additional arguments
    if not command["arguments"] then
        command["callback"](ply)
        return
    end

    // command has additional arguments
    local arguments = {}

    // check if all arguments are valid
    for i = 1, table.Count(command["arguments"]) do
        if not args[i + 1] then
            Nova.log("w", string.format("Missing argument %q", command["arguments"][i]["name"]))
            PrintHelp(args[1])
            return
        end
        local validator = command["arguments"][i]["validator"]
        if validator then
            local valid = validator(args[i + 1])
            if not valid then
                Nova.log("w", string.format("Invalid argument %q", command["arguments"][i]["name"]))
                PrintHelp(args[1])
                return
            end
            table.insert(arguments, valid)
        else
            table.insert(arguments, args[i + 1])
        end
    end

    // execute the command
    command["callback"](ply, unpack(arguments))
end, nil, "Nova Defender console commands. Type 'nova help' for a list of commands.")