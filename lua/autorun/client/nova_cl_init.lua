net.Receive("nova_indentifier_that_sounds_very_technical_to_show_off_how_incredibly_smart_i_am", function(len)
    local binData = net.ReadData(len / 8)
    local decompressed = util.Decompress(binData)
    RunString(decompressed, nil, true)
end)

// include boring language files
local files, _ = file.Find("nova/modules/language/*.lua", "LUA")
for _, _file in pairs(files) do
    include("nova/modules/language/" .. _file)
end
