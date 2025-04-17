// Version scheme: major.minor.patch

local patches = {
    ["1.2.9"] = function()
        // Drop database nova_detections and create new one
        Nova.log("i", "Replacing database nova_detections with new one")
        Nova.query("DROP TABLE IF EXISTS `nova_detections`")
        local detectionsQuery = "CREATE TABLE IF NOT EXISTS `nova_detections` (" ..
            "`id` TEXT, " ..
            "`steamid` VARCHAR(255) NOT NULL, " ..
            "`comment` TEXT, " ..
            "`reason` TEXT, " ..
            "`internal_reason` TEXT, " ..
            "`time` INT(11), " ..
            "`action_taken` INT(1), " ..
            "`action_taken_at` INT(11), " ..
            "`action_taken_by` VARCHAR(255), " ..
            "PRIMARY KEY (`id`)" ..
        ");"
        Nova.query(detectionsQuery)
    end,
    ["1.7.0"] = function()
        // Merge both settings into one
        Nova.log("i", "Merging networking_fetch_domains and networking_post_domains into networking_http_whitelistdomains")
        local whitelistFetch = Nova.getSetting("networking_fetch_domains", {})
        local whitelistPost = Nova.getSetting("networking_post_domains", {})

        local merge = {}
        for k,v in ipairs(whitelistFetch) do
            if not table.HasValue(merge, v) then table.insert(merge, v) end
        end
        for k,v in ipairs(whitelistPost) do
            if not table.HasValue(merge, v) then table.insert(merge, v) end
        end
        Nova.setSetting("networking_http_whitelistdomains", merge)

        Nova.setSetting("networking_http_logging", Nova.getSetting("networking_fetch_logging", false) or Nova.getSetting("networking_post_logging", false))

        // delete old settings
        Nova.deleteSetting("networking_fetch_domains")
        Nova.deleteSetting("networking_post_domains")
        Nova.deleteSetting("networking_fetch_logging")
        Nova.deleteSetting("networking_post_logging")
    end,
    ["1.8.0"] = function()
        Nova.log("i", "Deleting obsolete setting")
        Nova.deleteSetting("networking_screenshot_steam")
    end,
    ["1.10.0"] = function()
        local cur = Nova.getSetting("banbypass_bypass_fingerprint_action", "ask")
        if cur == "ban" then
            Nova.log("i", "Disabling 'ban' action for fingerprint bypass")
            Nova.setSetting("banbypass_bypass_fingerprint_action", "ask")
        end
    end
}

local function SearchPatch(oldVersion, newVersion)
    local patchesNecessary = {}
    for version, patch in pairs(patches) do
        if not Nova.isVersionHigherOrEqual(oldVersion, version) and Nova.isVersionHigherOrEqual(newVersion, version) then
            table.insert(patchesNecessary, version)
        end
    end
    // sort (low to high) 
    table.sort(patchesNecessary, function(a, b) return not Nova.isVersionHigherOrEqual(a, b) end)
    return patchesNecessary
end

local function CheckVersion()
    local lastVersion = Nova.getSetting("compatibility_lastversion", "none")
    // first time running Nova
    if lastVersion == "none" then
        lastVersion = Nova["version"]
        Nova.setSetting("compatibility_lastversion", lastVersion, false, true)
    end

    // version hasn't changed
    if lastVersion == Nova["version"] then return end

    // version has changed
    Nova.setSetting("compatibility_lastversion", Nova["version"])
    local patchesNecessary = SearchPatch(lastVersion, Nova["version"])

    // no patches found
    if #patchesNecessary == 0 then
        Nova.log("i", string.format("No patches necessary for version %s", Nova["version"]))
        return
    end

    Nova.log("i", string.format("Found %i patches for updating from version %s to %s", #patchesNecessary, lastVersion, Nova["version"]))
    for _, version in pairs(patchesNecessary) do
        if isfunction(patches[version]) then
            Nova.log("i", string.format("Running patch for version %s", version))
            patches[version]()
            Nova.log("s", string.format("Patch for version %s finished", version))
        else
            Nova.log("e", string.format("Patch for version %s invalid", version))
        end
    end
end


if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "compatibility_versionchanges", CheckVersion)
else
    CheckVersion()
end