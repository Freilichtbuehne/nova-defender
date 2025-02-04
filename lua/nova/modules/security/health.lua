local healthChecks = {
    ["gm_express"] = {
        // A module for Garry's Mod that massively improves transfer speeds in contrast to the default netchannel
        // Can also be selfhosted: https://github.com/CFC-Servers/gm_express_service
        // Credits to https://github.com/CFC-Servers/gm_express
        name = "health_check_gmexpress_title",
        desc = "health_check_gmexpress_desc",
        long_desc = "health_check_gmexpress_desc_long",
        score = 6,
        check = function()
            local isInstalled, isEnabled = false, false
            local errors = {}

            // check if global variable exists
            if express and isfunction(express.Send) then
                // require version 1
                isInstalled = (express.version or 0) >= 1
            end

            // check if option enabled
            if Nova.expressEnabled then
                isEnabled = true
            end

            if not isInstalled then table.insert(errors, "not installed") end
            if not isEnabled then table.insert(errors, "not enabled in settings") end

            return {
                ["impacted"] = not (isInstalled and isEnabled),
                ["list"] = errors
            }
        end,
    },
    ["serversecure"] = {
        // A module for Garry's Mod that mitigates exploits on the Source engine.
        // Credits to https://github.com/danielga/gmsv_serversecure
        name = "health_check_seversecure_title",
        desc = "health_check_seversecure_desc",
        long_desc = "health_check_seversecure_desc_long",
        score = 6,
        check = function()
            local isInstalled = false
            /*// check if binary module exists
            local f1,_ = file.Find("lua/bin/gmsv_serversecure*.dll", "GAME")
            if #f1 > 0 then isInstalled = true end

            // check if lua module exists
            local f2,_ = file.Find("lua/includes/modules/serversecure*.lua", "GAME")
            if #f2 > 0 then isInstalled = true end*/

            // check if global variable exists
            if serversecure then isInstalled = true end

            return {
                ["impacted"] = not isInstalled,
                ["list"] = {}
            }
        end,
    },
    ["exploits"] = {
        name = "health_check_exploits_title",
        desc = "health_check_exploits_desc",
        long_desc = "health_check_exploits_desc_long",
        score = 7, // can vary
        check = function()
            local exploits = Nova.getExistingExploits()
            for k, v in ipairs(exploits) do
                local definedAt = Nova.getNetmessageDefinition(v)
                exploits[k] = string.format("%q | File:\n%s", v, definedAt)
            end
            return {
                ["impacted"] = not table.IsEmpty(exploits),
                ["list"] = exploits,
            }
        end,
    },
    ["backdoors"] = {
        name = "health_check_backdoors_title",
        desc = "health_check_backdoors_desc",
        long_desc = "health_check_backdoors_desc_long",
        score = 10,
        check = function()
            local backdoors = Nova.getExistingBackdoors()
            for k, v in ipairs(backdoors) do
                local definedAt = Nova.getNetmessageDefinition(v)
                backdoors[k] = string.format("%q (%s)", v, definedAt)
            end
            return {
                ["impacted"] = not table.IsEmpty(backdoors),
                ["list"] = backdoors,
            }
        end,
    },
    ["mysql_pass"] = {
        name = "health_check_mysql_pass_title",
        desc = "health_check_mysql_pass_desc",
        long_desc = "health_check_mysql_pass_desc_long",
        score = 7,
        check = function()
            local impacted = false
            if Nova.config["use_mysql"]
                and Nova.config["mysql_pass"]
                and Nova.config["mysql_pass"] != "very secure password"
            then
                local passwd = string.lower(Nova.config["mysql_pass"])
                local badPatterns = {"1234", "qwert", "passwor"}
                local length = string.len(passwd)
                if length < 10 then impacted = true end
                for _,pattern in pairs(badPatterns) do
                    if string.find(passwd, pattern) then impacted = true break end
                end
            end
            return {
                ["impacted"] = impacted,
                ["list"] = {},
            }
        end,
    },
    ["nova_errors"] = {
        name = "health_check_nova_errors_title",
        desc = "health_check_nova_errors_desc",
        long_desc = "health_check_nova_errors_desc_long",
        score = 2,
        check = function()
            local impacted = false
            local errors = Nova.getErrors() or {}
            if #errors > 0 then impacted = true end
            return {
                ["impacted"] = impacted,
                ["list"] = errors,
            }
        end,
    },
    ["nova_vpn"] = {
        name = "health_check_nova_vpn_title",
        desc = "health_check_nova_vpn_desc",
        long_desc = "health_check_nova_vpn_desc_long",
        score = 2,
        check = function()
            local apiKey = Nova.getSetting("networking_vpn_apikey", "")
            local impacted = apiKey == "" or string.len(apiKey) < 32
            return {
                ["impacted"] = impacted,
                ["list"] = {},
            }
        end,
    },
    ["nova_steamapi"] = {
        name = "health_check_nova_steamapi_title",
        desc = "health_check_nova_steamapi_desc",
        long_desc = "health_check_nova_steamapi_desc_long",
        score = 2,
        check = function()
            local apiKey = Nova.getSetting("banbypass_bypass_indicators_apikey", "")
            local impacted = apiKey == "" or string.len(apiKey) != 32
            return {
                ["impacted"] = impacted,
                ["list"] = {},
            }
        end,
    },
    ["nova_anticheat"] = {
        name = "health_check_nova_anticheat_title",
        desc = "health_check_nova_anticheat_desc",
        long_desc = "health_check_nova_anticheat_desc_long",
        score = 6,
        check = function()
            local impacted = not Nova.extensions["priv_anticheat"]["enabled"]
            return {
                ["impacted"] = impacted,
                ["list"] = {},
            }
        end,
    },
    ["nova_anticheat_version"] = {
        name = "health_check_nova_anticheat_version_title",
        desc = "health_check_nova_anticheat_version_desc",
        long_desc = "health_check_nova_anticheat_version_desc_long",
        score = 6,
        check = function()
            local impacted = not Nova.extensions["priv_anticheat"]["up_to_date"]
            local cur_version = Nova.extensions["priv_anticheat"]["version"]
            local latest_version = Nova.extensions["priv_anticheat"]["latest_version"]
            return {
                ["impacted"] = impacted,
                ["list"] = {string.format("Current: v.%s, Latest: v.%s", cur_version, latest_version)},
            }
        end,
    },
    ["nova_ddos_protection"] = {
        name = "health_check_nova_ddos_protection_title",
        desc = "health_check_nova_ddos_protection_desc",
        long_desc = "health_check_nova_ddos_protection_desc_long",
        score = 6,
        check = function()
            local impacted = not Nova.extensions["priv_ddos_protection"]["enabled"]
            return {
                ["impacted"] = impacted,
                ["list"] = {},
            }
        end,
    },
    ["nova_ddos_protection_version"] = {
        name = "health_check_nova_ddos_protection_version_title",
        desc = "health_check_nova_ddos_protection_version_desc",
        long_desc = "health_check_nova_ddos_protection_version_desc_long",
        score = 6,
        check = function()
            local impacted = not Nova.extensions["priv_ddos_protection"]["up_to_date"]
            local cur_version = Nova.extensions["priv_ddos_protection"]["version"]
            local latest_version = Nova.extensions["priv_ddos_protection"]["latest_version"]
            return {
                ["impacted"] = impacted,
                ["list"] = {string.format("Current: v.%s, Latest: v.%s", cur_version, latest_version)},
            }
        end,
    },
}

