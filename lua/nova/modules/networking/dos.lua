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
local dosBlacklist = {
    "FProfile_", // https://github.com/FPtje/FProfiler
}

local nextCheck = 0
hook.Add("nova_networking_incoming_post", "networking_dos", function(client, strName, deltaTime)
    local steamID = client:SteamID()

    // check if the netmessage is blacklisted
    for _, v in ipairs(dosBlacklist) do
        if string.StartWith(strName, v) then
            return
        end
    end

    // check if the client is already in the table
    if not processTimeCollector[steamID] then
        processTimeCollector[steamID] = {
            total = 0,
            count = 0,
            max = 0,
            messages = {},
        }
    end

    // add the time to the table
    processTimeCollector[steamID].total = processTimeCollector[steamID].total + deltaTime
    processTimeCollector[steamID].count = processTimeCollector[steamID].count + 1
    if not processTimeCollector[steamID].messages[strName] then
        processTimeCollector[steamID].messages[strName] = deltaTime
    else
        processTimeCollector[steamID].messages[strName] = processTimeCollector[steamID].messages[strName] + deltaTime
    end

    // check every n seconds
    local curTime = CurTime()
    if curTime > nextCheck then
        nextCheck = curTime + Nova.getSetting("networking_dos_checkinterval", 5)
        // We don't want to do calculations while receiving netmessages, so we'll do it in next server think
        timer.Simple(0, CheckCollector)
    end

    // if netmessage took too long, we log the message
    if deltaTime > 0.5 then
        Nova.log("w", string.format("Netmessage %q from %s took %s to process.", strName, Nova.playerName(steamID), ConvertTime(deltaTime)))
    end
end)

// We don't remove client data on disconnect, because we want to keep the data for better accuracy

concommand.Add("nova_dos", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(processTimeCollector)
    print("Percentile: " .. globalPercentile)
end)