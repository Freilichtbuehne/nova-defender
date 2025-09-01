/*
    Detect a denial of service attack.
    Unlike the other detection methods based on counting the number of netmessages,
    we messure the time it takes to process a netmessage. If the time is too long,
    we assume that the client is trying to cause a denial of service attack.
*/

local sensitivities = {
    ["high"] = 2,
    ["medium"] = 4,
    ["low"] = 10,
}

local convBytes = Nova.bytesToHumanReadable
local function ConvertTime(time)
    // we can display time in seconds
    if time >= 0.1 then
        return string.format("%.1f %s", time, "s")
    else
        // or in milliseconds
        return string.format("%.1f %s", time * 1000, "ms")
    end
end

Nova.registerAction("networking_dos", "networking_dos_action", {
    ["add"] = function(steamid, time, interval)
        Nova.addDetection(steamid, "networking_dos", Nova.lang("notify_networking_dos", Nova.playerName(steamid), time, interval))
    end,
    ["nothing"] = function(steamid, time, interval)
        Nova.log("i", string.format("%s has caused a serverlag. Duration: %s within %d seconds, but no action was taken.", Nova.playerName(steamid), time, interval))
    end,
    ["notify"] = function(steamid, time, interval)
        Nova.log("w", string.format("%s has caused a serverlag. Duration: %s within %d seconds.", Nova.playerName(steamid), time, interval))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_dos", Nova.playerName(steamid), time, interval),
            ["ply"] = Nova.convertSteamID(steamid),
        })
    end,
    ["kick"] = function(steamid, time, interval)
        Nova.kickPlayer(steamid, Nova.getSetting("networking_dos_reason", "DoS"), "networking_dos")
    end,
    ["ban"] = function(steamid, time, interval)
        Nova.banPlayer(
            steamid,
            Nova.getSetting("networking_dos_reason", "DoS"),
            string.format("Caused serverlags. Duration: %s within %d seconds.", time, interval),
            "networking_dos"
        )
    end,
    ["allow"] = function(steamid, time, interval, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s has caused a serverlag. Duration: %s within %d seconds, but no action was taken.", Nova.playerName(steamid), time, interval))
    end,
    ["ask"] = function(steamid, time, interval, actionKey, _actions)
        steamid = Nova.convertSteamID(steamid)
        Nova.log("w", string.format("%s has caused a serverlag. Duration: %s within %d seconds.", Nova.playerName(steamid), time, interval))
        Nova.askAction({
            ["identifier"] = "networking_dos",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_dos_action", time, interval),
            ["ply"] = steamid,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamid,
                    comment = string.format("Caused serverlags. Duration: %s within %d seconds.", time, interval),
                    reason = Nova.getSetting("networking_dos_reason", "DoS"),
                    internal_reason = "networking_dos"
                })
                Nova.startAction("networking_dos", "nothing", steamid, time, interval)
                return
            end
            Nova.startAction("networking_dos", answer, steamid, time, interval, admin)
        end)
    end,
})

