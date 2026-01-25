local lang = "fr"

local phrases = {
    /*
        Notifications
    */
    ["menu_logging_debug"] = "Mode Debug:\nCeci affiche des logs supplémentaires dans la console du serveur.",
    ["menu_notify_timeopen"] = "Durée d'affichage des notifications en secondes.",
    ["menu_notify_showstaff"] = "Afficher les notifications au staff.",
    ["menu_notify_showinfo"] = "Afficher les notifications informationnelles",
    ["menu_access_player"] = "Le staff a accès à l'onglet 'Joueurs En Ligne' et peut effectuer des actions. Le staff ne peut pas cibler les joueurs protégés.",
    ["menu_access_staffseeip"] = "Le staff peut voir les adresses IP des joueurs",
    ["menu_access_detections"] = "Le staff a accès à l'onglet 'Détections'",
    ["menu_access_bans"] = "Le staff a accès à l'onglet 'Bans'",
    ["menu_access_health"] = "Le staff a accès à l'onglet 'Santé'",
    ["menu_access_inspection"] = "Le staff a accès à l'onglet 'Inspecter les Joueurs'",
    ["menu_access_ddos"] = "Le staff a accès à l'onglet 'DDoS'",

    ["menu_action_timeopen"] = "Durée d'affichage du dialogue de punition en secondes.",
    ["menu_action_showstaff"] = "Demander au staff une action de punition s'il n'y a pas de joueurs protégés (ou AFK).",
    /*
        Networking
    */
    ["networking_concommand_logging"] = "Enregistrer les Commandes:\nEnregistre chaque commande console exécutée par les clients et le serveur",
    ["networking_concommand_dump"] = "Dumper les Commandes:\nAffiche toutes les commandes qu'un joueur a exécutées lorsqu'il se déconnecte. Cela peut augmenter la taille de vos logs très rapidement.",
    ["networking_netcollector_dump"] = "Dumper les Netmessages:\nAffiche tous les netmessages qu'un joueur a envoyés au serveur lorsqu'il se déconnecte.",
    ["networking_netcollector_spam_action"] = "Que se passe-t-il lorsqu'un joueur spamme les netmessages au serveur?",
    ["networking_netcollector_spam_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir spammé les netmessages du serveur.",
    ["networking_dos_action"] = "Que se passe-t-il lorsqu'un joueur essaie de causer du lag serveur?",
    ["networking_dos_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir causé du lag serveur.",
    ["networking_dos_sensivity"] = "Quelle doit être la sensibilité de la détection?",
    ["networking_dos_crash_enabled"] = "Détecter les Attaques de Décompression:\nLes clients peuvent envoyer des données hautement compressées au serveur. Une fois décompressées, elles peuvent facilement atteindre 400 MB et causer du lag ou un crash. Un client peut envoyer un maximum de 65 KB au serveur. La compression utilisée dans Gmod (LZMA2) a généralement un ratio de compression d'environ 20:1 (dépend des données). On s'attendrait donc à environ 1 MB de données décompressées. Un ratio de compression de 1000:1 ou même 7000:1 n'a aucune utilisation légitime. Cette option remplace util.Decompress et ne nécessite pas de redémarrage.",
    ["networking_dos_crash_action"] = "Que se passe-t-il si un joueur essaie de crasher le serveur?",
    ["networking_dos_crash_ignoreprotected"] = "Ignorer les joueurs protégés.",
    ["networking_dos_crash_maxsize"] = "Taille maximale décompressée en MB:\nLorsque cette limite est atteinte, la décompression sera interrompue.",
    ["networking_dos_crash_ratio"] = "Ratio de compression maximal:\nLes données normales auront un ratio de compression d'environ 20:1. Un ratio de compression de 1000:1 ou même 7000:1 n'a aucune utilisation légitime. Ne réglez pas cela trop bas pour éviter les faux positifs.",
    ["networking_dos_crash_whitelist"] = "Netmessages en liste blanche qui seront ignorés.",
    ["networking_netcollector_actionAt"] = "À combien de messages d'un seul client en 3 secondes devrions-nous agir? NE RÉGLEZ JAMAIS CELA TROP BAS!",
    ["networking_netcollector_dropAt"] = "À combien de messages en 3 secondes devrions-nous ignorer un netmessage. Ceci est fait pour prévenir une attaque par déni de service. Doit être inférieur au paramètre ci-dessus.",
    ["networking_restricted_message_action"] = "Que se passe-t-il lorsqu'un joueur envoie un message au serveur qu'il n'est pas autorisé à envoyer? Sans manipuler le jeu ou un bug, il n'est pas possible pour les joueurs d'envoyer ce message.",
    ["networking_restricted_message_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir envoyé un message au serveur qu'il n'était pas autorisé à envoyer.",
    ["networking_sendlua_gm_express"] = "Activer gm_express:\nAmélioration massive des performances, en particulier pour les serveurs plus grands. Au lieu d'envoyer de grandes quantités de données via les netmessages intégrés (lent), elles sont transférées aux clients via HTTPS via un fournisseur externe (gmod.express). Cela accélère le temps de chargement des clients et réduit la charge sur le serveur. Cependant, cette option dépend de gmod.express. Si cette page ne peut pas être atteinte, l'authentification des clients échouera. Les nouveaux clients qui ne peuvent pas se connecter à gmod.express reviennent aux netmessages conventionnels. Cette option nécessite l'installation de gm_express. Plus de détails dans l'onglet 'Santé'.",
    ["networking_sendlua_authfailed_action"] = "Que se passe-t-il lorsqu'un joueur ne répond pas à l'authentification Nova Defender? S'il est ignoré, il n'y a aucune garantie que l'anticheat ou d'autres mécanismes côté client fonctionnent.",
    ["networking_sendlua_authfailed_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour ne pas avoir répondu à l'authentification Nova Defender.",
    ["networking_sendlua_validationfailed_action"] = "Que se passe-t-il lorsqu'un joueur bloque le code de Nova Defender?",
    ["networking_sendlua_validationfailed_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir bloqué le code de Nova Defender.",
    ["networking_fakenets_backdoors_load"] = "Créer de fausses portes dérobées et piéger les attaquants pour les utiliser.",
    ["networking_fakenets_backdoors_block"] = "Bloquer les portes dérobées sur le serveur. Pourrait bloquer les netmessages légitimes et casser les addons! D'abord, consultez l'onglet 'Santé' et vérifiez les portes dérobées existantes.",
    ["networking_fakenets_backdoors_action"] = "Que se passe-t-il lorsqu'un attaquant utilise une fausse porte dérobée?",
    ["networking_fakenets_exploits_load"] = "Créer de faux exploits et piéger les attaquants pour les utiliser.",
    ["networking_fakenets_exploits_block"] = "Bloquer les netmessages exploitables sur le serveur. Cela casse les addons exploitables sur votre serveur! D'abord, consultez l'onglet 'Santé' et vérifiez les addons exploitables.",
    ["networking_fakenets_exploits_action"] = "Que se passe-t-il lorsqu'un attaquant utilise un faux exploit?",
    ["networking_vpn_vpn-action"] = "Que se passe-t-il lorsqu'un joueur utilise un VPN?",
    ["networking_vpn_vpn-action_reason"] = "Raison pour laquelle un VPN est utilisé.",
    ["networking_vpn_country-action"] = "Que se passe-t-il lorsqu'un joueur vient d'un pays non autorisé?",
    ["networking_vpn_country-action_reason"] = "Raison pour venir d'un pays non autorisé.",
    ["networking_vpn_dump"] = "Affiche les informations sur l'adresse IP d'un joueur dans la console",
    ["networking_vpn_apikey"] = "Clé API VPN:\nPour analyser les adresses IP. Vous devez vous enregistrer sur https://www.ipqualityscore.com/create-account et récupérer votre clé sur https://www.ipqualityscore.com/user/settings.",
    ["networking_vpn_countrycodes"] = "Pays autorisés à rejoindre votre serveur. Obtenez les codes pays ici: https://countrycode.org/ (code à 2 lettres en majuscules). Il est recommandé de mettre sur liste blanche votre propre pays et les pays voisins. Vous pouvez ajouter d'autres pays au fil du temps.",
    ["networking_vpn_whitelist_asns"] = "Numéros ASN en liste blanche (numéro pour identifier un fournisseur de services Internet). Il se peut que l'API détecte incorrectement une connexion VPN. Par conséquent, les FAI connus sont mis sur liste blanche. Obtenez-les sur https://ipinfo.io/countries. Alternativement, vous pouvez voir l'ASN de chaque client connecté dans l'onglet 'Joueur'.",
    ["networking_screenshot_store_ban"] = "Enregistrer les captures d'écran (À la mise en ban):\nJuste avant qu'un joueur soit banni, une capture d'écran de son écran sera prise et enregistrée dans le dossier '/data/nova/ban_screenshots' du serveur.",
    ["networking_screenshot_store_manual"] = "Enregistrer les captures d'écran (Menu):\nSi un admin prend une capture d'écran d'un joueur, elle sera enregistrée dans le dossier '/data/nova/admin_screenshots' du serveur.",
    ["networking_screenshot_limit_ban"] = "Limite de captures d'écran (À la mise en ban):\nNombre maximal de captures d'écran stockées dans le dossier de données du serveur. Les plus anciennes seront supprimées.",
    ["networking_screenshot_limit_manual"] = "Limite de captures d'écran (Menu):\nNombre maximal de captures d'écran stockées dans le dossier de données du serveur. Les plus anciennes seront supprimées.",
    ["networking_screenshot_quality"] = "Qualité des Captures d'écran\nLes captures d'écran de haute qualité peuvent prendre jusqu'à une minute à transférer.",

    ["networking_http_overwrite"] = "Inspecter les appels HTTP (envoi+réception):\nSi ce paramètre est activé, la fonction HTTP est remplacée et les requêtes peuvent être enregistrées ou bloquées. Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_http_logging"] = "Enregistrer les requêtes:\nToutes les requêtes HTTP sont enregistrées en détail dans la console. C'est utile pour avoir un aperçu des URL appelées. Fonctionne uniquement lorsque les requêtes HTTP sont inspectées.",
    ["networking_http_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",
    ["networking_http_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et les adresses IP qui ont été ajoutés à la liste sont autorisés.",
    ["networking_http_whitelistdomains"] = "Domaines en liste blanche:\nAjoutez tous les domaines et IPs de confiance qui doivent être autorisés. Tout le reste sera bloqué. Si vous n'êtes pas sûr des domaines à mettre sur liste blanche, désactivez la liste blanche et activez uniquement la journalisation.",

    ["networking_fetch_overwrite"] = "Inspecter http.fetch (réception de données):\nRemplacer la fonction http.fetch. N'ACTIVEZ PAS SI VOUS UTILISEZ VCMOD! Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_fetch_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et les adresses IP ajoutés à la liste seront autorisés.",
    ["networking_fetch_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",

    ["networking_post_overwrite"] = "Inspecter http.post (envoi de données):\nRemplacer la fonction http.post. L'envoi de requêtes HTTP peut être utilisé par les attaquants pour voler des fichiers sur le serveur. Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_post_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et les adresses IP qui ont été ajoutés à la liste sont autorisés.",
    ["networking_post_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",

    ["networking_ddos_collect_days"] = "Jours de collecte des adresses IP:\nLa protection DDoS collecte les adresses IP de tous les joueurs connectés des n derniers jours. Lorsqu'une attaque DDoS est détectée, toute communication avec le serveur est bloquée, sauf pour les joueurs connectés des n derniers jours. Le serveur sera invisible pour les autres.",
    ["networking_ddos_notify"] = "Afficher les notifications si une attaque DDoS est détectée ou arrêtée.",
    /*
        Banbypass
    */
    ["banbypass_ban_banstaff"] = "Le staff peut être banni",
    ["banbypass_ban_default_reason"] = "Raison pour laquelle un joueur est banni si aucune raison n'est spécifiée",

    ["banbypass_bypass_default_reason"] = "Raison pour laquelle un joueur est banni s'il a contourné un ban",

    ["banbypass_bypass_familyshare_kick"] = "Expulser les joueurs utilisant un compte de famille partagée.",
    ["banbypass_bypass_familyshare_kick_reason"] = "Raison pour laquelle un joueur est expulsé s'il utilise un compte de famille partagée.",
    ["banbypass_bypass_familyshare_action"] = "Que se passe-t-il lorsqu'un joueur utilise un compte de famille partagée d'un joueur banni?",
    ["banbypass_bypass_clientcheck_action"] = "Que se passe-t-il lorsque nous trouvons des preuves de contournement de ban dans les fichiers locaux d'un joueur?",

    ["banbypass_bypass_ipcheck_action"] = "Que se passe-t-il lorsqu'un joueur a la même adresse IP qu'un joueur banni?",
    ["banbypass_bypass_fingerprint_enable"] = "Activer la Vérification d'Empreinte:\nCette option vérifie si un joueur utilise le même appareil qu'un utilisateur banni. Il peut empêcher un joueur de créer un nouveau compte sur le même appareil tant qu'il est banni.",
    ["banbypass_bypass_fingerprint_action"] = "Que se passe-t-il lorsqu'un joueur utilise le même appareil qu'un utilisateur banni?",
    ["banbypass_bypass_fingerprint_sensivity"] = "Quelle doit être la sensibilité de la correspondance d'empreinte?",

    ["banbypass_bypass_indicators_apikey"] = "Clé API Steam:\nL'API Steam peut être utilisée pour afficher des données plus détaillées sur un joueur. Les résultats sont affichés dans l'onglet 'Joueurs En Ligne' dans les indicateurs. Créez-en une sur https://steamcommunity.com/dev/apikey et collez-la ici.",
    /*
        Anticheat
    */
    ["anticheat_reason"] = "Raison pour laquelle un joueur est banni s'il utilise des cheats.",
    ["anticheat_enabled"] = "Activer Anticheat:\nSi ce paramètre est activé, le code anticheat sera envoyé à tous les clients et les détections seront traitées. Si ce paramètre est désactivé, le code anticheat reste actif sur tous les clients actuellement connectés mais les détections sont ignorées. Cette option inclut la détection d'autoclick et d'aimbot.",
    ["anticheat_action"] = "Que se passe-t-il lorsqu'un joueur a des cheats?",
    ["anticheat_verify_action"] = "Que se passe-t-il lorsque l'anticheat ne se charge pas pour un joueur?",
    ["anticheat_verify_execution"] = "Vérifier si anticheat fonctionne:\nAprès qu'un joueur reçoive l'anticheat, une confirmation est demandée pour vérifier qu'il l'a exécuté. Cependant, ce processus peut échouer pour plusieurs raisons et ne doit donc pas être défini sur 'Ban'.",
    ["anticheat_verify_reason"] = "Raison pour laquelle un joueur est banni si l'anticheat ne se charge pas.",
    ["anticheat_check_function"] = "Vérifier les Fonctions:\nCompare les noms de fonctions sur le client avec les noms de fonctions connus des cheats. Cela peut également détecter les fonctions légitimes à l'intérieur du code que vous fournissez.",
    ["anticheat_check_files"] = "Vérifier les Fichiers:\nSimilaire à 'Vérifier les Fonctions'. Compare le nom de fichier d'un script en cours d'exécution avec les noms de fichiers connus des cheats.",
    ["anticheat_check_globals"] = "Vérifier les Variables Globales:\nSimilaire à 'Vérifier les Fonctions'. Compare les noms de variables avec les noms de variables connus des cheats.",
    ["anticheat_check_modules"] = "Vérifier les Modules:\nSimilaire à 'Vérifier les Fonctions'. Compare les noms de modules avec les noms de modules connus des cheats.",
    ["anticheat_check_runstring"] = "Vérifier 'RunString':\nLe code Lua arbitraire peut être exécuté en utilisant la fonction intégrée 'RunString'. Cette option détecte l'utilisation inappropriée de cette fonction et recherche les modèles de cheat connus.",
    ["anticheat_check_external"] = "Vérifier la Manipulation Externe:\nCeci détecte le logiciel de cheat externe. Ceux-ci sont très difficiles à détecter dans un environnement Lua restreint. Cela ralentira les profileurs comme FProfiler.",
    ["anticheat_check_manipulation"] = "Détecter la Manipulation:\nDétecte les tentatives de blocage ou de manipulation de l'anticheat.",
    ["anticheat_check_cvars"] = "Vérifier les Variables de Console:\nSimilaire à 'Vérifier les Fonctions'. Certains cheats utilisent des cvars pour persister les paramètres. Compare les noms cvar avec les noms cvar connus des cheats.",
    ["anticheat_check_byte_code"] = "Vérifier la Compilation du Code:\nSous le capot, le code Lua est compilé en bytecode en utilisant JIT puis interprété. Nous pouvons parfois déterminer si cela est fait de manière inhabituelle. Par exemple, si un client exécute du code via lua_run_cl.",
    ["anticheat_check_detoured_functions"] = "Vérifier le Détournement de Fonctions:\nCertains cheats remplacent la fonctionnalité des fonctions intégrées pour contourner la détection ou manipuler le comportement du jeu.",
    ["anticheat_check_concommands"] = "Vérifier les Commandes Console:\nSimilaire à 'Vérifier les Variables Console'. Certains cheats peuvent être accédés via la console. Compare les noms de commandes avec les noms de commandes connus des cheats.",
    ["anticheat_check_net_scan"] = "Vérifier le Balayage:\nCertains scripts peuvent analyser le serveur pour détecter les vulnérabilités ou les portes dérobées connus.",
    ["anticheat_check_cheats_custom"] = "Détecter les cheats connus:\nDétecter les cheats largement utilisés par une analyse spéciale. Les noms exacts des cheats sont affichés dans la raison.",
    ["anticheat_check_cheats_custom_unsure"] = "Détecter les cheats inactifs:\nDétecte les cheats inactifs. Il est impossible de savoir si ce cheat est actuellement actif ou non. La seule certitude est que la personne a utilisé ce cheat une fois.",
    ["anticheat_check_experimental"] = "Activer les détections expérimentales:\nActive les détections de cheats qui n'ont pas encore été testées. Les joueurs ne seront PAS bannis. Les détections sont enregistrées dans le fichier suivant sur le serveur: 'data/nova/anticheat/experimental.txt'. Ce fichier peut être envoyé au développeur pour analyse.",
    ["anticheat_spam_filestealers"] = "Encombrer le voleur de fichiers:\nCertains cheats stockent tout le code Lua qu'ils reçoivent du serveur dans des fichiers texte. Pour encombrer ces fichiers et le rendre un peu plus difficile pour l'attaquant, nous les encombrons avec du code inutile. Cela remplit lentement le disque du joueur. Cela n'a aucun impact négatif sur le temps de chargement du joueur.",
    ["anticheat_autoclick_enabled"] = "Activer la détection d'autoclick:\nPour des raisons évidentes, nous ne voulons pas que les joueurs utilisent des programmes pour cliquer rapidement ou appuyer sur les touches. Cela inclut le clic gauche et droit, l'utilisation et la barre d'espace.",
    ["anticheat_autoclick_action"] = "Que se passe-t-il lorsqu'un joueur utilise l'autoclick?",
    ["anticheat_autoclick_reason"] = "Raison pour laquelle un joueur est banni s'il a utilisé l'autoclick.",
    ["anticheat_autoclick_sensivity"] = "Sensibilité de l'autoclick:\nUne sensibilité élevée peut détecter faussement les joueurs en raison de coïncidences rares. Les bons autoclickers peuvent ne pas être détectés avec une sensibilité basse. Décidez en fonction de l'avantage que les autoclickers peuvent donner aux tricheurs.",
    ["anticheat_autoclick_check_fast"] = "Vérifier la vitesse de clic rapide:\nAu-dessus d'un certain nombre de CPS (Clics Par Seconde), nous pouvons supposer qu'un être humain n'est pas capable de le faire sans aide. Cela s'applique également aux touches.",
    ["anticheat_autoclick_check_fastlong"] = "Vérifier le clic rapide sur longue durée:\nIl est peu probable qu'un joueur clique énormément rapidement pendant plusieurs minutes sans courtes pauses.",
    ["anticheat_autoclick_check_robotic"] = "Vérifier la cohérence inhumaine des clics:\nUn humain ne peut jamais cliquer à exactement la même vitesse. Cela sera toujours un peu plus rapide ou plus lent. Un programme, cependant, peut cronométrer cela très précisément. Si l'intervalle de temps entre les clics est trop cohérent, nous pouvons le dire.",
    ["anticheat_aimbot_enabled"] = "Activer la détection d'aimbot:\nSurveille en temps réel tous les mouvements des joueurs.",
    ["anticheat_aimbot_action"] = "Que se passe-t-il lorsqu'un joueur utilise un aimbot?",
    ["anticheat_aimbot_reason"] = "Raison du ban d'un joueur lorsqu'il utilise un aimbot.",
    ["anticheat_aimbot_check_snap"] = "Détecter l'accrochage:\nDétecte si la direction de vue des joueurs change instantanément. AVERTISSEMENT: Cela empêchera les clients de définir leurs angles de vue (s'ils ne sont pas effectués côté serveur) et cassera donc certains addons!",
    ["anticheat_aimbot_check_move"] = "Détecter les mouvements suspects:\nDétecte si un joueur change constamment sa vue sans bouger sa souris.",
    ["anticheat_aimbot_check_contr"] = "Détecter les mouvements contradictoires:\nDétecte si un joueur bouge sa souris dans une direction différente de celle de sa vue.",
    /*
        Exploit
    */
    ["exploit_fix_propspawn"] = "Propspawn:\nEmpêche l'apparition de props avec du matériel copié.",
    ["exploit_fix_material"] = "Matériel:\nEmpêche la copie de matériel.",
    ["exploit_fix_fadingdoor"] = "Fadingdoor:\nEmpêche le bug graphique qui empêche les joueurs de voir.",
    ["exploit_fix_physgunreload"] = "Physgun:\nDésactive le rechargement du physgun pour les utilisateurs.",
    ["exploit_fix_bouncyball"] = "Bouncyball:\nEmpêche le soudage des balles rebondissantes.",
    ["exploit_fix_bhop"] = "Bunnyhop:\nEmpêche le bunnyhopping.",
    ["exploit_fix_serversecure"] = "Configurer Serversecure automatiquement:\nVoir l'onglet 'Santé' pour plus d'informations.",
    /*
        Security
    */
    ["security_permissions_groups_protected"] = "Groupes d'utilisateurs protégés:\nTous les groupes d'utilisateurs considérés comme protégés. Seuls les joueurs en liste blanche peuvent avoir ce groupe. Les joueurs protégés ont un accès complet à ce menu.",
    ["security_permissions_groups_staff"] = "Groupes d'utilisateurs du staff et des admins:\nTous les groupes d'utilisateurs qui ont des permissions de staff.",
    ["security_privileges_group_protection_enabled"] = "Protection de rang automatisée:\nSi un joueur qui n'était pas en liste blanche a par exemple un groupe d'utilisateurs protégé, nous prenons une action.",
    ["security_privileges_group_protection_escalation_action"] = "Que se passe-t-il lorsqu'un joueur a un groupe d'utilisateurs protégé qu'il n'est pas supposé avoir?",
    ["security_privileges_group_protection_escalation_reason"] = "Raison pour laquelle un joueur est expulsé ou banni s'il a un groupe d'utilisateurs protégé qu'il n'était pas supposé avoir.",
    ["security_privileges_group_protection_removal_action"] = "Que se passe-t-il lorsqu'un joueur protégé perd son groupe d'utilisateurs?",
    ["security_privileges_group_protection_protected_players"] = "Joueurs Protégés:\nTous les joueurs autorisés à avoir un groupe d'utilisateurs protégé. Si vous supprimez un joueur qui est en ligne, il sera expulsé.",
    ["security_privileges_group_protection_kick_reason"] = "Raison pour expulser un joueur protégé si sa protection est retirée alors qu'il est connecté.",
    /*
        Detections
    */
    ["config_detection_banbypass_familyshare_account"] = "Compte de famille partagée",
    ["config_detection_banbypass_familyshare"] = "Compte de famille partagée contournant un ban",
    ["config_detection_banbypass_clientcheck"] = "Vérification du contournement de ban par le client",
    ["config_detection_banbypass_ipcheck"] = "Vérification de contournement de ban par IP",
    ["config_detection_banbypass_fingerprint"] = "Contournement de ban par empreinte",
    ["config_detection_networking_country"] = "Pays du joueur non autorisé",
    ["config_detection_networking_vpn"] = "Utilisation d'un VPN",
    ["config_detection_networking_backdoor"] = "Utilisation d'une fausse porte dérobée",
    ["config_detection_networking_spam"] = "Spam de netmessages",
    ["config_detection_networking_dos"] = "Causant du lag serveur",
    ["config_detection_networking_dos_crash"] = "Tentative de crash du serveur avec un grand message",
    ["config_detection_networking_authentication"] = "Le client ne peut pas s'authentifier avec le serveur",
    ["config_detection_networking_restricted_message"] = "Le client a envoyé un message réservé aux admins au serveur",
    ["config_detection_networking_exploit"] = "Utilisation d'un faux exploit",
    ["config_detection_networking_validation"] = "Le client ne peut pas valider l'exécution du code",
    ["config_detection_anticheat_scanning_netstrings"] = "Balayage des exploits et portes dérobées",
    ["config_detection_anticheat_runstring_dhtml"] = "Exécution de code via DHTML",
    ["config_detection_anticheat_runstring_bad_string"] = "RunString contient des modèles de cheat (chaîne)",
    ["config_detection_anticheat_remove_ac_timer"] = "Désactivation de l'anticheat",
    ["config_detection_anticheat_gluasteal_inject"] = "Utilisation du voleur de fichiers pour exécuter du code",
    ["config_detection_anticheat_function_detour"] = "Détournement de fonction pour manipuler le jeu",
    ["config_detection_anticheat_external_bypass"] = "Cheats Externes",
    ["config_detection_anticheat_runstring_bad_function"] = "RunString contient des modèles de cheat (fonction)",
    ["config_detection_anticheat_jit_compilation"] = "Compilation en bytecode inhabituelle",
    ["config_detection_anticheat_known_cvar"] = "Cvar de cheat",
    ["config_detection_anticheat_known_file"] = "Fichiers de cheat trouvés",
    ["config_detection_anticheat_known_data"] = "Restes de cheat trouvés",
    ["config_detection_anticheat_known_module"] = "Modules de cheat inclus",
    ["config_detection_anticheat_known_concommand"] = "Commande console de cheat",
    ["config_detection_anticheat_verify_execution"] = "Blocage de l'anticheat",
    ["config_detection_anticheat_known_global"] = "Variable globale de cheat",
    ["config_detection_anticheat_known_cheat_custom"] = "Cheat Connu",
    ["config_detection_anticheat_known_function"] = "Fonction globale de cheat",
    ["config_detection_anticheat_manipulate_ac"] = "Manipule l'anticheat",
    ["config_detection_anticheat_autoclick_fast"] = "Vitesse de clic inhumaine",
    ["config_detection_anticheat_autoclick_fastlong"] = "Vitesse de clic rapide sur longue durée",
    ["config_detection_anticheat_autoclick_robotic"] = "Cohérence inhumaine des clics",
    ["config_detection_anticheat_aimbot_snap"] = "Accrochage instantané d'aimbot en 1 tick",
    ["config_detection_anticheat_aimbot_move"] = "Mouvement suspect d'aimbot",
    ["config_detection_anticheat_aimbot_contr"] = "Mouvement contradictoire d'aimbot",
    ["config_detection_security_privilege_escalation"] = "Escalade de privilèges vers un groupe d'utilisateurs protégé",
    ["config_detection_admin_manual"] = "Ban manuel par admin ou console",
    /*
        Notifications
    */
    ["menu_notify_hello_staff"] = "Ce serveur est protégé par Nova Defender.\nVous êtes catégorisé comme staff.",
    ["menu_notify_hello_protected"] = "Ce serveur est protégé par Nova Defender.\nVous êtes catégorisé comme protégé.",
    ["menu_notify_hello_menu"] = "Ouvrir le menu avec !nova.",

    ["notify_admin_unban"] = "Débannissement réussi de %s. Le ban sera supprimé lorsque le joueur se reconnecte au serveur.",
    ["notify_admin_ban"] = "Bannissement réussi de %s. Le joueur sera banni s'il rejoint le serveur la prochaine fois.",
    ["notify_admin_ban_online"] = "Admin %s a banni %s. Le joueur sera banni dans quelques secondes.",
    ["notify_admin_ban_offline"] = "Admin %s a banni %s. Le joueur sera banni s'il rejoint le serveur la prochaine fois.",
    ["notify_admin_ban_fail"] = "Ban de %s échoué: %q",
    ["notify_admin_kick"] = "Admin %s a expulsé %s du serveur",
    ["notify_admin_reconnect"] = "Admin %s a reconnecté %s",
    ["notify_admin_quarantine"] = "Admin %s a mis %s en quarantaine réseau. Il ne sera pas en mesure d'interagir avec quoi que ce soit sur le serveur.",
    ["notify_admin_unquarantine"] = "Admin %s a retiré %s de la quarantaine réseau",
    ["notify_admin_no_permission"] = "Vous n'avez pas les permissions suffisantes pour faire cela",
    ["notify_admin_client_not_connected"] = "Le joueur est hors ligne",
    ["notify_admin_already_inspecting"] = "Vous inspectez déjà un autre joueur",

    ["notify_anticheat_detection"] = "Détection anticheat %q sur %s. Raison: %q",
    ["notify_anticheat_detection_action"] = "Anticheat: %q",
   
    ["notify_anticheat_issue_fprofiler"] = "Si l'anticheat est actif, le profilage côté client ne fonctionnera pas!",

    ["notify_aimbot_detection"] = "Détection d'aimbot %q sur %s. Raison: %q",
    ["notify_aimbot_detection_action"] = "Aimbot: %q",

    ["notify_anticheat_verify"] = "L'anticheat côté client de %s ne pouvait pas être chargé. Cela pourrait également être causé par une connexion lente.",
    ["notify_anticheat_verify_action"] = "L'anticheat côté client ne pouvait pas être chargé. Cela pourrait également être causé par une connexion lente.",

    ["notify_banbypass_ban_fail"] = "Impossible de bannir %s pour %q: %s",
    ["notify_banbypass_kick_fail"] = "Impossible d'expulser %s pour %q: %s",

    ["notify_banbypass_bypass_fingerprint_match"] = "%s pourrait contourner un ban: L'empreinte correspond au SteamID banni %s | Confiance: %d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "Pourrait contourner un ban: L'empreinte correspond au SteamID banni %s | Confiance: %d%%",

    ["notify_banbypass_familyshare"] = "Pourrait contourner un ban: Compte de famille partagée du SteamID banni %s",
    ["notify_banbypass_familyshare_action"] = "Pourrait contourner un ban: Compte de famille partagée du SteamID banni %s",

    ["notify_banbypass_clientcheck"] = "Pourrait contourner un ban: Preuves trouvées pour un contournement de ban de %s | Preuves: %s",
    ["notify_banbypass_clientcheck_action"] = "Pourrait contourner un ban: Preuves trouvées pour un contournement de ban de %s | Preuves: %s",

    ["notify_banbypass_ipcheck"] = "Pourrait contourner un ban: IP identique au joueur banni %s",
    ["notify_banbypass_ipcheck_action"] = "Pourrait contourner un ban: IP identique au joueur banni %s",

    ["notify_networking_exploit"] = "%s a utilisé un exploit réseau: %q",
    ["notify_networking_exploit_action"] = "Utilisation d'exploit réseau: %q",
    ["notify_networking_backdoor"] = "%s a utilisé une porte dérobée réseau: %q",
    ["notify_networking_backdoor_action"] = "Utilisation de porte dérobée réseau: %q",

    ["notify_networking_spam"] = "%s spamme les netmessages (%d/%ds) (%d autorisé).",
    ["notify_networking_spam_action"] = "Spam de netmessages (%d/%ds) (%d autorisé).",
    ["notify_networking_limit"] = "%s a dépassé la limite de %d netmessages par %d secondes.",
    ["notify_networking_limit_drop"] = "Ignorance des netmessages de %s car il a dépassé la limite de %d netmessages par %d secondes.",

    ["notify_networking_dos"] = "%s a causé un lag serveur. Durée: %s en %d secondes",
    ["notify_networking_dos_action"] = "Causant du lag serveur. Durée: %s en %d secondes",

    ["notify_networking_dos_crash"] = "%s a essayé de crasher le serveur avec un grand message. Message: %q, Taille: %s, Ratio de compression: %s",
    ["notify_networking_dos_crash_action"] = "Tentative de crash du serveur avec un grand message. Message: %q, Taille: %s, Ratio de compression: %s",

    ["notify_networking_restricted"] = "%s a essayé d'envoyer le netmessage %q restreint à %q. Cela ne peut pas être fait sans manipulation.",
    ["notify_networking_restricted_action"] = "Envoyé du netmessage %q que seul %q est autorisé à envoyer. Cela ne peut pas être fait sans manipulation.",

    ["notify_networking_screenshot_failed_multiple"] = "Capture d'écran de %s échouée: Vous ne pouvez prendre qu'une capture d'écran à la fois",
    ["notify_networking_screenshot_failed_progress"] = "Capture d'écran de %s échouée: Autre capture d'écran de ce joueur en cours.",
    ["notify_networking_screenshot_failed_timeout"] = "Capture d'écran de %s échouée: Aucune capture d'écran reçue du client.",
    ["notify_networking_screenshot_failed_empty"] = "Capture d'écran de %s échouée: La réponse est vide. Cela peut se produire si elle a été bloquée par un cheat ou si le joueur est dans le menu d'échappement.",

    ["notify_networking_auth_failed"] = "%s ne pouvait pas s'authentifier avec le serveur. Cela pourrait également être causé par une connexion lente.",
    ["notify_networking_auth_failed_action"] = "Impossible de s'authentifier avec le serveur. Cela pourrait également être causé par une connexion lente.",
    ["notify_networking_sendlua_failed"] = "%s bloque l'exécution du code Nova Defender. Cela pourrait également être causé par une connexion lente.",
    ["notify_networking_sendlua_failed_action"] = "Bloque l'exécution du code Nova Defender. Cela pourrait également être causé par une connexion lente.",

    ["notify_networking_issue_gm_express_not_installed"] = "gm_express n'est pas installé sur le serveur. Plus de détails dans l'onglet 'Santé'.",

    ["notify_networking_vpn"] = "%s utilise un VPN: %s",
    ["notify_networking_vpn_action"] = "Utilisation d'un VPN: %s",
    ["notify_networking_country"] = "%s vient d'un pays non autorisé. %s",
    ["notify_networking_country_action"] = "Venant d'un pays non autorisé. %s",

    ["notify_security_privesc"] = "%s a reçu le groupe d'utilisateurs %q qui est réservé à la liste blanche.",
    ["notify_security_privesc_action"] = "A reçu le groupe d'utilisateurs %q qui est réservé à la liste blanche.",

    ["notify_functions_action"] = "Quelle action devrions-nous prendre contre %s?\nRaison: %s",
    ["notify_functions_action_notify"] = "Admin %s a pris l'action suivante contre la détection %q de %s: %q.",
    ["notify_functions_allow_success"] = "Détection exclue avec succès.",
    ["notify_functions_allow_failed"] = "Il n'est pas possible d'exclure cette détection.",

    ["notify_custom_extension_ddos_protection_attack_started"] = "Attaque DDoS détectée. Ouvrez le menu avec !nova pour le statut en direct",
    ["notify_custom_extension_ddos_protection_attack_stopped"] = "Attaque DDoS arrêtée. Ouvrez le menu avec !nova pour les détails",
    /*
        Health
    */
    ["health_check_gmexpress_title"] = "Module gm_express",
    ["health_check_gmexpress_desc"] = "Amélioration massive des performances, en particulier pour les serveurs plus grands. Créé par CFC Servers.",
    ["health_check_gmexpress_desc_long"] =
[[Au lieu d'envoyer de grandes quantités de données via les netmessages intégrés (lent),
elles sont transférées aux clients via HTTPS en utilisant un fournisseur externe (gmod.express).
Cela accélère le temps de chargement des clients et réduit la charge sur le serveur.
Cependant, cette option dépend de gmod.express. Si cet hôte ne peut pas être atteint,
l'authentification des clients échoue. Les nouveaux clients qui ne peuvent pas se connecter à gmod.express,
reviennent aux netmessages conventionnels.

Pour installer, allez à: https://github.com/CFC-Servers/gm_express.
1. Cliquez sur "Code" et téléchargez le fichier .zip.
2. Décompressez le fichier .zip dans le répertoire "/garrysmod/addons".
3. Redémarrez votre serveur.
4. Activez l'option "Activer gm_express" dans l'onglet "Réseau".

Ce service peut également être auto-hébergé.
Voir: https://github.com/CFC-Servers/gm_express_service]],
    ["health_check_seversecure_title"] = "Module Serversecure",
    ["health_check_seversecure_desc"] = "Un module qui atténue les exploits sur le moteur Source. Créé par danielga.",
    ["health_check_seversecure_desc_long"] =
[[Sans ce module, il pourrait être possible de crasher facilement votre serveur.
Il peut limiter le nombre de paquets que votre serveur acceptera et les valider.

Pour installer, allez à https://github.com/danielga/gmsv_serversecure.
1. Allez à Releases et téléchargez le fichier .dll pour le système d'exploitation de votre serveur.
2. Créez un dossier "garrysmod/lua/bin" s'il n'existe pas.
3. Placez le fichier .dll dans votre dossier "/garrysmod/lua/bin".
4. Sur Github, téléchargez le fichier "serversecure.lua" ("/include/modules").
5. Placez ce fichier dans le dossier "/garrysmod/lua/includes/modules".
6. Redémarrez votre serveur.

Si vous souhaitez que Nova Defender configure le module pour vous, activez l'option
"Configurer Serversecure automatiquement" dans l'onglet "Exploits".]],
    ["health_check_reqwest_title"] = "Module Reqwest pour l'intégration Discord",
    ["health_check_reqwest_desc"] = "Un module qui vous permet d'utiliser des requêtes HTTP. Créé par WilliamVenner (Billy).",
    ["health_check_reqwest_desc_long"] =
[[Sans ce module, les webhooks Discord ne peuvent pas fonctionner.

Pour installer, allez à https://github.com/WilliamVenner/gmsv_reqwest.
1. Allez à l'onglet Releases et téléchargez le fichier .dll pour le système d'exploitation de votre serveur.
2. Créez un dossier "garrysmod/lua/bin" s'il n'existe pas.
3. Placez le fichier .dll dans le dossier "/garrysmod/lua/bin".
4. Redémarrez votre serveur.

Si vous souhaitez que Nova Defender envoie automatiquement des webhooks, activez l'option
"Webhook Discord" dans l'onglet "Discord".]],

    ["discord_webhook_enabled"] = "Activer Webhook Discord",
    ["discord_webhook_url"] = "Collez l'URL de votre webhook Discord ici.",

    ["health_check_exploits"] = "Addons Exploitables",
    ["health_check_exploits_desc"] = "Addons connus pour être exploitables.",
    ["health_check_exploits_title"] = "Addons avec exploits connus",
    ["health_check_exploits_desc"] = "Liste des netmessages des addons connus pour être exploitables.",
    ["health_check_exploits_desc_long"] =
[[Un netmessage permet la communication entre client et serveur.
Cependant, ces messages peuvent être facilement manipulés par un client.
Donc, si le serveur ne vérifie pas si le client est autorisé à envoyer ce message du tout,
des trous de sécurité exploitables (glitch d'argent, crash serveur, droits d'admin) peuvent se produire.

Tous les noms énumérés des netmessages peuvent ou pourraient être exploités.
Il n'y a aucune garantie que cette vulnérabilité existe toujours.
Aussi, il peut y avoir des netmessages vulnérables qui ne sont pas énumérés ici.

1. Mettez à jour vos addons régulièrement
2. Remplacez les addons obsolètes/non supportés par des nouveaux
3. Si vous êtes familier avec Lua, vérifiez manuellement les netmessages affectés]],
    ["health_check_backdoors_title"] = "Portes Dérobées",
    ["health_check_backdoors_desc"] = "Les portes dérobées peuvent être sur le serveur pour donner à un attaquant un accès non désiré.",
    ["health_check_backdoors_desc_long"] =
[[Les portes dérobées peuvent être chargées sur un serveur de plusieurs façons, entre autres:
1. Addons malveillants de l'atelier
2. Une personne vous demande de télécharger un fichier Lua sur le serveur
qui a été fait "spécialement pour vous"...
3. Un développeur avec accès à votre serveur a construit une porte dérobée pour lui-même
4. Le serveur lui-même a été compromis (vulnérabilité du système d'exploitation,
vulnérabilité du logiciel)

Façons de supprimer une porte dérobée:
1. Si disponible, vérifiez le chemin donné (si le chemin commence par 'lua/', c'est probablement de l'atelier)
2. Analysez votre serveur avec par exemple https://github.com/THABBuzzkill/nomalua
3. Supprimez tous les scripts que vous avez récemment ajoutés et vérifiez si ce message réapparaît
4. Téléchargez tous les fichiers de votre serveur et faites une recherche textuelle pour la porte dérobée énumérée
5. FAÇON DIFFICILE: supprimez TOUS les addons jusqu'à ce que ce message cesse d'apparaître, puis ajoutez-les
l'un après l'autre et vérifiez l'addon où il réapparaît.]],
    ["health_check_mysql_pass_title"] = "Mot de Passe de Base de Données Faible",
    ["health_check_mysql_pass_desc"] = "Le mot de passe de la base de données pour Nova Defender est trop faible.",
    ["health_check_mysql_pass_desc_long"] =
[[Si vous utilisez MySQL, vous avez besoin d'un mot de passe fort.
Même s'il n'est pas accessible à partir d'Internet.

Comment sécuriser votre base de données:
1. Un mot de passe de base de données fort n'est rien que vous devez mémoriser
2. Utilisez un générateur de mot de passe pour créer un mot de passe aléatoire
3. Utilisez un mot de passe différent pour chaque base de données
4. Utilisez une base de données différente pour chaque addon (ou permissions de base de données appropriées)]],
    ["health_check_nova_errors_title"] = "Erreurs Nova Defender",
    ["health_check_nova_errors_desc"] = "Erreurs générées par Nova Defender",
    ["health_check_nova_errors_desc_long"] =
[[Eh bien, lisez-les. Veuillez me contacter si vous ne savez pas comment résoudre un problème donné.
Si chaque message d'erreur vous est concluant et n'affecte pas la fonctionnalité,
vous pouvez ignorer ce message en toute sécurité.]],
    ["health_check_nova_vpn_title"] = "Protection VPN Nova Defender",
    ["health_check_nova_vpn_desc"] = "La protection VPN doit être configurée pour bloquer les pays et détecter les VPN.",
    ["health_check_nova_vpn_desc_long"] =
[[Dans l'onglet "Réseau", vous devez insérer votre clé API,
que vous obtenez après l'enregistrement gratuit sur ipqualityscore.com.
Avec cela, Nova Defender peut alors examiner les adresses IP via cette page.
1. allez à https://www.ipqualityscore.com/create-account
2. copiez votre clé API ici https://www.ipqualityscore.com/user/settings
3. collez-la dans l'onglet "Réseau" sous "Clé API VPN"]],
    ["health_check_nova_steamapi_title"] = "Protection du Profil Steam Nova Defender",
    ["health_check_nova_steamapi_desc"] = "La protection du profil Steam doit être configurée pour détecter les profils suspects des joueurs.",
    ["health_check_nova_steamapi_desc_long"] =
[[Dans l'onglet "Système de Ban", vous devez insérer votre clé API,
1. allez à https://steamcommunity.com/dev/apikey
2. entrez le nom de domaine de votre serveur
3. copiez votre clé API
4. collez-la dans l'onglet "Système de Ban" sous "Clé API Steam"]],
    ["health_check_nova_anticheat_title"] = "Extension Anticheat Nova Defender",
    ["health_check_nova_anticheat_desc"] = "L'anticheat a besoin d'une extension pour détecter plus de cheats.",
    ["health_check_nova_anticheat_desc_long"] =
    [[Actuellement, seuls quelques cheats simples sont détectés. Comme le code source de Nova Defender est ouvert
et visible, les cheats peuvent être facilement modifiés pour être indétectables.
Par conséquent, les propriétaires de serveur peuvent demander l'extension de l'anticheat,
qui détecte également les cheats externes, nouveaux ou payants par leur nom.
Cliquez sur le bouton correspondant en haut du menu ou rejoignez notre Discord pour en savoir plus.]],
    ["health_check_nova_anticheat_version_title"] = "Ancienne version d'Anticheat Nova Defender",
    ["health_check_nova_anticheat_version_desc"] = "L'anticheat n'est pas à jour.",
    ["health_check_nova_anticheat_version_desc_long"] =
    [[Veuillez télécharger la dernière version depuis GitHub:
https://github.com/Freilichtbuehne/nova-defender-anticheat/releases/latest]],
    ["health_check_nova_ddos_protection_title"] = "Extension de Protection DDoS Nova Defender",
    ["health_check_nova_ddos_protection_desc"] = "Défendez votre serveur Linux contre les attaques DDoS.",
    ["health_check_nova_ddos_protection_desc_long"] =
    [[Protection DDoS basée sur l'hôte pour les serveurs Linux.
Les propriétaires de serveur peuvent demander cette extension.
Cliquez sur le bouton correspondant en haut du menu ou rejoignez notre Discord pour en savoir plus.]],
    ["health_check_nova_ddos_protection_version_title"] = "Ancienne version de la Protection DDoS Nova Defender",
    ["health_check_nova_ddos_protection_version_desc"] = "La protection DDoS n'est pas à jour.",
    ["health_check_nova_ddos_protection_version_desc_long"] =
[[Veuillez télécharger la dernière version depuis GitHub:
https://github.com/Freilichtbuehne/nova-defender-ddos/releases/latest]],
    /*
        Server
    */
    ["server_general_suffix"] = "Texte à ajouter à chaque message d'expulsion, de ban ou de rejet. Par exemple votre Teamspeak, Discord ou tout autre site d'assistance.",

    ["server_access_maintenance_enabled"] = "Mode Maintenance:\nSeuls les joueurs protégés et les joueurs avec mot de passe peuvent rejoindre le serveur.",
    ["server_access_maintenance_allowed"] = "Qui peut rejoindre le serveur en mode maintenance? Les joueurs protégés sont toujours autorisés et n'ont pas besoin de mot de passe.",
    ["server_access_maintenance_password"] = "Mot de passe pour le mode maintenance, si vous avez sélectionné 'mot de passe' dans le paramètre ci-dessus.",
    ["server_access_maintenance_reason"] = "Raison à afficher à un client qui tente de se connecter pendant la maintenance.",
    ["server_access_password_lock"] = "Verrouiller les mauvaises tentatives:\nSi un client entre un mauvais mot de passe trop souvent, toutes les tentatives suivantes seront bloquées.",
    ["server_access_password_lock_reason"] = "Raison à afficher à un client s'il a entré un mauvais mot de passe trop souvent.",
    ["server_access_password_max_attempts"] = "Nombre maximum de tentatives avant verrouillage",

    ["server_lockdown_enabled"] = "Mode Verrouillage:\nSEUL le staff, les joueurs protégés et de confiance peuvent rejoindre le serveur. Utilisez ceci lorsque de nombreux nouveaux comptes sont créés pour rejoindre le serveur à des fins de trolling, griefing ou crash. Les joueurs déjà sur le serveur ne sont pas affectés. Assurez-vous de d'abord définir qui est de confiance dans le fichier de configuration de Nova Defender. Ceci ne doit être utilisé que brièvement.",
    ["server_lockdown_reason"] = "Raison d'expulser un joueur pendant le mode verrouillage s'il n'est pas protégé, staff ou de confiance.",
    /*
        Admin Menu
    */
    ["menu_title_banbypass"] = "Système de Ban",
    ["menu_title_health"] = "Santé",
    ["menu_title_network"] = "Réseau",
    ["menu_title_security"] = "Sécurité",
    ["menu_title_menu"] = "Menu",
    ["menu_title_anticheat"] = "Anticheat",
    ["menu_title_detections"] = "Détections",
    ["menu_title_bans"] = "Bans",
    ["menu_title_exploit"] = "Exploits",
    ["menu_title_players"] = "Joueurs En Ligne",
    ["menu_title_server"] = "Serveur",
    ["menu_title_inspection"] = "Inspecter les Joueurs",
    ["menu_title_ddos"] = "Protection DDoS",
    ["menu_title_discord"] = "Discord",

    ["menu_desc_banbypass"] = "Techniques pour empêcher les joueurs de contourner un ban Nova Defender",
    ["menu_desc_network"] = "Restreindre, contrôler et enregistrer l'activité réseau",
    ["menu_desc_security"] = "Protéger contre les escalades de privilèges des utilisateurs",
    ["menu_desc_menu"] = "Contrôle des notifications et du menu admin",
    ["menu_desc_anticheat"] = "Activer ou désactiver les fonctionnalités de l'anticheat côté client selon vos souhaits",
    ["menu_desc_bans"] = "Trouver, bannir ou débannir les joueurs",
    ["menu_desc_exploit"] = "Prévenir les exploits spécifiques dans les mécaniques de jeu",
    ["menu_desc_players"] = "Tous les joueurs actuellement en ligne",
    ["menu_desc_health"] = "Voir l'état de votre serveur d'un coup d'oeil",
    ["menu_desc_detections"] = "Toutes les détections en attente qui doivent être examinées",
    ["menu_desc_server"] = "Gérer l'accès à votre serveur",
    ["menu_desc_inspection"] = "Exécuter des commandes sur les joueurs et rechercher des fichiers",
    ["menu_desc_ddos"] = "Statut en direct de la Protection DDoS installée sur le serveur Linux",
    ["menu_desc_discord"] = "Gérer les messages webhook vers Discord",

    ["menu_elem_banbypass"] = "Système de Ban",
    ["menu_elem_network"] = "Réseau",
    ["menu_elem_security"] = "Sécurité",
    ["menu_elem_menu"] = "Menu",
    ["menu_elem_anticheat"] = "Anticheat",
    ["menu_elem_bans"] = "Bans",
    ["menu_elem_exploit"] = "Exploits",
    ["menu_elem_players"] = "Joueurs En Ligne",
    ["menu_elem_health"] = "Santé",
    ["menu_elem_detections"] = "Détections En Attente",
    ["menu_elem_server"] = "Accès Serveur",
    ["menu_elem_inspection"] = "Inspecter les Joueurs",
    ["menu_elem_ddos"] = "Protection DDoS",
    ["menu_elem_discord"] = "Webhook Discord",

    ["menu_elem_extensions"] = "Extensions:",
    ["menu_elem_disabled"] = "(désactivé)",
    ["menu_elem_outdated"] = "(obsolète)",
    ["menu_elem_add"] = "Ajouter",
    ["menu_elem_edit"] = "Modifier",
    ["menu_elem_unban"] = "Débannir",
    ["menu_elem_ban"] = "Bannir",
    ["menu_elem_kick"] = "Expulser",
    ["menu_elem_reconnect"] = "Reconnecter",
    ["menu_elem_quarantine"] = "Quarantaine",
    ["menu_elem_unquarantine"] = "Retirer la Quarantaine",
    ["menu_elem_verify_ac"] = "Vérifier Anticheat",
    ["menu_elem_screenshot"] = "Capture d'écran",
    ["menu_elem_detections"] = "Détections",
    ["menu_elem_indicators"] = "Indicateurs",
    ["menu_elem_commands"] = "Commandes",
    ["menu_elem_netmessages"] = "Netmessages",
    ["menu_elem_ip"] = "Détails IP",
    ["menu_elem_profile"] = "Profil Steam",
    ["menu_elem_rem"] = "Supprimer",
    ["menu_elem_reload"] = "Recharger",
    ["menu_elem_advanced"] = "Options Avancées",
    ["menu_elem_miss_options"] = "Manquer des options?",
    ["menu_elem_copy"] = "Copier",
    ["menu_elem_save"] = "Enregistrer sur le disque",
    ["menu_elem_saved"] = "Enregistré",
    ["menu_elem_settings"] = "Paramètres:",
    ["menu_elem_general"] = "Général:",
    ["menu_elem_discord"] = "Rejoignez notre Discord!",
    ["menu_elem_close"] = "Fermer",
    ["menu_elem_cancel"] = "Annuler",
    ["menu_elem_filter_by"] = "Filtrer par:",
    ["menu_elem_view"] = "Affichage",
    ["menu_elem_filter_text"] = "Texte du Filtre:",
    ["menu_elem_reason"] = "Raison",
    ["menu_elem_comment"] = "Commentaire",
    ["menu_elem_bans"] = "Bans (limité à 150 entrées):",
    ["menu_elem_new_value"] = "Nouvelle valeur",
    ["menu_elem_submit"] = "Soumettre",
    ["menu_elem_no_bans"] = "Aucun ban trouvé",
    ["menu_elem_no_data"] = "Aucune donnée disponible",
    ["menu_elem_checkboxtext_checked"] = "Actif",
    ["menu_elem_checkboxtext_unchecked"] = "Inactif",
    ["menu_elem_search_term"] = "Terme de recherche...",
    ["menu_elem_unavailable"] = "Indisponible",
    ["menu_elem_failed"] = "Échoué",
    ["menu_elem_passed"] = "Réussi",
    ["menu_elem_health_overview"] = "Vérifications:\n • Total: %d\n • Réussi: %d\n • Échoué: %d",
    ["menu_elem_health_most_critical"] = "Le Plus Critique:\n",
    ["menu_elem_mitigation"] = "Comment réparer?",
    ["menu_elem_list"] = "Détails",
    ["menu_elem_ignore"] = "Ignorer",
    ["menu_elem_reset"] = "Réinitialiser",
    ["menu_elem_reset_all"] = "Réinitialiser tous les contrôles ignorés:",
    ["menu_elem_player_count"] = "Joueurs en ligne: %d",
    ["menu_elem_foundindicator"] = "Trouvé %d Indicateur",
    ["menu_elem_foundindicators"] = "Trouvé %d Indicateurs",
    ["menu_elem_criticalindicators"] = "Indicateurs Critiques!",
    ["menu_elem_notauthed"] = "Authentification...",

    ["menu_elem_mitigated"] = "Atténué",
    ["menu_elem_unmitigated"] = "Non Atténué",
    ["menu_elem_next"] = "Suivant",
    ["menu_elem_prev"] = "Précédent",
    ["menu_elem_clear"] = "Supprimer les atténués",
    ["menu_elem_clear_all"] = "Supprimer tous",
    ["menu_elem_delete"] = "Supprimer",
    ["menu_elem_stats"] = "Entrées: %d",
    ["menu_elem_page"] = "Page: %d",

    ["menu_elem_nofocus"] = "Pas de focus",
    ["menu_elem_focus"] = "A le focus",
    ["menu_elem_connect"] = "Connecter",
    ["menu_elem_disconnect"] = "Déconnecter",
    ["menu_elem_input_command"] = "Entrez et exécutez le code Lua...",
    ["menu_elem_select_player"] = "Sélectionner un joueur",
    ["menu_elem_disconnected"] = "Déconnecté",
    ["menu_elem_exec_clientopen"] = "Le client a ouvert la connexion",
    ["menu_elem_exec_clientclose"] = "Le client a fermé la connexion",
    ["menu_elem_exec_error"] = "Erreur interne du serveur",
    ["menu_elem_exec_help"] = [[Application:
• Utilisez ceci si vous êtes familier avec Lua
• Conçu à des fins de débogage et de chasse aux cheats Lua

Général:
• Entrez le code Lua et appuyez sur Entrée pour l'exécuter sur le client sélectionné
• Les erreurs Lua seront affichées dans la console
• Les erreurs Lua sont invisibles pour le client

Affichage des valeurs:
• Pour obtenir la valeur d'un tableau ou d'une chaîne, utilisez "print()" ou "PrintTable()"
• L'exécution de "print" et "PrintTable" n'est pas visible pour le client
• L'exécution de "print" et "PrintTable" sera redirigée vers votre console
• Exemple 1: "PrintTable(hook.GetTable())"
• Exemple 2: "local nick = LocalPlayer():Nick() print(nick)"

Historique:
• Utilisez HAUT et BAS pour naviguer dans l'historique
• Utilisez TAB pour l'autocomplétion

Sécurité:
• Exécutez le code Lua de manière responsable
• Le code exécuté pourrait être visible pour le client
• Le code exécuté pourrait être bloqué ou manipulé par le client]],
    ["menu_elem_help"] = "Aide",
    ["menu_elem_filetime"] = "Dernière modification du fichier: %s",
    ["menu_elem_filesize"] = "Taille du fichier: %s",
    ["menu_elem_download"] = "Télécharger",
    ["menu_elem_download_confirm"] = "Êtes-vous sûr de télécharger le fichier suivant?\n%q",
    ["menu_elem_download_progress"] = "Chargement du chunk %i/%i...",
    ["menu_elem_download_finished_part"] = "Le fichier a été partiellement téléchargé et enregistré dans votre dossier de données local Garry's Mod:\n%q",
    ["menu_elem_download_finished"] = "Le fichier a été téléchargé et enregistré dans votre dossier de données local Garry's Mod:\n%q",
    ["menu_elem_download_failed"] = "Téléchargement échoué: %q",
    ["menu_elem_download_started"] = "Téléchargement du fichier: %q",
    ["menu_elem_download_confirmbutton"] = "Télécharger",
    ["menu_elem_canceldel"] = "Annuler et supprimer",

    ["menu_elem_ddos_active"] = "Serveur sous attaque DDoS!",
    ["menu_elem_ddos_inactive"] = "Protection DDoS active | Aucune attaque active",
    ["menu_elem_ddos_duration"] = "Durée: %s",
    ["menu_elem_ddos_avg"] = "Réception Moy: %s",
    ["menu_elem_ddos_max"] = "Réception Max: %s",
    ["menu_elem_ddos_stopped"] = "Arrêté à: %s",
    ["menu_elem_ddos_stats"] = "Statistiques de la dernière attaque:",
    ["menu_elem_ddos_cpu_util"] = "Utilisation CPU",
    ["menu_elem_ddos_net_util"] = "Utilisation Réseau",

    ["indicator_pending"] = "Le joueur n'a pas encore envoyé ses indicateurs au serveur. Soit il les bloque, soit il a besoin de plus de temps.",
    ["indicator_install_fresh"] = "Le joueur a récemment installé ce jeu",
    ["indicator_install_reinstall"] = "Le joueur a récemment réinstallé ce jeu",
    ["indicator_advanced"] = "Le joueur utilise des commandes de débogage/développeur (il pourrait savoir ce qu'il fait...)",
    ["indicator_first_connect"] = "Première connexion à ce serveur (si le jeu n'a pas été réinstallé)",
    ["indicator_cheat_hotkey"] = "Le joueur a appuyé sur une touche (INSER, ACCUEIL, PAGEUP, PAGEDOWN) qui est souvent utilisée pour ouvrir les menus de cheat",
    ["indicator_cheat_menu"] = "Le joueur a ouvert un menu en utilisant l'une des touches INSER, ACCUEIL, PAGEUP ou PAGEDOWN",
    ["indicator_bhop"] = "Le joueur a une liaison de bunnyhop sur sa molette de souris (comme 'bind mwheelup +jump')",
    ["indicator_memoriam"] = "Le joueur a utilisé le cheat 'Memoriam' par le passé ou le fait actuellement",
    ["indicator_multihack"] = "Le joueur a utilisé le cheat 'Garrysmod 64-bit Visuals Multihack Reborn' par le passé ou le fait actuellement",
    ["indicator_fenixmulti"] = "Le joueur a utilisé le cheat 'FenixMulti' par le passé ou le fait actuellement",
    ["indicator_interstate"] = "Le joueur a utilisé le cheat 'interstate editor' par le passé ou le fait actuellement",
    ["indicator_exechack"] = "Le joueur a utilisé le cheat payant 'exechack' par le passé ou le fait actuellement",
    ["indicator_fatalmenu"] = "Le joueur a utilisé le cheat 'FatalMenu' par le passé ou le fait actuellement",
    ["indicator_imgui"] = "Le joueur a un fichier imgui.ini dans son dossier Garry's Mod. Utilisé par de nombreux cheats externes pour stocker les paramètres.",
    ["indicator_imgui_active"] = "Le joueur a un fichier imgui.ini dans son dossier Garry's Mod qui a été créé après le lancement de son jeu. Utilisé par de nombreux cheats externes pour stocker les paramètres.",
    ["indicator_banned"] = "Le joueur a été banni par Nova Defender sur un autre serveur",
    ["indicator_lua_binaries"] = "Le joueur a des fichiers DLL dans le dossier 'garrysmod/lua/bin'. Les cheats y sont souvent placés. Les fichiers peuvent être consultés dans l'onglet 'Inspection'. Ces fichiers ont dû être créés manuellement par le joueur.",
    ["indicator_profile_familyshared"] = "Le joueur a un compte partagé en famille",
    ["indicator_profile_friend_banned"] = "Un ami Steam de ce joueur a été banni par Nova Defender",
    ["indicator_profile_recently_created"] = "Le profil Steam a été créé au cours des 7 derniers jours",
    ["indicator_profile_nogames"] = "Le joueur n'a acheté aucun jeu sur son profil Steam",
    ["indicator_profile_new_player"] = "Le joueur n'a pas joué à Garry's Mod pendant plus de 2 heures au total",
    ["indicator_profile_vac_banned"] = "Le joueur a déjà reçu un ban VAC",
    ["indicator_profile_vac_bannedrecent"] = "Le joueur a déjà reçu un ban VAC au cours des 5 derniers mois",
    ["indicator_profile_community_banned"] = "Le joueur a déjà reçu un ban communautaire de Steam",
    ["indicator_profile_not_configured"] = "Le joueur n'a même pas configuré son compte Steam",
    ["indicator_scenario_bypass_account"] = "Les indicateurs suggèrent que ce joueur a spécialement créé un nouveau compte Steam. Voir l'onglet du menu 'Joueurs En Ligne'.",
    ["indicator_scenario_cheatsuspect"] = "Les indicateurs suggèrent que ce joueur a triché. Voir l'onglet du menu 'Joueurs En Ligne'",
    ["indicator_scenario_sum"] = "Le joueur est suspect car il répond à un nombre élevé d'indicateurs typiques. Voir l'onglet du menu 'Joueurs En Ligne'",

    ["internal_reason"] = "Raison Interne",
    ["banned"] = "Banni",
    ["status"] = "Statut",
    ["reason"] = "Raison",
    ["unban_on_sight"] = "Débannir à vue",
    ["ip"] = "IP",
    ["ban_on_sight"] = "Bannir à vue",
    ["time"] = "Heure",
    ["comment"] = "Commentaire",
    ["steamid"] = "SteamID32",
    ["steamid64"] = "SteamID64",
    ["usergroup"] = "Groupe d'Utilisateurs",
    ["familyowner"] = "Propriétaire de Partage Familial",
    ["group"] = "Groupe",
    ["kick"] = "Expulser",
    ["allow"] = "Désactiver cette détection",
    ["reconnect"] = "Reconnecter",
    ["ban"] = "Bannir",
    ["notify"] = "Notifier",
    ["nothing"] = "Rien",
    ["set"] = "Réinitialiser",
    ["disable"] = "Désactiver à l'avenir",
    ["ignore"] = "Ignorer temporairement",
    ["dont_care"] = "Ne pas me soucier",
    ["action_taken_at"] = "Action prise à",
    ["action_taken_by"] = "Action prise par",

    ["sev_none"] = "Aucun",
    ["sev_low"] = "Faible",
    ["sev_medium"] = "Moyen",
    ["sev_high"] = "Élevé",
    ["sev_critical"] = "Critique",

    ["embed_detection_details"] = "Détails de la Détection",
}

// DO NOT CHANGE ANYTHING BELOW THIS
if SERVER then
    Nova    ["languages_" .. lang] = function() return phrases end
else
    NOVA_SHARED = NOVA_SHARED or {}
    NOVA_SHARED    ["languages_" .. lang] = phrases
end
