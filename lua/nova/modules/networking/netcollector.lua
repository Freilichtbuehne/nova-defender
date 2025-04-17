
/*
	We block netmessages if a player is spamming
    If player reaches max netmessages, he get's a punishment

    If a server has a net.Receive function that does big calculations (e.g. file.Find or ents.GetAll),
    a client could cause a denial of service by flooding the server with this netmessage.
*/

// false positives
local falsePositives = {
    ["mCasino_interface"] = true,
    ["Photon2:SetControllerChannelState"] = true,
}

// we only store 3 seconds of netmessages in this table to prevent accessing large tables
local activeNetCounter = {}

// all messages deleted after 3 seconds are inserted into this table to enable further investigation afterwards
local oldMessages = {}

Nova.registerAction("networking_spam", "networking_netcollector_spam_action", {
    ["add"] = function(steamid, count, max, interval)
        Nova.addDetection(steamid, "networking_spam", Nova.lang("notify_networking_spam", Nova.playerName(steamid), count, interval, max))
    end,
    ["nothing"] = function(steamid, count, max, interval)
        Nova.log("i", string.format("%s is spamming netmessages (%d/%ds) (%d allowed), but no action was taken.", Nova.playerName(steamid), count, interval, max))
    end,
    ["notify"] = function(steamid, count, max, interval)
        Nova.log("w", string.format("%s is spamming netmessages (%d/%ds) (%d allowed).", Nova.playerName(steamid), count, interval, max))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_spam", Nova.playerName(steamid), count, interval, max),
            ["ply"] = Nova.convertSteamID(steamid),
        })
    end,
    ["kick"] = function(steamid, count, max, interval)
        Nova.kickPlayer(steamid, Nova.getSetting("networking_netcollector_spam_reason", "DoS"), "networking_spam")
    end,
    ["ban"] = function(steamid, count, max, interval)
        Nova.banPlayer(
            steamid,
            Nova.getSetting("networking_netcollector_spam_reason", "DoS"),
            string.format("Spammed netmessages (%d/%ds) (%d allowed).", count, interval, max),
            "networking_spam"
        )
    end,
    ["allow"] = function(steamid, count, max, interval, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s is spamming netmessages (%d/%ds) (%d allowed), but no action was taken.", Nova.playerName(steamid), count, interval, max))
    end,
    ["ask"] = function(steamid, count, max, interval, actionKey, _actions)
        steamid = Nova.convertSteamID(steamid)
        Nova.log("w", string.format("%s is spamming netmessages (%d/%ds) (%d allowed).", Nova.playerName(steamid), count, interval, max))
        Nova.askAction({
            ["identifier"] = "networking_spam",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_spam_action", count, interval, max),
            ["ply"] = steamid,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamid,
                    comment = string.format("Spammed netmessages (%d/%ds) (%d allowed).", count, interval, max),
                    reason = Nova.getSetting("networking_netcollector_spam_reason", "DoS"),
                    internal_reason = "networking_spam"
                })
                Nova.startAction("networking_spam", "nothing", steamid, count, max, interval)
                return
            end
            Nova.startAction("networking_spam", answer, steamid, count, max, interval, admin)
        end)
    end,
})

local function MoveOldMessages()
    // insert all messages for each player into oldMessages
    for steamID, data in pairs(activeNetCounter or {}) do
        // check if player exists in oldMessages
        if not oldMessages[steamID] then oldMessages[steamID] = {} end

        // add up message counts
        for name, count in pairs(data or {}) do
            if not oldMessages[steamID][name] then oldMessages[steamID][name] = 0 end
            oldMessages[steamID][name] = oldMessages[steamID][name] + count
        end

        // check if player has exceeded the threshold
        local totalCount = activeNetCounter[steamID].___total_messages
        if totalCount > Nova.getSetting("networking_netcollector_actionAt", 500) then
            Nova.log("w", string.format("%s has exceeded the threshold of %d netmessages by %d netmessages.", Nova.playerName(steamID), Nova.getSetting("networking_netcollector_actionAt", 500), totalCount))

            local interval = Nova.getSetting("networking_netcollector_checkinterval", 3)
            local max = Nova.getSetting("networking_netcollector_actionAt", 500)

            Nova.startDetection("networking_spam", steamID, totalCount, max, interval, "networking_netcollector_spam_action")
        end

        // reset the counter
        activeNetCounter[steamID] = {___total_messages = 0}
    end
