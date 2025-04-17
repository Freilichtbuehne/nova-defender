// Nova.generateString(10)
//      returns a random string of length 10
// Nova.generateString(10, 15):
//      returns a random string of length between 10 and 15
Nova.generateString = function(min, max)
    local string_length = (max == nil and min or math.random(min, max))
    local output_str = ""
    // a-z: 97-122
    // 0-9: 48-57
    for i = 1, string_length do
        local randChar = string.char(math.random(97, 122))
        output_str = output_str .. randChar
    end
    return output_str
end

local fPlayer32Lookup = {}
local fPlayer64Lookup = {}
Nova.fPlayerBySteamID = function(steamID)
    if not steamID then return NULL end
    if not fPlayer32Lookup[steamID] or not IsValid(fPlayer32Lookup[steamID]) then
        local ply = player.GetBySteamID(steamID)
        if IsValid(ply) then
            fPlayer32Lookup[steamID] = ply
            return ply
        end
        fPlayer32Lookup[steamID] = false
        return NULL
    end
    return fPlayer32Lookup[steamID]
end
Nova.fPlayerBySteamID64 = function(steamID64)
    if not steamID64 then return NULL end
    if not fPlayer64Lookup[steamID64] or not IsValid(fPlayer64Lookup[steamID64])  then
        local ply = player.GetBySteamID64(steamID64)
        if IsValid(ply) then
            fPlayer64Lookup[steamID64] = ply
            return ply
        end
        fPlayer64Lookup[steamID64] = false
        return NULL
    end
    return fPlayer64Lookup[steamID64]
end
// Remove player from lookup table when they disconnect
hook.Add("nova_base_playerdisconnect", "functions_steamidlookup", function(steamID)
    fPlayer32Lookup[steamID] = nil
    local steamID64 = util.SteamIDTo64(steamID)
    if steamID64 then fPlayer64Lookup[steamID64] = nil end
end)


Nova.playerName = function(anything)
    // Console
    if anything == NULL then
        return "CONSOLE"
    // Player object and player is online
    elseif type(anything) == "Player" and IsValid(anything) then
        return string.format("%q (%s)", anything:Nick(), anything:SteamID())
    // any string value
    elseif type(anything) == "string" then
        // check if for steamid32
        if string.StartWith(anything, "STEAM_0:") then
            // check if player is online
            local ply = Nova.fPlayerBySteamID(anything)
            if IsValid(ply) then return string.format("%q (%s)", ply:Nick(), ply:SteamID())
            else return string.format("%s", anything) end
        // check for steamid64
        elseif tonumber(anything) then
            // check if player is online
            local ply = Nova.fPlayerBySteamID64(anything)
            if IsValid(ply) then return string.format("%q (%s)", ply:Nick(), ply:SteamID())
            else return string.format("%s", util.SteamIDFrom64(anything)) end
        else
            return anything
        end
    // any number value
    elseif type(anything) == "number" then
        // check for steamid64
        local ply = Nova.fPlayerBySteamID64(tostring(anything))
        if ply then
            return string.format("%q (%s)", ply:Nick(), ply:SteamID())
        else
            return util.SteamIDFrom64(tostring(anything))
        end
    // what else could it be? ;|
    else
        local default = tostring(anything) or ""
        return string.len(default) > 0 and default or "Unknown"
    end
end

// returns false if the IP is not valid or inside a private range
Nova.extractIP = function(ip, publicOnly)
    if not ip then return false, false end

    // check if IP has port and remove it
    local port = false
    if string.find(ip, ":") then
        port = string.sub(ip, string.find(ip, ":") + 1)
        ip = string.sub(ip, 1, string.find(ip, ":") - 1)
    end

    // if started in singleplayer
    if ip == "loopback" then return false, false end

    // if peer to peer
    if string.sub(ip, 1, 3) == "p2p" then return false, false end

    // check if ip is in Class A, B or C
    // it is a private ip range and we return false
    if string.match(ip, "^(%d+%.%d+%.%d+%.%d+)$") then
        local ip_split = string.Explode(".", ip)
        ip_split[1] = tonumber(ip_split[1])
        ip_split[2] = tonumber(ip_split[2])
        ip_split[3] = tonumber(ip_split[3])
        ip_split[4] = tonumber(ip_split[4])
        if publicOnly then
            if ip_split[1] == 10 then return false, false end // Class A (10.0.0.0/8)
            if ip_split[1] == 172 and ip_split[2] >= 16 and ip_split[2] <= 31 then return false, false end // Class B (172.16.0.0/12)
            if ip_split[1] == 192 and ip_split[2] == 168 then return false, false end // Class C (192.168.0.0/16)
        end
        return ip, port
    end
    return ip, port
end

