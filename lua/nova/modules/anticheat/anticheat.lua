local verificationLookup = {}
local rVerificationLookup = {}
local decryptionKey = ""
local playersVerified = {}
local verificationQueue = {}
local detectionQueue = {}
local cachedPayload = ""
local verificationTimeout = 80
local detectionTimeout = 60

local translationTable = {
    // default anticheat detections
    ["anticheat_verify_execution"] = "anticheat_verify_execution",
    ["anticheat_known_concommand"] = "anticheat_check_concommands",
    ["anticheat_known_file"] = "anticheat_check_files",
    ["anticheat_known_global"] = "anticheat_check_globals",
    ["anticheat_gluasteal_inject"] = "anticheat_check_external",
    ["anticheat_external_bypass"] = "anticheat_check_external",
    ["anticheat_known_function"] = "anticheat_check_function",
    ["anticheat_function_detour"] = "anticheat_check_detoured_functions",
    ["anticheat_jit_compilation"] = "anticheat_check_byte_code",
    ["anticheat_known_module"] = "anticheat_check_modules",
    ["anticheat_runstring_bad_string"] = "anticheat_check_runstring",
    ["anticheat_runstring_bad_function"] = "anticheat_check_runstring",
    ["anticheat_runstring_dhtml"] = "anticheat_check_runstring",
    ["anticheat_known_cvar"] = "anticheat_check_cvars",
    ["anticheat_scanning_netstrings"] = "anticheat_check_net_scan",
    ["anticheat_known_cheat_custom"] = "anticheat_check_cheats_custom",
    ["anticheat_manipulate_ac"] = "anticheat_check_manipulation",
    // autoclick detection
    ["anticheat_autoclick_fast"] = "anticheat_autoclick_check_fast",
    ["anticheat_autoclick_fastlong"] = "anticheat_autoclick_check_fastlong",
    ["anticheat_autoclick_robotic"] = "anticheat_autoclick_check_robotic",
    // experimental detections
    ["anticheat_experimental"] = "anticheat_check_experimental",
}

// this table is used to differentiate between anticheat detections and autoclick detections (as the are handled differently)
local autoclickDetections = {
    ["anticheat_autoclick_fast"] = true,
    ["anticheat_autoclick_fastlong"] = true,
    ["anticheat_autoclick_robotic"] = true,
}

