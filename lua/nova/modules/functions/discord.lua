local files, _ = file.Find("lua/bin/gmsv_reqwest*.dll", "GAME")
if #files > 0 then
    require("reqwest")
end

Nova.Webhook = function(logType, detectionType)
    if Nova.getSetting("discord_webhook_enabled") then
        local embedData = detectionType
        local embed = {}
        local steam32 = embedData.SteamID or ""
        local reason = embedData.Reason or ""
        local info = embedData.Info or ""

        local steamProfileUrl = ""
        if steam32 ~= "" and util and util.SteamIDTo64 then
            steamProfileUrl = "https://steamcommunity.com/profiles/" .. tostring(util.SteamIDTo64(steam32))
        end

        local function getTitle(logType)
            local translated = Nova.lang("config_detection_" .. logType)
            if translated and not translated:find("config_detection_") and translated ~= "" then
                return translated
            end
            return logType:gsub("_", " "):gsub("anticheat ", "Anticheat "):gsub("security ", "Security "):gsub("privilege ", "Privilege "):gsub("autoclick", "Autoclick"):gsub("detection", "Detection"):gsub("banbypass ", "BanBypass "):gsub("networking ", "Networking "):gsub("aimbot ", "Aimbot "):gsub("familyshare", "FamilyShare"):gsub("ipcheck", "IPCheck"):gsub("clientcheck", "ClientCheck"):gsub("fingerprint", "Fingerprint")
        end

        local function getCategoryColor(logType)
            logType = logType:lower()
            if logType:find("anticheat") then
                return 16760576
            elseif logType:find("vpn") or logType:find("country") or logType:find("familyshare") or logType:find("ipcheck") or logType:find("clientcheck") or logType:find("fingerprint") then
                return 3447003
            elseif logType:find("exploit") or logType:find("backdoor") or logType:find("dos") then
                return 15158332
            elseif logType:find("spam") or logType:find("netmessage") or logType:find("restricted_message") or logType:find("admin_only_message") then
                return 7733248
            elseif logType:find("privilege") then
                return 3066993
            elseif logType:find("banbypass") then
                return 3447003
            elseif logType:find("authentication") or logType:find("validation") then
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
            end
        })
    end
end