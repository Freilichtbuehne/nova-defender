local lang = "en"

local phrases = {
    /*
        Notifications
    */
    ["menu_logging_debug"] = "Debug Mode:\nThis prints additional logs to server console.",
    ["menu_notify_timeopen"] = "Notification display duration in seconds.",
    ["menu_notify_showstaff"] = "Show notifications to staff.",
    ["menu_notify_showinfo"] = "Show informational notifications",
    ["menu_access_player"] = "Staff has access to 'Players Online' tab and can perform actions there. Staff cannot target protected players.",
    ["menu_access_staffseeip"] = "Staff can see IP addresses of players",
    ["menu_access_detections"] = "Staff has access to 'Detections' tab",
    ["menu_access_bans"] = "Staff has access to 'Bans' tab",
    ["menu_access_health"] = "Staff has access to 'Health' tab",
    ["menu_access_inspection"] = "Staff has access to 'Inspect Players' tab",
    ["menu_access_ddos"] = "Staff has access to 'DDoS' tab",

    ["menu_action_timeopen"] = "Punishment promt display duration in seconds.",
    ["menu_action_showstaff"] = "Ask staff for punishment action if no protected players are there (or AFK).",
    /*
        Networking
    */
    ["networking_concommand_logging"] = "Log Commands:\nLog every console command executed by clients and server",
    ["networking_concommand_dump"] = "Dump Commands:\nPrint all commands a player has executed to console when he disconnects. This can grow your logs in size very fast.",
    ["networking_netcollector_dump"] = "Dump Netmessages:\nPrint all netmessages a player has sent to server to console when he disconnects.",
    ["networking_netcollector_spam_action"] = "What should happen when player spamms netmessages to server?",
    ["networking_netcollector_spam_reason"] = "Reason for a player get's kicked or banned by spamming netmessages to server.",
    ["networking_dos_action"] = "What should happen when player tried to cause server lags?",
    ["networking_dos_reason"] = "Reason for a player get's kicked or banned by causing server lags.",
    ["networking_dos_sensivity"] = "How sensitive should the detection be?",
    ["networking_dos_crash_enabled"] = "Detect Decompression Attacks:\nClients can send highly compressed data to the server. When unpacked it can easily reach up to 400 MB of data and will cause the server to lag or crash. A client can send a maximum of 65 KB to the server. The compression used in Gmod (LZMA2) has usually a compression ration of about 20:1 (depends on data). So we would expect about 1 MB of decompressed data. A compression ratio of 1000:1 or even 7000:1 has no legitimate usecase. This options overwrites util.Decompress and does not require a restart. ",
    ["networking_dos_crash_action"] = "What should happen if a player tries to crash the server?",
    ["networking_dos_crash_ignoreprotected"] = "Ignore protected players.",
    ["networking_dos_crash_maxsize"] = "Maximum decompressed size in MB:\nWhen reached, the decompression will be aborted.",
    ["networking_dos_crash_ratio"] = "Maximum compression ratio:\nNormal data will have a compression ratio of about 20:1. A compression ratio of 1000:1 or even 7000:1 has no legitimate usecase. Do not set this too low as it will cause false positives.",
    ["networking_dos_crash_whitelist"] = "Whitelisted netmessages that will be ignored.",
    ["networking_netcollector_actionAt"] = "At how many messages from a single client within 3 seconds should we take action? NEVER SET THIS TOO LOW!",
    ["networking_netcollector_dropAt"] = "At how many messages within 3 seconds should we ignore a netmessage. This is done to prevent a denial of service. Should be lower then above setting.",
    ["networking_restricted_message_action"] = "What should happen when a player sents a message to the server which he is not allowed to? Without manipulating the game or a bug it is not possible for players to send this message.",
    ["networking_restricted_message_reason"] = "Reason for a player get's kicked or banned by sending a message to the server which he is not allowed to.",
    ["networking_sendlua_gm_express"] = "Activate gm_express:\nMassive performance improvement, especially for larger servers. Instead of sending large amounts of data via the built-in netmessages (slow), they are transferred to the clients via HTTPS via an external provider (gmod.express). This speeds up the loading time of clients and reduces the load on the server. However, this option is dependent on gmod.express. If this page cannot be reached, authentication for clients will fail. New clients that cannot connect to gmod.express fall back to the conventional netmessages. This option requires the installation of gm_express. More details in the 'Health' tab.",
    ["networking_sendlua_authfailed_action"] = "What should happen when a player doesn't respond to Nova Defender authentication? If ignored there is no guarantee that the anticheat or other client-side mechanisms are working.",
    ["networking_sendlua_authfailed_reason"] = "Reason for a player get's kicked or banned by not responding to Nova Defender authentication.",
    ["networking_sendlua_validationfailed_action"] = "What should happen when a player blocks code from Nova Defender?",
    ["networking_sendlua_validationfailed_reason"] = "Reason for a player get's kicked or banned by blocking code from Nova Defender.",
    ["networking_fakenets_backdoors_load"] = "Create fake backdoors and trick attackers into using them.",
    ["networking_fakenets_backdoors_block"] = "Block backdoors on server. Might block legitimate netmessages and break addons! First see the 'Health' tab and check for existing backdoors.",
    ["networking_fakenets_backdoors_action"] = "What should happen when attacker uses a fake backdoor?",
    ["networking_fakenets_exploits_load"] = "Create fake exploits and trick attackers into using them.",
    ["networking_fakenets_exploits_block"] = "Block exploitable netmessages on server. This breaks exploitable addons on your server! First see the 'Health' tab and check which addons are exploitable.",
    ["networking_fakenets_exploits_action"] = "What should happen when attacker uses a fake exploit?",
    ["networking_vpn_vpn-action"] = "What should happen when a player uses a VPN?",
    ["networking_vpn_vpn-action_reason"] = "Reason for using a VPN.",
    ["networking_vpn_country-action"] = "What should happen when a player comes from a not allowed country?",
    ["networking_vpn_country-action_reason"] = "Reason for coming from a country not allowed.",
    ["networking_vpn_dump"] = "Prints information about a players IP address to console",
    ["networking_vpn_apikey"] = "VPN API key:\nFor scanning IP addresses. You need to register at https://www.ipqualityscore.com/create-account and retrieve your key at https://www.ipqualityscore.com/user/settings.",
    ["networking_vpn_countrycodes"] = "Allowed countries to join your server. Get country codes from here: https://countrycode.org/ (2-letter code in uppercase). It is recommended to whitelist your own and neighboring countries. You can add more countries time by time.",
    ["networking_vpn_whitelist_asns"] = "Whitelisted ASN numbers (number to identify an internet service provider). It may happen that the API incorrectly detects a VPN connection. Therefore, known ISPs are whitelisted. Get them from https://ipinfo.io/countries. Alternatively you can see the ASN of each connected client in 'Player' tab.",
    ["networking_screenshot_store_ban"] = "Save screenshots (On ban):\nRight before a player gets banned, a screenshot of his screen will be made and saved inside the servers '/data/nova/ban_screenshots' folder.",
    ["networking_screenshot_store_manual"] = "Save screenshots (Menu):\nIf an admin takes a screenshot of a player, it will get saved inside the servers '/data/nova/admin_screenshots' folder.",
    ["networking_screenshot_limit_ban"] = "Screenshot limit (On ban):\nMaximum number of screenshots stored inside the servers data folder. Oldest will get deleted.",
    ["networking_screenshot_limit_manual"] = "Screenshot limit (Menu):\nMaximum number of screenshots stored inside the servers data folder. Oldest will get deleted.",
    ["networking_screenshot_quality"] = "Screenshot Quality\nScreenshots with high quality may take up to a minute to transfer.",

    ["networking_http_overwrite"] = "Inspect HTTP calls (send+receive):\nIf this setting is enabled, the HTTP function is overridden and requests can be logged or blocked. However, this method can also be bypassed or disable DRM systems.",
    ["networking_http_logging"] = "Log requests:\nAll HTTP requests are logged in detail in the console. This is useful to get an overview of which URLs are called. Only works when HTTP requests are inspected.",
    ["networking_http_blockunsafe"] = "Block unsafe requests:\nRequests originating from unsafe sources such as console or RunString are blocked.",
    ["networking_http_whitelist"] = "Enable whitelist:\nOnly domains and IP addresses that have been added to the list are allowed.",
    ["networking_http_whitelistdomains"] = "Whitelist domains:\nAdd all trusted domains and IPs that should be allowed. Everything else will be blocked. If you are not sure which domains to whitelist, disable the whitelist and enable logging only.",

    ["networking_fetch_overwrite"] = "Inspect http.fetch (receiving data):\nOverwrite the http.fetch function. DO NOT ENABLE IF YOU ARE USING VCMOD! However, this method can also be bypassed or disable DRM systems.",
    ["networking_fetch_whitelist"] = "Enable whitelist:\nOnly domains and IP addresses added to the list will be allowed.",
    ["networking_fetch_blockunsafe"] = "Block unsafe requests:\nRequests originating from unsafe sources such as console or RunString are blocked.",

    ["networking_post_overwrite"] = "Inspect http.post (sending data):\nOverwrite the http.post function. Sending HTTP requests can be used by attackers to steal files on the server. However, this method can also be bypassed or disable DRM systems.",
    ["networking_post_whitelist"] = "Enable whitelist:\nOnly domains and IP addresses that have been added to the list are allowed.",
    ["networking_post_blockunsafe"] = "Block unsafe requests:\nRequests originating from insecure sources such as console or RunString are blocked.",
    
    ["networking_ddos_collect_days"] = "IP address collection days:\nThe DDoS protection collects IP addresses of all connected players of the last n days. When a DDoS attack is detected, all communication to the server is blocked, except for the connected players of the last n days. The server ignores all players that did not connect to the server in the last n days. The server will be invisible to them.",
    ["networking_ddos_notify"] = "Show notifications if a DDoS attack is detected or stopped.",
    /*
        Banbypass
    */
    ["banbypass_ban_banstaff"] = "Staff can get banned",
    ["banbypass_ban_default_reason"] = "Reason for a player get's banned if no reason is specified",

    ["banbypass_bypass_default_reason"] = "Reason for a player get's banned if he bypassed a ban",

    ["banbypass_bypass_familyshare_action"] = "What should happen when a player is using a family shared account of a banned player?",
    ["banbypass_bypass_clientcheck_action"] = "What should happen when we find evidence for a ban bypass in the local files of a player?",
    ["banbypass_bypass_ipcheck_action"] = "What should happen when a player has the identical IP address as a banned player?",

    ["banbypass_bypass_fingerprint_enable"] = "Enable Fingerprint Check:\nThis option checks if a player is using the same device as a banned user. It can prevent a player to create a new account on the same device as long as he is banned.",
    ["banbypass_bypass_fingerprint_action"] = "What should happen when a player is using the same device as a banned user?",
    ["banbypass_bypass_fingerprint_sensivity"] = "How sensitive should the fingerprint matching be?",

    ["banbypass_bypass_indicators_apikey"] = "Steam API key:\nThe SteamAPI can be used to view more detailed data about a player. Finds are displayed in the 'Player Online' tab in the indicators. Create one at https://steamcommunity.com/dev/apikey and paste it here.",
    /*
        Anticheat
    */
    ["anticheat_reason"] = "Reason for a player get's banned if he uses any sorts of cheats.",
    ["anticheat_enabled"] = "Enable Anticheat:\nIf this is enabled anticheat code will be sent to all clients and detections will be handled. If this gets disabled, the anticheat code remains active on all currently connected clients but detections are ignored. This option includes autoclick and aimbot detection.",
    ["anticheat_action"] = "What should happen when a player has cheats?",
    ["anticheat_verify_action"] = "What should happen when the anticheat doesn't load for a player?",
    ["anticheat_verify_execution"] = "Check if anticheat is running:\nAfter a player receives the anticheat, confirmation is requested whether he has executed it. However, this process can fail for several reasons and therefore should not be set to 'Ban'.",
    ["anticheat_verify_reason"] = "Reason for a player get's banned if the anticheat doesn't load.",
    ["anticheat_check_function"] = "Check Functions:\nCompares function names on the client with known function names of cheats. This may detect legitimate functions inside code you provide as well.",
    ["anticheat_check_files"] = "Check Files:\nSimilar to 'Check Functions'. Compares the filename of a running script with known file names of cheats.",
    ["anticheat_check_globals"] = "Check Global Variables:\nSimilar to 'Check Functions'. Compares variable names with known variable names of cheats.",
    ["anticheat_check_modules"] = "Check Modules:\nSimilar to 'Check Functions'. Compares module names with known module names of cheats.",
    ["anticheat_check_runstring"] = "Check 'RunString':\nArbitrary Lua code can be executed using the built-in 'RunString' function. This option detects the improper use of this function and searches for known cheat patterns.",
    ["anticheat_check_external"] = "Check External Tampering:\nThis detects external cheat software. Those are very difficult to detect within a restricted Lua environment. This will slow down profilers like FProfiler.",
    ["anticheat_check_manipulation"] = "Detect Manipulation:\nDetects attempts to block or manipulate the anticheat.",
    ["anticheat_check_cvars"] = "Check Console Variables:\nSimilar to 'Check Functions'. Some cheats utilize cvars to persist settings. Compares cvar names with known cvar names of cheats.",
    ["anticheat_check_byte_code"] = "Check Code Compilation:\nUnder the hood, Lua code is compiled into bytecode using JIT and then interpreted. We can sometimes determine if this is done in an unusual way. For example if a client executes code via lua_run_cl.",
    ["anticheat_check_detoured_functions"] = "Check Function Detour:\nSome cheats overwrite the functionality of built in functions to evade detection or manipulate the behaviour of the game.",
    ["anticheat_check_concommands"] = "Check Console Commands:\nSimilar to 'Check Console Variables'. Some cheats can be accessed via console. Compares command names with known command names of cheats.",
    ["anticheat_check_net_scan"] = "Check Scanning:\nSome scripts can scan the server for known vulnerabilities or backdoors.",
    ["anticheat_check_cheats_custom"] = "Detect known cheats:\nDetect widely used cheats by special analysis. Exact names of cheats are displayed in the reason.",
    ["anticheat_check_cheats_custom_unsure"] = "Detect inactive cheats:\nWhen detecting some cheats, it is unknown whether this cheat is currently active or not. The only thing that is certain is that the person has used this cheat once.",
    ["anticheat_check_experimental"] = "Enable experimental detections:\nActivates detections of cheats that have not yet been tested. Players will NOT be banned. Detections are logged in the following file on the server: 'data/nova/anticheat/experimental.txt'. This file can be sent to the developer for analysis.",
    ["anticheat_spam_filestealers"] = "Clutter filestealer:\nSome cheats store all the executed Lua code they receive from the server in text files. To clutter up these files and make it (a little) more difficult for the attacker, we clutter up these files with useless code. This slowly fills up the player's disk. This has no negative impact on player load time.",
    ["anticheat_autoclick_enabled"] = "Enable autoclick detection:\nFor obvious reasons, we don't want any players to use programs for fast clicking or keystrokes. This includes left and right click, use and space bar.",
    ["anticheat_autoclick_action"] = "What should happen when a player uses autoklick?",
    ["anticheat_autoclick_reason"] = "Reason for a player get's banned if he used autoclick.",
    ["anticheat_autoclick_sensivity"] = "Autoclick sensivity:\nHigh sensitivity can falsely detect players due to rare coincidences. Good autoclickers may not be detected with a low sensitivity. Decide depending on how autoclickers can give cheaters an advantage.",
    ["anticheat_autoclick_check_fast"] = "Check fast click speed:\nAbove a certain number of CPS (Clicks Per Second), we can assume that a human being is not capable of doing this without aids. This also applies to keys.",
    ["anticheat_autoclick_check_fastlong"] = "Check fast click over long time:\nIt is unlikely that a player will click enormously fast for several minutes without short pauses.",
    ["anticheat_autoclick_check_robotic"] = "Check inhuman click consistency:\nA human can never click at exactly the same speed. It will always be a little faster or slower. A program, however, can time this very precisely. If the time interval between clicks is too consistent, we can tell.",
    ["anticheat_aimbot_enabled"] = "Enable aimbot detection:\nMonitors in real time all player movements.",
    ["anticheat_aimbot_action"] = "What should happen when a player uses an aimbot?",
    ["anticheat_aimbot_reason"] = "Reason for ban of a player when he uses an aimbot.",
    ["anticheat_aimbot_check_snap"] = "Detect snapping:\nDetect if players viewdirection changes instantly. WARNING: This will prevent clients to set their viewangles (if not done serverside) and therefore break some addons!",
    ["anticheat_aimbot_check_move"] = "Detect suspicious movement:\nDetect if a player changes his view constantly without moving his mouse.",
    ["anticheat_aimbot_check_contr"] = "Detect contradictory movements:\nDetects if a player moves his mouse in a different direction than his view changes.",
    /*
        Exploit
    */
    ["exploit_fix_propspawn"] = "Propspawn:\nPrevents spawning of props with copied material.",
    ["exploit_fix_material"] = "Material:\nPrevents material copying.",
    ["exploit_fix_fadingdoor"] = "Fadingdoor:\nPrevents graphic bug that players can't see anymore.",
    ["exploit_fix_physgunreload"] = "Physgun:\nDisables physgun reload for users.",
    ["exploit_fix_bouncyball"] = "Bouncyball:\nPrevents welding bouncy balls.",
    ["exploit_fix_bhop"] = "Bunnyhop:\nPrevent bunnyhopping.",
    ["exploit_fix_serversecure"] = "Set up Serversecure automatically:\nSee 'Health' tab for more information.",
    /*
        Security
    */
    ["security_permissions_groups_protected"] = "Protected usergroups:\nAll usergroups that are considered protected. Only whitelisted players can have this group. Protected players have full access to this menu.",
    ["security_permissions_groups_staff"] = "Staff and admin usergroups:\nAll usergroups that have staff permissions.",
    ["security_privileges_group_protection_enabled"] = "Automated rank protection:\nIf a player that was not whitelisted has for example a protected usergroup, we take action.",
    ["security_privileges_group_protection_escalation_action"] = "What should happen when a player has a protected usergroup he is not supposed to?",
    ["security_privileges_group_protection_escalation_reason"] = "Reason for a player gets kicked or banned if he has a protected usergroup that he is not supposed to.",
    ["security_privileges_group_protection_removal_action"] = "What should happen when a protected player loses his usergroup?",
    ["security_privileges_group_protection_protected_players"] = "Protected Players:\nAll players that are allowed to have a protected usergroup. If you remove a player that is online will get him kicked.",
    ["security_privileges_group_protection_kick_reason"] = "Reason for kicking a protected player if his protection gets removed while he is connected.",
    /*
        Detections
    */
    ["config_detection_banbypass_familyshare"] = "Familyshared account bypassing a ban",
    ["config_detection_banbypass_clientcheck"] = "Banbypass clientcheck",
    ["config_detection_banbypass_ipcheck"] = "Banbypass IP check",
    ["config_detection_banbypass_fingerprint"] = "Banbypass fingerprint",
    ["config_detection_networking_country"] = "Country of player not allowed",
    ["config_detection_networking_vpn"] = "Usage of a VPN",
    ["config_detection_networking_backdoor"] = "Using a fake backdoor",
    ["config_detection_networking_spam"] = "Spamming netmessages",
    ["config_detection_networking_dos"] = "Causing Serverlags",
    ["config_detection_networking_dos_crash"] = "Tried crashing server with large message",
    ["config_detection_networking_authentication"] = "Client can't authenticate with server",
    ["config_detection_networking_restricted_message"] = "Client sent admin-only message to server",
    ["config_detection_networking_exploit"] = "Using a fake exploit",
    ["config_detection_networking_validation"] = "Client can't validate code execution",
    ["config_detection_anticheat_scanning_netstrings"] = "Scanning for exploits and backdoors",
    ["config_detection_anticheat_runstring_dhtml"] = "Code execution via DHTML",
    ["config_detection_anticheat_runstring_bad_string"] = "RunString contains cheat patterns (string)",
    ["config_detection_anticheat_remove_ac_timer"] = "Disabling anticheat",
    ["config_detection_anticheat_gluasteal_inject"] = "Filestealer usage to run code",
    ["config_detection_anticheat_function_detour"] = "Function detour to manipulate game",
    ["config_detection_anticheat_external_bypass"] = "External Cheats",
    ["config_detection_anticheat_runstring_bad_function"] = "RunString contains cheat patterns (function)",
    ["config_detection_anticheat_jit_compilation"] = "Unusual bytecode compilation",
    ["config_detection_anticheat_known_cvar"] = "Cheat cvar",
    ["config_detection_anticheat_known_file"] = "Cheat files found",
    ["config_detection_anticheat_known_data"] = "Cheat remains found",
    ["config_detection_anticheat_known_module"] = "Cheat modules included",
    ["config_detection_anticheat_known_concommand"] = "Cheat console command",
    ["config_detection_anticheat_verify_execution"] = "Blocking anticheat",
    ["config_detection_anticheat_known_global"] = "Cheat global variable",
    ["config_detection_anticheat_known_cheat_custom"] = "Known Cheat",
    ["config_detection_anticheat_known_function"] = "Cheat global function",
    ["config_detection_anticheat_manipulate_ac"] = "Manipulates anticheat",
    ["config_detection_anticheat_autoclick_fast"] = "Inhuman click speed",
    ["config_detection_anticheat_autoclick_fastlong"] = "Fast click speed over long time",
    ["config_detection_anticheat_autoclick_robotic"] = "Inhuman click consistency",
    ["config_detection_anticheat_aimbot_snap"] = "Aimbot instant snap within 1 tick",
    ["config_detection_anticheat_aimbot_move"] = "Aimbot suspicious movement",
    ["config_detection_anticheat_aimbot_contr"] = "Aimbot contradictory movement",
    ["config_detection_security_privilege_escalation"] = "Privilege escalation to protected usergroup",
    ["config_detection_admin_manual"] = "Manual ban by admin or console",
    /*
        Notifications
    */
    ["menu_notify_hello_staff"] = "This server is protected by Nova Defender.\nYou are categorized as staff.",
    ["menu_notify_hello_protected"] = "This server is protected by Nova Defender.\nYou are categorized as protected.",
    ["menu_notify_hello_menu"] = "Open menu with !nova.",

    ["notify_admin_unban"] = "Successfully unbanned %s. Ban will get removed when player connects to server next time.",
    ["notify_admin_ban"] = "Successfully banned %s. Player will get banned if he joins the server the next time.",
    ["notify_admin_ban_online"] = "Admin %s banned %s. Player will get banned in a few seconds.",
    ["notify_admin_ban_offline"] = "Admin %s banned %s. Player will get banned if he joins the server the next time.",
    ["notify_admin_ban_fail"] = "Ban for %s failed: %q",
    ["notify_admin_kick"] = "Admin %s kicked %s from server",
    ["notify_admin_reconnect"] = "Admin %s reconnected %s",
    ["notify_admin_quarantine"] = "Admin %s set %s into network quarantine. He won't be able to interact with anything on the server now.",
    ["notify_admin_unquarantine"] = "Admin %s removed %s from network quarantine",
    ["notify_admin_no_permission"] = "You do not have sufficient right to do that",
    ["notify_admin_client_not_connected"] = "Player is offline",
    ["notify_admin_already_inspecting"] = "You are already inspecting another player",

    ["notify_anticheat_detection"] = "Anticheat detection %q on %s. Reason: %q",
    ["notify_anticheat_detection_action"] = "Anticheat: %q",

    ["notify_anticheat_issue_fprofiler"] = "If the anticheat is active, client-side profiling will not work!",

    ["notify_aimbot_detection"] = "Aimbot detection %q on %s. Reason: %q",
    ["notify_aimbot_detection_action"] = "Aimbot: %q",

    ["notify_anticheat_verify"] = "Clientside anticheat from %s couldn't be loaded. This can also be caused by a slow connection.",
    ["notify_anticheat_verify_action"] = "Clientside anticheat couldn't be loaded. This can also be caused by a slow connection.",

    ["notify_banbypass_ban_fail"] = "Cannot ban %s for %q: %s",
    ["notify_banbypass_kick_fail"] = "Cannot kick %s for %q: %s",

    ["notify_banbypass_bypass_fingerprint_match"] = "%s might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "Might bypass a ban: Fingerprint matches with banned SteamID %s | Confidence: %d%%",

    ["notify_banbypass_familyshare"] = "Might bypass a ban: Familyshared account of banned SteamID %s",
    ["notify_banbypass_familyshare_action"] = "Might bypass a ban: Familyshared account of banned SteamID %s",

    ["notify_banbypass_clientcheck"] = "Might bypass a ban: Found evidence for a ban bypass of %s | Evidence: %s",
    ["notify_banbypass_clientcheck_action"] = "Might bypass a ban: Found evidence for a ban bypass of %s | Evidence: %s",

    ["notify_banbypass_ipcheck"] = "Might bypass a ban: Identical IP to banned player %s",
    ["notify_banbypass_ipcheck_action"] = "Might bypass a ban: Identical IP to banned player %s",

    ["notify_networking_exploit"] = "%s used an network exploit: %q",
    ["notify_networking_exploit_action"] = "Using network exploit: %q",
    ["notify_networking_backdoor"] = "%s used a network backdoor: %q",
    ["notify_networking_backdoor_action"] = "Using network backdoor: %q",

    ["notify_networking_spam"] = "%s is spamming netmessages (%d/%ds) (%d allowed).",
    ["notify_networking_spam_action"] = "Spamming netmessages (%d/%ds) (%d allowed).",
    ["notify_networking_limit"] = "%s exceeded the limit of %d netmessages per %d seconds.",
    ["notify_networking_limit_drop"] = "Ignoring netmessages from %s as he exceeded the limit of %d netmessages per %d seconds.",

    ["notify_networking_dos"] = "%s has caused a serverlag. Duration: %s within %d seconds",
    ["notify_networking_dos_action"] = "Causing serverlags. Duration: %s within %d seconds",

    ["notify_networking_dos_crash"] = "%s tried to crash server with large message. Message: %q, Size: %s, Compression ratio: %s",
    ["notify_networking_dos_crash_action"] = "Tried to crash server with large message. Message: %q ,Size: %s, Compression ratio: %s",

    ["notify_networking_restricted"] = "%s tried to send netmessage %q restricted to %q. This cannot be done without manipulation.",
    ["notify_networking_restricted_action"] = "Sent netmessage %q that only %q are allowed to. This cannot be done without manipulation.",

    ["notify_networking_screenshot_failed_multiple"] = "Screenshot for %s failed: You can only take one screenshot at a time",
    ["notify_networking_screenshot_failed_progress"] = "Screenshot for %s failed: Other screenshot for this player in progress.",
    ["notify_networking_screenshot_failed_timeout"] = "Screenshot for %s failed: Received no screenshot from client.",
    ["notify_networking_screenshot_failed_empty"] = "Screenshot of %s failed: Answer is empty. This can happen if it has been blocked by a cheat or the player is in the escape menu.", 

    ["notify_networking_auth_failed"] = "%s couldn't authenticate with the server. This could also be caused by a slow connection.",
    ["notify_networking_auth_failed_action"] = "Couldn't authenticate with the server. This could also be caused by a slow connection.",
    ["notify_networking_sendlua_failed"] = "%s blocks Nova Defender code from being run. This could also be caused by a slow connection.",
    ["notify_networking_sendlua_failed_action"] = "Blocks Nova Defender code from being run. This could also be caused by a slow connection.",

    ["notify_networking_issue_gm_express_not_installed"] = "gm_express is not installed on the server. More details in the 'Health' tab.",

    ["notify_networking_vpn"] = "%s is using a VPN: %s",
    ["notify_networking_vpn_action"] = "Using VPN: %s",
    ["notify_networking_country"] = "%s is from a not allowed country. %s",
    ["notify_networking_country_action"] = "From not allowed country. %s",

    ["notify_security_privesc"] = "%s was set usergroup %q that is whitelist only.",
    ["notify_security_privesc_action"] = "Was set usergroup %q that is whitelist only.",

    ["notify_functions_action"] = "Which action should we take against %s?\nReason: %s",
    ["notify_functions_action_notify"] = "Admin %s has taken the following action against detection %q of %s: %q.",
    ["notify_functions_allow_success"] = "Detection successfully excluded.",
    ["notify_functions_allow_failed"] = "Not possible to exclude this detection.",

    ["notify_custom_extension_ddos_protection_attack_started"] = "DDoS attack detected. Open menu with !nova for live status",
    ["notify_custom_extension_ddos_protection_attack_stopped"] = "DDoS attack stopped. Open menu with !nova for details",
    /*
        Health
    */
    ["health_check_gmexpress_title"] = "gm_express Module",
    ["health_check_gmexpress_desc"] = "Massive performance improvement, especially for larger servers. Created by CFC Servers.",
    ["health_check_gmexpress_desc_long"] =
[[Instead of sending large amounts of data via the built-in netmessages (slow),
they are transferred to the clients via HTTPS using an external provider (gmod.express).
This speeds up the loading time of clients and reduces the load on the server.
However, this option is dependent on gmod.express. If this host cannot be reached,
the authentication for clients fails. New clients that cannot connect to gmod.express,
fall back on the conventional netmessages.

To install, go to: https://github.com/CFC-Servers/gm_express.
   1. Click on "Code" and download the .zip file.
   2. Unzip the .zip file into the "/garrysmod/addons" directory.
   3. Restart your server.
   4. Activate the option "Activate gm_express" in the "Network" tab.

This service can also be self-hosted.
See: https://github.com/CFC-Servers/gm_express_service]],
    ["health_check_seversecure_title"] = "Serversecure Module",
    ["health_check_seversecure_desc"] = "A module that mitigates exploits on the Source engine. Created by danielga.",
    ["health_check_seversecure_desc_long"] =
[[Without this module it might be possible to easily crash your server.
It can limit the number of packets your server will accept and validate them.

To install, go to https://github.com/danielga/gmsv_serversecure.
   1. Go to Releases and download the .dll file for your servers operating system.
   2. Create a folder "garrysmod/lua/bin" if it doesn't exist.
   3. Place the .dll file in your "/garrysmod/lua/bin" folder.
   4. On Github download the "serversecure.lua" file ("/include/modules").
   5. Place this file inside the "/garrysmod/lua/includes/modules" folder.
   6. Restart your server.

If you want Nova Defender to configure the module for you, activate the
option "Set up Serversecure automatically" in the "Exploit" tab.]],
    ["health_check_exploits_title"] = "Addons with known exploits",
    ["health_check_exploits_desc"] = "List of netmessages of addons that are known to be exploitable.",
    ["health_check_exploits_desc_long"] =
[[A netmessage enables communication between client and server.
However, these messages can be easily manipulated by a client.
So if the server does not check if the client is allowed to send this message at all,
exploitable security holes (money glitch, server crashes, admin rights) can occur.

All listed names of netmessages can or could be exploited.
There is no guarantee that this vulnerability still exists.
Also there can be vulnerable netmessages which are not listed here.

   1. Update your addons regularly
   2. Replace outdated/unsupported addons with new ones
   3. If you are familiar with Lua, check the affected netmessages manually]],
    ["health_check_backdoors_title"] = "Backdoors",
    ["health_check_backdoors_desc"] = "Backdoors can be on the server to give an attacker unwanted access.",
    ["health_check_backdoors_desc_long"] =
[[Backdoors can be loaded onto a server in the following ways, among others:
   1. Malicious workshop addons
   2. A person asks you to upload a Lua file to the server
      that was made "especially for you"
   3. A developer with access to your server has built a backdoor for himself
   4. The server itself has been compromised (vulnerability in the operating system,
      vulnerability in software)

Ways to remove a back door:
   1. If available, check given path (if path starts with 'lua/' it's likely from workshop)
   2. Scan your server with e.g. https://github.com/THABBuzzkill/nomalua
   3. Remove all scripts you added recently and check if this message appears again
   4. Download all files on your server and do a text search for the listed backdoor
   5. HARD WAY: remove ALL addons until this message stops appearing, then add them
      back one by one and check the addon where it appears again.]],
    ["health_check_mysql_pass_title"] = "Weak Database Password",
    ["health_check_mysql_pass_desc"] = "Database password for Nova Defender is too weak.",
    ["health_check_mysql_pass_desc_long"] =
[[If you are using MySQL, you need a strong password.
Even if it is not accessible from the internet.

How to secure your database:
   1. A strong database password is nothing you have to remember
   2. Use a password generator to create a random password
   3. Use a different password for each database
   4. Use a different database for each addon (or proper database permissions)]],
   ["health_check_nova_errors_title"] = "Nova Defender Errors",
    ["health_check_nova_errors_desc"] = "Errors generated by Nova Defender",
    ["health_check_nova_errors_desc_long"] =
[[Well, read them. Please contact me, if you are unsure how to solve a given problem.
If each error message is conclusive to you and does not affect the functionality,
you can safely ignore this message.]],
    ["health_check_nova_vpn_title"] = "Nova Defender VPN Protection",
    ["health_check_nova_vpn_desc"] = "VPN protection must be set up to block countries and detect VPNs.",
    ["health_check_nova_vpn_desc_long"] =
    [[In the "Networking" tab you have to insert your API key,
which you get after the free registration at ipqualityscore.com.
With this, Nova-Defender can then examine IP addresses via this page.
   1. go to https://www.ipqualityscore.com/create-account
   2. copy your API key here https://www.ipqualityscore.com/user/settings
   3. paste it in the tab "Networking" under "VPN API key"]],
    ["health_check_nova_steamapi_title"] = "Nova Defender Steam Profile Protection",
    ["health_check_nova_steamapi_desc"] = "Steam profile protection must be set up to detect suspicious profiles of players.",
    ["health_check_nova_steamapi_desc_long"] =
    [[In the "Ban System" tab you need to insert your API key,
   1. go to https://steamcommunity.com/dev/apikey
   2. enter the domain name of your server
   3. copy your API key
   4. paste it in the tab "Ban System" under "Steam API key"]],
   ["health_check_nova_anticheat_title"] = "Nova Defender Anticheat extension",
   ["health_check_nova_anticheat_desc"] = "The anticheat needs an extension to detect more cheats.",
   ["health_check_nova_anticheat_desc_long"] =
   [[Currently only some simple cheats are detected. Since the source code of Nova Defender is open
and visible, cheats can be easily modified to be undetectable.
Therefore, serverowners can request the extension of the anticheat,
which also detects external, new or paid cheats by name.
Click the corresponding button at the top of the menu or join our Discord to read more.]],
   ["health_check_nova_anticheat_version_title"] = "Nova Defender Anticheat old version",
   ["health_check_nova_anticheat_version_desc"] = "The anticheat is not up to date.",
   ["health_check_nova_anticheat_version_desc_long"] =
   [[Please download the latest version from GitHub:
https://github.com/Freilichtbuehne/nova-defender-anticheat/releases/latest]],
   ["health_check_nova_ddos_protection_title"] = "Nova Defender DDoS protection extension",
   ["health_check_nova_ddos_protection_desc"] = "Defend your Linux server from DDoS attacks.",
   ["health_check_nova_ddos_protection_desc_long"] =
   [[Host-based DDoS protection for Linux servers.
Serverowners can request this extension.
Click the corresponding button at the top of the menu or join our Discord to read more.]],
   ["health_check_nova_ddos_protection_version_title"] = "Nova Defender DDoS protection old version",
   ["health_check_nova_ddos_protection_version_desc"] = "The DDoS protection is not up to date.",
   ["health_check_nova_ddos_protection_version_desc_long"] =
   [[Please download the latest version from GitHub:
https://github.com/Freilichtbuehne/nova-defender-ddos/releases/latest]],
    /*
        Server
    */
    ["server_general_suffix"] = "Text to append to every kick, ban or rejection message. For example your Teamspeak, Discord or other support site.",

    ["server_access_maintenance_enabled"] = "Maintenance Mode:\nOnly protected players and players with password can join the server.",
    ["server_access_maintenance_allowed"] = "Who can join the server in maintenance mode? Protected players are always allowed and don't need a password.",
    ["server_access_maintenance_password"] = "Password for maintenance mode, if you selected 'password' in the setting above.",
    ["server_access_maintenance_reason"] = "Reason to display a client, trying to connect during maintenance.",
    ["server_access_password_lock"] = "Lock wrong attempts:\nIf a client enters a wrong password too often, all following attempts will get blocked.",
    ["server_access_password_lock_reason"] = "Reason to display a client, if he entered a wrong password too often.",
    ["server_access_password_max_attempts"] = "Max attempts before lock",

    ["server_lockdown_enabled"] = "Lockdown Mode:\nONLY staff, protected and trusted can join the server. Use this when many new accounts are created to join the server for trolling, griefing or crashing the server. Players who are already on the server are not affected. Make sure to first define who is trusted in the config file of Nova Defender. This should be used only for a short time.",
    ["server_lockdown_reason"] = "Reason for kicking a player during lockdown mode if he is not protected, staff or trusted.",
    /*
        Admin Menu
    */
    ["menu_title_banbypass"] = "Ban System",
    ["menu_title_health"] = "Health",
    ["menu_title_network"] = "Networking",
    ["menu_title_security"] = "Security",
    ["menu_title_menu"] = "Menu",
    ["menu_title_anticheat"] = "Anticheat",
    ["menu_title_detections"] = "Detections",
    ["menu_title_bans"] = "Bans",
    ["menu_title_exploit"] = "Exploits",
    ["menu_title_players"] = "Players Online",
    ["menu_title_server"] = "Server",
    ["menu_title_inspection"] = "Inspect Players",
    ["menu_title_ddos"] = "DDoS Protection",

    ["menu_desc_banbypass"] = "Techniques to prevent players from bypassing a Nova Defender ban",
    ["menu_desc_network"] = "Restrict, control and log network activity",
    ["menu_desc_security"] = "Protect from privilege escalations of users",
    ["menu_desc_menu"] = "Control of notifications and admin menu",
    ["menu_desc_anticheat"] = "Enable or disable features of clientside anticheat to your desire",
    ["menu_desc_bans"] = "Find, ban or unban players",
    ["menu_desc_exploit"] = "Prevent specific exploits in game mechanic",
    ["menu_desc_players"] = "All players currently online",
    ["menu_desc_health"] = "See the state of your server at a glance",
    ["menu_desc_detections"] = "All pending detections that need to be reviewed",
    ["menu_desc_server"] = "Manage access to your server",
    ["menu_desc_inspection"] = "Run commands on players and search files",
    ["menu_desc_ddos"] = "Live status of DDoS Protection installed on Linux server",

    ["menu_elem_extensions"] = "Extensions:",
    ["menu_elem_disabled"] = "(disabled)",
    ["menu_elem_outdated"] = "(outdated)",
    ["menu_elem_add"] = "Add",
    ["menu_elem_edit"] = "Edit",
    ["menu_elem_unban"] = "Unban",
    ["menu_elem_ban"] = "Ban",
    ["menu_elem_kick"] = "Kick",
    ["menu_elem_reconnect"] = "Reconnect",
    ["menu_elem_quarantine"] = "Quarantine",
    ["menu_elem_unquarantine"] = "Unquarantine",
    ["menu_elem_verify_ac"] = "Check Anticheat",
    ["menu_elem_screenshot"] = "Screenshot",
    ["menu_elem_detections"] = "Detections",
    ["menu_elem_indicators"] = "Indicators",
    ["menu_elem_commands"] = "Commands",
    ["menu_elem_netmessages"] = "Netmessages",
    ["menu_elem_ip"] = "IP Details",
    ["menu_elem_profile"] = "Steamprofile",
    ["menu_elem_rem"] = "Remove",
    ["menu_elem_reload"] = "Reload",
    ["menu_elem_advanced"] = "Advanced Options",
    ["menu_elem_miss_options"] = "Miss some options?",
    ["menu_elem_copy"] = "Copy",
    ["menu_elem_save"] = "Save to disk",
    ["menu_elem_saved"] = "Saved",
    ["menu_elem_settings"] = "Settings:",
    ["menu_elem_general"] = "General:",
    ["menu_elem_discord"] = "Join our Discord!",
    ["menu_elem_close"] = "Close",
    ["menu_elem_cancel"] = "Cancel",
    ["menu_elem_filter_by"] = "Filter by:",
    ["menu_elem_view"] = "View",
    ["menu_elem_filter_text"] = "Filter Text:",
    ["menu_elem_reason"] = "Reason",
    ["menu_elem_comment"] = "Comment",
    ["menu_elem_bans"] = "Bans (limited to 150 entries):",
    ["menu_elem_new_value"] = "New value",
    ["menu_elem_submit"] = "Submit",
    ["menu_elem_no_bans"] = "No bans found",
    ["menu_elem_no_data"] = "No data available",
    ["menu_elem_checkboxtext_checked"] = "Active",
    ["menu_elem_checkboxtext_unchecked"] = "Inactive",
    ["menu_elem_search_term"] = "Search term...",
    ["menu_elem_unavailable"] = "Unavailable",
    ["menu_elem_failed"] = "Failed",
    ["menu_elem_passed"] = "Passed",
    ["menu_elem_health_overview"] = "Checks:\n  • Total: %d\n  • Passed: %d\n  • Failed: %d",
    ["menu_elem_health_most_critical"] = "Most Critical:\n",
    ["menu_elem_mitigation"] = "How to fix?",
    ["menu_elem_list"] = "Details",
    ["menu_elem_ignore"] = "Ignore",
    ["menu_elem_reset"] = "Reset",
    ["menu_elem_reset_all"] = "Reset all ignored checks:",
    ["menu_elem_player_count"] = "Players online: %d",
    ["menu_elem_foundindicator"] = "Found %d Indicator",
    ["menu_elem_foundindicators"] = "Found %d Indicators",
    ["menu_elem_criticalindicators"] = "Critical Indicators!",
    ["menu_elem_notauthed"] = "Authenticating...",

    ["menu_elem_mitigated"] = "Mitigated",
    ["menu_elem_unmitigated"] = "Not Mitigated",
    ["menu_elem_next"] = "Next",
    ["menu_elem_prev"] = "Previous",
    ["menu_elem_clear"] = "Delete mitigated",
    ["menu_elem_clear_all"] = "Delete all",
    ["menu_elem_delete"] = "Delete",
    ["menu_elem_stats"] = "Entries: %d",
    ["menu_elem_page"] = "Page: %d",

    ["menu_elem_nofocus"] = "No focus",
    ["menu_elem_focus"] = "Has focus",
    ["menu_elem_connect"] = "Connect",
    ["menu_elem_disconnect"] = "Disconnect",
    ["menu_elem_input_command"] = "Enter and run Lua code...",
    ["menu_elem_select_player"] = "Select a player",
    ["menu_elem_disconnected"] = "Disconnected",
    ["menu_elem_exec_clientopen"] = "Client opened the connection",
    ["menu_elem_exec_clientclose"] = "Client closed the connection",
    ["menu_elem_exec_error"] = "Internal server error",
    ["menu_elem_exec_help"] = [[Application:
• Use this if you are familiar with Lua
• Designed for debugging purposes and hunting for Lua cheats

General:
• Enter Lua code and press enter to execute it on the selected client
• Lua errors will be displayed in the console
• Lua errors are invisible to the client

Displaying values:
• To get the value of a table or string use "print()" or "PrintTable()"
• Executing "print" and "PrintTable" is not visible to the client
• Executing "print" and "PrintTable" will get redirected to your console
• Example 1: "PrintTable(hook.GetTable())"
• Example 2: "local nick = LocalPlayer():Nick() print(nick)"

History:
• Use UP and DOWN to navigate through history
• Use TAB to autocomplete

Security:
• Execute Lua code responsibly
• Executed code might be visible to the client
• Executed code could get blocked or manipulated by the client]],
    ["menu_elem_help"] = "Help",
    ["menu_elem_filetime"] = "Last file modification: %s",
    ["menu_elem_filesize"] = "Filesize: %s",
    ["menu_elem_download"] = "Download",
    ["menu_elem_download_confirm"] = "Are you sure to download the following file?\n%q",
    ["menu_elem_download_progress"] = "Loading chunk %i/%i...",
    ["menu_elem_download_finished_part"] = "File was partially downloaded and saved inside your local Garry's Mod data folder:\n%q",
    ["menu_elem_download_finished"] = "File finished downloading and was saved inside your local Garry's Mod data folder:\n%q",
    ["menu_elem_download_failed"] = "Download failed: %q",
    ["menu_elem_download_started"] = "Downloading file: %q",
    ["menu_elem_download_confirmbutton"] = "Download",
    ["menu_elem_canceldel"] = "Cancel and delete",

    ["menu_elem_ddos_active"] = "DDoS Protection enabled!",
    ["menu_elem_ddos_inactive"] = "DDoS Protection disabled",
    ["menu_elem_ddos_duration"] = "Duration: %s",
    ["menu_elem_ddos_avg"] = "Avg RX: %s",
    ["menu_elem_ddos_max"] = "Max RX: %s",
    ["menu_elem_ddos_stopped"] = "Stopped at: %s",
    ["menu_elem_ddos_stats"] = "Stats of last attack:",
    ["menu_elem_ddos_cpu_util"] = "CPU Utilization",
    ["menu_elem_ddos_net_util"] = "Network Utilization",

    ["indicator_pending"] = "Player has not sent his indicators to the server yet. Either he blocks them or needs some more time.",
    ["indicator_install_fresh"] = "Player recently installed this game",
    ["indicator_install_reinstall"] = "Player recently reinstalled this game",
    ["indicator_advanced"] = "Player uses debug/developer commands (he might know what he is doing...)",
    ["indicator_first_connect"] = "First time connected to this server (if game hasn't been reinstalled)",
    ["indicator_cheat_hotkey"] = "Player has pressed a key (INSERT, HOME, PAGEUP, PAGEDOWN) that is often used to open cheat menus",
    ["indicator_cheat_menu"] = "Player has opened a menu using one of the keys INSERT, HOME, PAGEUP or PAGEDOWN",
    ["indicator_bhop"] = "Player has a bunnyhop bind on his mouse wheel (like 'bind mwheelup +jump')",
    ["indicator_memoriam"] = "Player has used the cheat 'Memoriam' in the past or is currently doing so",
    ["indicator_multihack"] = "Player has used the cheat 'Garrysmod 64-bit Visuals Multihack Reborn' in the past or is currently doing so",
    ["indicator_fenixmulti"] = "Player has used the cheat 'FenixMulti' in the past or is currently doing so",
    ["indicator_interstate"] = "Player has used the cheat 'interstate editor' in the past or is currently doing so",
    ["indicator_exechack"] = "Player has used the paid cheat 'exechack' in the past or is currently doing so",
    ["indicator_banned"] = "Player has been banned by Nova Defender on another server",
    ["indicator_lua_binaries"] = "Player has DLL files in the folder 'garrysmod/lua/bin'. Cheats are often placed here. The files can be browsed in the 'Inspection' tab. These files must have been created manually by the player.",
    ["indicator_profile_familyshared"] = "Player has a familyshared account",
    ["indicator_profile_friend_banned"] = "A Steam friend of this player has been banned by Nova Defender",
    ["indicator_profile_recently_created"] = "Steam profile has been created in the last 7 days",
    ["indicator_profile_nogames"] = "Player has not purchased any games on his Steam profile yet",
    ["indicator_profile_new_player"] = "Player has not played Garry's Mod for more than 2 hours in total",
    ["indicator_profile_vac_banned"] = "Player has already received a VAC ban",
    ["indicator_profile_vac_bannedrecent"] = "Player has already received a VAC ban in the last 5 months",
    ["indicator_profile_community_banned"] = "Player has already received a community ban from Steam",
    ["indicator_profile_not_configured"] = "Player has not even set up his Steam account yet",
    ["indicator_scenario_bypass_account"] = "Indicators suggest that this player has specially created a new Steam account. See the 'Players Online' menu tab.",
    ["indicator_scenario_cheatsuspect"] = "Indicators suggest that this player cheated. See 'Players Online' menu tab",
    ["indicator_scenario_sum"] = "Player is suspicious because he meets a high number of typical indicators. See menu tab 'Player Online'",

    ["internal_reason"] = "Internal Reason",
    ["banned"] = "Banned",
    ["status"] = "Status",
    ["reason"] = "Reason",
    ["unban_on_sight"] = "Unban on sight",
    ["ip"] = "IP",
    ["ban_on_sight"] = "Ban on sight",
    ["time"] = "Time",
    ["comment"] = "Comment",
    ["steamid"] = "SteamID32",
    ["steamid64"] = "SteamID64",
    ["usergroup"] = "Usergroup",
    ["familyowner"] = "Family Sharing Owner",
    ["group"] = "Group",
    ["kick"] = "Kick",
    ["allow"] = "Disable this detection",
    ["reconnect"] = "Reconnect",
    ["ban"] = "Ban",
    ["notify"] = "Notify",
    ["nothing"] = "Nothing",
    ["set"] = "Set back",
    ["disable"] = "Disable in future",
    ["ignore"] = "Ignore temporarily",
    ["dont_care"] = "Don't care",
    ["action_taken_at"] = "Action taken at",
    ["action_taken_by"] = "Action taken by",

    ["sev_none"] = "None",
    ["sev_low"] = "Low",
    ["sev_medium"] = "Medium",
    ["sev_high"] = "High",
    ["sev_critical"] = "Critical",
}

// DO NOT CHANGE ANYTHING BELOW THIS
if SERVER then
    Nova["languages_" .. lang] = function() return phrases end
else
    NOVA_SHARED = NOVA_SHARED or {}
    NOVA_SHARED["languages_" .. lang] = phrases
end