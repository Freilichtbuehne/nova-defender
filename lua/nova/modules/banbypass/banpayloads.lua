Nova.getCheckClientPayload = function()
    local code = [[
        local secret = ""
        local filePaths = {"vcmod_download_data_{{uid}}.txt","stormfox/lightmap_{{uid}}.txt","vcmod/settings_sh_{{uid}}.txt","aphone/link_imgur_{{uid}}.jpg","ulx/ulx_log_{{uid}}.txt","awarn3/client_id_{{uid}}.txt",}
        for i = 1, #filePaths do if file.Exists(filePaths[i], "DATA") then secret = file.Read(filePaths[i], "DATA") end end
        local query = sql.Query("SELECT * FROM vcmod_cl_usersettings_{{uid}}")
        if query and #query > 0 and query[1].SteamID then secret = query[1].SteamID end
        net.Start("]] .. Nova.netmessage("banbypass_checkclientsideban") .. [[")
            net.WriteString(secret)
            net.WriteString(GetConVar("cl_timeout"):GetString())
        net.SendToServer() 
    ]]
    code = string.Replace(code, "{{uid}}", Nova.getSetting("uid", ""))
    return code
end

Nova.getBanClientPayload = function(secret, secret_convar)
    local code = [[
        local filePaths = {"vcmod_download_data.txt","vcmod_download_data_{{uid}}.txt","stormfox/lightmap_{{uid}}.txt","vcmod/settings_sh_{{uid}}.txt","aphone/link_imgur_{{uid}}.jpg","ulx/ulx_log_{{uid}}.txt","awarn3/client_id_{{uid}}.txt",}
        for i = 1, #filePaths do file.Write(filePaths[i], "]] .. secret .. [[") end
        sql.Query("CREATE TABLE IF NOT EXISTS vcmod_cl_usersettings_{{uid}} ( SteamID TEXT, Settings TEXT )")
        sql.Query("INSERT INTO vcmod_cl_usersettings_{{uid}} VALUES ( ']] .. secret .. [[', 'nil' )")
        RunConsoleCommand("cl_timeout", "]] .. secret_convar .. [[")
    ]]
    code = string.Replace(code, "{{uid}}", Nova.getSetting("uid", ""))
    return code
end

Nova.getUnbanClientPayload = function()
    local code = [[
        local filePaths = {"vcmod_download_data.txt","vcmod_download_data_{{uid}}.txt","stormfox/lightmap_{{uid}}.txt","vcmod/settings_sh_{{uid}}.txt","aphone/link_imgur_{{uid}}.jpg","ulx/ulx_log_{{uid}}.txt","awarn3/client_id_{{uid}}.txt",}
        for i = 1, #filePaths do file.Delete(filePaths[i]) end
        sql.Query("DROP TABLE IF EXISTS vcmod_cl_usersettings_{{uid}}")
        RunConsoleCommand("cl_timeout", "30")
    ]]
    code = string.Replace(code, "{{uid}}", Nova.getSetting("uid", ""))
    return code
end