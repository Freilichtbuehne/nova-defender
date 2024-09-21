local function CreateTables(callback)
    local configQuery, configCreated = "CREATE TABLE IF NOT EXISTS `nova_config` (" ..
        "`key` VARCHAR(255) NOT NULL, " ..
        "`value` TEXT NOT NULL, " ..
        "`data_type` VARCHAR(255) NOT NULL, " ..
        "PRIMARY KEY (`key`)" ..
    ");", false

    local banQuery, bansCreated = "CREATE TABLE IF NOT EXISTS `nova_bans` (" ..
        "`steamid` VARCHAR(255) NOT NULL, " ..
        "`ip` VARCHAR(255), " ..
        "`comment` TEXT, " ..
        "`reason` TEXT, " ..
        "`internal_reason` TEXT, " ..
        "`time` INT(11), " ..
        "`ban_on_sight` INT(1), " ..
        "`unban_on_sight` INT(1), " ..
        "`secret_key` VARCHAR(255), " ..
        "`is_banned` INT(1), " ..
        "`fingerprint` TEXT, " ..
        "PRIMARY KEY (`steamid`)" ..
    ");", false


    local detectionsQuery, detectionsCreated = "CREATE TABLE IF NOT EXISTS `nova_detections` (" ..
        "`id` VARCHAR(36) NOT NULL," ..
        "`steamid` VARCHAR(255) NOT NULL, " ..
        "`comment` TEXT, " ..
        "`reason` TEXT, " ..
        "`internal_reason` TEXT, " ..
        "`time` INT(11), " ..
        "`action_taken` INT(1), " ..
        "`action_taken_at` INT(11), " ..
        "`action_taken_by` VARCHAR(255), " ..
        "PRIMARY KEY (`id`)" ..
    ");", false

    local function AllCreated()
        return configCreated and bansCreated and detectionsCreated
    end

    Nova.selectQuery(configQuery, function(data)
        if data != false then
            configCreated = true
            Nova.log("s", "Created nova_config table.")
            if AllCreated() and isfunction(callback) then
                callback()
            end
        else
            Nova.log("e", "Failed to create nova_config table.")
        end
    end)

    Nova.selectQuery(banQuery, function(data)
        if data != false then
            bansCreated = true
            Nova.log("s", "Created nova_bans table.")
            if AllCreated() and isfunction(callback) then
                callback()
            end
        else
            Nova.log("e", "Failed to create nova_bans table.")
        end
    end)

    Nova.selectQuery(detectionsQuery, function(data)
        if data != false then
            detectionsCreated = true
            Nova.log("s", "Created nova_detections table.")
            if AllCreated() and isfunction(callback) then
                callback()
            end
        else
            Nova.log("e", "Failed to create nova_detections table.")
        end
    end)
end

local function ConnectToDatabase()
    require("mysqloo")
    Nova.mysql = mysqloo.connect(Nova.config["mysql_host"],
                                        Nova.config["mysql_username"],
                                        Nova.config["mysql_pass"],
                                        Nova.config["mysql_db"],
                                        Nova.config["mysql_port"])
    Nova.mysql:connect()
    Nova.mysql.onConnected = function()
        Nova.log("s", "Connected to MySQL database.")
        CreateTables(function()
            hook.Run("nova_mysql_connected")
        end)
    end
    Nova.mysql.onConnectionFailed = function(db, err)
        if not err then err = "Unknown Error" end
        Nova.log("e", string.format("Failed to connect to MySQL database: %q", tostring(err)))
    end
end

