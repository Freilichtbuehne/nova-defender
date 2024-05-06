local function InitPlayer(ply)
    if not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end
    // rather use hook: nova_networking_playerauthenticated
    hook.Run("nova_base_initplayer", ply)
end

hook.Add("PlayerInitialSpawn", "nova_base_initplayer", InitPlayer)

local function PlayerDisconnect(ply)
    if not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end
    local steamID = ply:SteamID()
    if not steamID then return end
    hook.Run("nova_base_playerdisconnect", steamID, ply)
end

hook.Add("PlayerDisconnected", "nova_base_playerdisconnect", PlayerDisconnect)

local function CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
    local steamID = util.SteamIDFrom64(steamID64)
    local canjoin, reason = hook.Run("nova_base_checkpassword", steamID, ipAddress, svPassword, clPassword, name)
    if canjoin == false then return false, reason or nil end
    if canjoin == true then return true end
end

hook.Add("CheckPassword", "nova_base_checkpassword", CheckPassword)

// Chat command to open the admin menu
local function AdminMenu(ply, text)
    if not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end
    if not Nova.isStaff(ply) then return end

    local menuChatCommand = Nova.config["menu_chatcommand"] or "!nova"

    if string.lower(text or "") == menuChatCommand then
        ply:ConCommand("nova_defender")

        return ""
    end
end

hook.Add("PlayerSay", "nova_base_adminmenu", AdminMenu)

// Analytics for aimbot detection and other stuff
local function StartCommand(ply, cmd)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    local steamID = ply:SteamID()
    hook.Run("nova_base_startcommand", ply, cmd, steamID)
end

hook.Add("StartCommand", "nova_base_startcommand", StartCommand)