Nova.registerAction("anticheat_detection", "anticheat_action", {
    ["add"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.addDetection(
            steamID,
            identifier,
            Nova.lang("notify_anticheat_detection", humanIdentifier, Nova.playerName(steamID), reason)
        )
    end,
    ["nothing"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q. But no action was taken.", humanIdentifier, Nova.playerName(steamID), reason))
    end,
    ["notify"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "anticheat",
            ["message"] = Nova.lang("notify_anticheat_detection", humanIdentifier, Nova.playerName(steamID), reason),
            ["ply"] = Nova.convertSteamID(steamID),
        })
    end,
    ["kick"] = function(steamID, identifier, reason)
        Nova.kickPlayer(steamID, Nova.getSetting("anticheat_reason", "Cheating/Exploiting"), identifier)
    end,
    ["ban"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        local formattedComment = string.format("Clientside Anticheat: %q", humanIdentifier)
        if humanIdentifier != reason then
            formattedComment = string.format("%s Reason: %q", formattedComment, reason)
        end
        Nova.banPlayer(
            steamID,
            Nova.getSetting("anticheat_reason", "Cheating/Exploiting"),
            formattedComment,
            identifier
        )
    end,
    ["allow"] = function(steamID, identifier, reason, admin)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        // check if identifier is in the translation table
        if not translationTable[identifier] then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // check if setting exists
        if Nova.getSetting(translationTable[identifier], "unknown") == "unknown" then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // disable the anticheat check
        Nova.setSetting(translationTable[identifier], false)
        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(steamID, identifier, reason, actionKey, _actions)
        steamID = Nova.convertSteamID(steamID)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
        // known cheats are displayed with their name
        if identifier == "anticheat_known_cheat_custom" then
            humanIdentifier = reason
        end
        Nova.askAction({
            ["identifier"] = identifier,
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_anticheat_detection_action", humanIdentifier),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                local formattedComment = string.format("Clientside Anticheat: %q", humanIdentifier)
                if humanIdentifier != reason then
                    formattedComment = string.format("%s Reason: %q", formattedComment, reason)
                end
                Nova.logDetection({
                    steamid = steamID,
                    comment = formattedComment,
                    reason = Nova.getSetting("anticheat_reason", "Cheating/Exploiting"),
                    internal_reason = identifier
                })
                Nova.startAction("anticheat_detection", "nothing", steamID, identifier, reason)
                return
            end
            Nova.startAction("anticheat_detection", answer, steamID, identifier, reason, admin)
        end)
    end,
})

Nova.registerAction("anticheat_autoclick", "anticheat_autoclick_action", {
    ["add"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.addDetection(
            steamID,
            identifier,
            Nova.lang("notify_anticheat_detection", humanIdentifier, Nova.playerName(steamID), reason)
        )
    end,
    ["nothing"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q. But no action was taken.", humanIdentifier, Nova.playerName(steamID), reason))
    end,
    ["notify"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "anticheat",
            ["message"] = Nova.lang("notify_anticheat_detection", humanIdentifier, Nova.playerName(steamID), reason),
            ["ply"] = Nova.convertSteamID(steamID),
        })
    end,
    ["kick"] = function(steamID, identifier, reason)
        Nova.kickPlayer(steamID, Nova.getSetting("anticheat_autoclick_reason"), identifier)
    end,
    ["ban"] = function(steamID, identifier, reason)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        local formattedComment = string.format("Clientside Anticheat: %q", humanIdentifier)
        if humanIdentifier != reason then
            formattedComment = string.format("%s Reason: %q", formattedComment, reason)
        end
        Nova.banPlayer(
            steamID,
            Nova.getSetting("anticheat_autoclick_reason"),
            formattedComment,
            identifier
        )
    end,
    ["allow"] = function(steamID, identifier, reason, admin)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        // check if identifier is in the translation table
        if not translationTable[identifier] then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // check if setting exists
        if Nova.getSetting(translationTable[identifier], "unknown") == "unknown" then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "action",
                ["message"] = Nova.lang("notify_functions_allow_failed"),
            }, admin)
            Nova.log("i", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))
            return
        end
        // disable the autoclick check
        Nova.setSetting(translationTable[identifier], false)
        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(steamID, identifier, reason, actionKey, _actions)
        steamID = Nova.convertSteamID(steamID)
        local humanIdentifier = Nova.lang("config_detection_" .. identifier or "")
        Nova.log("w", string.format("Anticheat detection %q on %s. Reason: %q", humanIdentifier, Nova.playerName(steamID), reason))

        Nova.askAction({
            ["identifier"] = identifier,
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_anticheat_detection_action", humanIdentifier),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                local formattedComment = string.format("Clientside Anticheat: %q", humanIdentifier)
                if humanIdentifier != reason then
                    formattedComment = string.format("%s Reason: %q", formattedComment, reason)
                end
                Nova.logDetection({
                    steamid = steamID,
                    comment = formattedComment,
                    reason = Nova.getSetting("anticheat_autoclick_reason"),
                    internal_reason = identifier
                })
                Nova.startAction("anticheat_autoclick", "nothing", steamID, identifier, reason)
                return
            end
            Nova.startAction("anticheat_autoclick", answer, steamID, identifier, reason, admin)
        end)
    end,
})

Nova.registerAction("anticheat_verify_execution", "anticheat_verify_action", {
    ["add"] = function(steamID)
        Nova.addDetection(
            steamID,
            "anticheat_verify_execution",
            Nova.lang("notify_anticheat_verify", Nova.playerName(steamID))
        )
    end,
    ["nothing"] = function(steamID)
        Nova.log("i", string.format("Anticheat verification for %s failed", Nova.playerName(steamID)))
    end,
    ["notify"] = function(steamID)
        Nova.log("w", string.format("Anticheat verification for %s failed", Nova.playerName(steamID)))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "anticheat",
            ["message"] = Nova.lang("notify_anticheat_verify", Nova.playerName(steamID)),
            ["ply"] = Nova.convertSteamID(steamID),
        })
    end,
    ["kick"] = function(steamID)
        Nova.kickPlayer(steamID, Nova.getSetting("anticheat_verify_reason", "Anticheat validation timeout"), "anticheat_verify_execution")
    end,
    ["ban"] = function(steamID)
        Nova.banPlayer(
            steamID,
            Nova.getSetting("anticheat_verify_reason", "Anticheat validation timeout"),
            Nova.lang("notify_anticheat_verify_action"),
            "anticheat_verify_execution"
        )
    end,
    ["allow"] = function(steamID, admin)
        // disable the anticheat check
        Nova.setSetting("anticheat_verify_execution", false)
        Nova.notify({
            ["severity"] = "s",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_success"),
        }, admin)
    end,
    ["ask"] = function(steamID, actionKey, _actions)
        steamID = Nova.convertSteamID(steamID)
        Nova.log("w", string.format("Anticheat verification for %s failed", Nova.playerName(steamID)))
        Nova.askAction({
            ["identifier"] = "anticheat_verify_execution",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_anticheat_verify_action"),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = "Failed to verify whether the anticheat is running on his side. This can also be caused by a slow connection.",
                    reason = Nova.getSetting("anticheat_verify_reason", "Anticheat validation timeout"),
                    internal_reason = "anticheat_verify_execution",
                })
                Nova.startAction("anticheat_verify_execution", "nothing", steamID)
                return
            end
            Nova.startAction("anticheat_verify_execution", answer, steamID, admin)
        end)
    end,
})

