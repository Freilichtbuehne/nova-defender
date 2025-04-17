/*
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!
	!DON'T EDIT THIS FILE!

    These are the default settings. 
	If a setting is later changed, it will not be overwritten here (4th. argument in setSetting).
*/

// Nova.setSetting("module_setting", value, showInUI, ifNotExists, options, advanced)

Nova.loadDefaultSettings = function()
Nova.log("d", "Loading default settings...")

/*===============================
	Logging
===============================*/

Nova.setSetting("menu_logging_debug", false, true, true, nil, true)

Nova.setSetting("menu_access_player", false, true, true)
Nova.setSetting("menu_access_inspection", false, true, true)
Nova.setSetting("menu_access_staffseeip", false, true, true)
Nova.setSetting("menu_access_ddos", false, false, true, nil, false)
Nova.setSetting("menu_access_detections", false, true, true)
Nova.setSetting("menu_access_bans", false, true, true)
Nova.setSetting("menu_access_health", false, true, true)


Nova.setSetting("menu_notify_timeopen", 15, true, true)
Nova.setSetting("menu_notify_showinfo", true, true, true)
Nova.setSetting("menu_notify_showstaff", true, true, true)

Nova.setSetting("menu_action_timeopen", 80, true, true)
Nova.setSetting("menu_action_showstaff", false, true, true)

/*===============================
	DDoS Protection
===============================*/

Nova.setSetting("networking_ddos_collect_days", 2, false, true)
Nova.setSetting("networking_ddos_notify", true, false, true)

/*===============================
	Netcollector
===============================*/

Nova.setSetting("networking_netcollector_spam_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_netcollector_spam_reason", "DoS", true, true, nil, true)
Nova.setSetting("networking_netcollector_actionAt", 500, true, true)
Nova.setSetting("networking_netcollector_dropAt", 200, true, true)
Nova.setSetting("networking_netcollector_dump", false, true, true, nil, true)
Nova.setSetting("networking_netcollector_checkinterval", 3, false, true)

Nova.setSetting("networking_dos_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_dos_reason", "DoS", true, true, nil, true)
Nova.setSetting("networking_dos_sensivity", "medium", true, true, {"high", "medium", "low"}, true)
Nova.setSetting("networking_dos_checkinterval", 5, false, true)

Nova.setSetting("networking_dos_crash_enabled", true, true, true)
Nova.setSetting("networking_dos_crash_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_dos_crash_ignoreprotected", true, true, true, nil, true)
Nova.setSetting("networking_dos_crash_maxsize", 200, true, true, nil, true)
Nova.setSetting("networking_dos_crash_ratio", 500, true, true, nil, true)
Nova.setSetting("networking_dos_crash_whitelist", {}, true, true, nil, true)

/*===============================
	Exploits/Backdoors
===============================*/

Nova.setSetting("networking_fakenets_backdoors_load", true, true, true, nil, true)
Nova.setSetting("networking_fakenets_backdoors_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_fakenets_backdoors_block", false, true, true, nil, true)
Nova.setSetting("networking_fakenets_exploits_load", true, true, true, nil, true)
Nova.setSetting("networking_fakenets_exploits_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_fakenets_exploits_block", false, true, true, nil, true)

/*===============================
	Sendlua
===============================*/

Nova.setSetting("networking_sendlua_gm_express", false, true, true)

Nova.setSetting("networking_sendlua_authfailed_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_sendlua_authfailed_reason", "Authentication Error", true, true, nil, true)
Nova.setSetting("networking_sendlua_maxAuthTries", 30, false, true)
Nova.setSetting("networking_sendlua_validationfailed_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_sendlua_validationfailed_reason", "Validation Error", true, true, nil, true)

/*===============================
	Screenshot
===============================*/

Nova.setSetting("networking_screenshot_store_ban", true, true, true)
Nova.setSetting("networking_screenshot_store_manual", false, true, true, nil, true)
Nova.setSetting("networking_screenshot_quality", "medium", true, true, {"low", "medium", "high"})
Nova.setSetting("networking_screenshot_limit_ban", 50, true, true, nil, true)
Nova.setSetting("networking_screenshot_limit_manual", 20, true, true, nil, true)

/*===============================
	Restricted Netmessages
===============================*/

Nova.setSetting("networking_restricted_message_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"}, true)
Nova.setSetting("networking_restricted_message_reason", "Exploit Attempt", true, true, nil, true)

/*===============================
	Concommands
===============================*/

