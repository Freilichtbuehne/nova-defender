/*
    The concept behind fingerprinting is to gather as much information as 
    possible about a player. We have to get a little creative because we can 
    only access very limited functionality through the Lua API. A fingerprint 
    is then stored for each banned player. This is then always compared with all 
    connected players. If we find a sufficient match, we can assume that this 
    person is bypassing a ban.
*/

// we only store the fingerprints of all players during runtime
local fingerprintCache = {}

// we store the frequency distribution of each fingerprint parameter
local parameterCache = {}
local parameterCacheCounts = {}

// percentage of similarity to be considered a match
local sensitivities = {
    ["very high"] = 79,
    ["medium"] = 85,
    ["low"] = 93,
}

local minimumProperties = 12

local allParams = {
    ["sys_screen"] = { ["match"] = 0, ["nomatch"] = 10, ["importance"] = 1 },
    ["sys_os"] = { ["match"] = 0, ["nomatch"] = 100, ["importance"] = 1 },
    ["sys_arch"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["sys_jit"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["sys_win"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["sys_country"] = { ["match"] = 0, ["nomatch"] = 5, ["importance"] = 1 },

    ["gm_dx"] = { ["match"] = 0, ["nomatch"] = 2, ["importance"] = 1 },
    ["gm_games"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["gm_window"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },

    ["fl_auto"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["fl_time_gminfo"] = { ["match"] = 5, ["nomatch"] = 0, ["importance"] = 0.1 },
    ["fl_time_lights"] = { ["match"] = 5, ["nomatch"] = 0, ["importance"] = 0.1 },
    ["fl_time_veh"] = { ["match"] = 5, ["nomatch"] = 0, ["importance"] = 0.1 },
    ["fl_time_se"] = { ["match"] = 5, ["nomatch"] = 0, ["importance"] = 0.1 },

    ["net_asn"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["net_port"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
    ["steam_info"] = { ["match"] = 0, ["nomatch"] = 0, ["importance"] = 1 },
}

local fingerprintPayload = [[
    local seed, mod = 0, 2 ^ 32
    local bls = bit.lshift
    local brs = bit.rshift
    local function blr(x, disp) return bls(x, disp) + brs(x, 32 - disp) end
    local function brr(x, disp) return brs(x, disp) + bls(x, 32 - disp) end
    local function xrshft() seed = blr(seed, 13) + brr(seed, 17) + blr(seed, 5) + seed return seed %% 256 end

    local function enc(input)
        seed = tonumber(string.upper(string.sub(util.SHA1(%q), 1, 8)),16) %% mod
        local out = {}
        for i = 1, string.len(input) do
            local b = string.byte(input, i)
            local c = xrshft()
            local e = bit.bxor(c, b)
            out[i] = string.format("\\%%03d", e)
        end
        return table.concat(out)
    end

    local fp = {
        ["sys_screen"] = ScrW()..ScrH(),
        ["sys_os"] = string.lower(jit.os or ""),
        ["sys_arch"] = string.lower(jit.arch or ""),
        ["sys_jit"] = util.SHA1(util.TableToJSON({select(1,jit.status())}) or ""),
        ["sys_win"] = tostring(system.IsWindows()),
        ["sys_country"] = string.lower(system.GetCountry() or ""),

        ["gm_dx"] = tostring(render.GetDXLevel() or 0),
        ["gm_games"] = util.SHA1(util.TableToJSON(table.MemberValuesFromKey(engine.GetGames(), "installed")) or ""),
        ["gm_window"] = tostring(system.IsWindowed()),

        --["fl_auto"] = util.SHA1(file.Read("cfg/autoexec.cfg", "GAME") or ""),
        ["fl_time_gminfo"] = file.Time("gameinfo.txt", "GAME") > 0 and tostring(file.Time("gameinfo.txt", "GAME")) or nil,
        --["fl_time_lights"] = file.Time("lights.rad", "GAME") > 0 and tostring(file.Time("lights.rad", "GAME")) or nil,
        ["fl_time_veh"] = file.Time("lua/autorun/base_vehicles.lua", "GAME") > 0 and tostring(file.Time("lua/autorun/base_vehicles.lua", "GAME")) or nil,
        ["fl_time_se"] = file.Time("sourceengine", "BASE_PATH") > 0 and tostring(file.Time("sourceengine", "BASE_PATH")) or nil,
        ["dummy"] = true,
    }

    net.Start(%q)
        net.WriteString(enc(util.TableToJSON(fp)))
    net.SendToServer()
]]

Nova.registerAction("banbypass_fingerprint", "banbypass_bypass_fingerprint_action", {
    ["add"] = function(ply, banned, confidence)
        Nova.addDetection(
            ply,
            "banbypass_fingerprint",
            Nova.lang("notify_banbypass_bypass_fingerprint_match", Nova.playerName(ply), Nova.playerName(banned), confidence)
        )
    end,
    ["nothing"] = function(ply, banned, confidence)
        Nova.log("i", string.format("%s might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%. But no action was taken.", Nova.playerName(ply), Nova.playerName(banned), confidence))
    end,
    ["notify"] = function(ply, banned, confidence)
        Nova.log("w", string.format("%s might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%", Nova.playerName(ply), Nova.playerName(banned), confidence))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "banbypass",
            ["message"] = Nova.lang("notify_banbypass_bypass_fingerprint_match", Nova.playerName(ply), Nova.playerName(banned), confidence),
            ["ply"] = Nova.convertSteamID(ply),
        })
    end,
    ["ban"] = function(ply, banned, confidence)
        Nova.log("i", string.format("Banning %s: Fingerprint matches with banned SteamID %s | Confidence: %d%%", Nova.playerName(ply), Nova.playerName(banned), confidence))
        Nova.banPlayer(
            ply,
            Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
            string.format(
                "Sharing device with banned player: %s | Confidence: %d%%",
                Nova.playerName(banned),
                confidence
            ),
            "banbypass_fingerprint"
        )
    end,
    ["allow"] = function(ply, banned, confidence, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%", Nova.playerName(ply), Nova.playerName(banned), confidence))
    end,
    ["ask"] = function(ply, banned, confidence, actionKey, _actions)
        local steamID = Nova.convertSteamID(ply)
        Nova.log("w", string.format("%s might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%", Nova.playerName(ply), Nova.playerName(banned), confidence))
        Nova.askAction({
            ["identifier"] = "banbypass_fingerprint",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_banbypass_bypass_fingerprint_match_action", Nova.playerName(banned), confidence),
            ["ply"] = steamID,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamID,
                    comment = string.format(
                        "Sharing device with banned player: %s | Confidence: %d%%",
                        Nova.playerName(banned),
                        confidence
                    ),
                    reason = Nova.getSetting("banbypass_bypass_default_reason", "Banbypass"),
                    internal_reason = "banbypass_fingerprint"
                })
                Nova.startAction("banbypass_fingerprint", "nothing", steamID, banned, confidence)
                return
            end
            Nova.startAction("banbypass_fingerprint", answer, steamID, banned, confidence, admin)
        end)
    end,
})

local function SendPayload(ply, encryptionKey)
    Nova.sendLua(
        ply,
        string.format(
            fingerprintPayload,
            encryptionKey,
            Nova.netmessage("banbypass_fingerprint")
        ),
        {
            protected = true,
            cache = true,
            reliable = true
        }
    )
    Nova.log("d", string.format("Sent fingerprint payload to %s", Nova.playerName(ply)))
end

local function CompareSimilarity(a, b, minEntries)
    local numerator = 0
    local denominator = 0

    for k, v in pairs(a or {}) do
        local toCompare = b[k]
        if not toCompare then continue end

        // check if parameter is present in distribution
        if not parameterCache[k] then continue end

        // check if both values are present in frequency distribution
        if not parameterCache[k][v] then
            parameterCache[k][v] = math.log(parameterCacheCounts[k] / 2) * (allParams[k] or 1)
        end
        if not parameterCache[k][toCompare] then
            parameterCache[k][toCompare] = math.log(parameterCacheCounts[k] / 2) * (allParams[k] or 1)
        end

        // calculate inverse frequency
        denominator = denominator + parameterCache[k][v]

        if toCompare == v then
            numerator = numerator + parameterCache[k][v] + allParams[k]["match"]
        else
            numerator = numerator - allParams[k]["nomatch"]
        end
    end

    if denominator == 0 then return 0 end
    return math.Clamp(math.floor((numerator / denominator) * 100), 0, 100)
end

local function FingerprintResponse(ply, fp)
    // Add serverside properties to fingerprint
    local _, port = Nova.extractIP(ply:IPAddress(), true)
    local ipInfo = Nova.getCachedVPNInfo(ply)

    if ipInfo and not ipInfo.active_vpn then
        // Information about location
        fp["net_asn"] = ipInfo.ASN

        // Information about network using port
        local portNum = tonumber(port)
        if portNum and portNum > 1 and portNum < 65535 then
            local info = nil
            if portNum == 27005 then
                info = "std"
            elseif portNum >= 27000 and portNum <= 28000 then
                info = "p2p"
            elseif portNum < 27000 then
                info = "low"
            elseif portNum > 28000 then
                info = "high"
            end
            fp["net_port"] = info
        end
    end

    // Get Steam Account Type from SteamID32 (STEAM_UNIVERSE:TYPE:ID)
    /*local universe = string.sub(string.Explode(":", ply:SteamID())[1], 7)
    local accountType = string.Explode(":", ply:SteamID())[2]
    if tonumber(universe) and tonumber(accountType) then
        fp["steam_info"] = string.format("%s:%s", universe, accountType)
    end*/

    local userPropCount = table.Count(fp)
    if userPropCount < minimumProperties then
        Nova.log("w", string.format("Fingerprint check for %s failed: Too few properties (%d of %d)", Nova.playerName(ply), userPropCount, minimumProperties))
        return
    end

    // Cache the fingerprint
    fingerprintCache[ply:SteamID()] = fp
end

local function PrecalcWeights(bans)
    // edge case: if we have no fingerprints, we can't precalc weights
    if not bans or table.Count(bans) == 0 then return end

    local weights = {}

    // Precalculate the weights of each fingerprint parameter
    for k, v in pairs(bans) do
        if not v.fingerprint or type(v.fingerprint) == "string" then continue end

        // count the number of each fingerprint parameter
        for param, value in pairs(v.fingerprint) do
            if not allParams[param] then continue end
            if not weights[param] then
                weights[param] = {
                    ["total"] = 0,
                    ["values"] = {}
                }
            end

            weights[param].total = weights[param].total + 1

            if not weights[param]["values"][value] then
                weights[param]["values"][value] = 1
            else
                weights[param]["values"][value] = weights[param]["values"][value] + 1
            end
        end
    end

    // calculate the frequency distribution of each fingerprint parameter and store it in the cache
    for param, value in pairs(weights) do
        if not parameterCache[param] then
            parameterCache[param] = {}
            parameterCacheCounts[param] = value.total
        end

        for k2, v2 in pairs(value.values) do
            local importance = allParams[param]["importance"] or 1
            local idf = math.log(value.total / (v2 + 1))
            parameterCache[param][k2] = idf * importance
        end
    end
end

Nova.getFingerprint = function(ply_or_steamid)
    local steamID = Nova.convertSteamID(ply_or_steamid)
    return fingerprintCache[steamID]
end

hook.Add("nova_banbypass_check", "banbypass_fingerprint", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not Nova.getSetting("banbypass_bypass_fingerprint_enable", false) then return end

    local fp = fingerprintCache[ply:SteamID()]
    if not fp then return end

    Nova.log("d", string.format("Checking fingerprint for %s", Nova.playerName(ply)))

    local userPropCount = table.Count(fp)

    // Compare the fingerprint with all existing bans
    local bans = Nova.getAllBans()
    local maxSimilarity = {
        ["steamid"] = nil,
        ["similarity"] = 0
    }

    // check if we already have precalculated weights
    if not parameterCache or table.Count(parameterCache) == 0 then
        Nova.log("d", string.format("Precalculating weights for fingerprint check"))
        Nova.profile(PrecalcWeights, bans)
    end

    local function IterateFingerprints()
        for k, v in pairs(bans or {}) do
            coroutine.yield()

            if not v.fingerprint or type(v.fingerprint) == "string" then continue end
            if v.is_banned != 1 and v.ban_on_sight != 1 then continue end

            // Step 1: We calculate the percentage of similar entries with the fingerprint with the least properties
            local banPropCount = table.Count(v.fingerprint)
            if banPropCount < minimumProperties then continue end

            // Step 2: We compare the fingerprints and see if they are similar enough
            // optimization: we compare the fingerprint with the least properties
            local similarity =
                userPropCount < banPropCount
                    and CompareSimilarity(fp, v.fingerprint, userPropCount)
                    or CompareSimilarity(v.fingerprint, fp, banPropCount)

            // Step 3: If the similarity is high enough, we ban the player
            if similarity >= (sensitivities[Nova.getSetting("banbypass_bypass_fingerprint_sensivity", "low")] or 100) then
                Nova.log("d", string.format("Fingerprint matches with banned SteamID %s | Confidence: %d%%", Nova.playerName(v.steamid), similarity))
                local bannedPlayer = v.steamid
                Nova.startDetection("banbypass_fingerprint", ply, bannedPlayer, similarity, "banbypass_bypass_fingerprint_action")
            end

            // Step 4: (Debug) We keep track of the most similar fingerprint
            if similarity > maxSimilarity.similarity then
                maxSimilarity.similarity = similarity
                maxSimilarity.steamid = v.steamid
            end
        end
    end

    local cr = coroutine.create(IterateFingerprints)
    local hookName = "nova_banbypass_fingerprint_co_" .. Nova.generateUUID()
    hook.Add("Think", hookName, function()
        if coroutine.status(cr) == "dead" then
            hook.Remove("Think", hookName)

            // Debug: If we have a most similar fingerprint, we log it
            if maxSimilarity.similarity > 0 and maxSimilarity.steamid then
                Nova.log("d", string.format("Most similar fingerprint for %s with banned player: %s | Confidence: %d%%",
                    Nova.playerName(ply),
                    Nova.playerName(maxSimilarity.steamid),
                    maxSimilarity.similarity)
                )
            end

            return
        end
        coroutine.resume(cr)
    end)
end)

hook.Add("nova_init_loaded", "banbypass_fingerprint", function()
    Nova.log("d", "Creating fingerprint netmessages")
    Nova.netmessage("banbypass_fingerprint")
    local encryptionKey = Nova.generateString(16, 32)
    Nova.netReceive(Nova.netmessage("banbypass_fingerprint"), {auth = true}, function(len, ply)
        // we already have his fingerprint
        if fingerprintCache[ply:SteamID()] then return end

        Nova.log("d", string.format("Received fingerprint check from %s", Nova.playerName(ply)))
        local fingerprint = net.ReadString()

        if not fingerprint or fingerprint == "" then
            Nova.log("w", string.format("Fingerprint response from %s is empty: Indicates manipulation", Nova.playerName(ply)))
            return
        end

        // decrypt fingerprint
        fingerprint = Nova.cipher.decrypt(Nova.decode(fingerprint), encryptionKey)
        fingerprint = util.JSONToTable(fingerprint)

        if not fingerprint or not istable(fingerprint) then
            //TODO: Take action?
            Nova.log("w", string.format("Fingerprint response from %s is invalid: Indicates manipulation", Nova.playerName(ply)))
            return
        elseif not fingerprint["dummy"] then
            Nova.log("w", string.format("Fingerprint response from %s was manipulated", Nova.playerName(ply)))
            return
        end

        // remove dummy entry
        fingerprint["dummy"] = nil

        // check if fingerprint contains only allowed parameters
        for k, v in pairs(fingerprint) do
            if not allParams[k] then
                Nova.log("w", string.format("Fingerprint response from %s contains invalid parameter %q: Indicates manipulation", Nova.playerName(ply), k))
                return
            end
        end

        FingerprintResponse(ply, fingerprint)
    end)

    hook.Add("nova_networking_playerauthenticated", "banbypass_fingerprint", function(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        SendPayload(ply, encryptionKey)
    end)
end)


concommand.Add("nova_finger", function(ply, cmd, args)
    if ply != NULL and not Nova.isProtected(ply) then return end
    PrintTable(fingerprintCache)
    PrintTable(parameterCache)
end)