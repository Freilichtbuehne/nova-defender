Nova.registerExtension = function(id, version)
    // Step 1: Check if the extension exists
    if not Nova.extensions[id] then
        Nova.log("e", string.format("Failed to register extension %s: Extension does not exist", id))
        return
    end

    // Step 2: Check if the version is up to date
    if Nova.isVersionHigherOrEqual(version, Nova.extensions[id]["latest_version"]) then
        Nova.extensions[id]["up_to_date"] = true
    end

    // Step 3: Set the version
    Nova.extensions[id]["version"] = version

    // Step 4: Enable the extension
    Nova.extensions[id]["enabled"] = true
end
