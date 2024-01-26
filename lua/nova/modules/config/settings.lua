/*
	We only read all configuration data from the database once, and then
    only read from memory. All data is converted to string format.
*/

local configCache = {}

local dataTypesSave = {
    ["string"] = tostring,
    ["number"] = tostring,
    ["boolean"] = tostring,
    ["table"] = util.TableToJSON,
}

local dataTypesLoad = {
    ["string"] = tostring,
    ["number"] = tonumber,
    ["boolean"] = tobool,
    ["table"] = util.JSONToTable,
}

local settingCounter = 0

Nova.setSetting = function(key, value, showInUI, ifNotExists, options, advanced)
    if not key then return end
    if value == nil then return end
    if not options then options = {} end

    local description = key

    local doesExists = configCache[key] != nil and configCache[key].value != nil
    if not doesExists then configCache[key] = {} end

    if ifNotExists then
        // give each setting a number so we can sort them in the UI
        settingCounter = settingCounter + 1
        configCache[key].index = settingCounter
    end

    // if this function gets called in default settings but the config entry does already exist, we return the current value
    if ifNotExists and doesExists then
        configCache[key].options = configCache[key].options or options
        configCache[key].advanced = configCache[key].advanced != nil or advanced
        configCache[key].show_in_ui = configCache[key].show_in_ui != nil or showInUI
        configCache[key].description = configCache[key].description or description

        configCache[key].default = value

        return configCache[key].value
    end

    // check if value can only have certain values
    if configCache[key]
        and configCache[key].options
        and not table.IsEmpty(configCache[key].options)
        and not table.HasValue(configCache[key].options, value)
    then
        Nova.log("e", string.format("Tried to set config key %q to value %q, but the value is not allowed.", tostring(key), tostring(value)))
        return
    end

    // if nothing has changed, we return the current value
    // if configCache[key] and configCache[key].value == value then return value end

    local oldValue = doesExists and configCache[key].value

    // change existing values that have changed
    if doesExists then
        configCache[key].value = value
        if description then configCache[key].description = description end
        if showInUI != nil then configCache[key].show_in_ui = showInUI end
        if not table.IsEmpty(options) then configCache[key].options = options end
        if advanced != nil then configCache[key].advanced = advanced end
    // else create new cache entry
    else
        configCache[key].value = value
        configCache[key].description = description or configCache[key].description or ""
        configCache[key].show_in_ui = (ifNotExists and showInUI or configCache[key].show_in_ui) or false
        configCache[key].options = (ifNotExists and options or configCache[key].options) or {}
        configCache[key].advanced = (ifNotExists and advanced or configCache[key].advanced) or false

        // give each setting a number so we can sort them in the UI
        settingCounter = settingCounter + 1
        configCache[key].index = settingCounter
    end

    // save to database
    local dataType = type(value)
    local convertedValue = dataTypesSave[dataType](value)

    // if the key is not in the cache, we need create a new entry
    if doesExists then
        local query = "UPDATE `nova_config` SET `value` = " .. Nova.sqlEscape(convertedValue) .. " WHERE `key` = " .. Nova.sqlEscape(key) .. ";"
        Nova.query(query)
    else
        local query = "INSERT INTO `nova_config` (`key`, `value`, `data_type`) VALUES (" .. Nova.sqlEscape(key) .. ", " .. Nova.sqlEscape(convertedValue) .. ", '" .. dataType .. "');"
        Nova.query(query)
    end

    // we run a hook so that we can react to changes in other modules
    hook.Run("nova_config_setting_changed", key, value, oldValue)

    return value
end

Nova.deleteSetting = function(key)
    if not key then return end

    // if setting is not in the cache, we return the default value
    if not configCache[key] then
        return
    end

    configCache[key] = nil

    local query = "DELETE FROM `nova_config` WHERE `key` = " .. Nova.sqlEscape(key) .. ";"
    Nova.query(query)
end

// this only gets called by ui
Nova.setUISetting = function(key, value)
    if not configCache[key] or not configCache[key].show_in_ui then
        Nova.log("d", string.format("Tried to change setting %q but it is not acessible in the UI.", key))
        return
    end

    return Nova.setSetting(key, value)
end

// function that returns all setting keys or a single setting
Nova.getUISetting = function(key)
    // no key is given, we return all available settings
    if not key then
        local keys = {}
        for k, v in pairs(configCache or {}) do
            if not v.show_in_ui then continue end
            table.insert(keys, {
                key = k,
                value = v.value,
                description = v.description,
                options = v.options,
                _type = type(v.value),
                advanced = v.advanced,
                index = v.index,
                default = v.default
            })
        end
        return keys, false
    // setting does not exist, we return nil
    elseif not configCache[key] then
        Nova.log("e", string.format("Tried to get setting %q but it does not exist.", key))
        return nil, true
    // setting exists but the setting is not accessible in the UI, we return nil
    elseif not configCache[key].show_in_ui then
        Nova.log("e", string.format("Tried to get setting %q but it is not acessible in the UI.", key))
        return nil, true
    // setting exists and is accessible in the UI, we return the value
    else
        return configCache[key].value, true
    end
end

// only read from memory, not from database
Nova.getSetting = function(key, default)
    if not key then return default end

    // if setting is not in the cache, we return the default value
    if not configCache[key] or configCache[key].value == nil then
        return default
    end

    return configCache[key].value
end

Nova.getSettingDescription = function(key)
    if not key then return end

    // if setting is not in the cache, we return the default value
    if not configCache[key] or not configCache[key].description then
        return Nova.lang("config_no_description")
    end

    return Nova.lang(configCache[key].description)
end

Nova.getAllSettings = function()
    return table.Copy(configCache)
end

Nova.getOptions = function(key)
    if not key then return end

    // if setting is not in the cache, we return the default value
    if not configCache[key] or not configCache[key].options then
        return {}
    end

    return table.Copy(configCache[key].options)
end

Nova.setShowInUI = function(key, show)
    if not key or type(show) != "boolean" then return end

    // if setting is not in the cache, we return the default value
    if not configCache[key] then
        return
    end

    configCache[key].show_in_ui = show
end

local function LoadConfig()
    local query = "SELECT * FROM `nova_config`"
    Nova.selectQuery(query, function(data)
        data = data or {}
        for _, row in pairs(data) do
            configCache[row.key] = {}
            configCache[row.key].value = dataTypesLoad[row.data_type](row.value)
        end
        local entryCount = tostring(#data or 0)
        Nova.log("s", string.format("Loaded %s configuration entries.", entryCount))
        Nova.loadDefaultSettings()
        hook.Run("nova_mysql_config_loaded")
    end)
end

// if we are already connected to database (hook will never run) or do we need to wait?
// depends on whether we setting.lua is loaded before or after mysql.lua
// wait until all modules are loaded
hook.Add("nova_init_loaded", "config_loadconfig", function()
    if Nova.sqlite or Nova.mysql then
        Nova.log("d", "Database is already connected, loading config...")
        LoadConfig()
    else
        Nova.log("d", "Waiting for database to connect, loading config...")
        hook.Add("nova_mysql_connected", "config_loadconfig", LoadConfig)
    end
end)

// in case of lua refresh
if Nova.defaultSettingsLoaded then
    LoadConfig()
end

// Debug Command
/*
concommand.Add("nova_settings", function(ply)
    if ply != NULL and not Nova.isProtected(ply) then return end
    // display all config values
    PrintTable(configCache)
end)
*/