hook.Add("nova_networking_playerauthenticated", "anticheat_sendpayload", function(ply)
    if not Nova.getSetting("anticheat_enabled", true) then return end

    local steamID = ply:SteamID()

    // we send the payload intentionally to protected players as well:
    //  1. if we remove a player from the protected list, we want a anticheat instantly in place
    //  2. if the anticheat produces any difficulties or bugs responsible admins won't notice it
    //  3. the anticheat should run without issues everywhere

    // if you disagree uncomment the following line:
    // if Nova.isProtected(ply) then return end

    // we need to make sure that the player does not run the anticheat twice
    if rVerificationLookup[steamID] or playersVerified[steamID] then
        Nova.log("d", string.format("Anticheat was already sent to %s", Nova.playerName(ply)))
        return
    end

    Nova.sendLua(ply, cachedPayload, {reliable = true})
    Nova.log("d", string.format("Sent anticheat payload to %s", Nova.playerName(ply)))

    if not Nova.getSetting("anticheat_verify_execution", false) then return end
    verificationQueue[steamID] = true
end)

// delay verification as transmission of netmessages is a bit slow reight after being connected
timer.Create("nova_anticheat_verification", 60, 0, function()
    if not Nova.getSetting("anticheat_verify_execution", false) then return end
    timer.Adjust("nova_anticheat_verification", math.random(30, 60) )
    for steamID, v in pairs(verificationQueue or {}) do
        // check if player is still connected
        local ply = Nova.fPlayerBySteamID(steamID)
        if not IsValid(ply) then
            verificationQueue[steamID] = nil
            continue
        end
        // check if player is timing out
        if ply:IsTimingOut() then
            Nova.log("d", string.format("Player %s is timing out, delay anticheat verification...", Nova.playerName(ply)))
            continue
        end
        // skip if player has already an verification running
        if rVerificationLookup[steamID] then
            Nova.log("d", string.format("Verification for player %s already running. Skipping...", Nova.playerName(ply)))
            continue
        end
        // skip if player has already been verified
        if playersVerified[steamID] then
            Nova.log("d", string.format("Player %s already verified... Removing from verification queue...", Nova.playerName(ply)))
            verificationQueue[steamID] = nil
            continue
        end

        Nova.verifyAnticheat(steamID, function(result)
            verificationQueue[steamID] = nil
            if result == "timeout" then
                Nova.startDetection("anticheat_verify_execution", steamID, "anticheat_verify_action")
            elseif result == "success" then
                playersVerified[steamID] = true
            end
        end)
    end
end)