Nova.setSetting("networking_concommand_logging", true, true, true, nil, true)
Nova.setSetting("networking_concommand_dump", false, true, true, nil, true)

/*===============================
	HTTP
===============================*/
Nova.setSetting("networking_http_overwrite", false, true, true)
Nova.setSetting("networking_http_logging", true, true, true, nil, true)
Nova.setSetting("networking_http_blockunsafe", false, true, true, nil, true)
Nova.setSetting("networking_http_whitelist", false, true, true, nil, true)
Nova.setSetting("networking_http_whitelistdomains", {
	"google.com",
	"vcmod.org",
	"m4dsolutions.com",
	"api.gmod-integration.com",
	"gmod.express",
}, true, true, nil, true)

Nova.setSetting("networking_fetch_overwrite", false, true, true)
Nova.setSetting("networking_fetch_whitelist", false, true, true, nil, true)
Nova.setSetting("networking_fetch_blockunsafe", false, true, true, nil, true)

Nova.setSetting("networking_post_overwrite", false, true, true)
Nova.setSetting("networking_post_whitelist", false, true, true, nil, true)
Nova.setSetting("networking_post_blockunsafe", false, true, true, nil, true)

/*===============================
	VPN
===============================*/

Nova.setSetting("networking_vpn_apikey", "", true, true)
Nova.setSetting("networking_vpn_dump", true, true, true, nil, true)

