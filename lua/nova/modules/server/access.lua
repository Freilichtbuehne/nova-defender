local failedAttempts = {}

local function WrongAttempt(steamID)
    if not failedAttempts[steamID] then
        failedAttempts[steamID] = {
            attempts = 1,
            locked = false,
        }
    else
        failedAttempts[steamID].attempts = failedAttempts[steamID].attempts + 1
        if failedAttempts[steamID].attempts >= Nova.getSetting("server_access_password_max_attempts", 10) then
            failedAttempts[steamID].locked = true
            Nova.log("i", string.format("User %s has been locked for too many join attempts with wrong password", steamID))
        end
    end
end

local function IsLocked(steamID)
    if not failedAttempts[steamID] or not failedAttempts[steamID].locked then return false end
    return true
end

local function ClearAttempts(steamID)
    failedAttempts[steamID] = nil
end

hook.Add("nova_base_checkpassword", "server_maintenance", function(steamID, ipAddress, svPassword, clPassword, name)
    local maintenanceEnabled = Nova.getSetting("server_access_maintenance_enabled", false)
    local maintenancePassword = Nova.getSetting("server_access_maintenance_password", "youshouldchangethis")
    local hasPassword = maintenanceEnabled or svPassword != ""

    // if no server password is set and maintenance is disabled, allow the player to join
    if not hasPassword then return end

    // convert SteamID64 to SteamID32
    steamID = Nova.convertSteamID(steamID)

    // always ignore protected players (prevent lockout)
    if Nova.isProtected(steamID) then return true end

    // if player is locked out and there is a password, disallow
    if Nova.getSetting("server_access_password_lock", false) and IsLocked(steamID) then
        local reason = Nova.getSetting("server_access_password_lock_reason", "too many failed attempts")
        local reasonSuffix = Nova.getSetting("server_general_suffix", "")
        reason = string.format("%s %s", reason, reasonSuffix)
        return false, reason
    end

    // Nova Defender maintenance and only protected players are allowed to join
    local allowed = Nova.getSetting("server_access_maintenance_allowed", "protected")
    if maintenanceEnabled and allowed == "protected only" then
        local reason = Nova.getSetting("server_access_maintenance_reason", "Maintenance")
        local reasonSuffix = Nova.getSetting("server_general_suffix", "")
        reason = string.format("%s %s", reason, reasonSuffix)
        return false, reason
    end

    // Nova Defender maintenance and password is required
    if maintenanceEnabled and allowed == "password" then
        if clPassword == maintenancePassword then
            ClearAttempts(steamID)
            return true
        elseif clPassword != "" then
            Nova.log("d", string.format("Player %q (%s) entered the wrong password: %q", name, steamID, clPassword))
            WrongAttempt(steamID)
        end
        local reason = Nova.getSetting("server_access_maintenance_reason", "Maintenance")
        local reasonSuffix = Nova.getSetting("server_general_suffix", "")
        reason = string.format("%s %s", reason, reasonSuffix)
        return false, reason
    end

    // server has a password and player entered the wrong password
    if svPassword != clPassword then
        WrongAttempt(steamID)
        return false
    end

    // server has a password and player entered the correct password
    ClearAttempts(steamID)
end)