Nova.verifyAnticheat = function(ply_or_steamid, callback)
    // check if callback is valid
    if not isfunction(callback) then
        Nova.log("e", "Invalid callback for anticheat verification")
        return
    end

    // check if anticheat is enabled
    if not Nova.getSetting("anticheat_enabled", true) then
        return callback("anticheat disabled in settings")
    end

    local steamID = Nova.convertSteamID(ply_or_steamid)
    local ply = Nova.fPlayerBySteamID(steamID)

    // check if player is valid
    if not IsValid(ply) then
        return callback("disconnected")
    end

    Nova.log("d", string.format("Starting anticheat verification for %s", Nova.playerName(ply)))

    // generate new identifier
    local identifier = Nova.generateString(7,13)

    // create new entry in lookup table
    verificationLookup[identifier] = {
        steamID = steamID,
        callback = callback,
        identifier = identifier,
        duration = 0,
    }
    rVerificationLookup[steamID] = identifier

    // start simple verification procedure
    net.Start(Nova.netmessage("anticheat_verify_send"))
        net.WriteString(identifier)
    net.Send(ply)

    local function Check()
         // check if player offline
         if not IsValid(ply) then
            return callback("disconnected")
        end

        // check if player already verified
        if not verificationLookup[identifier] then
            return
        end

        // check if player is timing out
        if ply:IsTimingOut() then
            Nova.log("d", string.format("Player %s is timing out, delay anticheat verification...", Nova.playerName(ply)))
            timer.Simple(5, Check)
            return
        end

        // check if he has time left
        if verificationLookup[identifier].duration < verificationTimeout then
            verificationLookup[identifier].duration = verificationLookup[identifier].duration + 5
            timer.Simple(5, Check)
            return
        end

        // player is not verified
        rVerificationLookup[steamID] = nil
        verificationLookup[identifier] = nil
        return callback("timeout")
    end

    timer.Simple(5, Check)
end

local logger = Nova.fileLogger:new("nova/anticheat/experimental.txt")

