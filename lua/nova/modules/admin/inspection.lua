
local encryptionKey = Nova.generateString(16, 32)
local sessions = {}
local clientSessionLookup = {}

/*
Structure of sessions:

["adminSteamID32"] = {
    ["clientSteamID"] = "STEAM_0:0:00000000",
    ["adminSteamID"] = "STEAM_0:0:00000000",
    ["client"] = client,
    ["admin"] = admin,
    ["status"] = {
        ["fps"] = 123,
        ["ping"] = 123,
        ["ram"] = 123,
        ["connected"] = true/false,
        ["activated"] = false (player has to send ack first)
    }
    ["queue"] = {
        ["id"] = callback function,
    },
}
*/

local inspectionPayload = [[
    local seed, mod = 0, 2 ^ 32
    local bls = bit.lshift
    local brs = bit.rshift
    local function blr(x, disp) return bls(x, disp) + brs(x, 32 - disp) end
    local function brr(x, disp) return brs(x, disp) + bls(x, 32 - disp) end
    local function xrshft() seed = blr(seed, 13) + brr(seed, 17) + blr(seed, 5) + seed return seed %% 256 end
    local timer_s = timer.Simple
    local ttj = util.TableToJSON
    local averageFPS = 0

    local function enc(input)
        seed = tonumber(string.upper(string.sub(util.SHA1(%q), 1, 8)),16) %% mod
        local out = {}
        for i = 1, string.len(input) do
            local b = string.byte(input, i)
            local c = xrshft()
            local e = bit.bxor(c, b)
            out[i] = string.char(e)
        end
        return table.concat(out)
    end

    local nm = %q
    local function Return(id, data)
        net.Start(nm)
            net.WriteString(id)
            local compressed = util.Compress(data)
            local enc = enc(util.Compress(data))
            net.WriteData(enc, string.len(enc))
        net.SendToServer()
    end
    local closed = false
    local function Status()
        if closed then return end
        timer_s(]] .. math.random(2,3) .. [[, Status)
        local status = {
            fps = math.Round(averageFPS),
            ram = collectgarbage("count"),
            focus = system.HasFocus(),
        }
        Return("status", ttj(status))
    end
    Status()

    local fpsTable = {}
    local function CalcAverageFPS()
        local fps = 1 / RealFrameTime()
        if system.HasFocus() then table.insert( fpsTable, fps ) end
        if #fpsTable > 10 then table.remove( fpsTable, 1 ) end
        local sum = 0
        for k, v in pairs( fpsTable ) do sum = sum + v end
        averageFPS = sum / #fpsTable
    end
    local thinkHook = %q
    hook.Add("Think", thinkHook, CalcAverageFPS)

    local function _PrintTable( t, indent, done )
        if not indent then indent = 0 end
        local ret = ""
        if not done then done = {} end
        local lIndent = string.rep( "\t", indent or 0 )
        if type( t ) == "table" then
            ret = ret .. lIndent .. tostring( t ) .. " {\n"
            if not done[ t ] then
                done[ t ] = true
                for key, value in pairs( t ) do
                    ret = ret .. lIndent .. "\t" .. tostring( key ) .. " = "
                    ret = ret .. _PrintTable( value, indent and ( indent + 1 ) or nil, done ) .. "\n"
                end
            end
            ret = ret .. lIndent .. "}"
        else
            ret = ret .. lIndent .. tostring( t )
        end

        return ret
    end

    local function Truncate(text, maxLength, append)
        if not text then return "" end
        if not maxLength then return text end
        append = append or ""
        if string.len(text) <= maxLength then return text end
        return string.sub(text, 1, maxLength - string.len(append)) .. append
    end

    local actions = {
        ["open"] = function(id)
            Return("ack", "ack")
        end,
        ["close"] = function(id)
            net.Receivers[nm] = nil
            closed = true
            Status = function() end
            hook.Remove("Think", thinkHook)
        end,
        ["exec"] = function(id)
            local command = net.ReadString()
            if not command then return end
            local oldPrint = print
            local oldPrintTable = PrintTable
            local printOutput = {}
            print = function(...)
                local args = {...}
                for k, v in ipairs(args) do args[k] = tostring(v) end
                table.insert(printOutput, table.concat(args, " "))
            end
            PrintTable = function(t)
                table.insert(printOutput, _PrintTable(t))
            end
            local err = RunString(command, nil, false)
            local response
            if err then response = err
            elseif table.Count(printOutput) == 0 then response = "Executed"
            else response = table.concat(printOutput, "\n") end
            -- cap response size
            response = Truncate(response, 64000, "\n\n[...]")
            local res = {err and "err" or "scc", response}
            Return(id, ttj(res))
            print = oldPrint
            PrintTable = oldPrintTable
        end,
        ["open_folder"] = function(id)
            local folder = net.ReadString()
            if not folder then return end
            local fi, fo = file.Find(folder .. "*", "BASE_PATH")
            Return(id, ttj({path = folder, files = fi, folders = fo}))
        end,
        ["open_file"] = function(id)
            local _file = net.ReadString()
            local res = {
                path = _file,
                size = 0,
                time = 0,
                content = "",
                err = false,
            }
            if not _file then return end
            if not file.Exists(_file, "BASE_PATH") then
                res.err = "file not found"
                Return(id, ttj(res))
                return
            end
            local fileSize = file.Size(_file, "BASE_PATH")
            local fileTime = file.Time(_file, "BASE_PATH")
            res.size = fileSize
            res.time = fileTime
            if fileSize > 100000 then
                res.err = "file too big, consider downloading it"
                Return(id, ttj(res))
                return
            end
            local content = file.Read(_file, "BASE_PATH")
            local compressed = util.Compress(content)
            if string.len(compressed) > 65535 then
                res.err = "file too big, consider downloading it"
                Return(id, ttj(res))
                return
            end
            res.content = content
            Return(id, ttj(res))
        end,
        ["download_file"] = function(id)
            local _file = net.ReadString()
            local chunk = tonumber(net.ReadString())
            local res = {
                cur = 0,
                total = 1,
                content = "",
                err = false,
            }
            if not file.Exists(_file, "BASE_PATH") then
                res.err = "file not found"
                Return(id, ttj(res))
                return
            end
            local chunkSize = 40000
            local fileSize = file.Size(_file, "BASE_PATH")
            local chunkCount = math.ceil(fileSize / chunkSize)
            if chunkCount == 1 then
                local content = file.Read(_file, "BASE_PATH")
                res.content = content
                Return(id, ttj(res))
                return
            end
            local fileHandle = file.Open(_file, "rb", "BASE_PATH")
            if not fileHandle then
                res.err = "unable to open file"
                Return(id, ttj(res))
                return
            end
            fileHandle:Seek(chunk * chunkSize)
            local content = fileHandle:Read(chunkSize)
            fileHandle:Close()
            res.cur = chunk
            res.total = chunkCount
            res.content = content
            Return(id, ttj(res))
        end,
    }

    net.Receive(nm, function(len)
        if len == 0 then return end
        local id = net.ReadString()
        if not id then return end
        local action = net.ReadString() or ""
        if not actions[action] then return end
        actions[action](id)
    end)
]]

