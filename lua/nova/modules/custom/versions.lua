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
}

local function IsVersionHigherOrEqual(version1, version2)
    if version1 == version2 then return true end
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

local function SearchPatch(oldVersion, newVersion)
    local patchesNecessary = {}
    for version, patch in pairs(patches) do
        if not IsVersionHigherOrEqual(oldVersion, version) and IsVersionHigherOrEqual(newVersion, version) then
            table.insert(patchesNecessary, version)
        end
    end
    // sort (low to high) 
    table.sort(patchesNecessary, function(a, b) return not IsVersionHigherOrEqual(a, b) end)
    return patchesNecessary
end

hook.Add("nova_mysql_config_loaded", "compatibility_versionchanges", function()
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
end)