hook.Add("nova_init_loaded", "anticheat_createnetmessage", function()
    Nova.log("d", "Creating anticheat net messages")
    // precache networkstring as soon as possible
    Nova.netmessage("anticheat_detection")
    // not randomized detection for usage within obfuscated payload (unencrypted but only used in validation process)
    util.AddNetworkString("nova_anticheat_detection")
    // used for verification
    Nova.netmessage("anticheat_verify_send")
    Nova.netmessage("anticheat_verify_response")
    // misused for detection via concommand
    Nova.netmessage("anticheat_detection_concommand")

    // check if anticheat extension was loaded
    local loader = Nova.getExtendedAnticheatPayload or Nova.getAnticheatPayload

    // precache anticheat payload as the obfuscation process is expensive
    // we use a simple symmetric algorithm to encrypt and decrypt the payload
    // this payload must not change, otherwise it has to be recompiled
    cachedPayload, decryptionKey = loader()
    cachedPayload = Nova.obfuscator.obfuscate(cachedPayload)

    local function DetectionNet(len, ply, protected)
        if len == 0 then return end

        local steamID = ply:SteamID()

        local identifier = net.ReadString() or ""
        local reason = net.ReadString() or ""

        identifier = protected and Nova.cipher.decrypt(Nova.decode(identifier), decryptionKey) or identifier
        reason = protected and Nova.cipher.decrypt(Nova.decode(reason), decryptionKey) or reason

        // limit the length of the identifier and reason to prevent spam as they are printed in the console
        identifier = Nova.truncate(identifier, 100)
        reason = Nova.truncate(reason, 200)

        // check if whole anticheat module is enabled
        if not Nova.getSetting("anticheat_enabled", false) then
            Nova.log("d", string.format("Anticheat detection %q on %s ignored: anticheat disabled", identifier, Nova.playerName(ply)))
            return
        end

        // we don't want to ban players with insufficient information
        if len == 0 or reason == "" then
            Nova.log("w", string.format("Anticheat detection %q on %s ignored: invalid or empty payload", identifier, Nova.playerName(ply)))
            return
        end

        // at this point we can assume that the detection is valid
        // only now we clear the last detection from the queue
        if protected and detectionQueue[steamID] then
            table.remove(detectionQueue[steamID], 1)
            Nova.log("d", string.format("Received anticheat detection verification from %s", Nova.playerName(ply)))
        // this may indicate that the netmessage was faster than the concommand
        // so we add a fake detection to the queue (golden ticket)
        // so the next time we receive a concommand we can ignore it
        elseif protected and #(detectionQueue[steamID] or {}) == 0 then
            if not detectionQueue[steamID] then
                detectionQueue[steamID] = {}
            end
            table.insert(detectionQueue[steamID], math.huge)
            Nova.log("w", string.format("Received anticheat detection from %s before backup concommand", Nova.playerName(ply)))
        end

        // check if type of detection is enabled
        // check if identifier is in the translation table
        local setting = Nova.getSetting(translationTable[identifier], "unknown")
        if setting == "unknown" then
            Nova.log("d", string.format("Anticheat detection %q on %s ignored: detection does not exist", identifier, Nova.playerName(ply)))
            Nova.startDetection(
                "anticheat_detection",
                steamID,
                "anticheat_manipulate_ac",
                "Player sent a detection to the server that does not exist (this should not happen)",
                "anticheat_action"
            )
            return
        elseif setting == false then
            Nova.log("d", string.format("Anticheat detection %q on %s ignored: disabled in settings", identifier, Nova.playerName(ply)))
            return
        end

        // check if detection was experimental
        if identifier == "anticheat_experimental" then
            if Nova.getSetting("anticheat_check_experimental", false) then
                logger:log(string.format("Detection from %q: %q", Nova.playerName(ply), reason))
            end
            return
        end

        // let's get rid of him
        if not autoclickDetections[identifier] then
            Nova.startDetection("anticheat_detection", steamID, identifier, reason, "anticheat_action")
        // special case for autoclick detection
        else
            if not Nova.getSetting("anticheat_autoclick_enabled", false) then
                Nova.log("d", string.format("Anticheat detection %q on %s ignored: autoclick disabled", identifier, Nova.playerName(ply)))
                return
            end
            Nova.startDetection("anticheat_autoclick", steamID, identifier, reason, "anticheat_autoclick_action")
        end
    end

    Nova.netReceive(Nova.netmessage("anticheat_detection"),
        {
            auth = true,
            limit = 2,
            interval = 1,
        },
    function(len, ply)
        DetectionNet(len, ply, true)
    end, function(len, ply)
        local steamID = ply:SteamID()
        // if request was rate limited, we add a fake detection to the queue (golden ticket)
        if not detectionQueue[steamID] then
            detectionQueue[steamID] = {}
        end
        table.insert(detectionQueue[steamID], math.huge)
    end)

    // not randomized detection for usage within obfuscated payload (unencrypted but only used in validation process)
    Nova.netReceive("nova_anticheat_detection",
        {
            auth = true,
            limit = 3,
            interval = 100,
        },
    DetectionNet, function(len, ply)
        local steamID = ply:SteamID()
        // if request was rate limited, we add a fake detection to the queue (golden ticket)
        if not detectionQueue[steamID] then
            detectionQueue[steamID] = {}
        end
        table.insert(detectionQueue[steamID], math.huge)
    end)

    // https://wiki.facepunch.com/gmod/Enums/FCVAR
    concommand.Add(Nova.netmessage("anticheat_detection_concommand"), function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        // check if whole anticheat module is enabled
        if not Nova.getSetting("anticheat_enabled", false) then
            Nova.log("d", string.format("Anticheat detection backup on %s ignored: anticheat disabled", Nova.playerName(ply)))
            return
        end

        local steamID = ply:SteamID()

        if not detectionQueue[steamID] then
            detectionQueue[steamID] = {}
        end

        // check for golden ticket
        if #detectionQueue[steamID] > 0 and detectionQueue[steamID][1] == math.huge then
            // remove golden ticket
            table.remove(detectionQueue[steamID], 1)
            Nova.log("d", string.format("Received anticheat detection backup via concommand from %s (golden ticket)", Nova.playerName(ply)))
            return
        end

        table.insert(detectionQueue[steamID], os.time())

        Nova.log("d", string.format("Received anticheat detection backup via concommand from %s", Nova.playerName(ply)))
    end)

    // iterate over all detections and check if they are older than n seconds
    timer.Create("nova_anticheat_detections", 5, 0, function()
        local curOSTime = os.time()
        // iterate over all players
        for steamID, detections in pairs(detectionQueue or {}) do
            // check if player is still connected
            local ply = Nova.fPlayerBySteamID(steamID)
            if not IsValid(ply) then continue end

            // check if player is timing out
            if ply:IsTimingOut() then
                Nova.log("d", string.format("Player %s is timing out, delay anticheat verification...", Nova.playerName(ply)))
                continue
            end

            // check if player has one or more detections that have expired
            local hasExpired = false
            for i, detectionTime in ipairs(detections) do
                if curOSTime - detectionTime > detectionTimeout then
                    table.remove(detections, i)
                    hasExpired = true
                end
            end

            if not hasExpired then continue end

            if not Nova.getSetting("anticheat_check_manipulation", false) then continue end

            Nova.startDetection(
                "anticheat_detection",
                steamID,
                "anticheat_manipulate_ac",
                string.format("Player blocked an unknown anticheat detection. This can also be caused by a timeout. Only a backup message was received within %d seconds.", detectionTimeout),
                "anticheat_action"
            )
        end
    end)

    Nova.netReceive(Nova.netmessage("anticheat_verify_response"), {auth = true}, function(len, ply)
        local steamID = ply:SteamID()

        // validate identifier
        local identifier = (len == 0) and "" or net.ReadString()

        // check if player was even sent the anticheat payload
        if not verificationLookup[identifier] then
            Nova.log("w", string.format("Anticheat verification from %s ignored: invalid identifier %q", Nova.playerName(ply), string.sub(identifier,1, 100)))
            // let the verification timeout
            return
        end

        // check if player is the same as the one who sent the verification
        if steamID != verificationLookup[identifier].steamID then
            Nova.log("w", string.format("Anticheat verification from %s ignored: invalid steamID", Nova.playerName(ply)))
            // let the verification timeout
            return
        end

        Nova.log("s", string.format("Anticheat verification finished for %s", Nova.playerName(ply)))
        verificationLookup[identifier].callback("success")
        verificationLookup[identifier] = nil
        rVerificationLookup[steamID] = nil
    end)
end)

// Remove quarantine info when player disconnects
hook.Add("nova_base_playerdisconnect", "anticheat_verification", function(steamID)
    Nova.log("d", string.format("Removing anticheat verification info for %s", steamID))
    if rVerificationLookup[steamID] then
        verificationLookup[rVerificationLookup[steamID]] = nil
        rVerificationLookup[steamID] = nil
    end
    playersVerified[steamID] = nil
    verificationQueue[steamID] = nil
    detectionQueue[steamID] = nil
end)

// Warning for known FProfiler issue
//hook.Run("nova_networking_onclientcommand", ply, steamID, command, "")
hook.Add("nova_networking_onclientcommand", "anticheat_fprofiler", function(ply, steamID, command, args)
    if command == "FProfiler" and Nova.isStaff(ply) and (verificationQueue[steamID] or rVerificationLookup[steamID]) then
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "anticheat",
            ["message"] = Nova.lang("notify_anticheat_issue_fprofiler"),
            ["ply"] = steamID,
        })
    end
end)