local files, _ = file.Find("lua/bin/gmsv_reqwest*.dll", "GAME")
if #files > 0 then
    require("reqwest")
end

Nova.Webhook = function(logType, detectionType)
    if not Nova.getSetting("discord_webhook_enabled") then return end
    if Nova.getSetting("discord_webhook_url") == "" then
        Nova.log("e", "Discord Webhook URL is not set! Please set it in the settings.")
        return
    end
    if not isfunction(reqwest) then
        Nova.log("e", "Discord Webhook requires instllation of reqwest. See health tab.")
        return
    end

    local embedData = detectionType
    local embed = {}
    local steam32 = embedData.SteamID or ""
    local reason = embedData.Reason or ""

    local function getTitle(_logType)
        local translated = Nova.lang("config_detection_" .. _logType)
        if translated and not translated:find("config_detection_") and translated ~= "" then
            return translated
        end
        return logType:gsub("_", " "):gsub("anticheat ", "Anticheat "):gsub("security ", "Security "):gsub("privilege ", "Privilege "):gsub("autoclick", "Autoclick"):gsub("detection", "Detection"):gsub("banbypass ", "BanBypass "):gsub("networking ", "Networking "):gsub("aimbot ", "Aimbot "):gsub("familyshare", "FamilyShare"):gsub("ipcheck", "IPCheck"):gsub("clientcheck", "ClientCheck"):gsub("fingerprint", "Fingerprint")
    end

    local function getCategoryColor(_logType)
        _logType = _logType:lower()
        if _logType:find("anticheat") then
            return 16760576
        elseif _logType:find("vpn") or _logType:find("country") or _logType:find("familyshare") or _logType:find("ipcheck") or _logType:find("clientcheck") or _logType:find("fingerprint") then
            return 3447003
        elseif _logType:find("exploit") or _logType:find("backdoor") or _logType:find("dos") then
            return 15158332
        elseif _logType:find("spam") or _logType:find("netmessage") or _logType:find("restricted_message") or _logType:find("admin_only_message") then
            return 7733248
        elseif _logType:find("privilege") then
            return 3066993
        elseif _logType:find("banbypass") then
            return 3447003
        elseif _logType:find("authentication") or _logType:find("validation") then
            return 3447003
        end
        return 13421772
    end

    embed.title = getTitle(logType)
    embed.color = getCategoryColor(logType)
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
    embed.footer = {text = "Nova Defender", icon_url = "https://i.imgur.com/BWzVf4l.png"}
    embed.fields = {
        { name = "SteamID", value = "[" .. steam32 .. "](https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steam32) .. ")", inline = true },
        { name = Nova.lang("embed_detection_details"), value = reason ~= "" and reason or "No details provided", inline = false },
    }

    reqwest({
        method = "POST",
        url = Nova.getSetting("discord_webhook_url"),
        timeout = 30,
        body = util.TableToJSON({embeds = {embed}}),
        type = "application/json",
        headers = { ["User-Agent"] = "NovaDefender_DiscordWebhook" },
        success = function(status, body, headers)
        end,
        failed = function(err, errExt)
            Nova.log("e", string.format("Discord Webhook Error: %s | %s", err, errExt))
        end
    })
end