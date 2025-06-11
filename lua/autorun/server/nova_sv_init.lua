Nova = Nova or {
    ["version"] = "1.10.0"
}

Nova.extensions = Nova.extensions or {
    ["priv_anticheat"] = {
        ["name"] = "Anticheat",
        ["latest_version"] = "1.1.5",
        ["up_to_date"] = false,
        ["version"] = "",
        ["enabled"] = false,
        ["url"] = "https://github.com/Freilichtbuehne/nova-defender?tab=readme-ov-file#-extended-anticheat"
    },
    ["priv_ddos_protection"] = {
        ["name"] = "DDoS Protection",
        ["latest_version"] = "1.0.2",
        ["up_to_date"] = false,
        ["version"] = "",
        ["enabled"] = false,
        ["url"] = "https://github.com/Freilichtbuehne/nova-defender?tab=readme-ov-file#-ddos-protection"
    },
}

local lines = {
    [[ ]],
    [[ ]],
    [[███╗   ██╗ ██████╗ ██╗   ██╗ █████╗                               ]],
    [[████╗  ██║██╔═══██╗██║   ██║██╔══██╗                              ]],
    [[██╔██╗ ██║██║   ██║██║   ██║███████║                              ]],
    [[██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║                              ]],
    [[██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║                              ]],
    [[╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝                              ]],
    [[                                                                  ]],
    [[██████╗ ███████╗███████╗███████╗███╗   ██╗██████╗ ███████╗██████╗ ]],
    [[██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗]],
    [[██║  ██║█████╗  █████╗  █████╗  ██╔██╗ ██║██║  ██║█████╗  ██████╔╝]],
    [[██║  ██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗]],
    [[██████╔╝███████╗██║     ███████╗██║ ╚████║██████╔╝███████╗██║  ██║]],
    [[╚═════╝ ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝]],
    [[═══ 🛡️ All-in-One Security Solution 🛡️ ═══]]
}
for i = 1, #lines do MsgC( Color(3,169,244), lines[i] .. "\n") end

// print version
MsgC( Color(3,169,244), string.format("Version v.%s\n", Nova["version"] or "unknown"))

// include main config
include("nova/sv_config.lua")

// include all folders in the nova/modules folder
local _, folders = file.Find("nova/modules/*", "LUA")

// load in following sequence:
local loadingOrder = {
    {
        ["name"] = "language",
        ["client"] = true,
        // true: load, false: skip
        ["check"] = function(_file)
            if _file == "languages.lua" then return true end
            return Nova.config["language"] == string.gsub(_file, ".lua", "")
        end,
        ["clientcheck"] = function(_file)
            if _file == "languages.lua" then return false end
            return true
        end
    },
    {
        ["name"] = "functions",
        ["client"] = false,
    },
    {
        ["name"] = "config",
        ["client"] = false,
    },
}

// add rest of the folders to the loading order
for _, folder in pairs(folders or {}) do
    // skip folders that are already in the loading order
    local skip = false
    for _, entry in pairs(loadingOrder or {}) do
        if entry["name"] == folder then skip = true continue end
    end
    if skip then continue end
    table.insert(loadingOrder, { ["name"] = folder })
end

// load files in the loading order
for _, entry in pairs(loadingOrder or {}) do
    local folder = entry["name"]
    // include all files in the modules folder
    local files, _ = file.Find(string.format("nova/modules/%s/*.lua", folder), "LUA")

    // sort files alphabetically (key(number), value(string))
    table.sort(files, function(a, b) return a < b end)

    for _, _file in pairs(files or {}) do
        // check if this file should be loaded
        if entry["check"] and not entry["check"](_file) then continue end

        // load the file serverside
        include(string.format("nova/modules/%s/%s", folder, _file))
        MsgC(Color(3,169,244), "[SERVER] ", Color(255,2555,255), string.format("Including %s\n", _file))

        // check if clients should load this file too
        if not entry["client"] then continue end
        if entry["clientcheck"] and not entry["clientcheck"](_file) then continue end
        MsgC(Color(222,169,9), "[CLIENT] ", Color(255,2555,255), string.format("Including %s\n", _file))
        AddCSLuaFile(string.format("nova/modules/%s/%s", folder, _file))
    end
end

// load materials to download
resource.AddFile( "materials/nova/banner.png" )
resource.AddFile( "materials/nova/icon.png" )
resource.AddFile( "materials/nova/discord.png" )

MsgC(Color(3,169,244),"\n[Nova Defender] [INFO] finished loading","\n")
hook.Run("nova_init_loaded")
Nova.initloaded = true