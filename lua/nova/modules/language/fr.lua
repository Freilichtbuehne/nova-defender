local lang = "fr"

local phrases = {
    /*
        Notifications
    */
    ["menu_logging_debug"] = "Mode Débogage:\nCela imprime des journaux supplémentaires dans la console du serveur.",
    ["menu_notify_timeopen"] = "Durée d'affichage de la notification en secondes.",
    ["menu_notify_showstaff"] = "Afficher les notifications au personnel.",
    ["menu_notify_showinfo"] = "Afficher les notifications d'information.",
    ["menu_access_player"] = "Le personnel a accès à l'onglet 'Joueurs en ligne' et peut y effectuer des actions. Le personnel ne peut pas cibler les joueurs protégés.",
    ["menu_access_staffseeip"] = "Le personnel peut voir les adresses IP des joueurs.",
    ["menu_access_detections"] = "Le personnel a accès à l'onglet 'Détections'.",
    ["menu_access_bans"] = "Le personnel a accès à l'onglet 'Bannissements'.",
    ["menu_access_health"] = "Le personnel a accès à l'onglet 'Santé'.",
    ["menu_access_inspection"] = "Le personnel a accès à l'onglet 'Inspection des joueurs'.",
    ["menu_access_ddos"] = "Le personnel a accès à l'onglet 'DDoS'.",
    
    ["menu_action_timeopen"] = "Durée d'affichage de l'invite de punition en secondes.",
    ["menu_action_showstaff"] = "Demander au personnel une action de punition si aucun joueur protégé n'est présent (ou AFK).",

    /*
        Réseau
    */
    ["networking_concommand_logging"] = "Journal des commandes:\nJournaliser chaque commande console exécutée par les clients et le serveur.",
    ["networking_concommand_dump"] = "Dump des commandes:\nImprimer toutes les commandes qu'un joueur a exécutées dans la console lorsqu'il se déconnecte. Cela peut augmenter rapidement la taille de vos journaux.",
    ["networking_netcollector_dump"] = "Dump des messages réseau:\nImprimer tous les messages réseau qu'un joueur a envoyés au serveur dans la console lorsqu'il se déconnecte.",
    ["networking_netcollector_spam_action"] = "Que doit-il se passer lorsqu'un joueur spamme des messages réseau au serveur?",
    ["networking_netcollector_spam_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir spammé des messages réseau au serveur.",
    ["networking_dos_action"] = "Que doit-il se passer lorsqu'un joueur tente de provoquer des lags sur le serveur?",
    ["networking_dos_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir provoqué des lags sur le serveur.",
    ["networking_dos_sensivity"] = "Quelle doit être la sensibilité de la détection?",
    ["networking_dos_crash_enabled"] = "Détecter les attaques par décompression:\nLes clients peuvent envoyer des données hautement compressées au serveur. Lorsqu'elles sont décompressées, elles peuvent facilement atteindre 400 Mo de données et provoquer un décalage ou un plantage du serveur. Un client peut envoyer un maximum de 65 Ko au serveur. La compression utilisée dans Gmod (LZMA2) a généralement un taux de compression d'environ 20:1 (en fonction des données). On peut donc s'attendre à environ 1 Mo de données décompressées. Un taux de compression de 1000:1 ou même 7000:1 n'a pas de raison d'être. Cette option écrase util.Decompress et ne nécessite pas de redémarrage.",
    ["networking_dos_crash_action"] = "Que doit-il se passer si un joueur tente de planter le serveur ?",
    ["networking_dos_crash_ignoreprotected"] = "Ignorer les joueurs protégés. ",
    ["networking_dos_crash_maxsize"] = "Taille maximale décompressée en Mo:\nQuand elle est atteinte, la décompression est interrompue.",
    ["networking_dos_crash_ratio"] = "Taux de compression maximal:\nLes données normales ont un taux de compression d'environ 20:1. Un taux de compression de 1000:1 ou même de 7000:1 n'a pas d'utilité légitime. Ne le fixez pas trop bas, car cela entraînerait des faux positifs.",
    ["networking_dos_crash_whitelist"] = "Liste blanche de messages réseau qui seront ignorés.",
    ["networking_netcollector_actionAt"] = "À combien de messages d'un seul client en 3 secondes devons-nous agir? NE JAMAIS RÉGLER CECI TROP BAS!",
    ["networking_netcollector_dropAt"] = "À combien de messages en 3 secondes devons-nous ignorer un message réseau. Cela est fait pour prévenir une attaque par déni de service. Doit être inférieur au réglage ci-dessus.",
    ["networking_restricted_message_action"] = "Que doit-il se passer lorsqu'un joueur envoie un message au serveur qu'il n'est pas autorisé à envoyer? Sans manipuler le jeu ou un bug, il n'est pas possible pour les joueurs d'envoyer ce message.",
    ["networking_restricted_message_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir envoyé un message au serveur qu'il n'est pas autorisé à envoyer.",
    ["networking_sendlua_gm_express"] = "Activer gm_express:\nAmélioration massive des performances, en particulier pour les gros serveurs. Au lieu d'envoyer de grandes quantités de données via les Netmessages intégrés (lent), celles-ci sont transmises aux clients via HTTPS par un fournisseur externe (gmod.express). Cela accélère le temps de chargement des clients et allège la charge du serveur. Cette option dépend toutefois de gmod.express. Si cette page n'est plus accessible de manière inattendue, l'authentification pour les clients échoue. Les nouveaux clients qui ne peuvent pas se connecter à gmod.express ont recours à la méthode traditionnelle. Cette option présuppose l'installation de gm_express. Plus de détails dans l'onglet 'Santé'",
    ["networking_sendlua_authfailed_action"] = "Que doit-il se passer lorsqu'un joueur ne répond pas à l'authentification de Nova Defender? Si ignoré, il n'y a aucune garantie que l'anti-triche ou d'autres mécanismes côté client fonctionnent.",
    ["networking_sendlua_authfailed_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour ne pas avoir répondu à l'authentification de Nova Defender.",
    ["networking_sendlua_validationfailed_action"] = "Que doit-il se passer lorsqu'un joueur bloque le code de Nova Defender?",
    ["networking_sendlua_validationfailed_reason"] = "Raison pour laquelle un joueur est expulsé ou banni pour avoir bloqué le code de Nova Defender.",
    ["networking_fakenets_backdoors_load"] = "Créer de fausses portes dérobées et tromper les attaquants pour qu'ils les utilisent.",
    ["networking_fakenets_backdoors_block"] = "Bloquer les portes dérobées sur le serveur. Cela peut bloquer des messages réseau légitimes et casser des addons! Consultez d'abord l'onglet 'Santé' et vérifiez les portes dérobées existantes.",
    ["networking_fakenets_backdoors_action"] = "Que doit-il se passer lorsqu'un attaquant utilise une fausse porte dérobée?",
    ["networking_fakenets_exploits_load"] = "Créer de fausses failles et tromper les attaquants pour qu'ils les utilisent.",
    ["networking_fakenets_exploits_block"] = "Bloquer les messages réseau exploitables sur le serveur. Cela casse les addons exploitables sur votre serveur! Consultez d'abord l'onglet 'Santé' et vérifiez quels addons sont exploitables.",
    ["networking_fakenets_exploits_action"] = "Que doit-il se passer lorsqu'un attaquant utilise une fausse faille?",
    ["networking_vpn_vpn-action"] = "Que doit-il se passer lorsqu'un joueur utilise un VPN?",
    ["networking_vpn_vpn-action_reason"] = "Raison pour l'utilisation d'un VPN.",
    ["networking_vpn_country-action"] = "Que doit-il se passer lorsqu'un joueur vient d'un pays non autorisé?",
    ["networking_vpn_country-action_reason"] = "Raison pour laquelle un joueur vient d'un pays non autorisé.",
    ["networking_vpn_dump"] = "Imprime des informations sur l'adresse IP d'un joueur dans la console.",
    ["networking_vpn_apikey"] = "Clé API VPN:\nPour scanner les adresses IP. Vous devez vous inscrire sur https://www.ipqualityscore.com/create-account et récupérer votre clé sur https://www.ipqualityscore.com/user/settings.",
    ["networking_vpn_countrycodes"] = "Pays autorisés à rejoindre votre serveur. Obtenez les codes pays ici : https://countrycode.org/ (code à 2 lettres en majuscules). Il est recommandé de mettre en liste blanche votre propre pays et les pays voisins. Vous pouvez ajouter d'autres pays au fil du temps.",
    ["networking_vpn_whitelist_asns"] = "Numéros ASN en liste blanche (numéro pour identifier un fournisseur de services Internet). Il peut arriver que l'API détecte incorrectement une connexion VPN. Par conséquent, les FAI connus sont mis en liste blanche. Obtenez-les sur https://ipinfo.io/countries. Alternativement, vous pouvez voir l'ASN de chaque client connecté dans l'onglet 'Joueur'.",
    ["networking_screenshot_store_ban"] = "Enregistrer les captures d'écran (Lors d'un bannissement):\nJuste avant qu'un joueur soit banni, une capture d'écran de son écran sera faite et enregistrée dans le dossier '/data/nova/ban_screenshots' du serveur.",
    ["networking_screenshot_store_manual"] = "Enregistrer les captures d'écran (Menu):\nSi un administrateur prend une capture d'écran d'un joueur, elle sera enregistrée dans le dossier '/data/nova/admin_screenshots' du serveur.",
    ["networking_screenshot_limit_ban"] = "Limite de captures d'écran (Lors d'un bannissement):\nNombre maximum de captures d'écran stockées dans le dossier de données du serveur. Les plus anciennes seront supprimées.",
    ["networking_screenshot_limit_manual"] = "Limite de captures d'écran (Menu):\nNombre maximum de captures d'écran stockées dans le dossier de données du serveur. Les plus anciennes seront supprimées.",
    ["networking_screenshot_quality"] = "Qualité des captures d'écran\nLes captures d'écran de haute qualité peuvent prendre jusqu'à une minute pour être transférées.",    
    ["networking_http_overwrite"] = "Inspecter les appels HTTP (envoi+réception):\nSi cette option est activée, la fonction HTTP est remplacée et les requêtes peuvent être journalisées ou bloquées. Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_http_logging"] = "Journaliser les requêtes:\nToutes les requêtes HTTP sont journalisées en détail dans la console. Cela est utile pour obtenir un aperçu des URL appelées. Ne fonctionne que lorsque les requêtes HTTP sont inspectées.",
    ["networking_http_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",
    ["networking_http_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et adresses IP ajoutés à la liste sont autorisés.",
    ["networking_http_whitelistdomains"] = "Domaines en liste blanche:\nAjoutez tous les domaines et IP de confiance qui doivent être autorisés. Tout le reste sera bloqué. Si vous n'êtes pas sûr des domaines à mettre en liste blanche, désactivez la liste blanche et activez uniquement la journalisation.",
    ["networking_fetch_overwrite"] = "Inspecter http.fetch (réception de données):\nRemplacer la fonction http.fetch. NE PAS ACTIVER SI VOUS UTILISEZ VCMOD! Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_fetch_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et adresses IP ajoutés à la liste seront autorisés.",
    ["networking_fetch_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",
    ["networking_post_overwrite"] = "Inspecter http.post (envoi de données):\nRemplacer la fonction http.post. L'envoi de requêtes HTTP peut être utilisé par des attaquants pour voler des fichiers sur le serveur. Cependant, cette méthode peut également être contournée ou désactiver les systèmes DRM.",
    ["networking_post_whitelist"] = "Activer la liste blanche:\nSeuls les domaines et adresses IP ajoutés à la liste sont autorisés.",
    ["networking_post_blockunsafe"] = "Bloquer les requêtes non sécurisées:\nLes requêtes provenant de sources non sécurisées telles que la console ou RunString sont bloquées.",    
    
    ["networking_ddos_collect_days"] = "Jours de collecte des adresses IP:\nLa protection DDoS collecte les adresses IP de tous les joueurs connectés au cours des n derniers jours. Lorsqu'une attaque DDoS est détectée, toutes les communications avec le serveur sont bloquées, à l'exception des joueurs connectés au cours des n derniers jours. Le serveur ignore tous les joueurs qui ne se sont pas connectés au serveur au cours des n derniers jours. Le serveur sera invisible pour eux.",
    ["networking_ddos_notify"] = "Afficher des notifications si une attaque DDoS est détectée ou stoppée.",
    /*
        Contournement de bannissement
    */
    ["banbypass_ban_banstaff"] = "Le personnel peut être banni",
    ["banbypass_ban_default_reason"] = "Raison pour laquelle un joueur est banni si aucune raison n'est spécifiée",
    ["banbypass_bypass_default_reason"] = "Raison pour laquelle un joueur est banni s'il a contourné un bannissement",
    ["banbypass_bypass_familyshare_action"] = "Que doit-il se passer lorsqu'un joueur utilise un compte partagé en famille d'un joueur banni?",
    ["banbypass_bypass_clientcheck_action"] = "Que doit-il se passer lorsque nous trouvons des preuves de contournement de bannissement dans les fichiers locaux d'un joueur?",
    ["banbypass_bypass_ipcheck_action"] = "Que doit-il se passer lorsqu'un joueur a la même adresse IP qu'un joueur banni?",
    ["banbypass_bypass_fingerprint_enable"] = "Activer la vérification des empreintes digitales:\nCette option vérifie si un joueur utilise le même appareil qu'un utilisateur banni. Elle peut empêcher un joueur de créer un nouveau compte sur le même appareil tant qu'il est banni.",
    ["banbypass_bypass_fingerprint_action"] = "Que doit-il se passer lorsqu'un joueur utilise le même appareil qu'un utilisateur banni?",
    ["banbypass_bypass_fingerprint_sensivity"] = "Quelle doit être la sensibilité de la correspondance des empreintes digitales?",
    ["banbypass_bypass_indicators_apikey"] = "Clé API Steam:\nL'API Steam peut être utilisée pour afficher des données plus détaillées sur un joueur. Les résultats sont affichés dans l'onglet 'Joueur en ligne' dans les indicateurs. Créez-en une sur https://steamcommunity.com/dev/apikey et collez-la ici.",
    /*
        Anti Triche
    */
    ["anticheat_reason"] = "Raison pour laquelle un joueur est banni s'il utilise des triches.",
    ["anticheat_enabled"] = "Activer l'Anticheat:\nSi cette option est activée, le code anticheat sera envoyé à tous les clients et les détections seront traitées. Si cette option est désactivée, le code anticheat reste actif sur tous les clients actuellement connectés mais les détections sont ignorées. Cette option inclut la détection d'autoclick et d'aimbot.",
    ["anticheat_action"] = "Que doit-il se passer lorsqu'un joueur utilise des triches?",
    ["anticheat_verify_action"] = "Que doit-il se passer lorsque l'anticheat ne se charge pas pour un joueur?",
    ["anticheat_verify_execution"] = "Vérifier si l'anticheat fonctionne:\nAprès qu'un joueur ait reçu l'anticheat, une confirmation est demandée pour savoir s'il l'a exécuté. Cependant, ce processus peut échouer pour plusieurs raisons et ne doit donc pas être réglé sur 'Ban'.",
    ["anticheat_verify_reason"] = "Raison pour laquelle un joueur est banni si l'anticheat ne se charge pas.",
    ["anticheat_check_function"] = "Vérifier les fonctions:\nCompare les noms de fonctions sur le client avec les noms de fonctions connus des triches. Cela peut également détecter des fonctions légitimes dans le code que vous fournissez.",
    ["anticheat_check_files"] = "Vérifier les fichiers:\nSimilaire à 'Vérifier les fonctions'. Compare le nom de fichier d'un script en cours d'exécution avec les noms de fichiers connus des triches.",
    ["anticheat_check_globals"] = "Vérifier les variables globales:\nSimilaire à 'Vérifier les fonctions'. Compare les noms de variables avec les noms de variables connus des triches.",
    ["anticheat_check_modules"] = "Vérifier les modules:\nSimilaire à 'Vérifier les fonctions'. Compare les noms de modules avec les noms de modules connus des triches.",
    ["anticheat_check_runstring"] = "Vérifier 'RunString':\nDu code Lua arbitraire peut être exécuté en utilisant la fonction intégrée 'RunString'. Cette option détecte l'utilisation incorrecte de cette fonction et recherche des modèles de triches connus.",
    ["anticheat_check_external"] = "Vérifier les manipulations externes:\nCela détecte les logiciels de triche externes. Ceux-ci sont très difficiles à détecter dans un environnement Lua restreint. Cela ralentira les profileurs comme FProfiler.",
    ["anticheat_check_manipulation"] = "Détecter les manipulations:\nDétecte les tentatives de blocage ou de manipulation de l'anticheat.",
    ["anticheat_check_cvars"] = "Vérifier les variables de console:\nSimilaire à 'Vérifier les fonctions'. Certaines triches utilisent des cvars pour persister les paramètres. Compare les noms de cvar avec les noms de cvar connus des triches.",
    ["anticheat_check_byte_code"] = "Vérifier la compilation du code:\nSous le capot, le code Lua est compilé en bytecode en utilisant JIT puis interprété. Nous pouvons parfois déterminer si cela est fait de manière inhabituelle. Par exemple, si un client exécute du code via lua_run_cl.",
    ["anticheat_check_detoured_functions"] = "Vérifier le détournement de fonctions:\nCertaines triches remplacent la fonctionnalité des fonctions intégrées pour échapper à la détection ou manipuler le comportement du jeu.",
    ["anticheat_check_concommands"] = "Vérifier les commandes de console:\nSimilaire à 'Vérifier les variables de console'. Certaines triches peuvent être accessibles via la console. Compare les noms de commande avec les noms de commande connus des triches.",
    ["anticheat_check_net_scan"] = "Vérifier les scans:\nCertains scripts peuvent scanner le serveur pour des vulnérabilités ou des portes dérobées connues.", 
    ["anticheat_check_cheats_custom"] = "Détecter les triches connues:\nDétecter les triches largement utilisées par une analyse spéciale. Les noms exacts des triches sont affichés dans la raison.",
    ["anticheat_check_cheats_custom_unsure"] = "Détecter les triches inactives:\nLors de la détection de certaines triches, il est inconnu si cette triche est actuellement active ou non. La seule chose certaine est que la personne a utilisé cette triche une fois.",
    ["anticheat_check_experimental"] = "Activer les détections expérimentales:\nActive les détections de triches qui n'ont pas encore été testées. Les joueurs ne seront PAS bannis. Les détections sont journalisées dans le fichier suivant sur le serveur : 'data/nova/anticheat/experimental.txt'. Ce fichier peut être envoyé au développeur pour analyse.",
    ["anticheat_spam_filestealers"] = "Encombrer les voleurs de fichiers:\nCertaines triches stockent tout le code Lua exécuté qu'elles reçoivent du serveur dans des fichiers texte. Pour encombrer ces fichiers et rendre (un peu) plus difficile pour l'attaquant, nous encombrons ces fichiers avec du code inutile. Cela remplit lentement le disque du joueur. Cela n'a aucun impact négatif sur le temps de chargement du joueur.",
    ["anticheat_autoclick_enabled"] = "Activer la détection d'autoclick:\nPour des raisons évidentes, nous ne voulons pas que les joueurs utilisent des programmes pour des clics rapides ou des frappes de touches. Cela inclut les clics gauche et droit, l'utilisation et la barre d'espace.",
    ["anticheat_autoclick_action"] = "Que doit-il se passer lorsqu'un joueur utilise un autoclick?",
    ["anticheat_autoclick_reason"] = "Raison pour laquelle un joueur est banni s'il a utilisé un autoclick.",
    ["anticheat_autoclick_sensivity"] = "Sensibilité de l'autoclick:\nUne sensibilité élevée peut détecter faussement des joueurs en raison de coïncidences rares. Les bons autoclickers peuvent ne pas être détectés avec une faible sensibilité. Décidez en fonction de la manière dont les autoclickers peuvent donner un avantage aux tricheurs.",
    ["anticheat_autoclick_check_fast"] = "Vérifier la vitesse de clic rapide:\nAu-dessus d'un certain nombre de CPS (clics par seconde), nous pouvons supposer qu'un être humain n'est pas capable de le faire sans aide. Cela s'applique également aux touches.",
    ["anticheat_autoclick_check_fastlong"] = "Vérifier le clic rapide sur une longue période:\nIl est peu probable qu'un joueur clique extrêmement rapidement pendant plusieurs minutes sans pauses courtes.",
    ["anticheat_autoclick_check_robotic"] = "Vérifier la cohérence inhumaine des clics:\nUn humain ne peut jamais cliquer à exactement la même vitesse. Ce sera toujours un peu plus rapide ou plus lent. Un programme, cependant, peut chronométrer cela très précisément. Si l'intervalle de temps entre les clics est trop cohérent, nous pouvons le dire.",
    ["anticheat_aimbot_enabled"] = "Activer la détection d'aimbot:\nSurveille en temps réel tous les mouvements des joueurs.",
    ["anticheat_aimbot_action"] = "Que doit-il se passer lorsqu'un joueur utilise un aimbot?",
    ["anticheat_aimbot_reason"] = "Raison pour laquelle un joueur est banni lorsqu'il utilise un aimbot.",
    ["anticheat_aimbot_check_snap"] = "Détecter les snaps:\nDétecter si la direction de vue des joueurs change instantanément. ATTENTION : Cela empêchera les clients de définir leurs angles de vue (si ce n'est pas fait côté serveur) et donc de casser certains addons!",
    ["anticheat_aimbot_check_move"] = "Détecter les mouvements suspects:\nDétecter si un joueur change constamment de vue sans bouger sa souris.",
    ["anticheat_aimbot_check_contr"] = "Détecter les mouvements contradictoires:\nDétecte si un joueur bouge sa souris dans une direction différente de celle de sa vue.",    
    ["exploit_fix_propspawn"] = "Propspawn:\nEmpêche l'apparition de props avec du matériel copié.",
    ["exploit_fix_material"] = "Matériel:\nEmpêche la copie de matériel.",
    ["exploit_fix_fadingdoor"] = "Porte dérobée:\nEmpêche le bug graphique que les joueurs ne peuvent plus voir.",
    ["exploit_fix_physgunreload"] = "Physgun:\nDésactive le rechargement du physgun pour les utilisateurs.",
    ["exploit_fix_bouncyball"] = "Balle rebondissante:\nEmpêche le soudage des balles rebondissantes.",
    ["exploit_fix_bhop"] = "Bunnyhop:\nEmpêche le bunnyhopping.",
    ["exploit_fix_serversecure"] = "Configurer Serversecure automatiquement:\nVoir l'onglet 'Santé' pour plus d'informations.",
    /*
        Sécurité
    */
    ["security_permissions_groups_protected"] = "Groupes d'utilisateurs protégés:\nTous les groupes d'utilisateurs considérés comme protégés. Seuls les joueurs en liste blanche peuvent avoir ce groupe. Les joueurs protégés ont un accès complet à ce menu.",
    ["security_permissions_groups_staff"] = "Groupes d'utilisateurs du personnel et des administrateurs:\nTous les groupes d'utilisateurs ayant des permissions de personnel.",
    ["security_privileges_group_protection_enabled"] = "Protection de rang automatisée:\nSi un joueur qui n'est pas en liste blanche a par exemple un groupe d'utilisateurs protégé, nous prenons des mesures.",
    ["security_privileges_group_protection_escalation_action"] = "Que doit-il se passer lorsqu'un joueur a un groupe d'utilisateurs protégé qu'il ne devrait pas avoir?",
    ["security_privileges_group_protection_escalation_reason"] = "Raison pour laquelle un joueur est expulsé ou banni s'il a un groupe d'utilisateurs protégé qu'il ne devrait pas avoir.",
    ["security_privileges_group_protection_removal_action"] = "Que doit-il se passer lorsqu'un joueur protégé perd son groupe d'utilisateurs?",
    ["security_privileges_group_protection_protected_players"] = "Joueurs protégés:\nTous les joueurs autorisés à avoir un groupe d'utilisateurs protégé. Si vous retirez un joueur qui est en ligne, il sera expulsé.",
    ["security_privileges_group_protection_kick_reason"] = "Raison pour expulser un joueur protégé si sa protection est retirée pendant qu'il est connecté.",
    /*
        Détections
    */
    ["config_detection_banbypass_familyshare"] = "Contournement de bannissement par compte partagé en famille",
    ["config_detection_banbypass_clientcheck"] = "Vérification du client de contournement de bannissement",
    ["config_detection_banbypass_ipcheck"] = "Vérification de l'IP de contournement de bannissement",
    ["config_detection_banbypass_fingerprint"] = "Empreinte digitale de contournement de bannissement",
    ["config_detection_networking_country"] = "Pays du joueur non autorisé",
    ["config_detection_networking_vpn"] = "Utilisation d'un VPN",
    ["config_detection_networking_backdoor"] = "Utilisation d'une fausse porte dérobée",
    ["config_detection_networking_spam"] = "Spam de messages réseau",
    ["config_detection_networking_dos"] = "Provoquer des lags sur le serveur",
    ["config_detection_networking_dos_crash"] = "Essai de plantage du serveur avec un message volumineux",
    ["config_detection_networking_authentication"] = "Le client ne peut pas s'authentifier avec le serveur",
    ["config_detection_networking_restricted_message"] = "Le client a envoyé un message réservé aux administrateurs au serveur",
    ["config_detection_networking_exploit"] = "Utilisation d'une fausse faille",
    ["config_detection_networking_validation"] = "Le client ne peut pas valider l'exécution du code",
    ["config_detection_anticheat_scanning_netstrings"] = "Scan pour des failles et des portes dérobées",
    ["config_detection_anticheat_runstring_dhtml"] = "Exécution de code via DHTML",
    ["config_detection_anticheat_runstring_bad_string"] = "RunString contient des modèles de triche (chaîne)",
    ["config_detection_anticheat_remove_ac_timer"] = "Désactivation de l'anticheat",
    ["config_detection_anticheat_gluasteal_inject"] = "Utilisation de filestealer pour exécuter du code",
    ["config_detection_anticheat_function_detour"] = "Détournement de fonction pour manipuler le jeu",
    ["config_detection_anticheat_external_bypass"] = "Triches externes",
    ["config_detection_anticheat_runstring_bad_function"] = "RunString contient des modèles de triche (fonction)",
    ["config_detection_anticheat_jit_compilation"] = "Compilation de bytecode inhabituelle",
    ["config_detection_anticheat_known_cvar"] = "Cvar de triche",
    ["config_detection_anticheat_known_file"] = "Fichiers de triche trouvés",
    ["config_detection_anticheat_known_data"] = "Restes de triche trouvés",
    ["config_detection_anticheat_known_module"] = "Modules de triche inclus",
    ["config_detection_anticheat_known_concommand"] = "Commande console de triche",
    ["config_detection_anticheat_verify_execution"] = "Blocage de l'anticheat",
    ["config_detection_anticheat_known_global"] = "Variable globale de triche",
    ["config_detection_anticheat_known_cheat_custom"] = "Triche connue",
    ["config_detection_anticheat_known_function"] = "Fonction globale de triche",
    ["config_detection_anticheat_manipulate_ac"] = "Manipule l'anticheat",
    ["config_detection_anticheat_autoclick_fast"] = "Vitesse de clic inhumaine",
    ["config_detection_anticheat_autoclick_fastlong"] = "Vitesse de clic rapide sur une longue période",
    ["config_detection_anticheat_autoclick_robotic"] = "Cohérence de clic inhumaine",
    ["config_detection_anticheat_aimbot_snap"] = "Aimbot snap instantané en 1 tick",
    ["config_detection_anticheat_aimbot_move"] = "Mouvement suspect d'aimbot",
    ["config_detection_anticheat_aimbot_contr"] = "Mouvement contradictoire d'aimbot",
    ["config_detection_security_privilege_escalation"] = "Escalade de privilège vers un groupe d'utilisateurs protégé",
    ["config_detection_admin_manual"] = "Bannissement manuel par un administrateur ou la console",
    /*
        Notifications
    */
    ["menu_notify_hello_staff"] = "Ce serveur est protégé par Nova Defender.\nVous êtes catégorisé comme personnel.",
    ["menu_notify_hello_protected"] = "Ce serveur est protégé par Nova Defender.\nVous êtes catégorisé comme protégé.",
    ["menu_notify_hello_menu"] = "Ouvrez le menu avec !nova.",
    ["notify_admin_unban"] = "%s a été débanni avec succès. Le bannissement sera supprimé lorsque le joueur se connectera au serveur la prochaine fois.",
    ["notify_admin_ban"] = "%s a été banni avec succès. Le joueur sera banni s'il rejoint le serveur la prochaine fois.",
    ["notify_admin_ban_online"] = "L'administrateur %s a banni %s. Le joueur sera banni dans quelques secondes.",
    ["notify_admin_ban_offline"] = "L'administrateur %s a banni %s. Le joueur sera banni s'il rejoint le serveur la prochaine fois.",
    ["notify_admin_ban_fail"] = "Le bannissement de %s a échoué : %q",
    ["notify_admin_kick"] = "L'administrateur %s a expulsé %s du serveur",
    ["notify_admin_reconnect"] = "L'administrateur %s a reconnecté %s",
    ["notify_admin_quarantine"] = "L'administrateur %s a mis %s en quarantaine réseau. Il ne pourra plus interagir avec quoi que ce soit sur le serveur maintenant.",
    ["notify_admin_unquarantine"] = "L'administrateur %s a retiré %s de la quarantaine réseau",
    ["notify_admin_no_permission"] = "Vous n'avez pas les droits suffisants pour faire cela",
    ["notify_admin_client_not_connected"] = "Le joueur est hors ligne",
    ["notify_admin_already_inspecting"] = "Vous inspectez déjà un autre joueur",
    ["notify_anticheat_detection"] = "Détection d'anticheat %q sur %s. Raison : %q",
    ["notify_anticheat_detection_action"] = "Anticheat : %q",
    ["notify_anticheat_issue_fprofiler"] = "Si l'anticheat est actif, le profilage côté client ne fonctionnera pas !", 
    ["notify_aimbot_detection"] = "Détection d'aimbot %q sur %s. Raison : %q",
    ["notify_aimbot_detection_action"] = "Aimbot : %q",   
    ["notify_anticheat_verify"] = "L'anticheat côté client de %s n'a pas pu être chargé. Cela peut également être causé par une connexion lente.",
    ["notify_anticheat_verify_action"] = "L'anticheat côté client n'a pas pu être chargé. Cela peut également être causé par une connexion lente.", 
    ["notify_banbypass_ban_fail"] = "Impossible de bannir %s pour %q : %s",
    ["notify_banbypass_kick_fail"] = "Impossible d'expulser %s pour %q : %s", 
    ["notify_banbypass_bypass_fingerprint_match"] = "%s pourrait contourner un bannissement : L'empreinte digitale correspond à SteamID banni %s | Confiance : %d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "Pourrait contourner un bannissement : L'empreinte digitale correspond à SteamID banni %s | Confiance : %d%%",
    ["notify_banbypass_familyshare"] = "Peut contourner un bannissement : Compte partagé en famille de SteamID banni %s",
    ["notify_banbypass_familyshare_action"] = "Peut contourner un bannissement : Compte partagé en famille de SteamID banni %s",
    ["notify_banbypass_clientcheck"] = "Peut contourner un bannissement : Preuve trouvée pour un contournement de bannissement de %s | Preuve : %s",
    ["notify_banbypass_clientcheck_action"] = "Peut contourner un bannissement : Preuve trouvée pour un contournement de bannissement de %s | Preuve : %s",
    ["notify_banbypass_ipcheck"] = "Peut contourner un bannissement : IP identique à celle du joueur banni %s",
    ["notify_banbypass_ipcheck_action"] = "Peut contourner un bannissement : IP identique à celle du joueur banni %s",
    ["notify_networking_exploit"] = "%s a utilisé une faille réseau : %q",
    ["notify_networking_exploit_action"] = "Utilisation d'une faille réseau : %q",
    ["notify_networking_backdoor"] = "%s a utilisé une porte dérobée réseau : %q",
    ["notify_networking_backdoor_action"] = "Utilisation d'une porte dérobée réseau : %q",
    ["notify_networking_spam"] = "%s spamme les messages réseau (%d/%ds) (%d autorisés).",
    ["notify_networking_spam_action"] = "Spam de messages réseau (%d/%ds) (%d autorisés).",
    ["notify_networking_limit"] = "%s a dépassé la limite de %d messages réseau par %d secondes.",
    ["notify_networking_limit_drop"] = "Ignorer les messages réseau de %s car il a dépassé la limite de %d messages réseau par %d secondes.",
    ["notify_networking_dos"] = "%s a causé un lag serveur. Durée : %s en %d secondes",
    ["notify_networking_dos_action"] = "Cause des lags serveur. Durée : %s en %d secondes",
    ["notify_networking_dos_crash"] = "%s a essayé de planter le serveur avec un message volumineux. Message : %q, Size : %s, Compression ratio : %s",
    ["notify_networking_dos_crash_action"] = "Tentative de plantage du serveur avec un message volumineux. Message : %q ,Taille : %s, Taux de compression : %s",
    ["notify_networking_restricted"] = "%s a essayé d'envoyer un message réseau %q réservé à %q. Cela ne peut pas être fait sans manipulation.",
    ["notify_networking_restricted_action"] = "A envoyé un message réseau %q que seuls %q sont autorisés à envoyer. Cela ne peut pas être fait sans manipulation.",
    ["notify_networking_screenshot_failed_multiple"] = "Capture d'écran pour %s échouée : Vous ne pouvez prendre qu'une capture d'écran à la fois",
    ["notify_networking_screenshot_failed_progress"] = "Capture d'écran pour %s échouée : Une autre capture d'écran pour ce joueur est en cours.",
    ["notify_networking_screenshot_failed_timeout"] = "Capture d'écran pour %s échouée : Aucune capture d'écran reçue du client.",
    ["notify_networking_screenshot_failed_empty"] = "Capture d'écran de %s échouée : Réponse vide. Cela peut se produire si elle a été bloquée par une triche ou si le joueur est dans le menu d'évasion.",
    ["notify_networking_auth_failed"] = "%s n'a pas pu s'authentifier avec le serveur. Cela peut également être causé par une connexion lente.",
    ["notify_networking_auth_failed_action"] = "N'a pas pu s'authentifier avec le serveur. Cela peut également être causé par une connexion lente.",
    ["notify_networking_sendlua_failed"] = "%s bloque l'exécution du code Nova Defender. Cela peut également être causé par une connexion lente.",
    ["notify_networking_sendlua_failed_action"] = "Bloque l'exécution du code Nova Defender. Cela peut également être causé par une connexion lente.",
    ["notify_networking_issue_gm_express_not_installed"] = "gm_express n'est pas installé sur le serveur. Plus de détails dans l'onglet 'Santé'",
    ["notify_networking_vpn"] = "%s utilise un VPN : %s",
    ["notify_networking_vpn_action"] = "Utilisation d'un VPN : %s",
    ["notify_networking_country"] = "%s vient d'un pays non autorisé. %s",
    ["notify_networking_country_action"] = "Vient d'un pays non autorisé. %s",
    ["notify_security_privesc"] = "%s a été défini dans le groupe d'utilisateurs %q qui est uniquement en liste blanche.",
    ["notify_security_privesc_action"] = "A été défini dans le groupe d'utilisateurs %q qui est uniquement en liste blanche.",
    ["notify_functions_action"] = "Quelle action devons-nous prendre contre %s?\nRaison : %s",
    ["notify_functions_action_notify"] = "L'administrateur %s a pris la mesure suivante contre la détection %q de %s : %q.",
    ["notify_functions_allow_success"] = "Détection exclue avec succès.",
    ["notify_functions_allow_failed"] = "Impossible d'exclure cette détection.",
    
    ["notify_custom_extension_ddos_protection_attack_started"] = "Attaque DDoS détectée. Ouvrir le menu avec !nova pour un statut en direct",
    ["notify_custom_extension_ddos_protection_attack_stopped"] = "Attaque DDoS stoppée. Ouvrir le menu avec !nova pour les détails",
    /*
        Santé
    */
    ["health_check_gmexpress_title"] = "gm_express Module",
    ["health_check_gmexpress_desc"] = "Amélioration massive des performances, en particulier pour les gros serveurs. Créé par CFC Servers.",
    ["health_check_gmexpress_desc_long"] =
[[Au lieu d'envoyer de grandes quantités de données via les Netmessages intégrés (lent),
celles-ci sont transmises aux clients via HTTPS par un fournisseur d'accès externe (gmod.express).
Cela accélère le temps de chargement des clients et allège la charge du serveur.
Cette option dépend toutefois de gmod.express. Si cette page n'est pas accessible,
l'authentification échoue pour les clients. Les nouveaux clients qui ne peuvent
pas se connecter à gmod.express ont recours aux Netmessages traditionnels.

Pour l'installer, rendez-vous sur : https://github.com/CFC-Servers/gm_express.
   1. clique sur « Code » et télécharge le fichier .zip.
   2. décompresse le fichier .zip dans le répertoire « /garrysmod/addons ».
   3. redémarre ton serveur.
   4. active l'option « Activer gm_express » dans l'onglet « Réseau ».

Ce service peut également être auto-hébergé.
Voir : https://github.com/CFC-Servers/gm_express_service]],
    ["health_check_seversecure_title"] = "Module Serversecure",
    ["health_check_seversecure_desc"] = "Un module qui atténue les failles sur le moteur Source. Créé par danielga.",
    ["health_check_seversecure_desc_long"] =
[[Sans ce module, il pourrait être facile de faire planter votre serveur.
Il peut limiter le nombre de paquets que votre serveur acceptera et les valider.

Pour l'installer, allez sur https://github.com/danielga/gmsv_serversecure.
   1. Allez dans Releases et téléchargez le fichier .dll pour le système d'exploitation de votre serveur.
   2. Créez un dossier "garrysmod/lua/bin" s'il n'existe pas.
   3. Placez le fichier .dll dans votre dossier "/garrysmod/lua/bin".
   4. Sur Github, téléchargez le fichier "serversecure.lua" ("/include/modules").
   5. Placez ce fichier dans le dossier "/garrysmod/lua/includes/modules".
   6. Redémarrez votre serveur.

Si vous voulez que Nova Defender configure le module pour vous, activez
l'option "Configurer Serversecure automatiquement" dans l'onglet "Exploit".]],
    ["health_check_exploits_title"] = "Addons avec des failles connues",
    ["health_check_exploits_desc"] = "Liste des netmessages des addons connus pour être exploitables.",
    ["health_check_exploits_desc_long"] =
[[Un netmessage permet la communication entre le client et le serveur.
Cependant, ces messages peuvent être facilement manipulés par un client.
Donc, si le serveur ne vérifie pas si le client est autorisé à envoyer ce message,
des failles de sécurité exploitables (glitch d'argent, plantages de serveur, droits d'administrateur) peuvent survenir.

Tous les noms de netmessages listés peuvent ou pourraient être exploités.
Il n'y a aucune garantie que cette vulnérabilité existe toujours.
Il peut également y avoir des netmessages vulnérables qui ne sont pas listés ici.

   1. Mettez à jour vos addons régulièrement
   2. Remplacez les addons obsolètes/non supportés par des nouveaux
   3. Si vous êtes familier avec Lua, vérifiez manuellement les netmessages affectés]],
    ["health_check_backdoors_title"] = "Backdoors",
    ["health_check_backdoors_desc"] = "Les backdoors peuvent être sur le serveur pour donner à un attaquant un accès non désiré.",
    ["health_check_backdoors_desc_long"] =
[[Les backdoors peuvent être chargées sur un serveur de plusieurs façons, entre autres :
   1. Addons malveillants du workshop
   2. Une personne vous demande de télécharger un fichier Lua sur le serveur
      qui a été fait "spécialement pour vous"
   3. Un développeur ayant accès à votre serveur a construit une backdoor pour lui-même
   4. Le serveur lui-même a été compromis (vulnérabilité dans le système d'exploitation,
      vulnérabilité dans le logiciel)

Façons de supprimer une backdoor :
   1. Si disponible, vérifiez le chemin donné (si le chemin commence par 'lua/' il est probablement du workshop)
   2. Scannez votre serveur avec par exemple https://github.com/THABBuzzkill/nomalua
   3. Supprimez tous les scripts que vous avez ajoutés récemment et vérifiez si ce message apparaît à nouveau
   4. Téléchargez tous les fichiers sur votre serveur et faites une recherche de texte pour la backdoor listée
   5. MÉTHODE DIFFICILE : supprimez TOUS les addons jusqu'à ce que ce message cesse d'apparaître, puis ajoutez-les
      un par un et vérifiez l'addon où il réapparaît.]],
    ["health_check_mysql_pass_title"] = "Mot de passe de base de données faible",
    ["health_check_mysql_pass_desc"] = "Le mot de passe de la base de données pour Nova Defender est trop faible.",
    ["health_check_mysql_pass_desc_long"] =
[[Si vous utilisez MySQL, vous avez besoin d'un mot de passe fort.
Même s'il n'est pas accessible depuis Internet.

Comment sécuriser votre base de données :
   1. Un mot de passe de base de données fort n'est pas quelque chose que vous devez mémoriser
   2. Utilisez un générateur de mots de passe pour créer un mot de passe aléatoire
   3. Utilisez un mot de passe différent pour chaque base de données
   4. Utilisez une base de données différente pour chaque addon
      (ou des permissions de base de données appropriées)]],
    ["health_check_nova_errors_title"] = "Erreurs de Nova Defender",
    ["health_check_nova_errors_desc"] = "Erreurs générées par Nova Defender",
    ["health_check_nova_errors_desc_long"] =
[[Eh bien, lisez-les. Veuillez me contacter si vous n'êtes pas sûr de la façon de résoudre un problème donné.
Si chaque message d'erreur est concluant pour vous et n'affecte pas la fonctionnalité,
vous pouvez ignorer ce message en toute sécurité.]],
    ["health_check_nova_vpn_title"] = "Protection VPN de Nova Defender",
    ["health_check_nova_vpn_desc"] = "La protection VPN doit être configurée pour bloquer les pays et détecter les VPN.",
    ["health_check_nova_vpn_desc_long"] =
[[Dans l'onglet "Networking", vous devez insérer votre clé API,
que vous obtenez après l'inscription gratuite sur ipqualityscore.com.
Avec cela, Nova-Defender peut alors examiner les adresses IP via cette page.
   1. allez sur https://www.ipqualityscore.com/create-account
   2. copiez votre clé API ici https://www.ipqualityscore.com/user/settings
   3. collez-la dans l'onglet "Networking" sous "VPN API key"]],
    ["health_check_nova_steamapi_title"] = "Protection du profil Steam de Nova Defender",
    ["health_check_nova_steamapi_desc"] = "La protection du profil Steam doit être configurée pour détecter les profils suspects des joueurs.",
    ["health_check_nova_steamapi_desc_long"] =
[[Dans l'onglet "Ban System", vous devez insérer votre clé API,
   1. allez sur https://steamcommunity.com/dev/apikey
   2. entrez le nom de domaine de votre serveur
   3. copiez votre clé API
   4. collez-la dans l'onglet "Ban System" sous "Steam API key"]],
    ["health_check_nova_anticheat_title"] = "Extension Anticheat de Nova Defender",
    ["health_check_nova_anticheat_desc"] = "L'anticheat a besoin d'une extension pour détecter plus de triches.",
    ["health_check_nova_anticheat_desc_long"] =
[[Actuellement, seuls quelques triches simples sont détectés. Comme le code source de Nova Defender est ouvert
et visible, les triches peuvent être facilement modifiées pour être indétectables.
Par conséquent, les propriétaires de serveurs peuvent demander l'extension de l'anticheat,
qui détecte également les triches externes, nouvelles ou payantes par nom.
Cliquez sur le bouton correspondant en haut du menu ou rejoignez notre Discord pour en savoir plus.]],
    ["health_check_nova_anticheat_version_title"] = "Ancienne version de l'anticheat de Nova Defender",
    ["health_check_nova_anticheat_version_desc"] = "L'anticheat n'est pas à jour.",
    ["health_check_nova_anticheat_version_desc_long"] =
[[Veuillez télécharger la dernière version depuis GitHub :
https://github.com/Freilichtbuehne/nova-defender-anticheat/releases/latest]],
    ["health_check_nova_ddos_protection_title"] = "Nova Defender DDoS protection extension",
    ["health_check_nova_ddos_protection_desc"] = "Défendez votre serveur Linux contre les attaques DDoS.",
    ["health_check_nova_ddos_protection_desc_long"] =
    [[Protection DDoS basée sur l'hôte pour les serveurs Linux.
Les propriétaires de serveurs peuvent demander cette extension.
Cliquez sur le bouton correspondant en haut du menu ou rejoignez notre Discord pour en savoir plus.]],
    ["health_check_nova_ddos_protection_version_title"] = "Ancienne version de la protection DDoS de Nova Defender",
    ["health_check_nova_ddos_protection_version_desc"] = "La protection DDoS n'est pas à jour.",
    ["health_check_nova_ddos_protection_version_desc_long"] =
[[Veuillez télécharger la dernière version depuis GitHub :
https://github.com/Freilichtbuehne/nova-defender-ddos/releases/latest]],
    /*
        Serveur
    */
    ["server_general_suffix"] = "Texte à ajouter à chaque message d'expulsion, de bannissement ou de rejet. Par exemple votre Teamspeak, Discord ou autre site de support.",
    ["server_access_maintenance_enabled"] = "Mode Maintenance:\nSeuls les joueurs protégés et les joueurs avec mot de passe peuvent rejoindre le serveur.",
    ["server_access_maintenance_allowed"] = "Qui peut rejoindre le serveur en mode maintenance ? Les joueurs protégés sont toujours autorisés et n'ont pas besoin de mot de passe.",
    ["server_access_maintenance_password"] = "Mot de passe pour le mode maintenance, si vous avez sélectionné 'mot de passe' dans le paramètre ci-dessus.",
    ["server_access_maintenance_reason"] = "Raison à afficher à un client essayant de se connecter pendant la maintenance.",
    ["server_access_password_lock"] = "Verrouiller les tentatives incorrectes:\nSi un client entre un mot de passe incorrect trop souvent, toutes les tentatives suivantes seront bloquées.",
    ["server_access_password_lock_reason"] = "Raison à afficher à un client, s'il a entré un mot de passe incorrect trop souvent.",
    ["server_access_password_max_attempts"] = "Nombre maximum de tentatives avant verrouillage",
    ["server_lockdown_enabled"] = "Mode Lockdown:\nSEUL le personnel, les protégés et les joueurs de confiance peuvent rejoindre le serveur. Utilisez cela lorsque de nombreux nouveaux comptes sont créés pour rejoindre le serveur pour troller, griefing ou faire planter le serveur. Les joueurs déjà sur le serveur ne sont pas affectés. Assurez-vous de définir d'abord qui est de confiance dans le fichier de configuration de Nova Defender. Cela ne doit être utilisé que pour une courte période.",
    ["server_lockdown_reason"] = "Raison d'expulser un joueur en mode lockdown s'il n'est pas protégé, personnel ou de confiance.",
    /*
        Menu Admin
    */
    ["menu_title_banbypass"] = "Système de Bannissement",
    ["menu_title_health"] = "Santé",
    ["menu_title_network"] = "Réseau",
    ["menu_title_security"] = "Sécurité",
    ["menu_title_menu"] = "Menu",
    ["menu_title_anticheat"] = "Anticheat",
    ["menu_title_detections"] = "Détections",
    ["menu_title_bans"] = "Bannissements",
    ["menu_title_exploit"] = "Exploits",
    ["menu_title_players"] = "Joueurs en ligne",
    ["menu_title_server"] = "Serveur",
    ["menu_title_inspection"] = "Inspecter les joueurs",
    ["menu_title_ddos"] = "Protection DDoS",

    ["menu_desc_banbypass"] = "Techniques pour empêcher les joueurs de contourner un bannissement de Nova Defender",
    ["menu_desc_network"] = "Restreindre, contrôler et enregistrer l'activité réseau",
    ["menu_desc_security"] = "Protéger contre les escalades de privilèges des utilisateurs",
    ["menu_desc_menu"] = "Contrôle des notifications et du menu admin",
    ["menu_desc_anticheat"] = "Activer ou désactiver les fonctionnalités de l'anticheat côté client selon vos désirs",
    ["menu_desc_bans"] = "Trouver, bannir ou débannir des joueurs",
    ["menu_desc_exploit"] = "Prévenir des exploits spécifiques dans la mécanique du jeu",
    ["menu_desc_players"] = "Tous les joueurs actuellement en ligne",
    ["menu_desc_health"] = "Voir l'état de votre serveur en un coup d'œil",
    ["menu_desc_detections"] = "Toutes les détections en attente qui doivent être examinées",
    ["menu_desc_server"] = "Gérer l'accès à votre serveur",
    ["menu_desc_inspection"] = "Exécuter des commandes sur les joueurs et rechercher des fichiers",
    ["menu_desc_ddos"] = "Statut en direct de la protection DDoS installée sur le serveur Linux",

    ["menu_elem_extensions"] = "Extensions:",
    ["menu_elem_disabled"] = "(désactivé)",
    ["menu_elem_outdated"] = "(obsolète)",
    ["menu_elem_add"] = "Ajouter",
    ["menu_elem_edit"] = "Éditer",
    ["menu_elem_unban"] = "Débannir",
    ["menu_elem_ban"] = "Bannir",
    ["menu_elem_kick"] = "Expulser",
    ["menu_elem_reconnect"] = "Reconnecter",
    ["menu_elem_quarantine"] = "Mettre en quarantaine",
    ["menu_elem_unquarantine"] = "Retirer de la quarantaine",
    ["menu_elem_verify_ac"] = "Vérifier l'anticheat",
    ["menu_elem_screenshot"] = "Capture d'écran",
    ["menu_elem_detections"] = "Détections",
    ["menu_elem_indicators"] = "Indicateurs",
    ["menu_elem_commands"] = "Commandes",
    ["menu_elem_netmessages"] = "Messages réseau",
    ["menu_elem_ip"] = "Détails IP",
    ["menu_elem_profile"] = "Profil Steam",
    ["menu_elem_rem"] = "Supprimer",
    ["menu_elem_reload"] = "Recharger",
    ["menu_elem_advanced"] = "Options avancées",
    ["menu_elem_miss_options"] = "Options manquantes ?",
    ["menu_elem_copy"] = "Copier",
    ["menu_elem_save"] = "Enregistrer sur le disque",
    ["menu_elem_saved"] = "Enregistré",
    ["menu_elem_settings"] = "Paramètres :",
    ["menu_elem_general"] = "Général :",
    ["menu_elem_discord"] = "Rejoignez notre Discord !",
    ["menu_elem_close"] = "Fermer",
    ["menu_elem_cancel"] = "Annuler",
    ["menu_elem_filter_by"] = "Filtrer par :",
    ["menu_elem_view"] = "Voir",
    ["menu_elem_filter_text"] = "Texte du filtre :",
    ["menu_elem_reason"] = "Raison",
    ["menu_elem_comment"] = "Commentaire",
    ["menu_elem_bans"] = "Bannissements (limité à 150 entrées) :",
    ["menu_elem_new_value"] = "Nouvelle valeur",
    ["menu_elem_submit"] = "Soumettre",
    ["menu_elem_no_bans"] = "Aucun bannissement trouvé",
    ["menu_elem_no_data"] = "Aucune donnée disponible",
    ["menu_elem_checkboxtext_checked"] = "Actif",
    ["menu_elem_checkboxtext_unchecked"] = "Inactif",
    ["menu_elem_search_term"] = "Terme de recherche...",
    ["menu_elem_unavailable"] = "Indisponible",
    ["menu_elem_failed"] = "Échoué",
    ["menu_elem_passed"] = "Réussi",
    ["menu_elem_health_overview"] = "Vérifications :\n  • Total : %d\n  • Réussi : %d\n  • Échoué : %d",
    ["menu_elem_health_most_critical"] = "Les plus critiques :\n",
    ["menu_elem_mitigation"] = "Comment réparer ?",
    ["menu_elem_list"] = "Détails",
    ["menu_elem_ignore"] = "Ignorer",
    ["menu_elem_reset"] = "Réinitialiser",
    ["menu_elem_reset_all"] = "Réinitialiser toutes les vérifications ignorées :",
    ["menu_elem_player_count"] = "Joueurs en ligne : %d",
    ["menu_elem_foundindicator"] = "Trouvé %d indicateur",
    ["menu_elem_foundindicators"] = "Trouvé %d indicateurs",
    ["menu_elem_criticalindicators"] = "Indicateurs critiques !",
    ["menu_elem_notauthed"] = "Authentification...",
    ["menu_elem_mitigated"] = "Atténué",
    ["menu_elem_unmitigated"] = "Non atténué",
    ["menu_elem_next"] = "Suivant",
    ["menu_elem_prev"] = "Précédent",
    ["menu_elem_clear"] = "Supprimer atténué",
    ["menu_elem_clear_all"] = "Tout supprimer",
    ["menu_elem_delete"] = "Supprimer",
    ["menu_elem_stats"] = "Entrées : %d",
    ["menu_elem_page"] = "Page : %d",
    ["menu_elem_nofocus"] = "Pas de focus",
    ["menu_elem_focus"] = "A le focus",
    ["menu_elem_connect"] = "Connecter",
    ["menu_elem_disconnect"] = "Déconnecter",
    ["menu_elem_input_command"] = "Entrer et exécuter du code Lua...",
    ["menu_elem_select_player"] = "Sélectionner un joueur",
    ["menu_elem_disconnected"] = "Déconnecté",
    ["menu_elem_exec_clientopen"] = "Le client a ouvert la connexion",
    ["menu_elem_exec_clientclose"] = "Le client a fermé la connexion",
    ["menu_elem_exec_error"] = "Erreur interne du serveur",
    ["menu_elem_exec_help"] = [[Application :
    • Utilisez ceci si vous êtes familier avec Lua
    • Conçu pour des fins de débogage et de chasse aux triches Lua
    
    Général :
    • Entrez du code Lua et appuyez sur Entrée pour l'exécuter sur le client sélectionné
    • Les erreurs Lua seront affichées dans la console
    • Les erreurs Lua sont invisibles pour le client
    
    Affichage des valeurs :
    • Pour obtenir la valeur d'une table ou d'une chaîne, utilisez "print()" ou "PrintTable()"
    • L'exécution de "print" et "PrintTable" n'est pas visible pour le client
    • L'exécution de "print" et "PrintTable" sera redirigée vers votre console
    • Exemple 1 : "PrintTable(hook.GetTable())"
    • Exemple 2 : "local nick = LocalPlayer():Nick() print(nick)"
    
    Historique :
    • Utilisez les flèches HAUT et BAS pour naviguer dans l'historique
    • Utilisez TAB pour l'autocomplétion
    
    Sécurité :
    • Exécutez du code Lua de manière responsable
    • Le code exécuté pourrait être visible pour le client
    • Le code exécuté pourrait être bloqué ou manipulé par le client]],
    ["menu_elem_help"] = "Aide",
    ["menu_elem_filetime"] = "Dernière modification du fichier : %s",
    ["menu_elem_filesize"] = "Taille du fichier : %s",
    ["menu_elem_download"] = "Télécharger",
    ["menu_elem_download_confirm"] = "Êtes-vous sûr de vouloir télécharger le fichier suivant ?\n%q",
    ["menu_elem_download_progress"] = "Chargement du morceau %i/%i...",
    ["menu_elem_download_finished_part"] = "Le fichier a été partiellement téléchargé et enregistré dans votre dossier de données local Garry's Mod :\n%q",
    ["menu_elem_download_finished"] = "Le fichier a été téléchargé et enregistré dans votre dossier de données local Garry's Mod :\n%q",
    ["menu_elem_download_failed"] = "Échec du téléchargement : %q",
    ["menu_elem_download_started"] = "Téléchargement du fichier : %q",
    ["menu_elem_download_confirmbutton"] = "Télécharger",
    ["menu_elem_canceldel"] = "Annuler et supprimer",
    
    ["menu_elem_ddos_active"] = "Protection DDoS activée!",
    ["menu_elem_ddos_inactive"] = "Protection DDoS désactivée",
    ["menu_elem_ddos_duration"] = "Durée: %s",
    ["menu_elem_ddos_avg"] = "RX moyen: %s",
    ["menu_elem_ddos_max"] = "RX max: %s",
    ["menu_elem_ddos_stopped"] = "Stopped at: %s",
    ["menu_elem_ddos_stats"] = "Stats de la dernière attaque:",
    ["menu_elem_ddos_cpu_util"] = "Utilisation CPU",
    ["menu_elem_ddos_net_util"] = "Utilisation réseau",

    ["indicator_pending"] = "Le joueur n'a pas encore envoyé ses indicateurs au serveur. Soit il les bloque, soit il a besoin de plus de temps.",
    ["indicator_install_fresh"] = "Le joueur a récemment installé ce jeu",
    ["indicator_install_reinstall"] = "Le joueur a récemment réinstallé ce jeu",
    ["indicator_advanced"] = "Le joueur utilise des commandes de débogage/développeur (il sait peut-être ce qu'il fait...)",
    ["indicator_first_connect"] = "Première connexion à ce serveur (si le jeu n'a pas été réinstallé)",
    ["indicator_cheat_hotkey"] = "Le joueur a appuyé sur une touche (INSERT, HOME, PAGEUP, PAGEDOWN) souvent utilisée pour ouvrir des menus de triche",
    ["indicator_cheat_menu"] = "Le joueur a ouvert un menu en utilisant l'une des touches INSERT, HOME, PAGEUP ou PAGEDOWN",
    ["indicator_bhop"] = "Le joueur a un bind bunnyhop sur sa molette de souris (comme 'bind mwheelup +jump')",
    ["indicator_memoriam"] = "Le joueur a utilisé la triche 'Memoriam' dans le passé ou le fait actuellement",
    ["indicator_multihack"] = "Le joueur a utilisé la triche 'Garrysmod 64-bit Visuals Multihack Reborn' dans le passé ou le fait actuellement",
    ["indicator_fenixmulti"] = "Le joueur a utilisé la triche 'FenixMulti' dans le passé ou le fait actuellement",
    ["indicator_interstate"] = "Le joueur a utilisé la triche 'interstate editor' dans le passé ou le fait actuellement",
    ["indicator_exechack"] = "Le joueur a utilisé la triche payante 'exechack' dans le passé ou le fait actuellement",
    ["indicator_banned"] = "Le joueur a été banni par Nova Defender sur un autre serveur",
    ["indicator_lua_binaries"] = "Le joueur a des fichiers DLL dans le dossier 'garrysmod/lua/bin'. Les triches sont souvent placées ici. Les fichiers peuvent être consultés dans l'onglet 'Inspection'. Ces fichiers doivent avoir été créés manuellement par le joueur.",
    ["indicator_profile_familyshared"] = "Le joueur a un compte partagé en famille",
    ["indicator_profile_friend_banned"] = "Un ami Steam de ce joueur a été banni par Nova Defender",
    ["indicator_profile_recently_created"] = "Le profil Steam a été créé au cours des 7 derniers jours",
    ["indicator_profile_nogames"] = "Le joueur n'a encore acheté aucun jeu sur son profil Steam",
    ["indicator_profile_new_player"] = "Le joueur n'a pas joué à Garry's Mod pendant plus de 2 heures au total",
    ["indicator_profile_vac_banned"] = "Le joueur a déjà reçu une interdiction VAC",
    ["indicator_profile_vac_bannedrecent"] = "Le joueur a déjà reçu une interdiction VAC au cours des 5 derniers mois",
    ["indicator_profile_community_banned"] = "Le joueur a déjà reçu une interdiction de la communauté Steam",
    ["indicator_profile_not_configured"] = "Le joueur n'a même pas encore configuré son compte Steam",
    ["indicator_scenario_bypass_account"] = "Les indicateurs suggèrent que ce joueur a spécialement créé un nouveau compte Steam. Voir l'onglet 'Joueurs en ligne'.",
    ["indicator_scenario_cheatsuspect"] = "Les indicateurs suggèrent que ce joueur a triché. Voir l'onglet 'Joueurs en ligne'",
    ["indicator_scenario_sum"] = "Le joueur est suspect car il répond à un grand nombre d'indicateurs typiques. Voir l'onglet 'Joueur en ligne'",
    ["internal_reason"] = "Raison interne",
    ["banned"] = "Banni",
    ["status"] = "Statut",
    ["reason"] = "Raison",
    ["unban_on_sight"] = "Débannir à vue",
    ["ip"] = "IP",
    ["ban_on_sight"] = "Bannir à vue",
    ["time"] = "Temps",
    ["comment"] = "Commentaire",
    ["steamid"] = "SteamID32",
    ["steamid64"] = "SteamID64",
    ["usergroup"] = "Groupe d'utilisateurs",
    ["familyowner"] = "Propriétaire du partage familial",
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
    ["dont_care"] = "Je m'en fiche",
    ["action_taken_at"] = "Action prise à",
    ["action_taken_by"] = "Action prise par",
    ["sev_none"] = "Aucun",
    ["sev_low"] = "Faible",
    ["sev_medium"] = "Moyen",
    ["sev_high"] = "Élevé",
    ["sev_critical"] = "Critique",    
}

// DO NOT CHANGE ANYTHING BELOW THIS
if SERVER then
    Nova["languages_" .. lang] = function() return phrases end
else
    NOVA_SHARED = NOVA_SHARED or {}
    NOVA_SHARED["languages_" .. lang] = phrases
end