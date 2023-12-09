local lang = "zh_hans"

local phrases = {
    -- Notifications
    ["menu_logging_debug"] = "调试模式：\n 这将向服务器控制台打印额外日志。",
    ["menu_notify_timeopen"] = "通知显示持续时间（秒）。",
    ["menu_notify_showstaff"] = "向管理员显示通知。",
    ["menu_notify_showinfo"] = "显示信息通知",
    ["menu_access_player"] = "管理员可以访问'玩家在线'选项卡，并在那里执行操作。管理员不能对受保护的玩家进行操作。",
    ["menu_access_staffseeip"] = "管理员可以看到玩家的 IP 地址",
    ["menu_access_detections"] = "管理员可访问'检测'选项卡",
    ["menu_access_bans"] = "管理员可访问'封禁'选项卡",
    ["menu_access_health"] = "管理员可访问'健康'选项卡",
    ["menu_access_inspection"] = "管理员可以访问'检查玩家'选项卡",
    ["menu_action_timeopen"] = "惩罚提示显示持续时间（秒）。",
    ["menu_action_showstaff"] = "如果没有受保护的玩家在场（或 AFK），则要求管理员采取惩罚行动。",
    -- Networking
    ["networking_concommand_logging"] = "记录命令：\n 记录客户端和服务器执行的每一条控制台命令",
    ["networking_concommand_dump"] = "Dump Commands:（转储命令）：当玩家断开连接时，将他执行过的所有命令打印到控制台。这会让你的日志快速增长。",
    ["networking_netcollector_dump"] = "Dump Netmessages:（当玩家断开连接时，将其发送到服务器的所有网络信息打印到控制台。",
    ["networking_netcollector_spam_action"] = "当玩家向服务器发送垃圾网络信息时会发生什么？",
    ["networking_netcollector_spam_reason"] = "玩家向服务器发送垃圾短信而被踢或禁言的原因",
    ["networking_dos_action"] = "当玩家试图导致服务器延迟时应该怎么办？",
    ["networking_dos_reason"] = "玩家因导致服务器延迟而被踢或禁言的原因",
    ["networking_dos_sensivity"] = "检测应该有多敏感？",
    ["networking_netcollector_actionAt"] = "在 3 秒钟内单个客户端发出多少条消息，我们就应该采取多少行动？切勿设置过低！",
    ["networking_netcollector_dropAt"] = "在 3 秒钟内收到多少条信息时，我们就应该忽略多少条 netmessage。这样做是为了防止拒绝服务。应低于上述设置。",
    ["networking_restricted_message_action"] = "当玩家向服务器发送不允许发送的信息时，应该如何处理？如果不操纵游戏或出现错误，玩家不可能发送此信息。",
    ["networking_restricted_message_reason"] = "玩家向服务器发送不允许发送的信息而被踢出或禁言的原因",
    ["networking_sendlua_authfailed_action"] = "当玩家没有回应 Nova Defender 验证时该怎么办？如果忽略，则无法保证 anticheat 或其他客户端机制是否有效。",
    ["networking_sendlua_authfailed_reason"] = "玩家因未响应 Nova Defender 身份验证而被踢或封禁的原因",
    ["networking_sendlua_validationfailed_action"] = "当玩家阻止 Nova Defender 的代码时会发生什么？",
    ["networking_sendlua_validationfailed_reason"] = "玩家被 Nova Defender 屏蔽代码踢出或禁言的原因",
    ["networking_fakenets_backdoors_load"] = "创建假后门并诱骗攻击者使用它们。",
    ["networking_fakenets_backdoors_block"] = "阻止服务器上的后门。可能会阻止合法的网络信息并破坏附加程序！首先查看'健康'选项卡并检查是否存在后门。",
    ["networking_fakenets_backdoors_action"] = "当攻击者使用假后门时会发生什么？",
    ["networking_fakenets_exploits_load"] = "创建虚假漏洞并诱使攻击者使用它们",
    ["networking_fakenets_exploits_block"] = "阻止服务器上可利用的网络信息。这会破坏服务器上的可利用插件！首先查看'健康'选项卡，检查哪些附加组件可被利用。",
    ["networking_fakenets_exploits_action"] = "当攻击者使用假冒漏洞时会发生什么？",
    ["networking_vpn_vpn-action"] = "当玩家使用 VPN 时会发生什么？",
    ["networking_vpn_vpn-action_reason"] = "使用 VPN 的原因",
    ["networking_vpn_country-action"] = "当玩家来自不允许的国家时会发生什么情况？",
    ["networking_vpn_country-action_reason"] = "来自不允许国家的原因",
    ["networking_vpn_dump"] = "将玩家 IP 地址信息打印到控制台",
    ["networking_vpn_apikey"] = "VPN API 密钥：用于扫描 IP 地址。您需要在 https://www.ipqualityscore.com/create-account 注册，并在 https://www.ipqualityscore.com/user/settings 获取密钥",
    ["networking_vpn_countrycodes"] = "允许加入您服务器的国家。从此处获取国家代码：https://countrycode.org/（大写 2 个字母的代码）。建议将本国和邻国列入白名单。您可以逐次添加更多国家。",
    ["networking_vpn_whitelist_asns"] = "白名单 ASN 号码（用于识别互联网服务提供商的号码）。API 可能会错误地检测到 VPN 连接。因此，已知的 ISP 会被列入白名单。请从 https://ipinfo.io/countries 获取。另外，您也可以在'玩家'选项卡中查看每个已连接客户端的 ASN",
    ["networking_screenshot_store_ban"] = "保存屏幕截图（禁言时）：在玩家被禁言之前，会制作一张他的屏幕截图，并保存在服务器的'/data/nova/ban_screenshots'文件夹中。",
    ["networking_screenshot_store_manual"] = "保存截图（菜单）：如果管理员给玩家截图，截图将保存在服务器的'/data/nova/admin_screenshots'文件夹中。",
    ["networking_screenshot_limit_ban"] = "截图限制（禁言时）:（截图上限）：服务器数据文件夹中存储的截图数量上限。最旧的截图将被删除。",
    ["networking_screenshot_limit_manual"] = "屏幕截图限制（菜单）：存储在服务器数据文件夹中的屏幕截图的最大数量。 最旧的截图将被删除。",
    ["networking_screenshot_steam"] = "通过 Steam 截图：\nCheats 通常会阻止插件截图。我们可以通过 Steam 截图绕过这一点。用户会注意到这一点，因为它会出现在他的 Steam 截图库中。如果未选中，则使用传统方法。",
    ["networking_screenshot_quality"] = "屏幕截图质量（Screenshot Quality）传输高质量屏幕截图可能需要一分钟。",

    ["networking_http_overwrite"] = "检查 HTTP 调用（发送+接收）：（n）如果启用此设置，HTTP 功能将被覆盖，并可记录或阻止请求。不过，这种方法也可以绕过或禁用 DRM 系统。",
    ["networking_http_logging"] = "记录请求：所有 HTTP 请求都会详细记录在控制台中。这有助于全面了解调用了哪些 URL。仅在检查 HTTP 请求时有效。",
    ["networking_http_blockunsafe"] = "阻止不安全的请求：\n来自控制台或 RunString 等不安全来源的请求会被阻止。",
    ["networking_http_whitelist"] = "启用白名单：只允许已添加到列表中的域和 IP 地址。",
    ["networking_http_whitelistdomains"] = "白名单域：添加应允许的所有可信域和 IP。其他一切都将被阻止。如果不确定要将哪些域列入白名单，请禁用白名单并只启用日志记录。",

    ["networking_fetch_overwrite"] = "检查 http.fetch（接收数据）：（n）重写 http.fetch 函数。如果使用 vcmod，请勿启用！不过，这种方法也可以绕过或禁用 DRM 系统。",
    ["networking_fetch_whitelist"] = "启用白名单：只允许添加到列表中的域和 IP 地址。",
    ["networking_fetch_blockunsafe"] = "阻止不安全的请求：\n来自控制台或 RunString 等不安全来源的请求会被阻止。",

    ["networking_post_overwrite"] = "检查 http.post（发送数据）：改写 http.post 函数。发送 HTTP 请求可被攻击者用来窃取服务器上的文件。不过，这种方法也可以绕过或禁用 DRM 系统。",
    ["networking_post_whitelist"] = "启用白名单：只允许已添加到列表中的域和 IP 地址。",
    ["networking_post_blockunsafe"] = "阻止不安全的请求：\n来自控制台或 RunString 等不安全来源的请求会被阻止。",
    -- Banbypass
    ["banbypass_ban_banstaff"] = "管理员可能被禁言",
    ["banbypass_ban_default_reason"] = "如果没有说明玩家被封禁的原因",

    ["banbypass_bypass_default_reason"] = "玩家绕过封禁被封禁的原因",

    ["banbypass_bypass_familyshare_action"] = "当玩家使用被禁言玩家的家庭共享账号时，应该怎么办？",
    ["banbypass_bypass_clientcheck_action"] = "如果我们在玩家的本地文件中发现了绕过禁言的证据，该怎么办？",
    ["banbypass_bypass_ipcheck_action"] = "如果玩家的 IP 地址与被禁玩家的相同，该怎么办？",

    ["banbypass_bypass_fingerprint_enable"] = "启用指纹检查:\n该选项检查玩家是否与被禁用户使用同一设备。只要玩家被禁用，它就能阻止他在同一设备上创建新账号",
    ["banbypass_bypass_fingerprint_action"] = "当玩家与被禁用户使用同一设备时该怎么办？",
    ["banbypass_bypass_fingerprint_sensivity"] = "指纹比对的灵敏度应该有多高？",

    ["banbypass_bypass_indicators_apikey"] = "Steam API 密钥：\nThe SteamAPI 可用于查看有关玩家的更详细数据。查找结果显示在指示器中的'玩家在线'选项卡中。在 https://steamcommunity.com/dev/apikey 创建一个并粘贴到这里。",
    -- Anticheat
    ["anticheat_reason"] = "如果玩家使用任何形式的作弊，他将被封禁的原因。",
    ["anticheat_enabled"] = "启用反作弊：\n如果启用此选项，反作弊代码将发送给所有客户端并处理检测。如果此选项被禁用，反作弊代码仍然在所有当前连接的客户端上保持活动，但检测将被忽略。此选项包括自动点击和瞄准辅助检测。",
    ["anticheat_action"] = "当玩家有作弊行为时应该发生什么？",
    ["anticheat_verify_action"] = "当反作弊无法为玩家加载时，应该发生什么？",
    ["anticheat_verify_execution"] = "检查反作弊是否正在运行：\n在玩家收到反作弊后，将请求确认他是否已执行它。然而，这个过程可能会因为几个原因而失败，因此不应设置为'封禁'。",
    ["anticheat_verify_reason"] = "如果反作弊无法加载，玩家将被封禁的原因。",
    ["anticheat_check_function"] = "检查函数：\n比较客户端上的函数名称与已知的作弊函数名称。这可能会检测到您提供的代码中的合法函数。",
    ["anticheat_check_files"] = "检查文件：\n类似于'检查函数'。比较正在运行的脚本的文件名与已知的作弊文件名。",
    ["anticheat_check_globals"] = "检查全局变量：\n类似于'检查函数'。比较变量名称与已知的作弊变量名称。",
    ["anticheat_check_modules"] = "检查模块：\n类似于'检查函数'。比较模块名称与已知的作弊模块名称。",
    ["anticheat_check_runstring"] = "检查'RunString'：\n可以使用内置的'RunString'函数执行任意Lua代码。此选项检测此函数的不当使用，并搜索已知的作弊模式。",
    ["anticheat_check_external"] = "检查外部篡改：\n这将检测外部作弊软件。这些在受限的Lua环境中非常难以检测。这将减慢像FProfiler这样的分析器。",
    ["anticheat_check_manipulation"] = "检测篡改：\n检测尝试阻止或操纵反作弊的行为。",
    ["anticheat_check_cvars"] = "检查控制台变量：\n类似于'检查函数'。一些作弊利用cvars来持久化设置。比较cvar名称与已知的作弊cvar名称。",
    ["anticheat_check_byte_code"] = "检查代码编译：\n在底层，Lua代码使用JIT编译成字节码，然后进行解释。我们有时可以确定这是否以不寻常的方式完成。例如，如果客户端通过lua_run_cl执行代码。",
    ["anticheat_check_detoured_functions"] = "检查函数绕行：\n一些作弊覆盖了内置函数的功能，以规避检测或操纵游戏行为。",
    ["anticheat_check_concommands"] = "检查控制台命令：\n类似于'检查控制台变量'。一些作弊可以通过控制台访问。比较命令名称与已知的作弊命令名称。",
    ["anticheat_check_net_scan"] = "检查扫描：\n一些脚本可以扫描服务器以寻找已知的漏洞或后门。",
    ["anticheat_check_cheats_custom"] = "检测已知的作弊：\n通过特殊分析检测广泛使用的作弊。作弊的确切名称将显示在原因中。",
    ["anticheat_check_cheats_custom_unsure"] = "检测不活动的作弊：\n在检测一些作弊时，我们不知道这个作弊是否当前处于活动状态。唯一确定的是，这个人曾经使用过这个作弊。",
    ["anticheat_spam_filestealers"] = "混乱文件窃取者：\n一些作弊将他们从服务器接收到的所有执行的Lua代码存储在文本文件中。为了使这些文件混乱并使攻击者更难（稍微），我们用无用的代码混乱这些文件。这会慢慢填满玩家的磁盘。这对玩家的加载时间没有负面影响。",
    ["anticheat_autoclick_enabled"] = "启用自动点击检测：\n出于明显的原因，我们不希望任何玩家使用程序进行快速点击或按键。这包括左键和右键点击，使用和空格键。",
    ["anticheat_autoclick_action"] = "当玩家使用自动点击时，应该发生什么？",
    ["anticheat_autoclick_reason"] = "如果玩家使用了自动点击，他将被封禁的原因。",
    ["anticheat_autoclick_sensivity"] = "自动点击灵敏度：\n高灵敏度可能会因为罕见的巧合错误地检测到玩家。好的自动点击器可能不会被低灵敏度检测到。根据自动点击器如何给作弊者带来优势来决定。",
    ["anticheat_autoclick_check_fast"] = "检查快速点击速度：\n在一定数量的CPS（每秒点击次数）以上，我们可以假设一个人不可能在没有辅助的情况下做到这一点。这也适用于键。",
    ["anticheat_autoclick_check_fastlong"] = "检查长时间的快速点击：\n玩家不太可能在几分钟内快速点击而没有短暂的暂停。",
    ["anticheat_autoclick_check_robotic"] = "检查非人类的点击一致性：\n一个人永远不能以完全相同的速度点击。它总是会稍微快一点或慢一点。然而，一个程序可以非常精确地计时。如果点击之间的时间间隔过于一致，我们可以告诉。",
    ["anticheat_aimbot_enabled"] = "启用瞄准辅助检测：\n实时监控所有玩家的移动。",
    ["anticheat_aimbot_action"] = "当玩家使用瞄准辅助时，应该发生什么？",
    ["anticheat_aimbot_reason"] = "玩家使用瞄准机器人时被禁赛的原因。",
    ["anticheat_aimbot_check_snap"] = "检测快速转动:\n检测玩家视角是否瞬间改变。警告：这将阻止客户端设置其视角角度（如果不是服务器端完成），因此会破坏某些插件！",
    ["anticheat_aimbot_check_move"] = "检测可疑的移动:\n检测玩家是否在不移动鼠标的情况下不断改变视角。",
    ["anticheat_aimbot_check_contr"] = "检测矛盾的移动:\n检测玩家是否将鼠标移动到与视角变化不同的方向。",
    -- Exploit
    ["exploit_fix_propspawn"] = "Propspawn:\n防止生成具有复制材料的道具。",
    ["exploit_fix_material"] = "Material:\n防止材料复制。",
    ["exploit_fix_fadingdoor"] = "Fadingdoor:\n防止玩家无法再看到的图形错误。",
    ["exploit_fix_physgunreload"] = "Physgun:\n为用户禁用物理枪重载。",
    ["exploit_fix_bouncyball"] = "Bouncyball:\n防止焊接弹跳球。",
    ["exploit_fix_bhop"] = "Bunnyhop:\n防止兔子跳。",
    ["exploit_fix_serversecure"] = "自动设置Serversecure:\n查看'Health'选项卡以获取更多信息。",
    -- Security
    ["security_permissions_groups_protected"] = "受保护的用户组：\n被视为受保护的所有用户组。只有白名单上的玩家可以拥有此组。受保护的玩家可以完全访问此菜单。",
    ["security_permissions_groups_staff"] = "员工和管理员用户组：\n拥有员工权限的所有用户组。",
    ["security_privileges_group_protection_enabled"] = "自动等级保护：\n如果一个没有被列入白名单的玩家例如拥有一个受保护的用户组，我们将采取行动。",
    ["security_privileges_group_protection_escalation_action"] = "当一个玩家拥有他不应该拥有的受保护用户组时，应该发生什么？",
    ["security_privileges_group_protection_escalation_reason"] = "如果一个玩家拥有他不应该拥有的受保护用户组，他被踢出或封禁的原因。",
    ["security_privileges_group_protection_removal_action"] = "当一个受保护的玩家失去他的用户组时，应该发生什么？",
    ["security_privileges_group_protection_protected_players"] = "受保护的玩家：\n所有被允许拥有受保护用户组的玩家。如果你移除一个在线的玩家，他将被踢出。",
    ["security_privileges_group_protection_kick_reason"] = "如果一个受保护的玩家在他连接时失去了他的保护，踢出他的原因。",
    -- Detections
    ["config_detection_banbypass_familyshare"] = "家庭共享账户绕过封禁",
    ["config_detection_banbypass_clientcheck"] = "封禁绕过客户端检查",
    ["config_detection_banbypass_ipcheck"] = "封禁绕过IP检查",
    ["config_detection_banbypass_fingerprint"] = "封禁绕过指纹",
    ["config_detection_networking_country"] = "不允许的玩家国家",
    ["config_detection_networking_vpn"] = "使用VPN",
    ["config_detection_networking_backdoor"] = "使用假后门",
    ["config_detection_networking_spam"] = "垃圾邮件网络消息",
    ["config_detection_networking_dos"] = "导致服务器延迟",
    ["config_detection_networking_authentication"] = "客户端无法与服务器进行身份验证",
    ["config_detection_networking_restricted_message"] = "客户端向服务器发送仅管理员可用的消息",
    ["config_detection_networking_exploit"] = "使用假漏洞",
    ["config_detection_networking_validation"] = "客户端无法验证代码执行",
    ["config_detection_anticheat_scanning_netstrings"] = "扫描漏洞和后门",
    ["config_detection_anticheat_runstring_dhtml"] = "通过DHTML执行代码",
    ["config_detection_anticheat_runstring_bad_string"] = "RunString包含作弊模式（字符串）",
    ["config_detection_anticheat_remove_ac_timer"] = "禁用反作弊",
    ["config_detection_anticheat_gluasteal_inject"] = "使用文件窃取器运行代码",
    ["config_detection_anticheat_function_detour"] = "函数绕行以操纵游戏",
    ["config_detection_anticheat_external_bypass"] = "外部作弊",
    ["config_detection_anticheat_runstring_bad_function"] = "RunString包含作弊模式（函数）",
    ["config_detection_anticheat_jit_compilation"] = "不寻常的字节码编译",
    ["config_detection_anticheat_known_cvar"] = "已知的作弊cvar",
    ["config_detection_anticheat_known_file"] = "发现作弊文件",
    ["config_detection_anticheat_known_data"] = "发现作弊遗留",
    ["config_detection_anticheat_known_module"] = "包含已知的作弊模块",
    ["config_detection_anticheat_known_concommand"] = "作弊控制台命令",
    ["config_detection_anticheat_verify_execution"] = "阻止反作弊",
    ["config_detection_anticheat_known_global"] = "作弊全局变量",
    ["config_detection_anticheat_known_cheat_custom"] = "已知的作弊",
    ["config_detection_anticheat_known_function"] = "作弊全局函数",
    ["config_detection_anticheat_manipulate_ac"] = "操纵反作弊",
    ["config_detection_anticheat_autoclick_fast"] = "非人类的点击速度",
    ["config_detection_anticheat_autoclick_fastlong"] = "长时间的快速点击速度",
    ["config_detection_anticheat_autoclick_robotic"] = "非人类的点击一致性",
    ["config_detection_anticheat_aimbot_snap"] = "瞄准辅助在1 tick内即时捕捉",
    ["config_detection_anticheat_aimbot_move"] = "瞄准辅助可疑的移动",
    ["config_detection_anticheat_aimbot_contr"] = "瞄准辅助矛盾的移动",
    ["config_detection_security_privilege_escalation"] = "权限升级到受保护的用户组",
    ["config_detection_admin_manual"] = "管理员或控制台的手动封禁",
    -- Notifications
    ["menu_notify_hello_staff"] = "此服务器受Nova Defender保护。\n您被归类为管理员。",
    ["menu_notify_hello_protected"] = "此服务器受Nova Defender保护。\n您被归类为受保护的用户。",
    ["menu_notify_hello_menu"] = "使用!nova打开菜单。",

    ["notify_admin_unban"] = "成功解禁%s。当玩家下次连接到服务器时，封禁将被移除。",
    ["notify_admin_ban"] = "成功封禁%s。如果他下次加入服务器，将被封禁。",
    ["notify_admin_ban_online"] = "管理员%s封禁了%s。玩家将在几秒钟内被封禁。",
    ["notify_admin_ban_offline"] = "管理员%s封禁了%s。如果他下次加入服务器，将被封禁。",
    ["notify_admin_ban_fail"] = "封禁%s失败：%q",
    ["notify_admin_kick"] = "管理员%s将%s踢出了服务器",
    ["notify_admin_reconnect"] = "管理员%s重新连接了%s",
    ["notify_admin_quarantine"] = "管理员%s将%s设置为网络隔离。他现在将无法与服务器上的任何东西进行交互。",
    ["notify_admin_unquarantine"] = "管理员%s将%s从网络隔离中移除",
    ["notify_admin_no_permission"] = "您没有足够的权限来执行此操作",
    ["notify_admin_client_not_connected"] = "玩家不在线",
    ["notify_admin_already_inspecting"] = "您已经在检查另一个玩家",

    ["notify_anticheat_detection"] = "在%s上检测到反作弊%q。原因：%q",
    ["notify_anticheat_detection_action"] = "反作弊：%q",

    ["notify_anticheat_issue_fprofiler"] = "如果反作弊处于活动状态，客户端侧的分析将无法工作！",

    ["notify_aimbot_detection"] = "在%s上检测到瞄准辅助%q。原因：%q",
    ["notify_aimbot_detection_action"] = "瞄准辅助：%q",

    ["notify_anticheat_verify"] = "%s的客户端反作弊无法加载。这也可能是由于连接速度慢造成的。",
    ["notify_anticheat_verify_action"] = "客户端反作弊无法加载。这也可能是由于连接速度慢造成的。",

    ["notify_banbypass_ban_fail"] = "无法封禁%s的%q：%s",
    ["notify_banbypass_kick_fail"] = "无法踢出%s的%q：%s",

    ["notify_banbypass_bypass_fingerprint_match"] = "%s可能绕过封禁：指纹与被封禁的SteamID %s匹配 | 置信度：%d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "可能绕过封禁：指纹与被封禁的SteamID %s匹配 | 置信度：%d%%",

    ["notify_banbypass_familyshare"] = "可能绕过封禁：被封禁的SteamID %s的家庭共享账户",
    ["notify_banbypass_familyshare_action"] = "可能绕过封禁：被封禁的SteamID %s的家庭共享账户",

    ["notify_banbypass_clientcheck"] = "可能绕过封禁：发现%s的封禁绕过证据 | 证据：%s",
    ["notify_banbypass_clientcheck_action"] = "可能绕过封禁：发现%s的封禁绕过证据 | 证据：%s",

    ["notify_banbypass_ipcheck"] = "可能绕过封禁：与被封禁的玩家%s的IP相同",
    ["notify_banbypass_ipcheck_action"] = "可能绕过封禁：与被封禁的玩家%s的IP相同",

    ["notify_networking_exploit"] = "%s使用了一个网络漏洞：%q",
    ["notify_networking_exploit_action"] = "使用网络漏洞：%q",
    ["notify_networking_backdoor"] = "%s使用了一个网络后门：%q",
    ["notify_networking_backdoor_action"] = "使用网络后门：%q",

    ["notify_networking_spam"] = "%s正在垃圾邮件网络消息（%d/%ds）（允许%d）。",
    ["notify_networking_spam_action"] = "垃圾邮件网络消息（%d/%ds）（允许%d）。",
    ["notify_networking_limit"] = "%s超过了每%d秒%d个网络消息的限制。",
    ["notify_networking_limit_drop"] = "忽略来自%s的网络消息，因为他超过了每%d秒%d个网络消息的限制。",

    ["notify_networking_dos"] = "%s导致了服务器延迟。持续时间：%s，%d秒内",
    ["notify_networking_dos_action"] = "导致服务器延迟。持续时间：%s，%d秒内",

    ["notify_networking_restricted"] = "%s试图发送仅限于%q的网络消息%q。这不能在没有操纵的情况下完成。",
    ["notify_networking_restricted_action"] = "发送了仅%q允许的网络消息%q。这不能在没有操纵的情况下完成。",

    ["notify_networking_screenshot_failed_multiple"] = "%s的截图失败：您一次只能拍摄一张截图",
    ["notify_networking_screenshot_failed_progress"] = "%s的截图失败：此玩家的其他截图正在进行中。",
    ["notify_networking_screenshot_failed_timeout"] = "%s的截图失败：未从客户端接收到截图。",

    ["notify_networking_auth_failed"] = "%s无法与服务器进行身份验证。这也可能是由于连接速度慢造成的。",
    ["notify_networking_auth_failed_action"] = "无法与服务器进行身份验证。这也可能是由于连接速度慢造成的。",
    ["notify_networking_sendlua_failed"] = "%s阻止Nova Defender代码运行。这也可能是由于连接速度慢造成的。",
    ["notify_networking_sendlua_failed_action"] = "阻止Nova Defender代码运行。这也可能是由于连接速度慢造成的。",

    ["notify_networking_vpn"] = "%s正在使用VPN：%s",
    ["notify_networking_vpn_action"] = "正在使用VPN：%s",
    ["notify_networking_country"] = "%s来自不允许的国家。%s",
    ["notify_networking_country_action"] = "来自不允许的国家。%s",

    ["notify_security_privesc"] = "%s被设置为仅白名单的用户组%q。",
    ["notify_security_privesc_action"] = "被设置为仅白名单的用户组%q。",

    ["notify_functions_action"] = "我们应该对%s采取哪种行动？\n原因：%s",
    ["notify_functions_action_notify"] = "管理员%s对%s的检测%q采取了以下行动：%q。",
    ["notify_functions_allow_success"] = "成功排除检测。",
    ["notify_functions_allow_failed"] = "无法排除此检测。",
    -- Health
    ["health_check_seversecure_title"] = "Serversecure模块",
    ["health_check_seversecure_desc"] = "一个可以减轻Source引擎上的漏洞的模块。由danielga创建。",
    ["health_check_seversecure_desc_long"] =
    [[如果没有这个模块，你的服务器可能很容易崩溃。
    它可以限制你的服务器接受的数据包数量并验证它们。

    要安装，请访问https://github.com/danielga/gmsv_serversecure。
       1. 转到Releases并下载适用于你服务器操作系统的.dll文件。
       2. 如果不存在"garrysmod/lua/bin"文件夹，请创建一个。
       3. 将.dll文件放在你的"/garrysmod/lua/bin"文件夹中。
       4. 在Github上下载"serversecure.lua"文件("/include/modules")。
       5. 将此文件放在"/garrysmod/lua/includes/modules"文件夹内。
       6. 重启你的服务器。

    如果你希望Nova Defender为你配置模块，请在"Exploit"选项卡中激活"自动设置Serversecure"选项。]],
    ["health_check_exploits_title"] = "已知可被利用的插件",
    ["health_check_exploits_desc"] = "已知可被利用的插件的网络消息列表。",
    ["health_check_exploits_desc_long"] =
    [[网络消息使客户端和服务器之间的通信成为可能。
    然而，这些消息可以被客户端轻易地操纵。
    所以，如果服务器不检查客户端是否被允许发送这个消息，
    就可能出现可被利用的安全漏洞（金钱漏洞，服务器崩溃，管理员权限）。

    所有列出的网络消息名称都可以或者可能被利用。
    不能保证这个漏洞仍然存在。
    此外，可能存在一些未在此列出的易受攻击的网络消息。

       1. 定期更新你的插件
       2. 用新的插件替换过时/不受支持的插件
       3. 如果你熟悉Lua，手动检查受影响的网络消息]],
    ["health_check_backdoors_title"] = "后门",
    ["health_check_backdoors_desc"] = "服务器上可能存在后门，使攻击者得到不必要的访问权限。",
    ["health_check_backdoors_desc_long"] =
    [[后门可以通过以下方式之一加载到服务器上：
       1. 恶意的工作坊插件
       2. 一个人要求你将一个Lua文件上传到服务器
          这个文件是"特别为你制作的"
       3. 有权访问你的服务器的开发者为自己建立了一个后门
       4. 服务器本身已经被破坏（操作系统的漏洞，
          软件的漏洞）

    移除后门的方法：
       1. 如果可用，检查给定的路径（如果路径以'lua/'开头，它可能来自工作坊）
       2. 使用例如https://github.com/THABBuzzkill/nomalua扫描你的服务器
       3. 移除你最近添加的所有脚本，并检查是否再次出现此消息
       4. 下载你服务器上的所有文件，并对列出的后门进行文本搜索
       5. 困难的方式：移除所有插件，直到此消息停止出现，然后逐一添加它们
          回来并检查它再次出现的插件。]],
    ["health_check_mysql_pass_title"] = "弱数据库密码",
    ["health_check_mysql_pass_desc"] = "Nova Defender的数据库密码太弱。",
    ["health_check_mysql_pass_desc_long"] =
    [[如果你正在使用MySQL，你需要一个强密码。
          即使它不从互联网上访问。

          如何保护你的数据库：
             1. 一个强大的数据库密码不是你必须记住的
             2. 使用密码生成器创建一个随机密码
             3. 为每个数据库使用不同的密码
             4. 为每个插件使用不同的数据库（或适当的数据库权限）]],
    ["health_check_nova_errors_title"] = "Nova Defender错误",
    ["health_check_nova_errors_desc"] = "由Nova Defender生成的错误",
    ["health_check_nova_errors_desc_long"] =
    [[好吧，阅读它们。如果你不确定如何解决给定的问题，请联系我。
          如果每个错误消息对你来说都是明确的，并且不影响功能，
          你可以安全地忽略这个消息。]],
    ["health_check_nova_vpn_title"] = "Nova Defender VPN保护",
    ["health_check_nova_vpn_desc"] = "必须设置VPN保护以阻止国家和检测VPN。",
    ["health_check_nova_vpn_desc_long"] =
    [[在"Networking"选项卡中，你必须插入你的API密钥，
          你可以在ipqualityscore.com免费注册后获得。
          有了这个，Nova-Defender可以通过这个页面检查IP地址。
             1. 转到https://www.ipqualityscore.com/create-account
             2. 在这里复制你的API密钥https://www.ipqualityscore.com/user/settings
             3. 将它粘贴在"Networking"选项卡下的"VPN API key"中]],
    ["health_check_nova_steamapi_title"] = "Nova Defender Steam个人资料保护",
    ["health_check_nova_steamapi_desc"] =
    "必须设置Steam个人资料保护以检测玩家的可疑个人资料。",
    ["health_check_nova_steamapi_desc_long"] =
    [[在"Ban System"选项卡中，你需要插入你的API密钥，
             1. 转到https://steamcommunity.com/dev/apikey
             2. 输入你的服务器的域名
             3. 复制你的API密钥
             4. 将它粘贴在"Ban System"选项卡下的"Steam API key"中]],
    ["health_check_nova_anticheat_title"] = "Nova Defender反作弊扩展",
    ["health_check_nova_anticheat_desc"] = "反作弊需要一个扩展来检测更多的作弊。",
    ["health_check_nova_anticheat_desc_long"] =
    [[目前只有一些简单的作弊被检测到。由于Nova Defender的源代码是开放的
          并且可见，作弊可以很容易地被修改为无法检测。
          因此，大型服务器的所有者可以请求反作弊的扩展，
          它还可以通过名称检测外部的、新的或付费的作弊。
          欢迎直接通过Steam联系我。
          然而，我保留拒绝请求的权利，即使不提供理由。]],
    -- Server
    ["server_general_suffix"] = "附加到每个踢出、封禁或拒绝消息的文本。例如你的Teamspeak，Discord或其他支持网站。",

    ["server_access_maintenance_enabled"] = "维护模式：\n只有受保护的玩家和有密码的玩家可以加入服务器。",
    ["server_access_maintenance_allowed"] = "谁可以在维护模式下加入服务器？受保护的玩家总是被允许的，不需要密码。",
    ["server_access_maintenance_password"] = "如果你在上面的设置中选择了'password'，那么这就是维护模式的密码。",
    ["server_access_maintenance_reason"] = "在维护期间尝试连接的客户端显示的原因。",
    ["server_access_password_lock"] = "锁定错误的尝试：\n如果一个客户端输入错误的密码太多次，所有后续的尝试都将被阻止。",
    ["server_access_password_lock_reason"] = "如果他输入了太多次错误的密码，显示给客户端的原因。",
    ["server_access_password_max_attempts"] = "锁定前的最大尝试次数",

    ["server_lockdown_enabled"] = "封锁模式：\n只有管理员、受保护的和受信任的可以加入服务器。当有许多新账户被创建用来加入服务器进行捣乱、破坏或崩溃服务器时使用。已经在服务器上的玩家不受影响。首先确保在Nova Defender的配置文件中定义了谁是受信任的。这应该只在短时间内使用。",
    ["server_lockdown_reason"] = "在封锁模式下，如果他不是受保护的、管理员或受信任的，踢出玩家的原因。",

    -- Admin Menu
    ["menu_title_banbypass"] = "封禁系统",
    ["menu_title_health"] = "服务器健康",
    ["menu_title_network"] = "网络",
    ["menu_title_security"] = "安全",
    ["menu_title_menu"] = "菜单",
    ["menu_title_anticheat"] = "反作弊",
    ["menu_title_detections"] = "检测",
    ["menu_title_bans"] = "封禁",
    ["menu_title_exploit"] = "漏洞",
    ["menu_title_players"] = "在线玩家",
    ["menu_title_server"] = "服务器",
    ["menu_title_inspection"] = "检查玩家",

    ["menu_desc_banbypass"] = "防止玩家绕过Nova Defender封禁的技术",
    ["menu_desc_network"] = "限制、控制和记录网络活动",
    ["menu_desc_security"] = "保护用户免受权限升级",
    ["menu_desc_menu"] = "控制通知和管理员菜单",
    ["menu_desc_anticheat"] = "根据你的需求启用或禁用客户端反作弊的功能",
    ["menu_desc_bans"] = "查找、封禁或解禁玩家",
    ["menu_desc_exploit"] = "防止游戏机制中的特定漏洞",
    ["menu_desc_players"] = "当前在线的所有玩家",
    ["menu_desc_health"] = "一目了然地看到你的服务器状态",
    ["menu_desc_detections"] = "所有需要审查的待处理检测",
    ["menu_desc_server"] = "管理对你的服务器的访问",
    ["menu_desc_inspection"] = "在玩家上运行命令和搜索文件",

    ["menu_elem_add"] = "添加",
    ["menu_elem_edit"] = "编辑",
    ["menu_elem_unban"] = "解禁",
    ["menu_elem_ban"] = "封禁",
    ["menu_elem_kick"] = "踢出",
    ["menu_elem_reconnect"] = "重新连接",
    ["menu_elem_quarantine"] = "隔离",
    ["menu_elem_unquarantine"] = "解除隔离",
    ["menu_elem_verify_ac"] = "检查反作弊",
    ["menu_elem_screenshot"] = "截图",
    ["menu_elem_detections"] = "检测",
    ["menu_elem_indicators"] = "指标",
    ["menu_elem_commands"] = "命令",
    ["menu_elem_netmessages"] = "网络消息",
    ["menu_elem_ip"] = "IP详情",
    ["menu_elem_profile"] = "Steam个人资料",
    ["menu_elem_rem"] = "移除",
    ["menu_elem_reload"] = "重新加载",
    ["menu_elem_advanced"] = "高级选项",
    ["menu_elem_miss_options"] = "缺少一些选项？",
    ["menu_elem_copy"] = "复制",
    ["menu_elem_save"] = "保存到磁盘",
    ["menu_elem_saved"] = "已保存",
    ["menu_elem_settings"] = "设置：",
    ["menu_elem_general"] = "通用：",
    ["menu_elem_close"] = "关闭",
    ["menu_elem_cancel"] = "取消",
    ["menu_elem_filter_by"] = "按照过滤：",
    ["menu_elem_view"] = "查看",
    ["menu_elem_filter_text"] = "过滤文本：",
    ["menu_elem_reason"] = "原因",
    ["menu_elem_comment"] = "评论",
    ["menu_elem_bans"] = "封禁（限制为150条条目）：",
    ["menu_elem_new_value"] = "新值",
    ["menu_elem_submit"] = "提交",
    ["menu_elem_no_bans"] = "没有找到封禁",
    ["menu_elem_no_data"] = "没有可用的数据",
    ["menu_elem_checkboxtext_checked"] = "激活",
    ["menu_elem_checkboxtext_unchecked"] = "禁用",
    ["menu_elem_search_term"] = "搜索词...",
    ["menu_elem_unavailable"] = "不可用",
    ["menu_elem_failed"] = "失败",
    ["menu_elem_passed"] = "通过",
    ["menu_elem_health_overview"] = "检查：\n  • 总计：%d\n  • 通过：%d\n  • 失败：%d",
    ["menu_elem_health_most_critical"] = "最关键的：\n",
    ["menu_elem_mitigation"] = "如何修复？",
    ["menu_elem_list"] = "详情",
    ["menu_elem_ignore"] = "忽略",
    ["menu_elem_reset"] = "重置",
    ["menu_elem_reset_all"] = "重置所有忽略的检查：",
    ["menu_elem_player_count"] = "在线玩家：%d",
    ["menu_elem_foundindicator"] = "找到%d个指标",
    ["menu_elem_foundindicators"] = "找到%d个指标",
    ["menu_elem_criticalindicators"] = "关键指标！",
    ["menu_elem_notauthed"] = "正在验证...",

    ["menu_elem_mitigated"] = "已缓解",
    ["menu_elem_unmitigated"] = "未缓解",
    ["menu_elem_next"] = "下一个",
    ["menu_elem_prev"] = "上一个",
    ["menu_elem_clear"] = "删除已缓解",
    ["menu_elem_clear_all"] = "删除全部",
    ["menu_elem_delete"] = "删除",
    ["menu_elem_stats"] = "条目：%d",
    ["menu_elem_page"] = "页：%d",

    ["menu_elem_nofocus"] = "无焦点",
    ["menu_elem_focus"] = "有焦点",
    ["menu_elem_connect"] = "连接",
    ["menu_elem_disconnect"] = "断开连接",
    ["menu_elem_input_command"] = "输入并运行Lua代码...",
    ["menu_elem_select_player"] = "选择一个玩家",
    ["menu_elem_disconnected"] = "已断开连接",
    ["menu_elem_exec_clientopen"] = "客户端打开了连接",
    ["menu_elem_exec_clientclose"] = "客户端关闭了连接",
    ["menu_elem_exec_error"] = "服务器内部错误",
    ["menu_elem_exec_help"] = [[应用：
    • 如果你熟悉Lua，可以使用这个
    • 设计用于调试目的和寻找Lua作弊

    通用：
    • 输入Lua代码并按回车在选定的客户端上执行
    • Lua错误将显示在控制台
    • Lua错误对客户端是不可见的

    显示值：
    • 要获取表或字符串的值，使用"print()"或"PrintTable()"
    • 执行"print"和"PrintTable"对客户端是不可见的
    • 执行"print"和"PrintTable"将被重定向到你的控制台
    • 示例1："PrintTable(hook.GetTable())"
    • 示例2："local nick = LocalPlayer():Nick() print(nick)"

    历史：
    • 使用UP和DOWN导航历史
    • 使用TAB自动完成

    安全：
    • 负责任地执行Lua代码
    • 执行的代码可能对客户端可见
    • 执行的代码可能被客户端阻止或操纵]],
    ["menu_elem_help"] = "帮助",
    ["menu_elem_filetime"] = "最后文件修改：%s",
    ["menu_elem_filesize"] = "文件大小：%s",
    ["menu_elem_download"] = "下载",
    ["menu_elem_download_confirm"] = "你确定要下载以下文件吗？\n%q",
    ["menu_elem_download_progress"] = "加载块%i/%i...",
    ["menu_elem_download_finished_part"] = "文件部分下载并保存在你本地的Garry's Mod数据文件夹中：\n%q",
    ["menu_elem_download_finished"] = "文件下载完成并保存在你本地的Garry's Mod数据文件夹中：\n%q",
    ["menu_elem_download_failed"] = "下载失败：%q",
    ["menu_elem_download_started"] = "正在下载文件：%q",
    ["menu_elem_download_confirmbutton"] = "下载",
    ["menu_elem_canceldel"] = "取消并删除",

    ["indicator_pending"] = "玩家还没有将他的指标发送到服务器。他可能阻止它们或需要更多的时间。",
    ["indicator_install_fresh"] = "玩家最近安装了这个游戏",
    ["indicator_install_reinstall"] = "玩家最近重新安装了这个游戏",
    ["indicator_advanced"] = "玩家使用调试/开发者命令（他可能知道他在做什么...）",
    ["indicator_first_connect"] = "第一次连接到这个服务器（如果游戏没有被重新安装）",
    ["indicator_cheat_hotkey"] = "玩家按下了通常用来打开作弊菜单的键（如INSERT或HOME）",
    ["indicator_bhop"] = "玩家在他的鼠标滚轮上绑定了兔子跳（如'bind mwheelup +jump'）",
    ["indicator_memoriam"] = "玩家过去或现在使用了作弊'Memoriam'",
    ["indicator_multihack"] = "玩家过去或现在使用了作弊'Garrysmod 64-bit Visuals Multihack Reborn'",
    ["indicator_exechack"] = "玩家过去或现在使用了付费作弊'exechack'",
    ["indicator_banned"] = "玩家已经在另一个服务器上被Nova Defender封禁",
    ["indicator_profile_familyshared"] = "玩家有一个家庭共享账户",
    ["indicator_profile_friend_banned"] = "这个玩家的一个Steam朋友已经被Nova Defender封禁",
    ["indicator_profile_recently_created"] = "Steam个人资料在过去7天内被创建",
    ["indicator_profile_nogames"] = "玩家还没有在他的Steam个人资料上购买任何游戏",
    ["indicator_profile_new_player"] = "玩家总共没有玩过超过2小时的Garry's Mod",
    ["indicator_profile_vac_banned"] = "玩家已经收到了一个VAC封禁",
    ["indicator_profile_vac_bannedrecent"] = "玩家在过去的5个月内已经收到了一个VAC封禁",
    ["indicator_profile_community_banned"] = "玩家已经从Steam收到了一个社区封禁",
    ["indicator_profile_not_configured"] = "玩家甚至还没有设置他的Steam账户",
    ["indicator_scenario_bypass_account"] = "指标表明这个玩家特意创建了一个新的Steam账户。请查看'在线玩家'菜单选项卡。",
    ["indicator_scenario_cheatsuspect"] = "指标表明这个玩家作弊。请查看'在线玩家'菜单选项卡",
    ["indicator_scenario_sum"] = "玩家因为符合大量典型的指标而被怀疑。请查看'在线玩家'菜单选项卡",

    ["internal_reason"] = "内部原因",
    ["banned"] = "被封禁",
    ["status"] = "状态",
    ["reason"] = "原因",
    ["unban_on_sight"] = "视线内解禁",
    ["ip"] = "IP",
    ["ban_on_sight"] = "视线内封禁",
    ["time"] = "时间",
    ["comment"] = "评论",
    ["steamid"] = "SteamID32",
    ["steamid64"] = "SteamID64",
    ["usergroup"] = "用户组",
    ["familyowner"] = "家庭共享所有者",
    ["group"] = "组",
    ["kick"] = "踢出",
    ["allow"] = "禁用此检测",
    ["reconnect"] = "重新连接",
    ["ban"] = "封禁",
    ["notify"] = "通知",
    ["nothing"] = "无",
    ["set"] = "设置回",
    ["disable"] = "未来禁用",
    ["ignore"] = "暂时忽略",
    ["dont_care"] = "不在乎",
    ["action_taken_at"] = "采取行动的时间",
    ["action_taken_by"] = "行动的执行者",

    ["sev_none"] = "无",
    ["sev_low"] = "低",
    ["sev_medium"] = "中",
    ["sev_high"] = "高",
    ["sev_critical"] = "关键",
}

-- DO NOT CHANGE ANYTHING BELOW THIS
if SERVER then
    Nova["languages_" .. lang] = function() return phrases end
else
    NOVA_SHARED = NOVA_SHARED or {}
    NOVA_SHARED["languages_" .. lang] = phrases
end