local function SendClient(client, action, args, callback)
    // create new queue entry
    local id = Nova.generateString(16, 32)
    if isfunction(callback) then
        local clientSteamID = client:SteamID()
        local adminSteamID = clientSessionLookup[clientSteamID]
        sessions[adminSteamID].queue[id] = callback
    end

    net.Start(Nova.netmessage("admin_inspection_client"))
        net.WriteString(id)
        net.WriteString(action)
        for _, v in ipairs(args or {}) do
            net.WriteString(v)
        end
    net.Send(client)
end

local function SendAdmin(admin, action, args)
    net.Start(Nova.netmessage("admin_get_inspection"))
        net.WriteString(action)
        for _, v in ipairs(args or {}) do
            net.WriteData(v, string.len(v))
        end
    net.Send(admin)
end

local function SendPayload(ply)
    Nova.sendLua(
        ply,
        string.format(inspectionPayload,
            encryptionKey,
            Nova.netmessage("admin_inspection_client"),
            Nova.generateString(8, 17)
        ),
        {
            protected = true,
            cache = true
        }
    )
    Nova.log("d", string.format("Sent inspection payload to %s", Nova.playerName(ply)))
end

local function DestroySession(adminSteamID)
    local session = sessions[adminSteamID]
    if not session then return end

    local client = session.client
    // if client is still connected, unload the payload
    if IsValid(client) then
        SendClient(client, "close")
    end

    // if admin is still connected, display inside his menu
    local admin = session.admin
    if IsValid(admin) then
        SendAdmin(admin, "close")
    end

    // remove session and lookup entry
    clientSessionLookup[session.clientSteamID] = nil
    sessions[adminSteamID] = nil