Nova.registerAction("networking_dos_crash", "networking_dos_crash_action", {
    ["add"] = function(steamid, compressed, decompressed, ratio, time, netmessage)
        Nova.addDetection(steamid, "networking_dos_crash", Nova.lang("notify_networking_dos_crash", Nova.playerName(steamid), netmessage, decompressed, ratio))
    end,
    ["nothing"] = function(steamid, compressed, decompressed, ratio, time, netmessage)
        Nova.log("i", string.format("%s tried to crash the server with an unusually highly compressed packet. Message: %s, size decompressed: %s, compression ratio: %s, took %s to process, but no action was taken.", Nova.playerName(steamid), netmessage, decompressed, ratio, time))
    end,
    ["notify"] = function(steamid, compressed, decompressed, ratio, time, netmessage)
        Nova.log("w", string.format("%s tried to crash the server with an unusually highly compressed packet. Message: %s, size decompressed: %s, compression ratio: %s, took %s to process.", Nova.playerName(steamid), netmessage, decompressed, ratio, time))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_dos_crash", Nova.playerName(steamid), netmessage, decompressed, ratio),
            ["ply"] = Nova.convertSteamID(steamid),
        })
    end,
    ["kick"] = function(steamid, compressed, decompressed, ratio, time, netmessage)
        Nova.kickPlayer(steamid, Nova.getSetting("networking_dos_reason", "DoS"), "networking_dos_crash")
    end,
    ["ban"] = function(steamid, compressed, decompressed, ratio, time, netmessage)
        Nova.banPlayer(
            steamid,
            Nova.getSetting("networking_dos_reason", "DoS"),
            string.format("Tried to crash server with an unusually highly compressed packet. Message: %s, size decompressed: %s, compression ratio: %s, took %s to process.", netmessage, decompressed, ratio, time),
            "networking_dos_crash"
        )
    end,
    ["allow"] = function(steamid, compressed, decompressed, ratio, time, netmessage, admin)
        // add to whitelist
        local whitelist = Nova.getSetting("networking_dos_crash_whitelist", {})
        if not table.HasValue(whitelist, netmessage) then
            table.insert(whitelist, netmessage)
            Nova.setSetting("networking_dos_crash_whitelist", whitelist)
        end

        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(steamid, compressed, decompressed, ratio, time, netmessage, actionKey, _actions)
        steamid = Nova.convertSteamID(steamid)
        Nova.log("w", string.format("%s tried to crash the server with an unusually highly compressed packet. Message: %s, size decompressed: %s, compression ratio: %s, took %s to process.", Nova.playerName(steamid), netmessage, decompressed, ratio, time))
        Nova.askAction({
            ["identifier"] = "networking_dos_crash",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_dos_crash_action", netmessage, decompressed, ratio),
            ["ply"] = steamid,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamid,
                    comment = string.format("Tried to crash server with an unusually highly compressed packet. Message: %s, size decompressed: %s, compression ratio: %s, took %s to process.", netmessage, decompressed, ratio, time),
                    reason = Nova.getSetting("networking_dos_reason", "DoS"),
                    internal_reason = "networking_dos_crash"
                })
                Nova.startAction("networking_dos_crash", "nothing", steamid, compressed, decompressed, ratio, time, netmessage)
                return
            end
            Nova.startAction("networking_dos_crash", answer, steamid, compressed, decompressed, ratio, time, netmessage, admin)
        end)
    end,
})

local processTimeCollector = {}
local percentile = 0.95
local globalPercentile = 0

local function IsTimeTooLong(time, messageCount, steamID)
    local minTime = 1
    local maxTime = Nova.getSetting("networking_dos_checkinterval", 5) * 0.9

    // Time is below minimum
    if time < minTime then
        return false
    end

    // Time is above maximum (constant server freeze)
    if time > maxTime then
        return true
    end

    // Check deviation from percentile
    local deviation = time / globalPercentile

    // Time is below percentile
    if deviation < 1 then
        return false
    end

    local sensitity = sensitivities[Nova.getSetting("networking_dos_sensivity", "medium")] or sensitivities["medium"]

    // Time is above average
    if deviation > sensitity then
        return true
    end

    return false
end

