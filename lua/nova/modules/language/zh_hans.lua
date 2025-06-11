local lang = "zh_hans"

local phrases = {
    -- Notifications
    ["menu_logging_debug"] = "调试模式：\n这将在服务器控制台打印额外的日志。",
    ["menu_notify_timeopen"] = "通知显示时长（秒）。",
    ["menu_notify_showstaff"] = "向管理员显示通知。",
    ["menu_notify_showinfo"] = "显示信息通知",
    ["menu_access_player"] = "管理员可以访问“在线玩家”标签页并在那里执行操作。管理员不能针对受保护的玩家。",
    ["menu_access_staffseeip"] = "管理员可以看到玩家的IP地址",
    ["menu_access_detections"] = "管理员可以访问“检测”标签页",
    ["menu_access_bans"] = "管理员可以访问“封禁”标签页",
    ["menu_access_health"] = "管理员可以访问“健康”标签页",
    ["menu_access_inspection"] = "管理员可以访问“检查玩家”标签页",
    ["menu_access_ddos"] = "工作人员可访问 “DDoS ”选项卡",

    ["menu_action_timeopen"] = "处罚提示显示时长（秒）。",
    ["menu_action_showstaff"] = "如果没有受保护的玩家（或AFK），询问管理员进行处罚操作。",
    -- Networking
    ["networking_concommand_logging"] = "命令日志：\n记录客户端和服务器执行的每个控制台命令",
    ["networking_concommand_dump"] = "转储命令：\n当玩家断开连接时，将他执行的所有命令打印到控制台。这可能会很快增加你的日志大小。",
    ["networking_netcollector_dump"] = "转储网络消息：\n当玩家断开连接时，将他发送到服务器的所有网络消息打印到控制台。",
    ["networking_netcollector_spam_action"] = "当玩家向服务器发送垃圾网络消息时应该发生什么？",
    ["networking_netcollector_spam_reason"] = "玩家因向服务器发送垃圾网络消息而被踢出或封禁的原因。",
    ["networking_dos_action"] = "当玩家试图导致服务器延迟时应该发生什么？",
    ["networking_dos_reason"] = "玩家因试图导致服务器延迟而被踢出或封禁的原因。",
    ["networking_dos_sensivity"] = "检测的灵敏度应该是多少？",
    ["networking_dos_crash_enabled"] = "检测解压缩攻击：\n客户可以向服务器发送高度压缩的数据。解压缩后，数据量可轻松达到 400 MB，并会导致服务器滞后或崩溃。客户端最多只能向服务器发送 65 KB 的数据。Gmod 中使用的压缩方式（LZMA2）的压缩率通常约为 20:1（取决于数据）。因此，我们预计会有大约 1 MB 的解压缩数据。1000:1甚至7000:1的压缩比并没有合理的用途。该选项会覆盖 util.Decompress，不需要重启。",
    ["networking_dos_crash_action"] = "如果玩家试图让服务器崩溃会发生什么？",
    ["networking_dos_crash_ignoreprotected"] = "忽略受保护的玩家。",
    ["networking_dos_crash_maxsize"] = "最大解压缩大小（单位：MB）：\n达到时，解压缩将被中止。",
    ["networking_dos_crash_ratio"] = "最大压缩比：\n正常数据的压缩比约为 20:1。1000:1甚至7000:1的压缩率都没有合法的用途。请勿设置过低，否则会导致误报。",
    ["networking_dos_crash_whitelist"] = "将被忽略的白名单网络信息",
    ["networking_netcollector_actionAt"] = "在3秒内从单个客户端接收到多少条消息时我们应该采取行动？永远不要设置得太低！",
    ["networking_netcollector_dropAt"] = "在3秒内我们应该忽略多少条消息。这样做是为了防止拒绝服务。应该低于上面的设置。",
    ["networking_restricted_message_action"] = "当玩家向服务器发送他不被允许的消息时应该发生什么？如果没有操纵游戏或bug，玩家不可能发送此消息。",
    ["networking_restricted_message_reason"] = "玩家因向服务器发送他不被允许的消息而被踢出或封禁的原因。",
    ["networking_sendlua_gm_express"] = "激活 gm_express:\n性能大幅提升，尤其是对于大型服务器。不再通过内置的 Netmessages（速度慢）发送大量数据，而是通过外部提供商（gmod.express）通过 HTTPS 将这些数据传输到客户端。这将加快客户端的加载时间并减轻服务器的负担。不过，该选项依赖于 gmod.express。如果该页面意外无法访问，客户端的身份验证将失败。无法连接到 gmod.express 的新客户端将退回到传统方法。此选项需要安装 gm_express。更多详情请参阅'健康'选项卡",
    ["networking_sendlua_authfailed_action"] = "当玩家没有响应Nova Defender认证时应该发生什么？如果忽略，不能保证反作弊或其他客户端机制的工作。",
    ["networking_sendlua_authfailed_reason"] = "玩家因没有响应Nova Defender认证而被踢出或封禁的原因。",
    ["networking_sendlua_validationfailed_action"] = "当玩家阻止Nova Defender代码时应该发生什么？",
    ["networking_sendlua_validationfailed_reason"] = "玩家因阻止Nova Defender代码而被踢出或封禁的原因。",
    ["networking_fakenets_backdoors_load"] = "创建假后门并诱骗攻击者使用它们。",
    ["networking_fakenets_backdoors_block"] = "在服务器上阻止后门。可能会阻止合法的网络消息并破坏插件！首先查看“健康”标签页并检查现有后门。",
    ["networking_fakenets_backdoors_action"] = "当攻击者使用假后门时应该发生什么？",
    ["networking_fakenets_exploits_load"] = "创建假漏洞并诱骗攻击者使用它们。",
    ["networking_fakenets_exploits_block"] = "在服务器上阻止可利用的网络消息。这将破坏您服务器上的可利用插件！首先查看“健康”标签页并检查哪些插件是可利用的。",
    ["networking_fakenets_exploits_action"] = "当攻击者使用假漏洞时应该发生什么？",
    ["networking_vpn_vpn-action"] = "当玩家使用VPN时应该发生什么？",
    ["networking_vpn_vpn-action_reason"] = "使用VPN的原因。",
    ["networking_vpn_country-action"] = "当玩家来自不被允许的国家时应该发生什么？",
    ["networking_vpn_country-action_reason"] = "来自不被允许的国家的原因。",
    ["networking_vpn_dump"] = "将玩家的IP地址信息打印到控制台",
    ["networking_vpn_apikey"] = "VPN API密钥：\n用于扫描IP地址。您需要在'https://www.ipqualityscore.com/create-account'注册并在'https://www.ipqualityscore.com/user/settings'获取您的密钥。",
    ["networking_vpn_countrycodes"] = "允许加入您服务器的国家。从这里获取国家代码'https://countrycode.org/'（大写的2字母代码）。建议将您自己和邻国列入白名单。您可以随着时间逐渐添加更多国家。",
    ["networking_vpn_whitelist_asns"] = "白名单ASN号码（用于识别互联网服务提供商的数字）。可能发生的情况是，API错误地检测到VPN连接。因此，已知的ISP被列入白名单。从'https://ipinfo.io/countries'获取它们。或者，您可以在“玩家”标签页中看到每个连接客户端的ASN。",
    ["networking_screenshot_store_ban"] = "保存截图（封禁时）：\n在玩家被封禁前的最后一刻，将对他的屏幕进行截图并保存在服务器的'/data/nova/ban_screenshots'文件夹内。",
    ["networking_screenshot_store_manual"] = "保存截图（菜单）：\n如果管理员对玩家进行截图，它将保存在服务器的'/data/nova/admin_screenshots'文件夹内。",
    ["networking_screenshot_limit_ban"] = "截图限制（封禁时）：\n服务器数据文件夹内存储的截图最大数量。最旧的将被删除。",
    ["networking_screenshot_limit_manual"] = "截图限制（菜单）：\n服务器数据文件夹内存储的截图最大数量。最旧的将被删除。",
    ["networking_screenshot_quality"] = "截图质量\n高质量的截图可能需要长达一分钟的时间来传输。",

    ["networking_http_overwrite"] = "检查HTTP调用（发送+接收）：\n如果启用此设置，将覆盖HTTP函数并可以记录或阻止请求。然而，这种方法也可以被绕过或禁用DRM系统。",
    ["networking_http_logging"] = "记录请求：\n所有HTTP请求都将在控制台中详细记录。这有助于了解哪些URL被调用。仅在检查HTTP请求时工作。",
    ["networking_http_blockunsafe"] = "阻止不安全的请求：\n来自不安全来源（如控制台或RunString）的请求被阻止。",
    ["networking_http_whitelist"] = "启用白名单：\n只允许已添加到列表中的域名和IP地址。",
    ["networking_http_whitelistdomains"] = "白名单域名：\n添加所有受信任的域名和IP，应该被允许。其他所有内容都将被阻止。如果您不确定哪些域名要列入白名单，禁用白名单并仅启用日志记录。",

    ["networking_fetch_overwrite"] = "检查http.fetch（接收数据）：\n覆盖http.fetch函数。如果您使用VCMOD，请不要启用！然而，这种方法也可以被绕过或禁用DRM系统。",
    ["networking_fetch_whitelist"] = "启用白名单：\n只允许已添加到列表中的域名和IP地址。",
    ["networking_fetch_blockunsafe"] = "阻止不安全的请求：\n来自不安全来源（如控制台或RunString）的请求被阻止。",

    ["networking_post_overwrite"] = "检查http.post（发送数据）：\n覆盖http.post函数。发送HTTP请求可以被攻击者用来窃取服务器上的文件。然而，这种方法也可以被绕过或禁用DRM系统。",
    ["networking_post_whitelist"] = "启用白名单：\n只允许已添加到列表中的域名和IP地址。",
    ["networking_post_blockunsafe"] = "阻止不安全的请求：\n来自不安全来源（如控制台或RunString）的请求被阻止。",

    ["networking_ddos_collect_days"] = "IP 地址收集天数：\n DDoS 防护会收集过去 n 天内所有已连接玩家的 IP 地址。当检测到 DDoS 攻击时，除了过去 n 天内连接的玩家外，所有与服务器的通信都会被阻止。服务器会忽略过去 n 天内未连接服务器的所有玩家。他们将看不到服务器。",
    ["networking_ddos_notify"] = "检测到或阻止 DDoS 攻击时显示通知。",
    -- Banbypass
    ["banbypass_ban_banstaff"] = "管理员可以被封禁",
    ["banbypass_ban_default_reason"] = "如果没有指定原因，玩家被封禁的原因",

    ["banbypass_bypass_default_reason"] = "玩家因绕过封禁而被封禁的原因",

    ["banbypass_bypass_familyshare_action"] = "当玩家使用被封禁玩家的家庭共享账户时应该发生什么？",
    ["banbypass_bypass_clientcheck_action"] = "当我们在玩家的本地文件中发现绕过封禁的证据时应该发生什么？",
    ["banbypass_bypass_ipcheck_action"] = "当玩家与被封禁玩家的IP地址相同时应该发生什么？",

    ["banbypass_bypass_fingerprint_enable"] = "启用指纹检查：\n此选项检查玩家是否使用与被封禁用户相同的设备。只要他被封禁，就可以防止玩家在同一设备上创建新账户。",
    ["banbypass_bypass_fingerprint_action"] = "当玩家使用与被封禁用户相同的设备时应该发生什么？",
    ["banbypass_bypass_fingerprint_sensivity"] = "指纹匹配的灵敏度应该是多少？",

    ["banbypass_bypass_indicators_apikey"] = "Steam API密钥：\nSteamAPI可以用来查看有关玩家的更详细数据。在“在线玩家”标签页的指示器中显示发现。在https://steamcommunity.com/dev/apikey创建一个并粘贴在这里。",
    -- Anticheat
    ["anticheat_reason"] = "玩家因使用任何形式的作弊而被封禁的原因。",
    ["anticheat_enabled"] = "启用反作弊：\n如果启用，反作弊代码将发送给所有客户端，并处理检测。如果禁用，反作弊代码仍在所有当前连接的客户端上保持活动，但检测将被忽略。此选项包括自动点击和瞄准辅助检测。",
    ["anticheat_action"] = "当玩家有作弊行为时应该发生什么？",
    ["anticheat_verify_action"] = "当反作弊未为玩家加载时应该发生什么？",
    ["anticheat_verify_execution"] = "检查反作弊是否正在运行：\n在玩家收到反作弊后，请求确认他是否已执行它。然而，这个过程可能因多种原因失败，因此不应设置为“封禁”。",
    ["anticheat_verify_reason"] = "玩家因反作弊未加载而被封禁的原因。",
    ["anticheat_check_function"] = "检查函数：\n将客户端的函数名称与已知的作弊函数名称进行比较。这也可能检测到您提供的代码中的合法函数。",
    ["anticheat_check_files"] = "检查文件：\n类似于“检查函数”。将正在运行的脚本的文件名与已知的作弊文件名进行比较。",
    ["anticheat_check_globals"] = "检查全局变量：\n类似于“检查函数”。将变量名与已知的作弊变量名进行比较。",
    ["anticheat_check_modules"] = "检查模块：\n类似于“检查函数”。将模块名与已知的作弊模块名进行比较。",
    ["anticheat_check_runstring"] = "检查'RunString'：\n使用内置的'RunString'函数可以执行任意Lua代码。此选项检测此函数的不当使用，并搜索已知的作弊模式。",
    ["anticheat_check_external"] = "检查外部篡改：\n这检测外部作弊软件。这些在受限制的Lua环境中非常难以检测。这将减慢像FProfiler这样的分析器。",
    ["anticheat_check_manipulation"] = "检测篡改：\n检测尝试阻止或篡改反作弊的行为。",
    ["anticheat_check_cvars"] = "检查控制台变量：\n类似于“检查函数”。一些作弊利用cvars来持久化设置。将cvar名称与已知的作弊cvar名称进行比较。",
    ["anticheat_check_byte_code"] = "检查代码编译：\n在底层，Lua代码使用JIT编译成字节码，然后解释执行。我们有时可以确定这是否以不寻常的方式完成。例如，如果客户端通过lua_run_cl执行代码。",
    ["anticheat_check_detoured_functions"] = "检查函数绕行：\n一些作弊通过覆盖内置函数的功能来避免检测或操纵游戏行为。",
    ["anticheat_check_concommands"] = "检查控制台命令：\n类似于“检查控制台变量”。一些作弊可以通过控制台访问。将命令名称与已知的作弊命令名称进行比较。",
    ["anticheat_check_net_scan"] = "检查扫描：\n一些脚本可以扫描服务器以寻找已知的漏洞或后门。",
    ["anticheat_check_cheats_custom"] = "检测已知作弊：\n通过特殊分析检测广泛使用的作弊工具。作弊工具的确切名称将显示在原因中。",
    ["anticheat_check_cheats_custom_unsure"] = "检测非活跃作弊：\n在检测某些作弊时，无法确定这些作弊工具当前是否活跃。唯一确定的是，该玩家曾经使用过这些作弊工具。",
    ["anticheat_check_experimental"] = "启用实验检测:\n激活尚未测试的作弊检测。玩家不会被封禁。检测结果将记录在服务器上的以下文件中： data/nova/anticheat/experimental.txt”。该文件可发送给开发人员进行分析。",
    ["anticheat_spam_filestealers"] = "干扰文件窃取器：\n某些作弊工具会将从服务器接收到的所有执行的Lua代码存储在文本文件中。为了使这些文件混乱并稍微增加攻击者的难度，我们会用无用的代码填充这些文件。这将慢慢填满玩家的磁盘空间。这对玩家加载时间没有负面影响。",
    ["anticheat_autoclick_enabled"] = "启用自动点击检测：\n出于显而易见的原因，我们不希望任何玩家使用程序进行快速点击或按键操作。这包括左右点击、使用和空格键。",
    ["anticheat_autoclick_action"] = "当玩家使用自动点击时应采取什么措施？",
    ["anticheat_autoclick_reason"] = "玩家因使用自动点击而被禁止的原因。",
    ["anticheat_autoclick_sensivity"] = "自动点击灵敏度：\n高灵敏度可能会因为罕见的巧合错误地检测到玩家。低灵敏度可能检测不到好的自动点击器。根据自动点击器可能给作弊者带来的优势来决定。",
    ["anticheat_autoclick_check_fast"] = "检查快速点击速度：\n超过一定的CPS（每秒点击次数），我们可以假设没有辅助工具，人类无法做到这一点。这同样适用于按键。",
    ["anticheat_autoclick_check_fastlong"] = "长时间快速点击检查：\n玩家不太可能在几分钟内极快速度点击而不短暂停顿。",
    ["anticheat_autoclick_check_robotic"] = "检查非人类点击一致性：\n人类不可能以完全相同的速度点击。它总会快一点或慢一点。然而，程序可以非常精确地控制这一点。如果点击之间的时间间隔过于一致，我们就能发现。",
    ["anticheat_aimbot_enabled"] = "启用自瞄检测：\n实时监控所有玩家的移动。",
    ["anticheat_aimbot_action"] = "当玩家使用自瞄时应采取什么措施？",
    ["anticheat_aimbot_reason"] = "玩家因使用自瞄而被禁止的原因。",
    ["anticheat_aimbot_check_snap"] = "检测瞬间移动：\n检测玩家视角方向是否瞬间改变。警告：这将阻止客户端设置他们的视角（如果不在服务器端完成），因此可能破坏某些插件！",
    ["anticheat_aimbot_check_move"] = "检测可疑移动：\n检测玩家是否在不移动鼠标的情况下持续改变视角。",
    ["anticheat_aimbot_check_contr"] = "检测矛盾移动：\n检测玩家移动鼠标的方向与视角变化的方向是否不一致。",
    -- Exploit
    ["exploit_fix_propspawn"] = "Propspawn:\n防止使用复制的材质生成道具。",
    ["exploit_fix_material"] = "Material:\n防止材质复制。",
    ["exploit_fix_fadingdoor"] = "Fadingdoor:\n防止玩家看不见的图形错误。",
    ["exploit_fix_physgunreload"] = "Physgun:\n对用户禁用物理枪重载。",
    ["exploit_fix_bouncyball"] = "Bouncyball:\n防止弹力球焊接。",
    ["exploit_fix_bhop"] = "Bunnyhop:\n防止兔子跳。",
    ["exploit_fix_serversecure"] = "自动设置Serversecure:\n更多信息见'Health'标签页。",
    -- Security
    ["security_permissions_groups_protected"] = "Protected usergroups:\n所有被视为受保护的用户组。只有白名单上的玩家可以拥有这个组。受保护的玩家可以完全访问这个菜单。",
    ["security_permissions_groups_staff"] = "Staff and admin usergroups:\n所有拥有员工权限的用户组。",
    ["security_privileges_group_protection_enabled"] = "Automated rank protection:\n如果一个未列入白名单的玩家拥有例如受保护的用户组，我们将采取行动。",
    ["security_privileges_group_protection_escalation_action"] = "当一个玩家拥有他不应该拥有的受保护用户组时应该发生什么？",
    ["security_privileges_group_protection_escalation_reason"] = "如果玩家拥有他不应该拥有的受保护用户组而被踢出或封禁的原因。",
    ["security_privileges_group_protection_removal_action"] = "当一个受保护的玩家失去他的用户组时应该发生什么？",
    ["security_privileges_group_protection_protected_players"] = "Protected Players:\n所有被允许拥有受保护用户组的玩家。如果你移除一个在线的玩家，他将被踢出。",
    ["security_privileges_group_protection_kick_reason"] = "如果一个受保护的玩家在连接时失去了他的保护而被踢出的原因。",
    -- Detections
    ["config_detection_banbypass_familyshare"] = "家庭共享账户绕过封禁",
    ["config_detection_banbypass_clientcheck"] = "封禁绕过客户端检查",
    ["config_detection_banbypass_ipcheck"] = "封禁绕过IP检查",
    ["config_detection_banbypass_fingerprint"] = "封禁绕过指纹",
    ["config_detection_networking_country"] = "不允许的玩家国家",
    ["config_detection_networking_vpn"] = "使用VPN",
    ["config_detection_networking_backdoor"] = "使用假后门",
    ["config_detection_networking_spam"] = "垃圾信息网络消息",
    ["config_detection_networking_dos"] = "导致服务器延迟",
    ["config_detection_networking_dos_crash"] = "尝试用大信息使服务器崩溃",
    ["config_detection_networking_authentication"] = "客户端无法与服务器进行认证",
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
    ["config_detection_anticheat_known_cvar"] = "作弊cvar",
    ["config_detection_anticheat_known_file"] = "发现作弊文件",
    ["config_detection_anticheat_known_data"] = "发现作弊残留",
    ["config_detection_anticheat_known_module"] = "包含作弊模块",
    ["config_detection_anticheat_known_concommand"] = "作弊控制台命令",
    ["config_detection_anticheat_verify_execution"] = "阻止反作弊",
    ["config_detection_anticheat_known_global"] = "作弊全局变量",
    ["config_detection_anticheat_known_cheat_custom"] = "已知作弊",
    ["config_detection_anticheat_known_function"] = "作弊全局函数",
    ["config_detection_anticheat_manipulate_ac"] = "操纵反作弊",
    ["config_detection_anticheat_autoclick_fast"] = "非人类点击速度",
    ["config_detection_anticheat_autoclick_fastlong"] = "长时间快速点击",
    ["config_detection_anticheat_autoclick_robotic"] = "非人类点击一致性",
    ["config_detection_anticheat_aimbot_snap"] = "瞬间对准1tick内的自动瞄准",
    ["config_detection_anticheat_aimbot_move"] = "自动瞄准可疑移动",
    ["config_detection_anticheat_aimbot_contr"] = "自动瞄准矛盾移动",
    ["config_detection_security_privilege_escalation"] = "提升到受保护用户组的权限",
    ["config_detection_admin_manual"] = "管理员或控制台的手动封禁",
    -- Notifications
    ["menu_notify_hello_staff"] = "该服务器受Nova Defender保护。\n您被归类为管理员。",
    ["menu_notify_hello_protected"] = "该服务器受Nova Defender保护。\n您被归类为受保护者。",
    ["menu_notify_hello_menu"] = "使用 !nova 打开菜单。",

    ["notify_admin_unban"] = "成功解封 %s。玩家下次连接服务器时将移除封禁。",
    ["notify_admin_ban"] = "成功封禁 %s。如果他下次加入服务器，将被封禁。",
    ["notify_admin_ban_online"] = "管理员 %s 封禁了 %s。玩家将在几秒钟内被封禁。",
    ["notify_admin_ban_offline"] = "管理员 %s 封禁了 %s。如果他加入服务器，将被封禁。",
    ["notify_admin_ban_fail"] = "封禁 %s 失败：%q",
    ["notify_admin_kick"] = "管理员 %s 将 %s 踢出服务器",
    ["notify_admin_reconnect"] = "管理员 %s 重新连接了 %s",
    ["notify_admin_quarantine"] = "管理员 %s 将 %s 置于网络隔离。他现在无法与服务器上的任何东西互动。",
    ["notify_admin_unquarantine"] = "管理员 %s 将 %s 从网络隔离中移除",
    ["notify_admin_no_permission"] = "您没有足够的权限执行该操作",
    ["notify_admin_client_not_connected"] = "玩家离线",
    ["notify_admin_already_inspecting"] = "您已经在检查另一位玩家了",

    ["notify_anticheat_detection"] = "反作弊检测 %q 在 %s。原因：%q",
    ["notify_anticheat_detection_action"] = "反作弊：%q",

    ["notify_anticheat_issue_fprofiler"] = "如果反作弊处于活动状态，客户端侧的性能分析将无法工作！",

    ["notify_aimbot_detection"] = "自动瞄准检测 %q 在 %s。原因：%q",
    ["notify_aimbot_detection_action"] = "自动瞄准：%q",

    ["notify_anticheat_verify"] = "来自 %s 的客户端反作弊无法加载。这也可能是由于连接慢导致的。",
    ["notify_anticheat_verify_action"] = "客户端反作弊无法加载。这也可能是由于连接慢导致的。",

    ["notify_banbypass_ban_fail"] = "无法封禁 %s 由于 %q：%s",
    ["notify_banbypass_kick_fail"] = "无法踢出 %s 由于 %q：%s",

    ["notify_banbypass_bypass_fingerprint_match"] = "%s 可能绕过封禁：指纹与被封禁的SteamID %s 匹配 | 置信度：%d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "可能绕过封禁：指纹与被封禁的SteamID %s 匹配 | 置信度：%d%%",

    ["notify_banbypass_familyshare"] = "可能绕过封禁：被封禁SteamID %s 的家庭共享账户",
    ["notify_banbypass_familyshare_action"] = "可能绕过封禁：被封禁SteamID %s 的家庭共享账户",

    ["notify_banbypass_clientcheck"] = "可能绕过封禁：发现 %s 的封禁绕过证据 | 证据：%s",
    ["notify_banbypass_clientcheck_action"] = "可能绕过封禁：发现 %s 的封禁绕过证据 | 证据：%s",

    ["notify_banbypass_ipcheck"] = "可能绕过封禁：与被封禁玩家 %s 的IP相同",
    ["notify_banbypass_ipcheck_action"] = "可能绕过封禁：与被封禁玩家 %s 的IP相同",

    ["notify_networking_exploit"] = "%s 使用了网络漏洞：%q",
    ["notify_networking_exploit_action"] = "使用网络漏洞：%q",
    ["notify_networking_backdoor"] = "%s 使用了网络后门：%q",
    ["notify_networking_backdoor_action"] = "使用网络后门：%q",

    ["notify_networking_spam"] = "%s 正在垃圾信息网络消息 (%d/%ds) (%d 允许)。",
    ["notify_networking_spam_action"] = "垃圾信息网络消息 (%d/%ds) (%d 允许)。",
    ["notify_networking_limit"] = "%s 超过了每 %d 秒 %d 网络消息的限制。",
    ["notify_networking_limit_drop"] = "忽略来自 %s 的网络消息，因为他超过了每 %d 秒 %d 网络消息的限制。",

    ["notify_networking_dos"] = "%s 导致了服务器延迟。持续时间：%s 在 %d 秒内",
    ["notify_networking_dos_action"] = "导致服务器延迟。持续时间：%s 在 %d 秒内",

    ["notify_networking_dos_crash"] = "%s 试图通过大信息使服务器崩溃。信息： %q，大小：%s，压缩率：%s",
    ["notify_networking_dos_crash_action"] = "试图用大信息使服务器崩溃。信息： %q ,Size: %s, Compression ratio: %s",

    ["notify_networking_restricted"] = "%s 尝试发送仅限 %q 的网络消息 %q。没有操纵是做不到的。",
    ["notify_networking_restricted_action"] = "发送了仅 %q 允许的网络消息 %q。没有操纵是做不到的。",

    ["notify_networking_screenshot_failed_multiple"] = "%s 的截图失败：一次只能进行一次截图",
    ["notify_networking_screenshot_failed_progress"] = "%s 的截图失败：此玩家的其他截图正在进行中。",
    ["notify_networking_screenshot_failed_timeout"] = "%s 的截图失败：未从客户端收到截图。",
    ["notify_networking_screenshot_failed_empty"] = "%s 的截图失败：答案为空。如果被作弊器阻止或玩家处于逃生菜单中，就会出现这种情况。",

    ["notify_networking_auth_failed"] = "%s 无法与服务器进行认证。这也可能是由于连接慢导致的。",
    ["notify_networking_auth_failed_action"] = "无法与服务器进行认证。这也可能是由于连接慢导致的。",
    ["notify_networking_sendlua_failed"] = "%s 阻止了运行Nova Defender代码。这也可能是由于连接慢导致的。",
    ["notify_networking_sendlua_failed_action"] = "阻止了运行Nova Defender代码。这也可能是由于连接慢导致的。",

    ["notify_networking_issue_gm_express_not_installed"] = "服务器上未安装 gm_express。更多详情请查看 “健康”选项卡。",

    ["notify_networking_vpn"] = "%s 正在使用VPN：%s",
    ["notify_networking_vpn_action"] = "使用VPN：%s",
    ["notify_networking_country"] = "%s 来自不允许的国家。%s",
    ["notify_networking_country_action"] = "来自不允许的国家。%s",

    ["notify_security_privesc"] = "%s 被设置为仅白名单的用户组 %q。",
    ["notify_security_privesc_action"] = "被设置为仅白名单的用户组 %q。",

    ["notify_functions_action"] = "我们应该对 %s 采取哪种行动？\n原因：%s",
    ["notify_functions_action_notify"] = "管理员 %s 针对 %s 的检测 %q 采取了以下行动：%q。",
    ["notify_functions_allow_success"] = "成功排除检测。",
    ["notify_functions_allow_failed"] = "无法排除此检测。",

    ["notify_custom_extension_ddos_protection_attack_started"] = "检测到 DDoS 攻击。使用 !nova 打开菜单，查看实时状态",
    ["notify_custom_extension_ddos_protection_attack_stopped"] = "DDoS 攻击停止。用 !nova 打开菜单，了解详情",
    -- Health
    ["health_check_gmexpress_title"] = "gm_express 模块",
    ["health_check_gmexpress_desc"] = "性能大幅提升，尤其适用于大型服务器。由 CFC 服务器创建。",
    ["health_check_gmexpress_desc_long"] =
[[我们不再通过内置的 Netmessages（速度慢）发送大量数据，而是使用外部提供商（gmod.express）通过 HTTPS 将这些数据传输到客户端
这样可以加快客户端的加载时间，减轻服务器的负担。不过，该选项依赖于 gmod.express。如果无法访问该页面，客户端的身份验证将失败
无法连接到 gmod.express 的新客户端将退回到传统的 Netmessages。

要安装，请访问：https://github.com/CFC-Servers/gm_express。
   1. 点击 “代码 ”并下载 .zip 文件。
   2. 将 .zip 文件解压到“/garrysmod/addons ”目录下。
   3. 重新启动服务器。
   4. 激活 “网络 ”选项卡中的 “激活 gm_express ”选项。

该服务也可自行托管。
请参见： https://github.com/CFC-Servers/gm_express_service]],
    ["health_check_seversecure_title"] = "服务器安全模块",
    ["health_check_seversecure_desc"] = "一个用于减轻Source引擎漏洞利用的模块，由danielga创建。",
    ["health_check_seversecure_desc_long"] =
[[如果没有这个模块，您的服务器可能很容易被崩溃。
它能够限制服务器接受的数据包数量并进行验证。

要安装，请访问 https://github.com/danielga/gmsv_serversecure。
   1. 前往Releases并下载适合您服务器操作系统的.dll文件。
   2. 如果不存在，则创建文件夹"garrysmod/lua/bin"。
   3. 将.dll文件放在"/garrysmod/lua/bin"文件夹中。
   4. 在Github下载"serversecure.lua"文件（"/include/modules"）。
   5. 将此文件放置在"/garrysmod/lua/includes/modules"文件夹内。
   6. 重启您的服务器。

如果您希望Nova Defender为您自动配置该模块，请在"Exploit"标签中激活
"自动设置Serversecure"选项。]],
    ["health_check_exploits_title"] = "已知存在漏洞的插件",
    ["health_check_exploits_desc"] = "已知可被利用的插件netmessages列表。",
    ["health_check_exploits_desc_long"] =
[[Netmessage使客户端与服务器之间的通信成为可能。
然而，这些消息很容易被客户端操纵。
因此，如果服务器没有检查客户端是否有权发送此消息，
就可能出现可被利用的安全漏洞（金钱漏洞、服务器崩溃、管理员权限）。

所有列出的netmessages名称都可以或可能被利用。
不能保证这个漏洞仍然存在。
此外，还有可能存在未列出的可被利用的netmessages。

   1. 定期更新您的插件
   2. 用新的替换过时/不受支持的插件
   3. 如果您熟悉Lua，手动检查受影响的netmessages
    ]],
    ["health_check_backdoors_title"] = "后门",
    ["health_check_backdoors_desc"] = "服务器上的后门可能会给攻击者提供不受欢迎的访问权限。",
    ["health_check_backdoors_desc_long"] =
[[后门可以通过以下几种方式之一加载到服务器上：
   1. 恶意的工作坊插件
   2. 有人要求您上传一个“特别为您制作”的Lua文件到服务器
   3. 有访问您服务器的开发者为自己设置了后门
   4. 服务器本身已被泄露（操作系统的漏洞，软件的漏洞）
    
移除后门的方法：
   1. 如果可用，检查给定路径（如果路径以'lua/'开头，很可能来自工作坊）
   2. 使用例如https://github.com/THABBuzzkill/nomalua等工具扫描您的服务器
   3. 移除您最近添加的所有脚本，并检查此消息是否再次出现
   4. 下载服务器上的所有文件，并对列出的后门进行文本搜索
   5. 困难方式：移除所有插件，直到此消息停止出现，然后逐一添加回插件并检查它再次出现的插件。]],
    ["health_check_mysql_pass_title"] = "数据库密码弱",
    ["health_check_mysql_pass_desc"] = "Nova Defender的数据库密码太弱。",
    ["health_check_mysql_pass_desc_long"] = [[
        如果您使用MySQL，您需要一个强密码。
        即使它不可从互联网访问。
    
        如何保护您的数据库：
        1. 强数据库密码是您不需要记住的
        2. 使用密码生成器创建一个随机密码
        3. 为每个数据库使用不同的密码
        4. 为每个插件使用不同的数据库（或适当的数据库权限）
    ]],
    ["health_check_nova_errors_title"] = "Nova Defender错误",
    ["health_check_nova_errors_desc"] = "由Nova Defender生成的错误",
    ["health_check_nova_errors_desc_long"] = [[
        好吧，阅读它们。如果您不确定如何解决给定的问题，请联系我。
        如果每个错误消息对您来说都是明确的，并且不影响功能，
        您可以安全地忽略此消息。
    ]],
    ["health_check_nova_vpn_title"] = "Nova Defender VPN保护",
    ["health_check_nova_vpn_desc"] = "必须设置VPN保护以阻止国家和检测VPN。",
    ["health_check_nova_vpn_desc_long"] = [[
        在“网络”标签中，您必须插入您在ipqualityscore.com免费注册后获得的API密钥。
        有了这个，Nova-Defender可以通过这个页面检查IP地址。
        1. 前往https://www.ipqualityscore.com/create-account
        2. 在这里复制您的API密钥https://www.ipqualityscore.com/user/settings
        3. 在“网络”标签下的“VPN API密钥”处粘贴它
    ]],
    ["health_check_nova_steamapi_title"] = "Nova Defender Steam资料保护",
    ["health_check_nova_steamapi_desc"] = "必须设置Steam资料保护以检测玩家的可疑资料。",
    ["health_check_nova_steamapi_desc_long"] = [[
        在“封禁系统”标签中，您需要插入您的API密钥，
        1. 前往https://steamcommunity.com/dev/apikey
        2. 输入您服务器的域名
        3. 复制您的API密钥
        4. 在“封禁系统”标签下的“Steam API密钥”处粘贴它
    ]],
    ["health_check_nova_anticheat_title"] = "Nova Defender反作弊扩展",
    ["health_check_nova_anticheat_desc"] = "反作弊需要一个扩展来检测更多的作弊。",
    ["health_check_nova_anticheat_desc_long"] = [[
        目前只检测到一些简单的作弊。由于Nova Defender的源代码是开放和可见的，作弊可以很容易地被修改为不可检测。
        因此，大型服务器的所有者可以请求反作弊的扩展，
        它还可以通过名称检测外部的、新的或付费的作弊。
        欢迎直接通过Steam联系我。
        然而，我保留拒绝请求的权利，即使不提供理由。
    ]],
    ["health_check_nova_anticheat_version_title"] = "Nova Defender反作弊旧版本",
    ["health_check_nova_anticheat_version_desc"] = "反作弊不是最新的。",
    ["health_check_nova_anticheat_version_desc_long"] =
    [[请从GitHub下载最新版本：
https://github.com/Freilichtbuehne/nova-defender-anticheat/releases/latest]],
    ["health_check_nova_ddos_protection_title"] = "Nova Defender DDoS 防护扩展",
    ["health_check_nova_ddos_protection_desc"] = "保护您的 Linux 服务器免受 DDoS 攻击",
    ["health_check_nova_ddos_protection_desc_long"] =
    [[为 Linux 服务器提供基于主机的 DDoS 保护。
服务器所有者可以申请此扩展。
请单击菜单顶部的相应按钮或加入我们的 Discord 了解更多信息]],
    ["health_check_nova_ddos_protection_version_title"] = "Nova Defender DDoS 防护旧版本",
    ["health_check_nova_ddos_protection_version_desc"] = "DDoS 防护不是最新版本",
    ["health_check_nova_ddos_protection_version_desc_long"] =
    [[请从GitHub下载最新版本：
 https://github.com/Freilichtbuehne/nova-defender-ddos/releases/latest]],

    -- Server
    ["server_general_suffix"] = "每次踢出、封禁或拒绝消息时附加的文本。例如您的Teamspeak、Discord或其他支持站点。",

    ["server_access_maintenance_enabled"] = "维护模式：\n只有受保护的玩家和有密码的玩家可以加入服务器。",
    ["server_access_maintenance_allowed"] = "在维护模式下谁可以加入服务器？受保护的玩家始终被允许，不需要密码。",
    ["server_access_maintenance_password"] = "维护模式的密码，如果您在上面的设置中选择了'密码'。",
    ["server_access_maintenance_reason"] = "尝试在维护期间连接的客户端显示的原因。",
    ["server_access_password_lock"] = "锁定错误尝试：\n如果客户端输入错误密码太多次，所有后续尝试都将被阻止。",
    ["server_access_password_lock_reason"] = "如果他输入错误密码太多次，显示给客户端的原因。",
    ["server_access_password_max_attempts"] = "锁定前的最大尝试次数",

    ["server_lockdown_enabled"] = "封锁模式：\n只有管理员、受保护和受信任的玩家可以加入服务器。当许多新账户被创建来加入服务器进行捣乱、破坏或崩溃服务器时使用此模式。已经在服务器上的玩家不受影响。确保首先在Nova Defender的配置文件中定义谁是受信任的。这应该只用于短时间。",
    ["server_lockdown_reason"] = "如果玩家在封锁模式下不受保护、不是管理员或不受信任时踢出玩家的原因。",
    -- Admin Menu
    ["menu_title_banbypass"] = "封禁系统",
    ["menu_title_health"] = "健康",
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
    ["menu_title_ddos"] = "DDoS 保护",

    ["menu_desc_banbypass"] = "防止玩家绕过Nova Defender封禁的技术",
    ["menu_desc_network"] = "限制、控制和记录网络活动",
    ["menu_desc_security"] = "保护免受用户权限提升的攻击",
    ["menu_desc_menu"] = "控制通知和管理员菜单",
    ["menu_desc_anticheat"] = "根据您的需求启用或禁用客户端反作弊功能",
    ["menu_desc_bans"] = "查找、封禁或解封玩家",
    ["menu_desc_exploit"] = "防止游戏机制中的特定漏洞",
    ["menu_desc_players"] = "当前在线的所有玩家",
    ["menu_desc_health"] = "一目了然地查看服务器的状态",
    ["menu_desc_detections"] = "所有需要审查的待处理检测",
    ["menu_desc_server"] = "管理对您服务器的访问",
    ["menu_desc_inspection"] = "对玩家执行命令和搜索文件",
    ["menu_desc_ddos"] = "Linux 服务器上安装的 DDoS 防护的实时状态",

    ["menu_elem_extensions"] = "扩展：",
    ["menu_elem_disabled"] = "(已停用)",
    ["menu_elem_outdated"] = "(已过时)",
    ["menu_elem_add"] = "添加",
    ["menu_elem_edit"] = "编辑",
    ["menu_elem_unban"] = "解封",
    ["menu_elem_ban"] = "封禁",
    ["menu_elem_kick"] = "踢出",
    ["menu_elem_reconnect"] = "重新连接",
    ["menu_elem_quarantine"] = "隔离",
    ["menu_elem_unquarantine"] = "解除隔离",
    ["menu_elem_verify_ac"] = "检查反作弊",
    ["menu_elem_screenshot"] = "截图",
    ["menu_elem_detections"] = "检测",
    ["menu_elem_indicators"] = "指示器",
    ["menu_elem_commands"] = "命令",
    ["menu_elem_netmessages"] = "网络消息",
    ["menu_elem_ip"] = "IP详情",
    ["menu_elem_profile"] = "Steam资料",
    ["menu_elem_rem"] = "移除",
    ["menu_elem_reload"] = "重新加载",
    ["menu_elem_advanced"] = "高级选项",
    ["menu_elem_miss_options"] = "缺少一些选项？",
    ["menu_elem_copy"] = "复制",
    ["menu_elem_save"] = "保存到磁盘",
    ["menu_elem_saved"] = "已保存",
    ["menu_elem_settings"] = "设置：",
    ["menu_elem_general"] = "常规：",
    ["menu_elem_discord"] = "加入我们的Discord！",
    ["menu_elem_close"] = "关闭",
    ["menu_elem_cancel"] = "取消",
    ["menu_elem_filter_by"] = "过滤条件：",
    ["menu_elem_view"] = "查看",
    ["menu_elem_filter_text"] = "过滤文本：",
    ["menu_elem_reason"] = "原因",
    ["menu_elem_comment"] = "评论",
    ["menu_elem_bans"] = "封禁（限制为150条记录）：",
    ["menu_elem_new_value"] = "新值",
    ["menu_elem_submit"] = "提交",
    ["menu_elem_no_bans"] = "未找到封禁",
    ["menu_elem_no_data"] = "无可用数据",
    ["menu_elem_checkboxtext_checked"] = "激活",
    ["menu_elem_checkboxtext_unchecked"] = "未激活",
    ["menu_elem_search_term"] = "搜索词...",
    ["menu_elem_unavailable"] = "不可用",
    ["menu_elem_failed"] = "失败",
    ["menu_elem_passed"] = "通过",
    ["menu_elem_health_overview"] = "检查：\n  • 总数：%d\n  • 通过：%d\n  • 失败：%d",
    ["menu_elem_health_most_critical"] = "最关键的：\n",
    ["menu_elem_mitigation"] = "如何修复？",
    ["menu_elem_list"] = "详情",
    ["menu_elem_ignore"] = "忽略",
    ["menu_elem_reset"] = "重置",
    ["menu_elem_reset_all"] = "重置所有忽略的检查：",
    ["menu_elem_player_count"] = "在线玩家：%d",
    ["menu_elem_foundindicator"] = "发现%d个指示器",
    ["menu_elem_foundindicators"] = "发现%d个指示器",
    ["menu_elem_criticalindicators"] = "关键指示器！",
    ["menu_elem_notauthed"] = "正在认证...",

    ["menu_elem_mitigated"] = "已缓解",
    ["menu_elem_unmitigated"] = "未缓解",
    ["menu_elem_next"] = "下一个",
    ["menu_elem_prev"] = "上一个",
    ["menu_elem_clear"] = "删除已缓解",
    ["menu_elem_clear_all"] = "删除所有",
    ["menu_elem_delete"] = "删除",
    ["menu_elem_stats"] = "条目：%d",
    ["menu_elem_page"] = "页码：%d",

    ["menu_elem_nofocus"] = "无焦点",
    ["menu_elem_focus"] = "有焦点",
    ["menu_elem_connect"] = "连接",
    ["menu_elem_disconnect"] = "断开连接",
    ["menu_elem_input_command"] = "输入并运行Lua代码...",
    ["menu_elem_select_player"] = "选择一个玩家",
    ["menu_elem_disconnected"] = "已断开",
    ["menu_elem_exec_clientopen"] = "客户端打开连接",
    ["menu_elem_exec_clientclose"] = "客户端关闭连接",
    ["menu_elem_exec_error"] = "内部服务器错误",
    ["menu_elem_exec_help"] = [[
        应用：
        • 如果您熟悉Lua，请使用此功能
        • 旨在用于调试目的和寻找Lua作弊
    
        通用：
        • 输入Lua代码并按回车在选定的客户端上执行
        • Lua错误将显示在控制台中
        • 客户端看不到Lua错误
    
        显示值：
        • 要获取表或字符串的值，请使用"print()"或"PrintTable()"
        • 执行"print"和"PrintTable"对客户端不可见
        • 执行"print"和"PrintTable"的结果将重定向到您的控制台
        • 示例1："PrintTable(hook.GetTable())"
        • 示例2："local nick = LocalPlayer():Nick() print(nick)"
    
        历史：
        • 使用上和下箭头浏览历史记录
        • 使用TAB自动完成
    
        安全：
        • 负责任地执行Lua代码
        • 执行的代码可能对客户端可见
        • 客户端可能会阻止或操纵执行的代码
    ]],
    ["menu_elem_help"] = "帮助",
    ["menu_elem_filetime"] = "最后文件修改：%s",
    ["menu_elem_filesize"] = "文件大小：%s",
    ["menu_elem_download"] = "下载",
    ["menu_elem_download_confirm"] = "您确定要下载以下文件吗？\n%q",
    ["menu_elem_download_progress"] = "正在加载块 %i/%i...",
    ["menu_elem_download_finished_part"] = "文件已部分下载并保存在您的本地Garry's Mod数据文件夹中：\n%q",
    ["menu_elem_download_finished"] = "文件下载完成并保存在您的本地Garry's Mod数据文件夹中：\n%q",
    ["menu_elem_download_failed"] = "下载失败：%q",
    ["menu_elem_download_started"] = "正在下载文件：%q",
    ["menu_elem_download_confirmbutton"] = "下载",
    ["menu_elem_canceldel"] = "取消并删除",

    ["menu_elem_ddos_active"] = "DDoS 保护已启用！",
    ["menu_elem_ddos_inactive"] = "DDoS 保护已禁用",
    ["menu_elem_ddos_duration"] = "持续时间：%s",
    ["menu_elem_ddos_avg"] = "Avg RX: %s",
    ["menu_elem_ddos_max"] = "最大 RX：%s",
    ["menu_elem_ddos_stopped"] = "Stopped at： %s",
    ["menu_elem_ddos_stats"] = "上次攻击的统计信息：",
    ["menu_elem_ddos_cpu_util"] = "CPU 使用率",
    ["menu_elem_ddos_net_util"] = "网络利用率",

    ["indicator_pending"] = "玩家尚未将其指示器发送到服务器。他可能阻止了它们，或者需要更多时间。",
    ["indicator_install_fresh"] = "玩家最近安装了这款游戏",
    ["indicator_install_reinstall"] = "玩家最近重新安装了这款游戏",
    ["indicator_advanced"] = "玩家使用调试/开发者命令（他可能知道自己在做什么...）",
    ["indicator_first_connect"] = "首次连接到此服务器（如果游戏未被重新安装）",
    ["indicator_cheat_hotkey"] = "玩家按下了一个键（INSERT、HOME、PAGEUP、PAGEDOWN），这些键通常用于打开作弊菜单",
    ["indicator_cheat_menu"] = "玩家使用INSERT、HOME、PAGEUP或PAGEDOWN中的一个键打开了菜单",
    ["indicator_bhop"] = "玩家在他的鼠标滚轮上绑定了兔跳（如'bind mwheelup +jump'）",
    ["indicator_memoriam"] = "玩家过去使用过或当前正在使用作弊'Memoriam'",
    ["indicator_multihack"] = "玩家过去使用过或当前正在使用作弊'Garrysmod 64-bit Visuals Multihack Reborn'",
    ["indicator_fenixmulti"] = "玩家过去使用过或当前正在使用作弊'FenixMulti'",
    ["indicator_interstate"] = "玩家过去使用过或当前正在使用作弊'interstate editor'",
    ["indicator_exechack"] = "玩家过去使用过或当前正在使用付费作弊'exechack'",
    ["indicator_banned"] = "玩家已被Nova Defender在另一个服务器上封禁",
    ["indicator_lua_binaries"] = "玩家在 'garrysmod/lua/bin '文件夹中有 DLL 文件。作弊器通常放在这里。可以在 '检查玩家'选项卡中搜索这些文件。这些文件必须由玩家手动创建。",
    ["indicator_profile_familyshared"] = "玩家拥有一个家庭共享账户",
    ["indicator_profile_friend_banned"] = "这位玩家的Steam好友已被Nova Defender封禁",
    ["indicator_profile_recently_created"] = "Steam个人资料在过去7天内创建",
    ["indicator_profile_nogames"] = "玩家在他的Steam个人资料上尚未购买任何游戏",
    ["indicator_profile_new_player"] = "玩家在Garry's Mod中的总游戏时间不超过2小时",
    ["indicator_profile_vac_banned"] = "玩家已经收到了VAC封禁",
    ["indicator_profile_vac_bannedrecent"] = "玩家在过去5个月内已经收到了VAC封禁",
    ["indicator_profile_community_banned"] = "玩家已经收到了Steam的社区封禁",
    ["indicator_profile_not_configured"] = "玩家甚至还没有设置他的Steam账户",
    ["indicator_scenario_bypass_account"] = "指示器表明这位玩家特别创建了一个新的Steam账户。查看'在线玩家'菜单标签。",
    ["indicator_scenario_cheatsuspect"] = "指示器表明这位玩家作弊。查看'在线玩家'菜单标签",
    ["indicator_scenario_sum"] = "玩家因满足大量典型指示器而被怀疑。查看菜单标签'在线玩家'",

    ["internal_reason"] = "内部原因",
    ["banned"] = "已封禁",
    ["status"] = "状态",
    ["reason"] = "原因",
    ["unban_on_sight"] = "见到即解封",
    ["ip"] = "IP",
    ["ban_on_sight"] = "见到即封禁",
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
    ["nothing"] = "无操作",
    ["set"] = "重置",
    ["disable"] = "未来禁用",
    ["ignore"] = "临时忽略",
    ["dont_care"] = "不关心",
    ["action_taken_at"] = "采取行动的时间",
    ["action_taken_by"] = "采取行动的人",

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