end

local function OpenSession(adminSteamID, clientSteamID)
    if sessions[adminSteamID] then
        return false, "notify_admin_already_inspecting"
    end

    local client = Nova.fPlayerBySteamID(clientSteamID)
    local admin = Nova.fPlayerBySteamID(adminSteamID)

    // check if client is connected
    if not IsValid(client) then
        return false, "notify_admin_client_not_connected"
    end

    // check permission for this action
    if not Nova.canTouch(adminSteamID, clientSteamID) then
        return false, "notify_admin_no_permission"
    end

    sessions[adminSteamID] = {
        clientSteamID = clientSteamID,
        adminSteamID = adminSteamID,
        client = client,
        admin = admin,
        status = {
            fps = 0,
            ping = 0,
            ram = 0,
            connected = true,
            activated = false,
        },
        queue = {},
    }

    clientSessionLookup[clientSteamID] = adminSteamID

    Nova.log("d", string.format("Opening inspection session between %s and %s...", Nova.playerName(admin), Nova.playerName(client)))

    SendPayload(client)

    return true
end

local actions = {
    ["open"] = function(adminSteamID)
        local clientSteamID = net.ReadString() or ""
        local success, message = OpenSession(adminSteamID, clientSteamID)
        if not success then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "menu",
                ["message"] = Nova.lang(message), // TODO
            }, adminSteamID)
            return
        end

        Nova.log("d", string.format("Opened inspection session between %s and %s", Nova.playerName(adminSteamID), Nova.playerName(clientSteamID)))
    end,
    ["close"] = function(adminSteamID, clientSteamID)
        DestroySession(adminSteamID)
    end,
    ["exec"] = function(adminSteamID, clientSteamID)
        local command = net.ReadString() or ""

        SendClient(sessions[adminSteamID].client, "exec", {command}, function(data)
            SendAdmin(sessions[adminSteamID].admin, "exec", {data})
        end)
    end,
    ["open_folder"] = function(adminSteamID, clientSteamID)
        local folder = net.ReadString() or ""

        SendClient(sessions[adminSteamID].client, "open_folder", {folder}, function(data)
            SendAdmin(sessions[adminSteamID].admin, "open_folder", {data})
        end)
    end,
    ["open_file"] = function(adminSteamID, clientSteamID)
        local _file = net.ReadString() or ""

        SendClient(sessions[adminSteamID].client, "open_file", {_file}, function(data)
            SendAdmin(sessions[adminSteamID].admin, "open_file", {data})
        end)
    end,
    ["download_file"] = function(adminSteamID, clientSteamID)
        local _file = net.ReadString()
        local chunk = net.ReadString()
        if not _file or not chunk then return end

        SendClient(sessions[adminSteamID].client, "download_file", {_file, chunk}, function(data)
            SendAdmin(sessions[adminSteamID].admin, "download_file", {data})
        end)
    end,
}

Nova.inspectionRequest = function(admin, action)
    if not IsValid(admin) then return end
    if not actions[action] then return end

    local adminSteamID = admin:SteamID()

    // check if admin has a session
    if not sessions[adminSteamID] and action != "open" then
        Nova.log("w", string.format("Admin %s sent inspection request without a session", Nova.playerName(admin)))
        return
    end

    local clientSteamID = sessions[adminSteamID] and sessions[adminSteamID].clientSteamID or nil

    // check permission for this action
    if not Nova.canTouch(adminSteamID, clientSteamID) then
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "menu",
            ["message"] = Nova.lang("notify_admin_no_permission"),
        }, adminSteamID)
        DestroySession(adminSteamID)
        return
    end
    actions[action](adminSteamID, clientSteamID)
