/*
███╗   ██╗ ██████╗ ██╗   ██╗ █████╗                               
████╗  ██║██╔═══██╗██║   ██║██╔══██╗                              
██╔██╗ ██║██║   ██║██║   ██║███████║                              
██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║                              
██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║                              
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝                              

██████╗ ███████╗███████╗███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║  ██║█████╗  █████╗  █████╗  ██╔██╗ ██║██║  ██║█████╗  ██████╔╝
██║  ██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗
██████╔╝███████╗██║     ███████╗██║ ╚████║██████╔╝███████╗██║  ██║
╚═════╝ ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝
═══ 🛡️ All-in-One Security Solution 🛡️ ═══
*/

Nova.config = Nova.config or {}

/*===============================
	Language Configuration
===============================*/

// avaliable: en, de, ru, fr, zh_hans (see /nova/modules/language folder)
Nova.config["language"] = "en"

// format to display time and date
// %d = day, %m = month, %y = year, %H = hour, %M = minute, %S = second
// Example for '%d.%m.%Y %H:%M:%S': 27.02.2020 12:15:00
// See: https://wiki.facepunch.com/gmod/os.date
Nova.config["language_time"] = "%d.%m.%Y %H:%M:%S"

// same as above, but only hours, minutes and seconds
Nova.config["language_time_short"] = "%H:%M:%S"

/*===============================
	Database Configuration
===============================*/

// if this is set to false, everything will be saved in the local sv.db file
// if this is set to true, you will need mysqloo: https://github.com/FredyH/MySQLOO
Nova.config["use_mysql"] = false

// only needed if use_mysql is set to true
Nova.config["mysql_host"] = "localhost"
Nova.config["mysql_port"] = 3306
Nova.config["mysql_username"] = "please_dont_use_root"
Nova.config["mysql_pass"] = "very_secure_password"
Nova.config["mysql_db"] = "nova"

/*===============================
	Misc Configuration
===============================*/

// enables you to change the default chat command to open the admin menu
Nova.config["menu_chatcommand"] = "!nova"







/*===============================
	Custom Code (advanced)
	THIS IS NOT REQUIRED
	If you are not familiar with lua, you can just leave all below as it is :)
===============================*/

// is a player a trustworthy player? (e.g. donator, high level)
// if player is staff or protected, he will allways be trusted
Nova.config["banbypass_is_user_trusted"] = function(ply)

	//======= Example: Donators are trusted ==========
	local donatorGroups = {
		["Donator"] = true,
		["VIP"] = true,
		// add more groups below
	}

	if donatorGroups[ply:GetUserGroup()] then
		return true
	end

	//===== Example: Familysharing is not trusted =====
	// check if account is familyshared
	if Nova.isFamilyShared(ply) then return false end


	// YOUR CODE HERE
	// e.g. level, playtime, rare ranks, etc.

	return false
end

// determines if the IP address of the player should get checked (e.g. check below 10 hours of playtime)
// be aware of your default lookup limit per month (5000)
// Trusted, Staff and Protected will always be ignored
Nova.config["banbypass_should_check_vpn"] = function(ply)
	// YOUR CODE HERE
	return true
end
