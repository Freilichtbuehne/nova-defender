local cachedLang = Nova.config["language"]
local cachedLanguageTable = Nova["languages_" .. Nova.config["language"]] and Nova["languages_" .. Nova.config["language"]]() or nil

Nova.lang = function(key, ...)
    // check if language changed
    if cachedLang != Nova.config["language"] then
        cachedLang = Nova.config["language"]

        // check if language table exists
        if Nova["languages_" .. Nova.config["language"]] then
            cachedLanguageTable = Nova["languages_" .. Nova.config["language"]]()
        // if not, use english
        else
            cachedLanguageTable = Nova["languages_en"]()
        end
    end

    // check if cachedLanguageTable exists
    if not cachedLanguageTable then
        // check if we can load the language table
        if Nova["languages_" .. Nova.config["language"]] then
            cachedLanguageTable = Nova["languages_" .. Nova.config["language"]]()
        else
            Nova.log("e", string.format("Language %q does not exist", Nova.config["language"]))
            // we return the key as a fallback
            return key
        end
    end

    // check if this phrase exists
    if not cachedLanguageTable[key] then
        Nova.log("d", string.format("Missing language key: %q in language: %q", key,  Nova.config["language"]))
        // we return the key as a fallback
        return key
    end

    // check if we have args (implement string.format directly in the language function)
    local args = {...}
    if args then
        return string.format(cachedLanguageTable[key], unpack(args))
    else
        return cachedLanguageTable[key]
    end
end