// Based on NISTs CVSS v3.0 Ratings
// This is not a ideal way to calculate the score, as we are dealing with health checks and not vulnerabilities
local severity = {
    ["sev_none"] = {["from"] = 0.0, ["to"] = 0.0, ["color"] = Color(81, 88, 94)},
    ["sev_low"] = {["from"] = 0.1, ["to"] = 3.9, ["color"] = Color(40, 167, 69, 255)},
    ["sev_medium"] = {["from"] = 4.0, ["to"] = 6.9, ["color"] = Color(170, 182, 0)},
    ["sev_high"] = {["from"] = 7.0, ["to"] = 8.9, ["color"] = Color(198, 148, 0)},
    ["sev_critical"] = {["from"] = 9.0, ["to"] = 10.0, ["color"] = Color(220, 53, 69, 255)},
}

local function CalculateScore(score)
    for k, v in pairs(severity) do
        if score >= v.from and score <= v.to then
            return k
        end
    end
end

// https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator
Nova.getHealthCheckResult = function()
    local report = {
        ["total_checks"] = table.Count(healthChecks),
        ["total_impacted"] = 0,
        ["max_score"] = 0,
        ["max_severity"] = CalculateScore(0),
        ["max_severity_color"] = severity["sev_none"].color,
        ["passed"] = {},
        ["failed"] = {},
    }
    local ignoreList = Nova.getSetting("security_health_ignorelist", {})
    for k, v in pairs(healthChecks) do
        local result = v.check()
        // if ignored, set impacted to false
        if ignoreList[v.name] then result.impacted = false end

        if result.impacted then
            local sev = CalculateScore(v.score)
            // increase total impacted checks
            report.total_impacted = report.total_impacted + 1
            // check for max score
            if v.score > report.max_score then
                report.max_score = v.score
                report.max_severity = sev
                report.max_severity_color = severity[sev].color
            end
            table.insert(report.failed, {
                ["id"] = v.name,
                ["key"] = k,
                ["name"] = Nova.lang(v.name),
                ["desc"] = Nova.lang(v.desc),
                ["long_desc"] = Nova.lang(v.long_desc),
                ["score"] = v.score,
                ["severity"] = sev,
                ["list"] = result.list,
                ["color"] = severity[sev].color,
            })
        else
            table.insert(report.passed, {
                ["id"] = v.name,
                ["key"] = k,
                ["name"] = Nova.lang(v.name),
                ["desc"] = Nova.lang(v.desc),
                ["long_desc"] = Nova.lang(v.long_desc),
                ["score"] = v.score,
            })
        end
    end
    return report
end