local function CheckCollector()
    local timeValues = {}
    for k, v in pairs(processTimeCollector) do
        // Check if we got new data
        if v.total == 0 and v.total == 0 then
            continue
        end

        // Check if the time is acceptable
        local timeTooLong = IsTimeTooLong(v.total, v.count, k)

        // Player is not trying to cause a denial of service attack, so we can rely on that data
        if not timeTooLong then
            // Insert the time into the table
            table.insert(timeValues, v.max)
            // Check max time
            if v.max < v.total then
                v.max = v.total
            end
        // Client is trying to cause a denial of service attack
        else
            local interval = Nova.getSetting("networking_dos_checkinterval", 5)
            Nova.log("w", string.format("Player %s has caused a serverlag. Printing debug infos:", Nova.playerName(k)))
            PrintTable(v)
            Nova.startDetection("networking_dos", k, ConvertTime(v.total), interval, "networking_dos_action")
        end

        // Reset time
        v.total = 0
        v.count = 0
        v.messages = {}
    end

    // Get percentile
    if #timeValues == 0 then return end
    table.sort(timeValues)
    local percentileIndex = math.Round(#timeValues * percentile)
    globalPercentile = timeValues[percentileIndex]
end

// Some netmessages often causes serverlags
// They are almost guaranteed to be laggy but they are not part of a denial of service attack
// TODO: Add option to dynamically add netmessages to the blacklist
local dosBlacklist = {
    "FProfile_", // https://github.com/FPtje/FProfiler
    "zmc_fridge_buy", // https://www.gmodstore.com/market/view/zero-s-masterchef-cooking-script
}

// We have to keep track which client sent the netmessage (for util.Decompress)
local lastClient = nil
local lastMessage = nil
local lastMessageLength = 0
hook.Add("nova_networking_incoming", "networking_dos", function(client, steamID, strName, len)
    lastClient = steamID
    lastMessage = strName
    lastMessageLength = len
end)

local nextCheck = 0
hook.Add("nova_networking_incoming_post", "networking_dos", function(client, strName, deltaTime)
    local steamID = client:SteamID()
    lastClient = nil
    lastMessage = nil
    lastMessageLength = 0

    // Step 1: Check if the netmessage is blacklisted
    for _, v in ipairs(dosBlacklist) do
        if string.StartWith(strName, v) then
            return
        end
    end

    // Step 2: Check if the client is already in the table
    // If not, we create a new table
    if not processTimeCollector[steamID] then
        processTimeCollector[steamID] = {
            total = 0,
            count = 0,
            max = 0,
            messages = {},
        }
    end

    // Step 3: Add the consumed time to the table
    processTimeCollector[steamID].total = processTimeCollector[steamID].total + deltaTime
    processTimeCollector[steamID].count = processTimeCollector[steamID].count + 1
    if not processTimeCollector[steamID].messages[strName] then
        processTimeCollector[steamID].messages[strName] = deltaTime
    else
        processTimeCollector[steamID].messages[strName] = processTimeCollector[steamID].messages[strName] + deltaTime
    end

    // Step 4: Set the time for next check
    local curTime = CurTime()
    if curTime > nextCheck then
        nextCheck = curTime + Nova.getSetting("networking_dos_checkinterval", 5)
        // We don't want to do calculations while receiving netmessages, so we'll do it in next server think
        timer.Simple(0, CheckCollector)
    end

    // Debug: If netmessage took too long, we log the message
    if deltaTime > 0.5 then
        Nova.log("w", string.format("Netmessage %q from %s took %s to process.", strName, Nova.playerName(steamID), ConvertTime(deltaTime)))
    end
end)

// We don't remove client data on disconnect, because we want to keep the data for better accuracy

// util.Decompress is often being targeted for denial of service attacks
// Just like with zipbombs, we can use a limit to prevent this.
// An attacker can send a compressed payload that, when decompressed, is much larger than the server memory can handle

local minDecompressedSize = 10000000 // 10 MB
local maxDecompressedSize = 400000000 // 400 MB
local maxCompressionRatio = 100 // 100:1 (10 MB compressed = 1 GB decompressed)
local netWhitelist = {}
local ignoreAdmins = false
local function OverwriteDecompress(active)
    if active then
        if Nova.overrides["util.Decompress"] then return end
        Nova.overrides["util.Decompress"] = util.Decompress
        function util.Decompress(compressed, limit, ...)
            local compressedSize = #compressed

            // We don't limit the size of the compressed data if:
            // 1. The limit is already set
            if limit and limit > 0 or
            // 2. The function was not called from a netmessage
                lastMessage == nil or
                lastClient == nil or
            // 3. The compressed data must come from the client
                lastMessageLength < compressedSize or
            // 4. The function is not used by Nova Defender itself
                Nova.isInternalNetmessage(lastMessage) or
            // 5. The function is used by a whitelisted netmessage (settings)
                netWhitelist[lastMessage] or
            // 6. The function is used by a protected player (settings)
                (ignoreAdmins and Nova.isProtected(lastClient)) or
            // 7. The compressed size is not zero
                compressedSize == 0
            then
                return Nova.overrides["util.Decompress"](compressed, limit, ...)
            end

            // Calculate the max size of the decompressed data
            // Limit of data a client can send is 65533 bytes
            // Clients can easily achieve a compression ratio with LZMA2 of (roughly) 7000:1
            // 65533 * 7000 = 458,331,000 bytes (458 MB)

            // Heavily depending on the server, the Lua state will also be around 400 MB
            // We can assume, there is no legitimate usecase for a decompressed payload larger than 400 MB
            // Additionally, there is not reason for a compression ratio larger than 7000:1 with legitimate data

            // Call the actual decompress function
            local startTime = SysTime()
            local decompressed = Nova.overrides["util.Decompress"](compressed, maxDecompressedSize, ...)
            local deltaTime = SysTime() - startTime
            if decompressed == nil then
                // Throw an error for developers
                ErrorNoHalt("util.Decompress blocked by Nova Defender to prevent server crash.\n")

                // we have to estimate the compression ratio as we don't know the decompressed size
                local estimatedCompressionRatio = math.Round(maxDecompressedSize / compressedSize, 2)
                Nova.startDetection(
                    "networking_dos_crash",
                    lastClient,
                    convBytes(compressedSize),
                    string.format("> %s", convBytes(maxDecompressedSize)),
                    string.format("> %d", estimatedCompressionRatio),
                    ConvertTime(deltaTime),
                    lastMessage,
                    "networking_dos_crash_action"
                )
            end

            local decompressedSize = decompressed and #decompressed or 0
            local ratio = math.Round(decompressedSize / compressedSize, 2)
            Nova.log("d",
                string.format("Client %s sent a compressed payload. Compressed: %s, Decompressed: %s, Ratio: %s, Took %s to process.",
                Nova.playerName(lastClient),
                convBytes(compressedSize),
                convBytes(decompressedSize),
                ratio,
                ConvertTime(deltaTime))
            )

            // Check for compression ratio
            if decompressedSize > minDecompressedSize and ratio > maxCompressionRatio then
                Nova.startDetection(
                    "networking_dos_crash",
                    lastClient,
                    convBytes(compressedSize),
                    convBytes(decompressedSize),
                    ratio,
                    ConvertTime(deltaTime),
                    lastMessage,
                    "networking_dos_crash_action"
                )
            end

            return decompressed
        end
    elseif Nova.overrides["util.Decompress"] then
        util.Decompress = Nova.overrides["util.Decompress"]
        Nova.overrides["util.Decompress"] = nil
    end
end

local function LoadConfig()
    if Nova.getSetting("networking_dos_crash_enabled", false) then
        OverwriteDecompress(true)
    end
    maxDecompressedSize = Nova.getSetting("networking_dos_crash_maxsize", 400) * 1000000
    maxCompressionRatio = Nova.getSetting("networking_dos_crash_ratio", 100)
    netWhitelist = {}
    for k, v in pairs(Nova.getSetting("networking_dos_crash_whitelist", {})) do
        netWhitelist[v] = true
    end
    ignoreAdmins = Nova.getSetting("networking_dos_crash_ignoreprotected", false)
end

// To avoid breaking other addons, we con only override http functions if we know
// that the option is enabled. This is after the settings were loaded.
if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "networking_dos_overwrite", LoadConfig)
else
    LoadConfig()
end

hook.Add("nova_config_setting_changed", "networking_dos_overwrite", function(key, value, oldValue)
    if not string.StartWith(key, "networking_dos_crash") then return end

    if key == "networking_dos_crash_enabled" and value != oldValue then
        OverwriteDecompress(value)
        Nova.log("d", string.format("util.Decompress overwriting %s", value and "enabled" or "disabled"))
    end

    maxDecompressedSize = Nova.getSetting("networking_dos_crash_maxsize", 400) * 1000000
    maxCompressionRatio = Nova.getSetting("networking_dos_crash_ratio", 100)
    netWhitelist = {}
    for k, v in pairs(Nova.getSetting("networking_dos_crash_whitelist", {})) do
        netWhitelist[v] = true
    end
    ignoreAdmins = Nova.getSetting("networking_dos_crash_ignoreprotected", false)
end)

concommand.Add("nova_dos", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(processTimeCollector)
    print("Percentile: " .. globalPercentile)
end)
