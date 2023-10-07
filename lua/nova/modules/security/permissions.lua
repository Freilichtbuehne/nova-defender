/*
	We split players in 4 groups:
	- Player	(zero trust, new players)
	- Trusted	(e. g. high level, donator)
	- Staff		(gets notified on suspicious activity)
	- Protected	(gets excluded from detection and their group protected)

	If a player is in a higher group then he is also in all lower groups.
	Example: A protected player is also in the staff, trusted and player group.
*/

local playerGroups = {
	["Player"] = 0,
	["Trusted"] = 1,
	["Staff"] = 2,
	["Protected"] = 3,
}

local function ValidWhitelist()
	local whitelist = Nova.getSetting("security_privileges_group_protection_protected_players", {})
	if not whitelist or whitelist == {} then return false end
	// Only the default value exists, return false
	if whitelist["STEAM_0:1:12345678"] and table.Count(whitelist) <= 1 then return false end
	if table.Count(whitelist) == 0 then return false end
	return true
end

local function GetGroup(ply_or_steamid)
	// we got nothing, so we return the lowest possible group (Player)
	if not ply_or_steamid then return "Player" end

	local steamID = Nova.convertSteamID(ply_or_steamid)

	// SteamID is not valid, so we return the lowest possible group (Player)
	if steamID == "" then return "Player" end

	local ply = Nova.fPlayerBySteamID(steamID)
	local isOnline = IsValid(ply) and ply:IsPlayer()

	local protectedPlayers = Nova.getSetting("security_privileges_group_protection_protected_players", {})
	local staffGroups = Nova.getSetting("security_permissions_groups_staff", {})

	// we got a steamid and player is offline
	if not isOnline and protectedPlayers[steamID] then
		return "Protected"
	end

	// player is online
	if isOnline then
		// player is protected (double check)
		if steamID and protectedPlayers[steamID] then
			return "Protected"
		end

		// during setup of Nova Defender there might be no whitelisted admins
		// if this is the case we temporarily use the built-in ply:IsSuperAdmin() function
		if not ValidWhitelist() and ply:IsSuperAdmin() then
			return "Protected"
		end

		local userGroup = ply:GetUserGroup()
		if userGroup and table.HasValue(staffGroups, userGroup) then
			return "Staff"
		end

		// the only way we check if a player is trusted is by device cookie
		local hasCookie = Nova.playerHasCookie(ply)
		if hasCookie then
			return "Trusted"
		end
	end

	// if we don't find a group, we default to player
	return "Player"
end

local function PermissionCheck(client, isEqualOrHigherThan)
	return playerGroups[GetGroup(client)] >= playerGroups[isEqualOrHigherThan]
end

Nova.isTrusted = function(ply_or_steamid) return PermissionCheck(ply_or_steamid, "Trusted") end
Nova.isStaff = function(ply_or_steamid) return PermissionCheck(ply_or_steamid, "Staff") end
Nova.isProtected = function(ply_or_steamid) return PermissionCheck(ply_or_steamid, "Protected") end

Nova.canTouch = function(ply_or_steamid, target_ply_or_steamid)
	// if they are the same player, we allow it
	if ply_or_steamid == target_ply_or_steamid then return true end

	local plyGroup = GetGroup(ply_or_steamid)
	local targetGroup = GetGroup(target_ply_or_steamid)
	if Nova.isProtected(ply_or_steamid) then return true end
	return playerGroups[plyGroup] > playerGroups[targetGroup]
end

Nova.getPlayerPermission = function(ply_or_steamid)
	local group = GetGroup(ply_or_steamid)
	return group, playerGroups[group] or 0
end

hook.Add("nova_banbypass_cookieloaded", "security_loadpermissions", function(ply)
	Nova.log("d", string.format("%s joined the server categorized as '%s'", Nova.playerName(ply), GetGroup(ply)))
end)