end

local nextCheck = 0
hook.Add("nova_networking_incoming", "networking_counter", function(client, steamID, strName, len)
    // we don't want to intercept messages from Nova Defender
    if Nova.isInternalNetmessage(strName) then return end

    // first message from this client
    if not activeNetCounter[steamID] then
        activeNetCounter[steamID] = {___total_messages = 0}
    end

    // first time the client sent this request
    if not activeNetCounter[steamID][strName] then
        activeNetCounter[steamID][strName] = 0
    end

    // increment the counters
    activeNetCounter[steamID][strName] = activeNetCounter[steamID][strName] + 1
    if not falsePositives[strName] then
        activeNetCounter[steamID].___total_messages = activeNetCounter[steamID].___total_messages + 1
    end

    // check every n seconds
    local curTime = CurTime()
    if curTime > nextCheck then
        nextCheck = curTime + Nova.getSetting("networking_netcollector_checkinterval", 3)
        // We don't want to do large calculations while receiving netmessages, so we'll do it in next server think
        timer.Simple(0, MoveOldMessages)
    end

    local dropAt = math.min(Nova.getSetting("networking_netcollector_dropAt", 100), Nova.getSetting("networking_netcollector_actionAt", 500))

    // check if player exeeds the limit of netmessages per n seconds and drop the message if so
    if activeNetCounter[steamID].___total_messages > dropAt then
        // just warn once
        if activeNetCounter[steamID].___total_messages - 1 == dropAt then
            Nova.log("w", string.format("Ignoring netmessages from %s as he exceeded the limit of %d netmessages per %d seconds.", Nova.playerName(client), dropAt, Nova.getSetting("networking_netcollector_checkinterval", 3)))
            Nova.notify({
                ["severity"] = "w",
                ["module"] = "network",
                ["message"] = Nova.lang("notify_networking_limit_drop", Nova.playerName(client), dropAt, Nova.getSetting("networking_netcollector_checkinterval", 3)),
                ["ply"] = Nova.convertSteamID(steamID),
            })
        end

        // drop the message
        return false
    end
end)

hook.Add("nova_base_playerdisconnect", "networking_remove_playerdata_collector", function(steamID)
    if not steamID then return end

    if Nova.getSetting("networking_netcollector_dump", false) then
        Nova.log("d", string.format("Dumping netmessages for %s", Nova.playerName(steamID)))

        // if nil, set to empty table
        activeNetCounter[steamID] = activeNetCounter[steamID] or {___total_messages = 0}
        oldMessages[steamID] = oldMessages[steamID] or {___total_messages = 0}

        // store total message counts
        local totalNew = activeNetCounter[steamID].___total_messages
        local totalOld = oldMessages[steamID].___total_messages

        // remove total message counts from tables
        oldMessages[steamID].___total_messages, activeNetCounter[steamID].___total_messages = nil

        local checkInterval = Nova.getSetting("networking_netcollector_checkinterval", 3)

        // create a new table to dump to console
        local dumpTable = {
            ["Old_Messages"] = oldMessages[steamID],
            ["Latest_Messages"] = activeNetCounter[steamID],
            ["Total_Messages_Last_" ..  tostring(checkInterval) .. "_Seconds"] = totalNew,
            ["Total_Messages"] = totalOld + totalNew,
        }
        PrintTable(dumpTable, 1)
    end

    Nova.log("d", string.format("Removing netmessages from %s", Nova.playerName(steamID)))
    activeNetCounter[steamID] = nil
    oldMessages[steamID] = nil
end)

Nova.getPlayerNetmessages = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    local messages = table.Copy(oldMessages[steamID] or {})
    // check for all messages if it is internal (by Nova Defender) and unrandomize the name
    for name, count in pairs(messages or {}) do
        if Nova.isInternalNetmessage(name) then
            messages[Nova.getNetmessage(name)] = count
            messages[name] = nil
        end
    end
    return messages
end