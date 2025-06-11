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

Nova.fileLogger = {}
Nova.fileLogger.__index = Nova.fileLogger

function Nova.fileLogger:new(filename, lineLimit)
    assert(string.EndsWith(filename, ".txt"), "Filename must end with .txt")

    local instance = {
        filename = filename,
        lineLimit = lineLimit or 5000,
        currentLins = 0,
        logToConsole = false,
    }
    setmetatable(instance, self)

    // initialize the directory
    local directory = string.GetPathFromFilename(filename)
    if not file.Exists(directory, "DATA") then
        file.CreateDir(directory)
    end

    // create the file if it doesn't exist
    local f = file.Open(filename, "a", "DATA")
    // update the line count
    instance.currentLines = table.Count(string.Explode("\n", f:Read(f:Size()) or "")) - 1
    f:Close()

    return instance
end

// addidionally log to console
function Nova.fileLogger:toConsole(logLevel)
    assert(logLevels[logLevel], "Invalid log level")
    self.logToConsole = logLevel
end

function Nova.fileLogger:rotate()
    local date = os.date("%Y%m%d")

    // rename the current file to oldname_date.txt
    local newName = string.Replace(self.filename, ".txt", "_%s.txt")
    newName = string.format(newName, date)

    // if the file already exists, we will append a number to the end
    if file.Exists(newName, "DATA") then
        newName = string.Replace(newName, ".txt", "_%d.txt")
        // set limit to 50 to prevent infinite loop (however this should happen...)
        for i = 1, 50 do
            if not file.Exists(string.format(newName, i), "DATA") then
                newName = string.format(newName, i)
                break
            end
        end
    end

    file.Rename(self.filename, newName)
    self.currentLines = 0
end

function Nova.fileLogger:log(message)
    if not message then return end

    // check if we need to rotate the log
    if self.currentLines >= self.lineLimit then
        self:rotate()
    end

    local logLine = string.format("[%s] %s\n", os.date(Nova.config["language_time"]), message)

    local f = file.Open(self.filename, "a", "DATA")
    f:Write(logLine)
    f:Close()

    // check if we need to log to console
    if self.logToConsole then
        Nova.log(self.logToConsole, message)
    end

    self.currentLines = self.currentLines + 1
end
