Nova.overrides = Nova.overrides or {}
/*
	Analyze all concommands executed on the server.
    This is done by overriding the concommand.Run function.
    See: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/concommand.lua#L48
*/

if not Nova.overrides["concommand.Run"] then
    Nova.overrides["concommand.Run"] = concommand.Run
    function concommand.Run( ply, command, arguments, argstring, ... )
        if Nova.getSetting("networking_concommand_logging", false) then
            local res, reason = hook.Run("nova_networking_concommand_run", ply, command, arguments, argstring)
            if res == false then
                Msg( string.format("Command blocked by Nova Defender: %q\n", reason or "No reason given") )
                return
            end
        end

        pcall( Nova.overrides["concommand.Run"], ply, command, arguments, argstring, ... )
    end
end

if not Nova.overrides["RunConsoleCommand"] then
    Nova.overrides["RunConsoleCommand"] = RunConsoleCommand
    function RunConsoleCommand( cmd, varargs, ... )
        if Nova.getSetting("networking_concommand_logging", false) then
            local res = hook.Run("nova_networking_runconsolecommand", cmd, varargs)
            if res == false then
                Msg( "Command blocked by Nova Defender\n" )
                return
            end
        end

        pcall( Nova.overrides["RunConsoleCommand"], cmd, varargs, ... )
    end
end

local concommandCounter = {}
local commandTransferLimit = 100
local recentCommandsLimit = 10
local payload = ""

hook.Add("nova_init_loaded", "networking_concomamnds", function()
    Nova.log("d", "Creating concommand logging netmessages")
    Nova.netmessage("networking_log_concommand")

    payload = string.format([[
        local message = %q
        local queue = {}
        local count = 0

        local function check()
            timer.Simple(1, check)
            if count == 0 then return end
            net.Start(message, true)
            net.WriteUInt(table.Count(queue), 8)
            for c, argtable in pairs(queue) do
                net.WriteString(c)
                net.WriteUInt(math.Clamp(argtable.__count, 0, (2^12)-1), 12)
                argtable.__count = nil
                argtable[""] = nil
                net.WriteUInt(table.Count(argtable), 8)
                for arg, _ in pairs(argtable) do
                    net.WriteString(arg)
                end
            end
            net.SendToServer()
            queue, count = {}, 0
        end
        check()

        local function add(c, a)
            c, a = c or "", a or ""

            c = string.sub(c, 1, 20)
            a = string.sub(a, 1, 40)

            if count >= %d then return end
            if a == "__count" then return end

            if not queue[c] then
                queue[c] = {__count = 0}
            end
            
            if not queue[c][a] then
                queue[c][a] = true
                count = count + 1
            end

            queue[c].__count = queue[c].__count + 1
        end

        local ol1 = concommand.Run
        function concommand.Run( p, c, a, as, ... )
            add(c, as)
            pcall(ol1, p, c, a, as, ... )
        end

        local ol2 = RunConsoleCommand
        function RunConsoleCommand( c, a, ... )
            add(c, a)
            pcall(ol2, c, a, ...)
        end
    ]], Nova.netmessage("networking_log_concommand"), commandTransferLimit)

    local function AddCommand(steamID, command, arguments, count)
        local hasArgs = arguments != ""

        // first message from this client
        if not concommandCounter[steamID] then concommandCounter[steamID] = {} end

        // first time the client executed this command
        if not concommandCounter[steamID][command] then
            // if we dont have any arguments, we can just log the count
            // otherwise we have to store the arguments
            concommandCounter[steamID][command] = {total_executions = 1, recent_arguments = hasArgs and {} or nil, last_execution = os.time()}
        // increment the counters
        elseif count then
            concommandCounter[steamID][command].total_executions = concommandCounter[steamID][command].total_executions + count
        end
        // update the last execution time
        concommandCounter[steamID][command].last_execution = os.time()

        if hasArgs then
            // add the arguments to the recent arguments list if it doesnt exist yet
            if not table.HasValue(concommandCounter[steamID][command].recent_arguments, arguments) then
                table.insert(concommandCounter[steamID][command].recent_arguments, 1, arguments)
            end

            // remove the arguments with the lowest count if we have too many
            if table.Count(concommandCounter[steamID][command].recent_arguments) > recentCommandsLimit then
                // remove the last element
                table.remove(concommandCounter[steamID][command].recent_arguments)
            end
        end
    end

    Nova.netReceive(Nova.netmessage("networking_log_concommand"),
        {
            interval = 1,
            time = 1,
            auth = true
        },
    function(len, ply)
        if not Nova.getSetting("networking_concommand_logging", false) then return end

        if len == 0 then return end

        local steamID = ply:SteamID()
        local count = net.ReadUInt(8)

        if count < 1 or count > commandTransferLimit then return end

        for i = 1, count do
            local command = net.ReadString()
            if not command then return end

            // exclude anticheat backup command
            if command == Nova.netmessage("anticheat_detection_concommand") then
                continue
            end

            local executions = net.ReadUInt(12)
            if not executions or executions < 1 then return end

            local argCount = net.ReadUInt(8)
            if not argCount or // nil
                argCount < 0 or // negative
                argCount > count or // impossible
                argCount > commandTransferLimit // too many arguments
            then return end

            if argCount == 0 then
                AddCommand(steamID, command, "", executions)
                hook.Run("nova_networking_onclientcommand", ply, steamID, command, "")
                continue
            end

            for j = 1, argCount do
                local argument = net.ReadString()
                if not argument then return end
                hook.Run("nova_networking_onclientcommand", ply, steamID, command, argument)
                AddCommand(steamID, command, argument)
            end
        end
    end)
end)

Nova.getPlayerCommands = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    return table.Copy(concommandCounter[steamID] or {})
end

hook.Add("nova_base_playerdisconnect", "networking_remove_playerdata_concommand", function(steamID)
    if not steamID then return end

    if Nova.getSetting("networking_concommand_dump", false) then
        Nova.log("d", "Dumping concommands for " .. Nova.playerName(steamID))

        local commands = Nova.getPlayerCommands(steamID)
        local sortedCommands = {}
        local count = 1
        for k, v in pairs(commands or {}) do
            sortedCommands[count] = {
                ["command"] = k,
                ["recent_arguments"] = v.recent_arguments,
                ["total_executions"] = v.total_executions,
                ["last_execution"] = os.date(Nova.config["language_time_short"] or "%H:%M:%S", v.last_execution),
                ["last_execution_unix"] = v.last_execution,
            }
            count = count + 1
        end
        table.SortByMember(sortedCommands or {}, "last_execution_unix", false)

        // sort the commands into subtables of last execution time
        local result = {}
        local lastTime = 0
        for k, v in pairs(sortedCommands or {}) do
            if lastTime != v.last_execution then
                lastTime = v.last_execution
                result[lastTime] = {}
            end
            v["last_execution"] = nil
            v["last_execution_unix"] = nil
            table.insert(result[lastTime], v)
        end

        PrintTable(result)
    end

    Nova.log("d", "Removing concommands from " .. Nova.playerName(steamID))
    concommandCounter[steamID] = nil
end)

hook.Add("nova_networking_playerauthenticated", "networking_send_concommandpayload", function(ply)
    if not payload or payload == "" then
        Nova.log("e", string.format("Could not send concommand payload to %s because it is empty", Nova.playerName(ply)))
        return
    end
    Nova.sendLua(ply, payload, {protected = true, cache = true, reliable = true})
    Nova.log("d", string.format("Sent concommand logging payload to %s", Nova.playerName(ply)))
end)