Nova.extractDomain = function(url, includeSubdomain)
    local domain = string.match(url, "https?://([^/]+)")
    if not domain then return false end

    // check if domain is IP address
    local ip = Nova.extractIP(domain)
    if ip and ip != domain then return ip end

    // check if we have subdomains
    if includeSubdomain then return domain end
    local levels = string.Explode(".", domain)
    // we have second level domain and top level domain
    if #levels == 2 then
        // return the domain
        return table.concat(levels, ".")
    end
    // we have subdomains
    if #levels > 2 then
        // remove only second level domain and top level domain
        return table.concat({levels[#levels - 1], levels[#levels]}, ".")
    end
    return domain
end

// function converts steamid64 to steamid or returns steamid if it is already a steamid
Nova.convertSteamID = function(ply_or_steamID)
    if not ply_or_steamID or ply_or_steamID == NULL then return "" end

    // online player
    if type(ply_or_steamID) == "Player" and ply_or_steamID:IsPlayer() then
        return ply_or_steamID:SteamID()
    end

    // steamid64
    if type(ply_or_steamID) == "number" then
        local ply = Nova.fPlayerBySteamID64(tostring(ply_or_steamID))
        // player is online
        if ply then return ply:SteamID()
        // player is offline
        else return util.SteamIDFrom64(tostring(ply_or_steamID)) end
    end

    // steamid32 or steamid64
    if type(ply_or_steamID) == "string" then
        // empty
        if ply_or_steamID == "" then return "" end
        // steamid32
        if string.match(ply_or_steamID, "STEAM_[0-9]:[0-9]:[0-9]+") then return ply_or_steamID end
        // steamid64
        if tonumber(ply_or_steamID) then return util.SteamIDFrom64(ply_or_steamID) end
    end

    return ""
end

Nova.isAFK = function(ply)
    if not ply or not ply:IsPlayer() then return false end
    if GExtension and isfunction(ply.GE_IsAFK) then
        return ply:GE_IsAFK() == true
    elseif DarkRP and isfunction(ply.getDarkRPVar) then
        return ply:getDarkRPVar("AFK") == true
    elseif (system.UpTime() or 0) > 60 * 5 then return true end // 5 minutes
    return false
end

Nova.getNetmessageDefinition = function(name)
    // return where function for netmessage is defined
    if not net.Receivers[name] then return "undefined" end
    local info = debug.getinfo(net.Receivers[name])
    return string.format("%s:%i", info.short_src or "unknown_file", info.linedefined or "unknown_line")
end

Nova.profile = function(func, ...)
    local startTime = SysTime()
    local res = {func(...)}
    local endTime = SysTime()
    Nova.log("d", string.format("Time elapsed: %.6f", endTime - startTime))
    return unpack(res)
end

Nova.generateUUID = function()
    local function randomChar()
        local r = math.random(0, 15)
        if r < 10 then
            return tostring(r)
        else
            return string.char(string.byte("a") + r - 10)
        end
    end

    local function randomSection(length)
        local section = {}
        for _ = 1, length do
            table.insert(section, randomChar())
        end
        return table.concat(section)
    end

    local timeHigh = randomSection(4)
    local timeLow = randomSection(4)
    local clockSeq = randomSection(4)
    local node = randomSection(12)

    return string.format(
        "%s-%s-4%s-a%s-%s",
        timeLow,
        timeHigh,
        string.sub(clockSeq, 2),
        string.sub(clockSeq, 1, 1),
        node
    )
end

Nova.decode = function(encoded)
    if not encoded then return "" end
    if #encoded == 0 then return "" end

    local decoded = ""
    local i = 1

    while i <= #encoded do
        local c = string.sub(encoded, i, i)

        if c == "\\" then
            // The next three characters are an ASCII code in decimal.
            local code = tonumber(string.sub(encoded, i + 1, i + 3))
            decoded = decoded .. string.char(code)
            i = i + 3
        else
            // The character is not a backslash, so it's a regular character.
            decoded = decoded .. c
        end

        i = i + 1
    end

    return decoded
end

// protect from displaying potentially large strings
// this can cause a denial of service attack if an attacker crafts a large string and spams it
Nova.truncate = function(text, maxLength, append)
    if not text then return "" end
    if not maxLength then return text end
    append = append or ""
    if string.len(text) <= maxLength then return text end
    return string.sub(text, 1, maxLength - string.len(append)) .. append
end

// returns true if version1 is higher or equal to version2
// 1.0.0 > 0.9.9 => true
// 1.0.0 > 1.0.0 => true
// 1.0.0 > 1.0.1 => false
Nova.isVersionHigherOrEqual = function(version1, version2)
    if version1 == version2 then return true end

    if not isstring(version1) or not isstring(version2) then
        return false
    end

    local v1 = string.Split(version1, ".")
    local v2 = string.Split(version2, ".")

    for i = 1, 3 do
        if tonumber(v1[i]) > tonumber(v2[i]) then
            return true
        elseif tonumber(v1[i]) == tonumber(v2[i]) then
            continue
        elseif tonumber(v1[i]) < tonumber(v2[i]) then
            return false
        end
    end
    return false
end

Nova.bytesToHumanReadable = function(num_bytes, decimal_places)
    local units = {"B", "KB", "MB", "GB", "TB", "PB"}
    local index = 1

    if num_bytes == nil then
        num_bytes = 0
    end

    while num_bytes >= 1000 and index < #units do
        num_bytes = num_bytes / 1000
        index = index + 1
    end

    local format_str = "%." .. (decimal_places or 1) .. "f %s"
    return string.format(format_str, num_bytes, units[index])
end