Nova.setSetting("networking_vpn_vpn-action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("networking_vpn_vpn-action_reason", "Usage of a VPN is not permitted", true, true, nil, true)
Nova.setSetting("networking_vpn_whitelist_asns", {
	"3320",
	"3209",
}, true, true)

Nova.setSetting("networking_vpn_country-action", "nothing", true, true, {"kick", "ban", "notify", "ask", "nothing"}, true)
Nova.setSetting("networking_vpn_country-action_reason", "Your country is blocked on this server", true, true, nil, true)
Nova.setSetting("networking_vpn_countrycodes", {
	"DE",
	"US",
	"EN"
}, true, true, nil, true)

/*===============================
	Banbypass
===============================*/

Nova.setSetting("banbypass_ban_default_reason", "Server Security", true, true)
Nova.setSetting("banbypass_ban_banstaff", true, true, true, nil, true)

Nova.setSetting("banbypass_bypass_default_reason", "Banbypass", true, true)

Nova.setSetting("banbypass_bypass_clientcheck_action", "ask", true, true, {"ban", "notify", "ask", "nothing"})
Nova.setSetting("banbypass_bypass_ipcheck_action", "ask", true, true, {"ban", "notify", "ask", "nothing"})
Nova.setSetting("banbypass_bypass_familyshare_action", "ask", true, true, {"ban", "notify", "ask", "nothing"})

Nova.setSetting("banbypass_bypass_fingerprint_enable", true, true, true)
Nova.setSetting("banbypass_bypass_fingerprint_action", "ask", true, true, {"ban", "notify", "ask", "nothing"})
Nova.setSetting("banbypass_bypass_fingerprint_sensivity", "low", true, true, {"very high", "medium", "low"}, true)

Nova.setSetting("banbypass_bypass_indicators_apikey", "", true, true)

/*===============================
	Exploit
===============================*/

Nova.setSetting("exploit_fix_propspawn", true, true, true)
Nova.setSetting("exploit_fix_material", true, true, true)
Nova.setSetting("exploit_fix_fadingdoor", true, true, true)
Nova.setSetting("exploit_fix_physgunreload", true, true, true)
Nova.setSetting("exploit_fix_bouncyball", true, true, true)
Nova.setSetting("exploit_fix_bhop", false, true, true)
Nova.setSetting("exploit_fix_serversecure", false, true, true)

/*===============================
	Anticheat
===============================*/

Nova.setSetting("anticheat_enabled", true, true, true)
Nova.setSetting("anticheat_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("anticheat_reason", "Cheating/Exploiting", true, true, nil, true)

Nova.setSetting("anticheat_autoclick_enabled", true, true, true)
Nova.setSetting("anticheat_autoclick_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("anticheat_autoclick_reason", "Autoclick detected", true, true, nil, true)
Nova.setSetting("anticheat_autoclick_sensivity", "low", true, true, {"high", "medium", "low"}, true)
Nova.setSetting("anticheat_autoclick_check_fast", true, true, true, nil, true)
Nova.setSetting("anticheat_autoclick_check_fastlong", true, true, true, nil, true)
Nova.setSetting("anticheat_autoclick_check_robotic", true, true, true, nil, true)

Nova.setSetting("anticheat_aimbot_enabled", false, true, true)
Nova.setSetting("anticheat_aimbot_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("anticheat_aimbot_reason", "Aimbot detected", true, true, nil, true)
Nova.setSetting("anticheat_aimbot_check_snap", false, true, true, nil, true)
Nova.setSetting("anticheat_aimbot_check_move", true, true, true, nil, true)
Nova.setSetting("anticheat_aimbot_check_contr", true, true, true, nil, true)

Nova.setSetting("anticheat_verify_execution", true, true, true, nil, true)
Nova.setSetting("anticheat_verify_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("anticheat_verify_reason", "Anticheat validation timeout", true, true, nil, true)

Nova.setSetting("anticheat_check_cheats_custom", true, false, true, nil, true)
Nova.setSetting("anticheat_check_cheats_custom_unsure", false, false, true, nil, true)
Nova.setSetting("anticheat_check_manipulation", true, true, true, nil, true)
Nova.setSetting("anticheat_check_function", true, true, true, nil, true)
Nova.setSetting("anticheat_check_globals", true, true, true, nil, true)
Nova.setSetting("anticheat_check_modules", true, true, true, nil, true)
Nova.setSetting("anticheat_check_cvars", true, true, true, nil, true)
Nova.setSetting("anticheat_check_external", true, true, true, nil, true)
Nova.setSetting("anticheat_check_runstring", true, true, true, nil, true)
Nova.setSetting("anticheat_check_detoured_functions", true, true, true, nil, true)
Nova.setSetting("anticheat_check_concommands", true, true, true, nil, true)
Nova.setSetting("anticheat_check_files", true, true, true, nil, true)
Nova.setSetting("anticheat_check_byte_code", true, false, true, nil, true)
Nova.setSetting("anticheat_check_net_scan", true, true, true, nil, true)
Nova.setSetting("anticheat_spam_filestealers", false, true, true, nil, true)

Nova.setSetting("anticheat_check_experimental", true, true, true, nil, true)

/*===============================
	Security
===============================*/

Nova.setSetting("security_privileges_group_protection_enabled", false, true, true)
Nova.setSetting("security_privileges_group_protection_timer_interval", 5, false, true)
Nova.setSetting("security_privileges_group_protection_protected_players", {
	["STEAM_0:1:12345678"] = {
		["group"] = "superadmin",
		["comment"] = "Person's name",
		["steamid"] = "STEAM_0:1:12345678",
	},
}, true, true)

Nova.setSetting("security_permissions_groups_staff", {
	"operator",
	"moderator",
	"supporter",
}, true, true)

Nova.setSetting("security_permissions_groups_protected", {
	"owner",
	"superadmin",
	"admin",
}, true, true)

Nova.setSetting("security_privileges_group_protection_escalation_action", "ask", true, true, {"kick", "ban", "notify", "ask", "nothing"})
Nova.setSetting("security_privileges_group_protection_escalation_reason", "Privilege Escalation", true, true, nil, true)
Nova.setSetting("security_privileges_group_protection_removal_action", "set", true, true, {"set", "nothing"})
Nova.setSetting("security_privileges_group_protection_kick_reason", "Protected Usergroup Removed", true, true, nil, true)

/*===============================
	Server
===============================*/

Nova.setSetting("server_general_suffix", "", true, true)

Nova.setSetting("server_access_maintenance_enabled", false, true, true)
Nova.setSetting("server_access_maintenance_allowed", "protected only", true, true, {"protected only", "password"})
Nova.setSetting("server_access_maintenance_password", "youshouldchangethis", true, true)
Nova.setSetting("server_access_maintenance_reason", "Maintenance", true, true)

Nova.setSetting("server_access_password_lock", false, true, true, nil, true)
Nova.setSetting("server_access_password_lock_reason", "Too many failed attempts", true, true, nil, true)
Nova.setSetting("server_access_password_max_attempts", 10, true, true, nil, true)

Nova.setSetting("server_lockdown_enabled", false, true, true)
Nova.setSetting("server_lockdown_reason", "You are not allowed to play at the moment", true, true)

/*===============================
	Health
===============================*/

Nova.setSetting("security_health_ignorelist", {}, false, true)

/*===============================
	Misc
===============================*/

Nova.setSetting("uid", string.format("%x", math.random(0x11111111111111, 0xFFFFFFFFFFFFFF)), false, true)

Nova.defaultSettingsLoaded = true
end