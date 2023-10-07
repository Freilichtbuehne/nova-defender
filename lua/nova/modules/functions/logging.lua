local logLevels = {
    ["d"] = {
        tag = "[DEBUG]",
        color = Color(255, 255, 255),
    },
    ["i"] = {
        tag = "[INFO]",
        color = Color(0, 174, 255),
    },
    ["w"] = {
        tag = "[WARNING]",
        color = Color(255, 255, 0),
    },
    ["e"] = {
        tag = "[ERROR]",
        color = Color(255, 0, 0),
    },
    ["s"] = {
        tag = "[SUCCESS]",
        color = Color(0, 255, 0),
    },
}

local errorLogs = {}

Nova.getErrors = function()
    return table.Copy(errorLogs or {})
end

Nova.log = function(loglevel, message)
    if not message then return end

    // don't log debug messages if debug is disabled
    if loglevel == "d" and Nova.getSetting and not Nova.getSetting("menu_logging_debug", false) then
        return
    end

    local color = logLevels[loglevel] and logLevels[loglevel].color or Color(255, 255, 255)
    local tag = logLevels[loglevel] and logLevels[loglevel].tag or " "

    MsgC(Color(0,204,255), "[Nova Defender] ", color, tag, color_white, " " .. tostring(message), "\n")

    if loglevel == "e" then
        table.insert(errorLogs, message)
    end
end