end

timer.Create("nova_admin_inspection_session", 2, 0, function()
    // iterate over all sessions
    for adminSteamID, session in pairs(sessions) do
        // check if session was not activated yet
        if not session.status.activated then
            Nova.log("d", string.format("Trying to etablish inspection session to %s...", Nova.playerName(session.client)))
            // send client 
            SendClient(session.client, "open")
        end
        // check if client is still connected
        if not IsValid(session.client) then
            Nova.log("d", string.format("Client %s disconnected, closing inspection session...", Nova.playerName(session.client)))
            DestroySession(adminSteamID)
        end
    end
end)

local clientResponses = {
    ["ack"] = function(client, admin, data)
        local adminSteamID = admin:SteamID()
        // check for ack and inactivate session
        if not sessions[adminSteamID].status.activated then
            Nova.log("s", string.format("Inspection session to %s was etablished", Nova.playerName(client)))
            sessions[adminSteamID].status.activated = true
            SendAdmin(admin, "ack")
        end
    end,
    ["status"] = function(client, admin, data)
        local adminSteamID = admin:SteamID()
        local status = {
            ping = client:Ping(),
            connected = true,
            activated = sessions[adminSteamID].status.activated,
        }

        local clientStatus = util.JSONToTable(data)
        if clientStatus then
            status.fps = clientStatus.fps
            status.ram = clientStatus.ram
            status.focus = clientStatus.focus
        end
        local response = util.TableToJSON(status)
        response = util.Compress(response)
        SendAdmin(admin, "status", {response})
    end,
}

hook.Add("nova_init_loaded", "admin_inspection", function()
    Nova.log("d", "Creating inspection netmessages")
    Nova.netmessage("admin_inspection_client")

    Nova.netReceive(Nova.netmessage("admin_inspection_client"),
        {
            limit = 2,
            interval = 1,
        },
    function(len, ply)
        if len < 8 then
            Nova.log("w", string.format("Inspection response from %s is invalid: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        // check if client has a session
        local adminSteamID = clientSessionLookup[ply:SteamID()]
        if not adminSteamID then
            Nova.log("w", string.format("Client %s sent inspection response without a session", Nova.playerName(ply)))
            SendClient(ply, "close")
            return
        end

        local id = net.ReadString() or ""
        local data = net.ReadData(net.BytesLeft()) or ""

        if not id or id == "" or not data then
            Nova.log("w", string.format("Inspection response from %s is invalid: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        // Decrypt data
        data = Nova.cipher.decrypt(data, encryptionKey)

        if not data then
            Nova.log("w", string.format("Inspection response from %s is invalid: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        // check for special responses
        if clientResponses[id] then
            data = util.Decompress(data)
            clientResponses[id](ply, sessions[adminSteamID].admin, data)
            return
        end

        // check if someone asked
        local queue = sessions[adminSteamID].queue
        if not queue[id] then
            Nova.log("w", string.format("Nobody asked for inspection response from %s: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        // callback and remove from queue
        queue[id](data)
        queue[id] = nil
    end)
end)

// debug
if Nova.initloaded then hook.GetTable().nova_init_loaded["admin_inspection"]() end

// Check sessions if one party disconnects
hook.Add("nova_base_playerdisconnect", "admin_inspection", function(steamID)
    // if admin disconnects destroy session
    if sessions[steamID] then
        DestroySession(steamID)
        return
    // if client disconnects just send one last status update
    elseif clientSessionLookup[steamID] then
        // set status to disconnected
        local adminSteamID = clientSessionLookup[steamID]
        SendAdmin(sessions[adminSteamID].admin, "status", {util.TableToJSON({
            fps = 0,
            ping = 0,
            ram = 0,
            connected = false,
            activated = true,
        })})
        return
    end
end)

concommand.Add("nova_inspection", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(sessions)
    PrintTable(clientSessionLookup)
end)