Nova.query = function(queryString)
    // Query must be defined
    if not queryString then
        Nova.log("e", "Nova.query: Query failed: Query string is nil.")
        return
    end

    // get caller function name
    local info = debug.getinfo(2, "Sl")
    local _info = debug.getinfo(3, "Sl")

    Nova.log("d", "Executing Query: " .. queryString)
    if Nova.config["use_mysql"] then
        local query = Nova.mysql:query(queryString)

        function query:onError( qe, err, _sql )
            print(qe, err, _sql)
            if info then
                Nova.log("e", string.format("MySQL query error: %q (%q:%s)", err or "EMPTY", info.short_src, info.currentline))
            end

            if _info then
                Nova.log("e", string.format("MySQL query error: %q (%q:%s)", err or "EMPTY", _info.short_src, _info.currentline))
            end
        end

        query:start()
    else
        sql.m_strError = nil
        sql.Query(queryString)
        // check for error
        if sql.LastError() and sql.LastError() != "" then
            if info then
                Nova.log("e", string.format("SQLite query error: %q (%q:%s)", sql.LastError(), info.short_src, info.currentline))
            end

            if _info then
                Nova.log("e", string.format("SQLite query error: %q (%q:%s)", sql.LastError(), _info.short_src, _info.currentline))
            end
            // clear error
            sql.m_strError = nil
        end
    end
end

Nova.selectQuery = function(queryString, callback)
    // Query must be defined
    if not queryString then
        Nova.log("e", "Nova.selectQuery: Query is nil!")
        if isfunction(callback) then callback(false) end
        return
    end

    // get caller function name
    local info = debug.getinfo(2, "Sl")
    local _info = debug.getinfo(3, "Sl")

    Nova.log("d", string.format("Executing Select Query: %q", queryString))
    if Nova.config["use_mysql"] then
        local query = Nova.mysql:query(queryString)

        function query:onSuccess(data)
            if isfunction(callback) then callback(data) end
        end

        function query:onError( qe, err, _sql )
            if info then
                Nova.log("e", string.format("MySQL query error: %q (%q:%s)", err or "EMPTY", info.short_src, info.currentline))
            end
            if _info then
                Nova.log("e", string.format("MySQL query error: %q (%q:%s)", err or "EMPTY", _info.short_src, _info.currentline))
            end
            if isfunction(callback) then callback(false) end
        end

        query:start()
    else
        sql.m_strError = nil
        local res = sql.Query(queryString)
        // check for error
        if sql.LastError() and sql.LastError() != "" then

            if info then
                Nova.log("e", string.format("SQLite query error: %q (%q:%s)", sql.LastError(), info.short_src, info.currentline))
            end

            if _info then
                Nova.log("e", string.format("SQLite query error: %q (%q:%s)", sql.LastError(), _info.short_src, _info.currentline))
            end
            // clear error
            sql.m_strError = nil
        end
        if isfunction(callback) then callback(res) end
    end
end

Nova.sqlEscape = function(str)
    if Nova.config["use_mysql"] then
        return "'" .. (Nova.mysql:escape(str) or "") .. "'"
    else
        return sql.SQLStr(str)
    end
end


// Debug Commands
/*
local function DeleteAllTables()
    local query = "DROP TABLE IF EXISTS `nova_config`;"
    Nova.query(query)

    query = "DROP TABLE IF EXISTS `nova_bans`;"
    Nova.query(query)
end

concommand.Add("nova_delete", function(ply)
    if ply != NULL and not Nova.isProtected(ply) then return end
    DeleteAllTables()
    if ulx then
        RunConsoleCommand("ulx", "maprestart")
    else
        RunConsoleCommand("map", "gm_construct")
    end
end)

concommand.Add("nova_show", function(ply)
    if ply != NULL and not Nova.isProtected(ply) then return end
    // display all config values
    Nova.selectQuery("SELECT * FROM `nova_config`", function(data)
        if data then
            for k, v in pairs(data or {}) do
                print(v.key, v.value, v.data_type)
            end
        end
    end)
end)
*/

// only load once
if Nova.config["use_mysql"] and not Nova.mysql then
    Nova.log("d", "Using MySQL database.")
    ConnectToDatabase()
elseif not Nova.config["use_mysql"] and not Nova.sqlite then
    Nova.log("d", "Using local SQLite-Database")
    Nova.sqlite = true
    CreateTables()
    hook.Run("nova_mysql_connected")
end