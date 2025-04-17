local lang = "de"

local phrases = {
    /*
        Notifications
    */
    ["menu_logging_debug"] = "Debug Modus:\nErzeugt zusätzliche Informationen in der Serverkonsole.",
    ["menu_notify_timeopen"] = "Anzeigedauer Benachrichtigung in Sekunden",
    ["menu_notify_showstaff"] = "Zeige Benachrichtigungen Teammitgliedern.",
    ["menu_notify_showinfo"] = "Informationsbenachrichtigungen anzeigen",
    ["menu_access_player"] = "Teammitglieder haben Zugriff auf 'Spieler Online'-Tab. Spieler mit einem höheren Rang können aber nicht ausgewählt werden.",
    ["menu_access_staffseeip"] = "Teammitglieder können die IP-Adressen von Spielern einsehen.",
    ["menu_access_detections"] = "Teammitglieder haben Zugriff auf 'Erkennungen'-Tab.",
    ["menu_access_bans"] = "Teammitglieder haben Zugriff auf 'Bans'-Tab.",
    ["menu_access_health"] = "Teammitglieder haben Zugriff auf 'Gesundheit'-Tab.",
    ["menu_access_inspection"] = "Teammitglieder haben Zugriff auf 'Spieleranalyse'-Tab.",
    ["menu_access_ddos"] = "Teammitglieder haben Zugriff auf 'DDoS'-Tab.",

    ["menu_action_timeopen"] = "Anzeigedauer einer Spielermeldung in Sekunden.",
    ["menu_action_showstaff"] = "Frage Teammitglieder nach Bestrafungen wenn keine Admins online sind (oder AFK).",
    /*
        Networking
    */
    ["networking_concommand_logging"] = "Konsolenbefehle loggen:\nLogge jeden Konsolenbefehl vom Server und Spielern",
    ["networking_concommand_dump"] = "Konsolenbefehle im Serverlog:\nGib alle Befehle, die ein Spieler ausgeführt hat, auf der Konsole aus, wenn er die Verbindung trennt. Dies kann die Größe der Logs sehr schnell erhöhen.",
    ["networking_netcollector_dump"] = "Netmessages im Serverlog:\nGibt alle Netmessages, die ein Spieler an den Server gesendet hat, auf die Konsole aus, wenn er die Verbindung trennt.",
    ["networking_netcollector_spam_action"] = "Was soll passieren, wenn ein Spieler Netmessages an den Server spammt?",
    ["networking_netcollector_spam_reason"] = "Grund für den Kick oder Bann eines Spielers durch Spamming von Netmessages an den Server.",
    ["networking_dos_action"] = "Was sollte passieren, wenn ein Spieler versucht, Server-Lags zu verursachen?",
    ["networking_dos_reason"] = "Grund für den Kick oder Bann eines Spielers, wenn er Server-Lags verursacht.",
    ["networking_dos_sensivity"] = "Sensitivität Server-Lag Erkennung",
    ["networking_dos_crash_enabled"] = "Erkenne Dekomprimierungs-Angriffe:\nClients können stark komprimierte Daten an den Server senden. Wenn sie entpackt werden, können sie leicht bis zu 400 MB an Daten erreichen und den Server zum laggen oder Absturz bringen. Ein Client kann maximal 65 KB an den Server senden. Daten haben  normalerweise eine Kompressionsrate von ungefähr 20:1 (abhängig von den Daten). Wir würden also etwa 1 MB dekomprimierte Daten erwarten. Ein Kompressionsverhältnis von 1000:1 oder sogar 7000:1 hat keinen legitimen Anwendungsfall. Diese Option überschreibt util.Decompress und erfordert keinen Neustart.",
    ["networking_dos_crash_action"] = "Was soll passieren, wenn ein Spieler versucht, den Server zum Absturz zu bringen?",
    ["networking_dos_crash_ignoreprotected"] = "Geschützte Spieler ignorieren. ",
    ["networking_dos_crash_maxsize"] = "Maximale dekomprimierte Größe in MB:\nWenn sie erreicht ist, wird die Dekomprimierung abgebrochen.",
    ["networking_dos_crash_ratio"] = "Maximales Kompressionsverhältnis:\nNormale Daten haben ein Kompressionsverhältnis von etwa 20:1. Ein Kompressionsverhältnis von 1000:1 oder sogar 7000:1 hat keinen legitimen Anwendungsfall. Setzen Sie diesen Wert nicht zu niedrig an, da dies zu Fehlalarmen führt.",
    ["networking_dos_crash_whitelist"] = "Gewhitelistete Netmessages die ignoriert werden.",
    ["networking_netcollector_actionAt"] = "Ab wie vielen Nachrichten von einem einzelnen Spieler innerhalb von 3 Sekunden sollt gehandelt werden? SETZE DIESEN WERT NIE ZU TIEF!",
    ["networking_netcollector_dropAt"] = "Ab wie vielen Nachrichten innerhalb von 3 Sekunden sollten diese ignoriert werden. Dies geschieht, um einen Denial of Service zu verhindern. Sollte niedriger sein als die obige Einstellung.",
    ["networking_restricted_message_action"] = "Was soll passieren, wenn ein Spieler eine Netmessage an den Server sendet, die er nicht senden darf? Ohne Manipulation des Spiels oder einen Bug ist es für Spieler nicht möglich, diese Netmessage zu senden.",
    ["networking_restricted_message_reason"] = "Ein Spieler wird gekickt oder gebannt, wenn er eine Nachricht an den Server sendet, die er nicht senden darf.",
    ["networking_sendlua_gm_express"] = "Aktiviere gm_express:\nMassive Performance-Verbesserung, insbesondere für größere Server. Anstatt große Datenmengen über die eingebauten Netmessages zu versenden (langsam), werden diese via HTTPS über einen externen Provider (gmod.express) an die Clients übertragen. Dies beschleunigt die Ladezeit von Clients und entlastet den Server. Diese Option ist jedoch abhängig von gmod.express. Ist diese Seite nicht erreichbar, schlägt die Authentifizierung für Clients fehl. Neue Clients, welche sich nicht mit gmod.express verbinden können, greifen auf die herkömmlichen Netmessages zurück. Diese Option setzt die Installation von gm_express voraus. Mehr Details im Tab 'Gesundheit'.",
    ["networking_sendlua_authfailed_action"] = "Was soll passieren, wenn ein Spieler nicht auf die Nova Defender-Authentifizierung reagiert? Wenn er nicht authentifiziert ist, gibt es keine Garantie dafür, dass das Anticheat oder andere clientseitige Mechanismen funktionieren.",
    ["networking_sendlua_authfailed_reason"] = "Grund für den Kick oder Ban eines Spielers, der nicht auf die Nova Defender-Authentifizierung reagiert.",
    ["networking_sendlua_validationfailed_action"] = "Was soll passieren, wenn ein Spieler den Code von Nova Defender blockiert?",
    ["networking_sendlua_validationfailed_reason"] = "Grund für den Kick oder Ban eines Spielers durch Blockieren von Code von Nova Defender.",
    ["networking_fakenets_backdoors_load"] = "Erstelle Fake-Backdoors um Angreifer zu erkennen, die sie benutzen wollen.",
    ["networking_fakenets_backdoors_block"] = "Backdoors auf dem Server blockieren. Könnte legitime Netmessages blockieren und Addons kapuut machen! Schaue dir zuerst den Tab 'Gesundheit' an und prüfe ob es keine bestehenden Backdoors gibt.",
    ["networking_fakenets_backdoors_action"] = "Was soll passieren, wenn ein Angreifer eine Fake-Backdoor benutzt?",
    ["networking_fakenets_exploits_load"] = "Erstelle Fake-Sicherheitslücken um Angreifer zu erkennen, die sie benutzen wollen.",
    ["networking_fakenets_exploits_block"] = "Blockiere Netmessages mit Sicherheitslücken. Addons mit vermutlichen Sicherheitslücken funktionieren dann nicht mehr! Schaue dir zuerst den Tab 'Gesundheit' an und prüfe ob es bestehenden Sicherheitslücken gibt.",
    ["networking_fakenets_exploits_action"] = "Was soll passieren, wenn ein Angreifer eine Fake-Sicherheitslücke benutzt?",
    ["networking_vpn_vpn-action"] = "Was sollte geschehen, wenn ein Spieler ein VPN benutzt?",
    ["networking_vpn_vpn-action_reason"] = "Grund für den Kick oder Bann eines Spielers, bei Verwendung eines VPN.",
    ["networking_vpn_country-action"] = "Was soll passieren, wenn ein Spieler aus einem nicht zugelassenen Land kommt?",
    ["networking_vpn_country-action_reason"] = "Grund für den Kick oder Bann eines Spielers, der aus einem nicht zugelassenen Land kommt.",
    ["networking_vpn_dump"] = "Gibt Informationen über die IP-Adresse eines Spielers zusätzlich in der Konsole aus.",
    ["networking_vpn_apikey"] = "VPN API-Key:\nFür Untersuchung von IP-Addressen. Erstelle zuerst hier einen Account https://www.ipqualityscore.com/create-account und bekomme deinen API-Key unter https://www.ipqualityscore.com/user/settings.",
    ["networking_vpn_countrycodes"] = "Erlaubte Länder von Spielern. Ländercodes findest du hier: https://countrycode.org/ (2-Buchstaben-Code in Großbuchstaben). Es empfiehlt sich, dein eigenes und benachbarte Länder auf die Whitelist zu setzen. Nach und nach können weitere Länder hinzugefügt werden.",
    ["networking_vpn_whitelist_asns"] = "Erlaubte ASN-Nummern (Nummer zur Identifizierung eines Internetanbieters). Es kann vorkommen, dass die API fälschlicherweise eine VPN erkennt. Daher sind bekannte ASNs hiervon ausgeschlossen. ASN-Nummern erhälst du hier: https://ipinfo.io/countries. Alternativ kannst du die ASN jedes verbundenen Spielers im Tab 'Spieler online' sehen.",
    ["networking_screenshot_store_ban"] = "Speichere Screenshot (bei einem Ban):\nKurz bevor ein Spieler gebannt wird, wird ein Screenshot seines Bildschirms gemacht und im Ordner '/data/nova/ban_screenshots' des Servers gespeichert.",
    ["networking_screenshot_store_manual"] = "Speichere Screenshot (über das Menü):\nWenn ein Admin einen Screenshot von einem Spieler macht, wird dieser im Ordner '/data/nova/admin_screenshots' des Servers gespeichert.",
    ["networking_screenshot_limit_ban"] = "Screenshot Limit (bei einem Ban):\nMaximale Anzahl von Screenshots, die auf dem Server gespeichert werden. Die ältesten werden gelöscht.",
    ["networking_screenshot_limit_manual"] = "Screenshot Limit (über das Menü):\nMaximale Anzahl von Screenshots, die auf dem Server gespeichert werden. Die ältesten werden gelöscht.",
    ["networking_screenshot_quality"] = "Screenshot-Qualität\nScreenshots mit hoher Qualität können bis zu einer Minute für die Übertragung benötigen.",

    ["networking_http_overwrite"] = "Untersuche HTTP-Aufrufe (Senden+Empfangen):\nIst diese Einstellung aktiviert, wird die HTTP-Funktion überschrieben und Anfragen können protokolliert oder blockiert werden. Diese Methode kann jedoch auch umgangen werden oder DRM-Systeme deaktivieren.",
    ["networking_http_logging"] = "Anfragen protokollieren:\nAlle HTTP-Anfragen werden im Detail in der Konsole geloggt. Dies ist nützlich, um einen Überblick darüber zu erhalten, welche URLs aufgerufen werden. Funktioniert nur, wenn HTTP-Anfragen untersucht werden.",
    ["networking_http_blockunsafe"] = "Unsichere Anfragen blockieren:\nAnfragen, die von unsicheren Quellen wie Konsole oder RunString stammen, werden blockiert.",
    ["networking_http_whitelist"] = "Whitelist aktivieren:\nNur Domains und IP-Adressen, die der Liste hinzugefügt wurden, werden zugelassen.",
    ["networking_http_whitelistdomains"] = "Domains whitelisten:\nFüge alle vertrauten Domains und IPs die erlaubt sein sollen hinzu. Alles andere wird blockiert. Wenn du dir nicht sicher bist, welche Domain auf die Whitelist gesetzt werden sollen, deaktiviere die Whitelist und schalte nur die Protokollierung ein.",

    ["networking_fetch_overwrite"] = "Untersuche http.Fetch (Empfangen von Daten):\nÜberschreibt die http.Fetch-Funktion. NICHT AKTIVIEREN, WENN DU VCMOD VERWENDEST! Diese Methode kann jedoch auch umgangen werden oder DRM-Systeme deaktivieren.",
    ["networking_fetch_whitelist"] = "Whitelist aktivieren:\nNur Domains und IP-Adressen, die der Liste hinzugefügt wurden, werden zugelassen.",
    ["networking_fetch_blockunsafe"] = "Unsichere Anfragen blockieren:\nAnfragen, die von unsicheren Quellen wie Konsole oder RunString stammen, werden blockiert.",

    ["networking_post_overwrite"] = "Untersuche http.Post (Senden von Daten):\nÜberschreibt die http.Post-Funktion. Das Senden von HTTP-Anfragen kann von Angreifern genutzt werden, um Dateien auf dem Server zu klauen. Diese Methode kann jedoch auch umgangen werden oder DRM-Systeme deaktivieren.",
    ["networking_post_whitelist"] = "Whitelist aktivieren:\nNur Domains und IP-Adressen, die der Liste hinzugefügt wurden, werden zugelassen.",
    ["networking_post_blockunsafe"] = "Unsichere Anfragen blockieren: \nAnfragen, die von unsicheren Quellen wie Konsole oder RunString stammen, werden blockiert.",
    
    ["networking_ddos_collect_days"] = "IP-Adressen-Sammeltage:\nDer DDoS-Schutz sammelt die IP-Adressen aller verbundenen Spieler der letzten n Tage. Wenn ein DDoS-Angriff erkannt wird, wird die gesamte Kommunikation zum Server blockiert (mit Ausnahme der verbundenen Spieler der letzten n Tage). Der Server ignoriert alle Spieler, die sich in den letzten n Tagen nicht mit dem Server verbunden haben. Der Server wird für sie unsichtbar sein.",
    ["networking_ddos_notify"] = "Benachrichtigung anzeigen, wenn ein DDoS-Angriff erkannt wird oder beendet ist.",
    /*
        Banbypass
    */
    ["banbypass_ban_banstaff"] = "Können Teammitglieder gebannt werden?",
    ["banbypass_ban_default_reason"] = "Grund für Ban eines Spielers, wenn kein Grund angegeben wird",

    ["banbypass_bypass_default_reason"] = "Grund für den Ban eines Spielers, wenn er versucht den Ban zu umgehen.",

    ["banbypass_bypass_familyshare_action"] = "Was soll passieren, wenn ein Spieler den Familysharing Account eines gebannten Spielers benutzt?",
    ["banbypass_bypass_clientcheck_action"] = "Was soll passieren, wenn in den lokalen Dateien eines Spielers Beweise für die Umgehung eines Bans sind?",
    ["banbypass_bypass_ipcheck_action"] = "Was soll passieren, wenn ein Spieler die gleiche IP-Adresse wie ein gebannter Spieler hat?",

    ["banbypass_bypass_fingerprint_enable"] = "Fingerabdruckprüfung aktivieren:\nDiese Option prüft, ob ein Spieler dasselbe Gerät wie ein gebannter Benutzer verwendet. Sie kann einen Spieler daran hindern, ein neues Konto auf demselben Gerät zu erstellen, solange er gesperrt ist.",
    ["banbypass_bypass_fingerprint_action"] = "Was sollte passieren, wenn ein Spieler dasselbe Gerät wie ein gebannter Benutzer verwendet?",
    ["banbypass_bypass_fingerprint_sensivity"] = "Wie empfindlich sollte der Fingerabdruckabgleich sein?",

    ["banbypass_bypass_indicators_apikey"] = "Steam API-Key:\nÜber die SteamAPI können genauere Daten über einen Spieler einegsehen werden. Funde werden im 'Spieler Online' Tab bei den Indikatoren angezeigt. Erstelle dir unter https://steamcommunity.com/dev/apikey einen und füge ihn hier ein.",
    /*
        Anticheat
    */
    ["anticheat_reason"] = "Grund für Ban eines Spielers, wenn er Cheats benutzt.",
    ["anticheat_enabled"] = "Anticheat aktivieren:\nWenn dies aktiviert ist, wird der Anticheat-Code an alle Clients gesendet und Cheats werden erkannt. Wenn dies nachträglich deaktiviert wird, bleibt der Anticheat-Code auf allen derzeit verbundenen Clients aktiv, aber Erkennungen werden ignoriert. Diese Option schließt Autoklick und Aimbot-Erkennung mit ein.",
    ["anticheat_action"] = "Was soll passieren, wenn ein Spieler Cheats benutzt?",
    ["anticheat_verify_action"] = "Was soll passieren, wenn das Anticheat bei einem Spieler nicht lädt?",
    ["anticheat_verify_execution"] = "Prüfe ob Anticheat läuft:\nNachdem ein Spieler das Anticheat erhält, wird eine Bestätigung angefordert, ob es aktiv ist. Dieser Prozess kann jedoch aus mehreren Gründen scheitern und sollte daher nicht auf 'ban' gesetzt werden.",
    ["anticheat_verify_reason"] = "Grund für Ban eines Spielers, wenn er das Anticheat nicht ausführt.",
    ["anticheat_check_function"] = "Funktionen prüfen:\nVergleicht Funktionsnamen auf dem Client mit bekannten Funktionsnamen von Cheats. Dabei können auch legitime Funktionen aus deinem Code erkannt werden.",
    ["anticheat_check_files"] = "Dateien prüfen:\nÄhnlich wie 'Funktionen prüfen'. Vergleicht den Dateinamen eines laufenden Skripts mit bekannten Dateinamen von Cheats.",
    ["anticheat_check_globals"] = "Globale Variablen prüfen:\nÄhnlich wie 'Funktionen prüfen'. Vergleicht Variablennamen mit bekannten Variablennamen von Cheats.",
    ["anticheat_check_modules"] = "Module prüfen:\nÄhnlich wie 'Funktionen prüfen'. Vergleicht Modulnamen mit bekannten Modulnamen von Cheats.",
    ["anticheat_check_runstring"] = "'RunString' prüfen:\nBeliebiger Lua-Code kann mit der eingebauten 'RunString'-Funktion ausgeführt werden. Diese Option erkennt die Verwendung dieser Funktion und sucht nach bekannten Mustern.",
    ["anticheat_check_external"] = "Externe Cheats:\nDamit werden externe Cheatprogramme erkannt. Generell sind diese aber in einer eingeschränkten Lua-Umgebung sehr schwer zu erkennen. Dies wird Profiler wie FProfiler verlangsamen.",
    ["anticheat_check_manipulation"] = "Manipulation:\nErkennt Versuche das Anticheat zu deaktivieren oder zu manipulieren.",
    ["anticheat_check_cvars"] = "Konsolen Variablen prüfen:\nÄhnlich wie 'Funktionen prüfen'. Einige Cheats verwenden cvars, um Einstellungen zu speichern. Vergleicht Cvar-Namen mit bekannten Cvar-Namen von Cheats.",
    ["anticheat_check_byte_code"] = "Code Kompilierung prüfen:\nIntern wird Lua-Code mit JIT in Bytecode kompiliert und dann interpretiert. Wir können manchmal feststellen, ob dies auf eine ungewöhnliche Weise geschieht. Beispielsweise wenn ein Spieler unerlaubt Code mit lua_run_cl ausführt.",
    ["anticheat_check_detoured_functions"] = "Funktion Überschreibung prüfen:\nEinige Cheats überschreiben die Funktionalität der eingebauten Funktionen, um Anticheats zu umgehen oder das Spielverhalten zu verändern.",
    ["anticheat_check_concommands"] = "Konsolenbefehle prüfen:\nÄhnlich wie 'Konsolenvariablen prüfen'. Auf einige Cheats kann über die Konsole zugegriffen werden. Vergleicht Befehlsnamen mit bekannten Befehlsnamen von Cheats.",
    ["anticheat_check_net_scan"] = "Scanning erkennen:\nEinige Skripte können den Server auf bekannte Sicherheitslücken oder Backdoors überprüfen. Auf der Serverseite wird durch Fake-Backdoors Abhilfe geschaffen.",
    ["anticheat_check_cheats_custom"] = "Bekannt Cheats erkennen:\nWeit verbreitete Cheats erkennen durch spezielle Analysen. Genaue Namen der Cheats werden im Grund angezeigt.",
    ["anticheat_check_cheats_custom_unsure"] = "Inaktive Cheats erkennen:\nBei der Erkennung einiger Cheats ist unbekannt, ob dieser gerade aktiv ist oder nicht. Sicher ist nur, dass die Person diesen Cheat einmal benutzt hat.",
    ["anticheat_check_experimental"] = "Experimentelle Erkennung aktivieren:\nAktiviert Erkennungen von Cheats, welche noch nicht getestet wurden. Spieler werden NICHT gebannt. Erkennungen werden in folgender Datei auf dem Server protokolliert: 'data/nova/anticheat/experimental.txt'. Diese Datei kann dem Entwickler zur Analyse gesendet werden.",
    ["anticheat_spam_filestealers"] = "Filestealer zumüllen:\nEinige Cheats speichern allen ausgeführten Lua-Code, den sie vom Server erhalten in Textdateien. Um diese Dateien zuzumüllen und es dem Angreifer (ein wenig) zu erschweren, wird unnötig Code ausgeführt. Dadurch füllt sich der Speicherplatz des Spielers langsam. Dies hat keinen negativen Einfluss auf die Ladezeit für Spieler.",
    ["anticheat_autoclick_enabled"] = "Autoklick Erkennung aktivieren:\nAus offensichtlichen Gründen wollen wir nicht, dass Spieler Programme für schnelles Klicken oder Tastenanschläge verwenden. Dazu gehören der Links- und Rechtsklick, 'E' und die Leertaste.",
    ["anticheat_autoclick_action"] = "Was soll passieren, wenn ein Spieler Autoclick benutzt?",
    ["anticheat_autoclick_reason"] = "Grund für Ban eines Spielers, wenn er Autoklicker benutzt.",
    ["anticheat_autoclick_sensivity"] = "Autoklick-Empfindlichkeit:\nEine hohe Empfindlichkeit kann Spieler aufgrund seltener Zufälle fälschlicherweise erkennen. Gute Autoklicker werden mit einer niedrigen Empfindlichkeit möglicherweise nicht erkannt. Wähle je nach dem wie groß der Vorteil durch Autoklicker ist, den sich ein Cheater verschaffen kann.",
    ["anticheat_autoclick_check_fast"] = "Zu schnelles klicken:\nAb einer bestimmten Anzahl von CPS (Clicks Per Second) können wir davon ausgehen, dass ein Mensch nicht in der Lage ist, dies ohne Hilfsmittel zu tun. Dies gilt auch für Tastendrücke.",
    ["anticheat_autoclick_check_fastlong"] = "Zu schnelles klicken über lange Zeit:\nEs ist unwahrscheinlich, dass ein Spieler mehrere Minuten lang ohne kurze Pausen enorm schnell klickt.",
    ["anticheat_autoclick_check_robotic"] = "Unmenschliche Klick-Konsistenz prüfen:\nEin Mensch kann nie mit exakt derselben Geschwindigkeit klicken. Er wird immer ein wenig schneller oder langsamer sein. Ein Programm kann dies jedoch sehr genau timen. Wenn der Zeitabstand zwischen den Klicks zu gleichmäßig ist, können wir das feststellen.",
    ["anticheat_aimbot_enabled"] = "Aimbot Erkennung aktivieren:\nÜberwacht in Echtzeit alle bewegungen der Spieler.",
    ["anticheat_aimbot_action"] = "Was soll passieren, wenn ein Spieler einen Aimbot benutzt?",
    ["anticheat_aimbot_reason"] = "Grund für Ban eines Spielers, wenn er einen Aimbot benutzt.",
    ["anticheat_aimbot_check_snap"] = "Snapping erkennen:\nErkennen, ob sich die Blickrichtung des Spielers sofort ändert. WARNUNG: Dies verhindert, dass Clients ihre Blickwinkel einstellen können (wenn dies nicht serverseitig geschieht) und kann daher die Funktion einiger Addons beeinträchtigen!",
    ["anticheat_aimbot_check_move"] = "Verdächtige Bewegungen erkennen:\nErkennt, ob ein Spieler seine Blickrichtung ändert, ohne die Maus zu bewegen.",
    ["anticheat_aimbot_check_contr"] = "Widersprüchliche Bewegungen erkennen:\nErkennt, ob ein Spieler seine Maus in eine andere Richtung bewegt, als sich sein Blick ändert.",
    /*
        Exploit
    */
    ["exploit_fix_propspawn"] = "Propspawn:\nVerhindert das Spawnen von Props mit kopiertem Material.",
    ["exploit_fix_material"] = "Material:\nVerhindert das Kopieren von Materialien.",
    ["exploit_fix_fadingdoor"] = "Fadingdoor:\nVerhindert Grafik-Bug der einen Blackscreen bei vielen Spielern erzeugt.",
    ["exploit_fix_physgunreload"] = "Physgun:\nVerhindert Nachladen der Physgun von Nutzern.",
    ["exploit_fix_bouncyball"] = "Bouncyball:\nVerhindert Verbinden von 'Bouncy Balls'.",
    ["exploit_fix_bhop"] = "Bunnyhop:\nVerhindert bunnyhopping.",
    ["exploit_fix_serversecure"] = "Serversecure automatisch einrichten:\nSiehe 'Gesundheit'-Tab für weitere Informationen.",
    /*
        Security
    */
    ["security_permissions_groups_protected"] = "Geschützte Benutzergruppen:\nAlle Benutzergruppen, die als geschützt gelten. Nur Spieler, die auf der Whitelist stehen, können diese Gruppe haben. Geschützte Spieler haben Zugriff auf dieses Menü.",
    ["security_permissions_groups_staff"] = "Teammitglieder Benutzergruppen:\nAlle Benutzergruppen, die Teammitglieder haben.",
    ["security_privileges_group_protection_enabled"] = "Automatischer Rang-Schutz:\nWenn ein Spieler, der nicht auf der Whitelist steht, z.B. eine geschützte Benutzergruppe hat oder einem geschützen Benutzer entfernt wird, wird gehandelt.",
    ["security_privileges_group_protection_escalation_action"] = "Was soll passieren, wenn ein Spieler eine geschütze Benutzergruppe hat, die er nicht haben soll?",
    ["security_privileges_group_protection_escalation_reason"] = "Grund, warum ein Spieler gekickt oder gebannt wird, wenn er eine geschütze Benutzergruppe hat, die er nicht haben darf.",
    ["security_privileges_group_protection_removal_action"] = "Was soll passieren, wenn ein geschützter Spieler seine Benutzergruppe verliert?",
    ["security_privileges_group_protection_protected_players"] = "Geschützte Spieler:\nAlle Spieler, die eine geschützte Benutzergruppe haben. Wenn du einen Spieler entfernst, der online ist, wird er gekickt.",
    ["security_privileges_group_protection_kick_reason"] = "Grund für den Kick eines geschützten Spielers, wenn sein Schutz entfernt wird, während er verbunden ist.",
    /*
        Detections
    */
    ["config_detection_banbypass_familyshare"] = "Familysharing Account zur Banumgehung",
    ["config_detection_banbypass_clientcheck"] = "Banumgehung Clientprüfung",
    ["config_detection_banbypass_ipcheck"] = "Banumgehung IP-Prüfung",
    ["config_detection_banbypass_fingerprint"] = "Banumgehung Fingerabdruck",
    ["config_detection_networking_country"] = "Land von Spieler nicht erlaubt",
    ["config_detection_networking_vpn"] = "Nutzung eines VPN",
    ["config_detection_networking_backdoor"] = "Nutzung einer Fake-Backdoor",
    ["config_detection_networking_spam"] = "Spammt Netmessages",
    ["config_detection_networking_dos"] = "Verursacht Serverlags",
    ["config_detection_networking_dos_crash"] = "ersuchter Serverabsturz mit großem Paket",
    ["config_detection_networking_authentication"] = "Kann sich nicht mit Server authentifizieren",
    ["config_detection_networking_restricted_message"] = "Sendet Netmessage nur für Admins an Server",
    ["config_detection_networking_exploit"] = "Benutzt Fake-Exploit",
    ["config_detection_networking_validation"] = "Führt Nova Defender Code nicht aus",
    ["config_detection_anticheat_scanning_netstrings"] = "Suche nach Backdoors/Exploits",
    ["config_detection_anticheat_runstring_dhtml"] = "Codeausführung via DHTML",
    ["config_detection_anticheat_runstring_bad_string"] = "RunString beinhaltet Cheat-Muster (Text)",
    ["config_detection_anticheat_remove_ac_timer"] = "Umgeht Anticheat",
    ["config_detection_anticheat_gluasteal_inject"] = "Filestealer um Code auszuführen",
    ["config_detection_anticheat_function_detour"] = "Überschreibt Funktionen",
    ["config_detection_anticheat_external_bypass"] = "Externe Cheats",
    ["config_detection_anticheat_runstring_bad_function"] = "RunString beinhaltet Cheat-Muster (Funktionen)",
    ["config_detection_anticheat_jit_compilation"] = "Untypische Bytecode Kompilierung",
    ["config_detection_anticheat_known_cvar"] = "Cvar aus Cheats",
    ["config_detection_anticheat_known_file"] = "Cheat-Datei gefunden",
    ["config_detection_anticheat_known_data"] = "Cheat Überreste gefunden",
    ["config_detection_anticheat_known_module"] = "Cheat Modul ausgeführt",
    ["config_detection_anticheat_known_concommand"] = "Konsolen Befehl aus Cheat",
    ["config_detection_anticheat_verify_execution"] = "Blockiert Anticheat",
    ["config_detection_anticheat_known_global"] = "Variable aus Cheats",
    ["config_detection_anticheat_known_cheat_custom"] = "Bekannter Cheat",
    ["config_detection_anticheat_known_function"] = "Funktion aus Cheats",
    ["config_detection_anticheat_manipulate_ac"] = "Manipuliert das Anticheat",
    ["config_detection_anticheat_autoclick_fast"] = "Unmenschliche Klickgeschwindigkeit",
    ["config_detection_anticheat_autoclick_fastlong"] = "Schnelle Klickgeschwindigkeit über lange Zeit",
    ["config_detection_anticheat_autoclick_rebotic"] = "Unmenschlich genaue Klick-Zeitabstände",
    ["config_detection_anticheat_aimbot_snap"] = "Aimbot (sofortiger Blickwechsel innerhalb eines Ticks)",
    ["config_detection_anticheat_aimbot_move"] = "Aimbot (verdächtige Bewegung)",
    ["config_detection_anticheat_aimbot_contr"] = "Aimbot (widersprüchliche Bewegung)",
    ["config_detection_security_privilege_escalation"] = "Hat zu hohen Rang",
    ["config_detection_admin_manual"] = "Manueller Ban durch Nova Defender oder Admin",
    /*
        Notifications
    */
    ["menu_notify_hello_staff"] = "Dieser Server ist geschützt durch Nova Defender.\nDu bist als Teammitglied eingestuft.",
    ["menu_notify_hello_protected"] = "Dieser Server ist geschützt durch Nova Defender.\nDu bist als 'Geschützt' eingestuft.",
    ["menu_notify_hello_menu"] = "Öffne das Menü mit !nova.",

    ["notify_admin_unban"] = "Erfolgreich %s entbannt. Ban wird entfernt, sobald der Spieler das nächste Mal auf dem Server ist.",
    ["notify_admin_ban"] = "Erfolgreich %s gebannt. Spieler wird gebannt, sobald er das nächste Mal auf dem Server ist.",
    ["notify_admin_ban_online"] = "Admin %s hat %s gebannt. Spieler wird in einigen Sekunden gekicked.",
    ["notify_admin_ban_offline"] = "Admin %s hat %s gebannt. Spieler wird gebannt, sobald er das nächste Mal auf dem Server ist.",
    ["notify_admin_ban_fail"] = "Ban von %s nicht möglich: %q",
    ["notify_admin_kick"] = "Admin %s hat %s vom Server gekicked",
    ["notify_admin_reconnect"] = "Admin %s hat %s neu verbinden lassen",
    ["notify_admin_quarantine"] = "Admin %s hat %s in Netzwerk-Quarantäne versetzt. Er kann nun mit nichts auf dem Server mehr interagieren.",
    ["notify_admin_unquarantine"] = "Admin %s hat %s aus Netzwerk-Quarantäne entfernt",
    ["notify_admin_no_permission"] = "Du bist hierzu nicht berechtigt",
    ["notify_admin_client_not_connected"] = "Spieler ist offline",
    ["notify_admin_already_inspecting"] = "Du untersuchst bereits einen anderen Spieler",

    ["notify_anticheat_detection"] = "Anticheat Erkennung %q bei %s. Grund: %q",
    ["notify_anticheat_detection_action"] = "Anticheat: %q",

    ["notify_anticheat_issue_fprofiler"] = "Wenn das Anticheat aktiv ist, funktioniert das client-seitige Profiling nicht!",

    ["notify_aimbot_detection"] = "Aimbot Erkennung %q bei %s. Grund: %q",
    ["notify_aimbot_detection_action"] = "Aimbot: %q",

    ["notify_anticheat_verify"] = "Clientseitiges Anticheat bei %s konnte nicht geladen werden. Dies kann auch durch eine langsame Verbindung verursacht werden.",
    ["notify_anticheat_verify_action"] = "Clientseitiges Anticheat konnte nicht geladen werden. Dies kann auch durch eine langsame Verbindung verursacht werden.",

    ["notify_banbypass_ban_fail"] = "Ban von %s für %q nicht möglich: %s",
    ["notify_banbypass_kick_fail"] = "Kick von %s für %q nicht möglich: %s",

    ["notify_banbypass_bypass_fingerprint_match"] = "%s umgeht möglicherweise einen Ban: Fingerabdruck ähnelt gebannter SteamID %s | Übereinstimmung: %d%%",
    ["notify_banbypass_bypass_fingerprint_match_action"] = "Umgeht möglicherweise einen Ban: Fingerabdruck ähnelt gebannter SteamID %s | Übereinstimmung: %d%%",

    ["notify_banbypass_familyshare"] = "Umgeht möglicherweise einen Ban: Familysharing Account von gebannter SteamID %s",
    ["notify_banbypass_familyshare_action"] = "Umgeht möglicherweise einen Ban: Familysharing Account von gebannter SteamID %s",

    ["notify_banbypass_clientcheck"] = "Umgeht möglicherweise einen Ban: Beweise für Banumgehung in lokalen Dateien von %s | Beweistyp: %s",
    ["notify_banbypass_clientcheck_action"] = "Umgeht möglicherweise einen Ban: Beweise für Banumgehung in lokalen Dateien von %s | Beweistyp: %s",

    ["notify_banbypass_ipcheck"] = "Umgeht möglicherweise einen Ban: Hat gleiche IP-Adresse wie gebannter Spieler %s",
    ["notify_banbypass_ipcheck_action"] = "Umgeht möglicherweise einen Ban: Hat gleiche IP-Adresse wie gebannter Spieler %s",

    ["notify_networking_exploit"] = "%s hat einen Exploit benutzt: %q",
    ["notify_networking_exploit_action"] = "Benutzung eines Exploits: %q",
    ["notify_networking_backdoor"] = "%s hat eine Backdoor benutzt: %q",
    ["notify_networking_backdoor_action"] = "Benutzung einer Backdoor: %q",

    ["notify_networking_spam"] = "%s spammt Netmessages (%d/%ds) (%d allowed).",
    ["notify_networking_spam_action"] = "Spamming von Netmessages (%d/%ds) (%d allowed).",
    ["notify_networking_limit"] = "%s hat das Limit von %d Netmessages pro %d Sekunden erreicht.",
    ["notify_networking_limit_drop"] = "Ignoriere Netmessages von %s das er das Limit von %d Nachrichten pro %d Sekunden erreicht hat.",

    ["notify_networking_dos"] = "%s hat einen Serverlag verursacht. Dauer: %s innerhalb von %d Sekunden",
    ["notify_networking_dos_action"] = "Verursacht Serverlags. Dauer: %s innerhalb von %d Sekunden",

    ["notify_networking_dos_crash"] = "%s hat versucht Server mit großem Paket zum Absturz zu bringen. Nachricht: %q, Größe: %s, Komprimierungsrate: %s",
    ["notify_networking_dos_crash_action"] = "Versuchter Servercrash mit großen Paket. Nachricht: %q ,Größe: %s, Komprimierungsrate: %s",

    ["notify_networking_restricted"] = "%s versucht Netmessage %q beschränkt auf %q zu senden. Dies kann ohne Manipulation nicht geschehen.",
    ["notify_networking_restricted_action"] = "Hat Netmessage %q beschränkt auf %q gesendet. Dies kann ohne Manipulation nicht geschehen.",

    ["notify_networking_screenshot_failed_multiple"] = "Screenshot von %s fehlgeschlagen: Nur ein Screenshot gleichzeitig möglich.",
    ["notify_networking_screenshot_failed_progress"] = "Screenshot von %s fehlgeschlagen: Ein anderer Screenshot für die Person ist aktuell im Gange.",
    ["notify_networking_screenshot_failed_timeout"] = "Screenshot von %s fehlgeschlagen: Keinen Screenshot vom Client erhalten.",
    ["notify_networking_screenshot_failed_empty"] = "Screenshot von %s fehlgeschlagen: Antwort ist leer. Dies kann passieren, wenn er durch einen Cheat blockiert wurde oder der Spieler sich im Escape-Menü befindet.", 

    ["notify_networking_auth_failed"] = "%s konnte sich nicht beim Server authentifizieren. Dies kann auch durch eine langsame Verbindung verursacht werden.",
    ["notify_networking_auth_failed_action"] = "Konnte sich nicht beim Server authentifizieren. Dies kann auch durch eine langsame Verbindung verursacht werden.",
    ["notify_networking_sendlua_failed"] = "%s hat Nova Defender Code nicht ausgeführt. Dies kann auch durch eine langsame Verbindung verursacht werden.",
    ["notify_networking_sendlua_failed_action"] = "Hat Nova Defender Code nicht ausgeführt. Dies kann auch durch eine langsame Verbindung verursacht werden.",
    
    ["notify_networking_issue_gm_express_not_installed"] = "gm_express ist nicht auf dem Server installiert. Mehr Details im Tab 'Gesundheit'.",

    ["notify_networking_vpn"] = "%s benutzt ein VPN: %s",
    ["notify_networking_vpn_action"] = "Benutzt VPN: %s",
    ["notify_networking_country"] = "%s ist von einem nicht erlaubten Land. %s",
    ["notify_networking_country_action"] = "Ist von einem nicht erlaubten Land. %s",

    ["notify_security_privesc"] = "%s hat die Benutzergruppe %q für die er nicht gewhitelisted ist.",
    ["notify_security_privesc_action"] = "Hat die Benutzergruppe %q für die er nicht gewhitelisted ist.",

    ["notify_functions_action"] = "Was soll gegen %s unternommen werden?\nGrund: %s",
    ["notify_functions_action_notify"] = "Admin %s hat gegen Erkennung %q von %s folgendes unternommen: %q",
    ["notify_functions_allow_success"] = "Erkennung erfolgreich ausgeschlossen.",
    ["notify_functions_allow_failed"] = "Diese Erkennung kann nicht ausgeschlossen werden.",

    ["notify_custom_extension_ddos_protection_attack_started"] = "DDoS-Angriff erkannt. Live-Status im Menü mit !nova",
    ["notify_custom_extension_ddos_protection_attack_stopped"] = "DDoS-Angriff beendet. Details im Menü mit !nova",
    /*
        Health
    */
    ["health_check_gmexpress_title"] = "Express Modul",
    ["health_check_gmexpress_desc"] = "Massive Performance-Verbesserung, insbesondere für größere Server. Erstellt von CFC Servers.",
    ["health_check_gmexpress_desc_long"] =
[[Anstatt große Datenmengen über die eingebauten Netmessages zu versenden (langsam),
werden diese via HTTPS über einen externen Provider (gmod.express) an die Clients
übertragen. Dies beschleunigt die Ladezeit von Clients und entlastet den Server.
Diese Option ist jedoch abhängig von gmod.express. Ist diese Seite nicht erreichbar,
schlägt die Authentifizierung für Clients fehl. Neue Clients, welche sich nicht mit
gmod.express verbinden können, greifen auf die herkömmlichen Netmessages zurück.

Zum Installieren gehe auf: https://github.com/CFC-Servers/gm_express.
   1. Klicke auf "Code" und downloade die .zip Datei.
   2. Entpacke die .zip Datei in das "/garrysmod/addons" Verzeichnis.
   3. Starte deinen Server neu.
   4. Aktiviere im "Netzwerk"-Tab die Option "Aktiviere gm_express".

Dieser Service kann auch selbst gehosted werden.
Siehe: https://github.com/CFC-Servers/gm_express_service]],
    ["health_check_seversecure_title"] = "Serversecure Modul",
    ["health_check_seversecure_desc"] = "Ein Modul das Sicherheitslücken in der Source Engine behebt. Erstellt von danielga.",
    ["health_check_seversecure_desc_long"] =
[[Ohne dieses Modul kann der Server ohne Weiteres zum Abstürzen gebracht werden.
Vereinfacht validiert und begrenzt es Packete die der Client zum Server senden kann.

Zum Installieren gehe auf: https://github.com/danielga/gmsv_serversecure.
   1. Gehe zu Releases und downloade die .dll Datei für dein Server-Betriebssystem.
   2. Erstelle einen Ordner "garrysmod/lua/bin" falls er nicht existiert.
   3. Platziere die .dll Datei in das "/garrysmod/lua/bin" Verzeichnis.
   4. Lade auf Github die "serversecure.lua" Datei ( in "/include/modules") herunter.
   5. Platziere die Datei in das "/garrysmod/lua/includes/modules" Verzeichnis.
   6. Starte deinen Server neu.

Wenn Nova Defender das Modul für dich automatisch konfigurieren soll,
aktiviere im "Exploits"-Tab die Option "Serversecure automatisch einrichten"]],
    ["health_check_exploits_title"] = "Addons mit Sicherheitslücken",
    ["health_check_exploits_desc"] = "Liste von Netmessages von Addons, bei denen eine Sicherheitslücke bekannt ist.",
    ["health_check_exploits_desc_long"] =
[[Eine Netmessage ermöglicht die Kommunikation zwischen Client und Server.
Diese Nachrichten können jedoch von einem Client leicht manipuliert werden.
Wenn also der Server nicht überprüft, ob der Client diese Nachricht überhaupt senden darf,
können ausnutzbare Sicherheitslücken (Geldbugs, Serverabstürze, Adminrechte) entstehen.

Alle aufgeführten Namen von Netmessages können oder konnten ausgenutzt werden.
Es gibt keine Garantie, dass diese Sicherheitslücke noch existiert.
Es kann auch Sicherheitslücken geben, die hier nicht aufgeführt sind.

   1. Aktualisiere deine Addons regelmäßig
   2. Ersetze veraltete oder nicht unterstützte Addons durch Neue
   3. Wenn du mit Lua vertraut bist, prüfe die Netmessages selbst im Code]],
    ["health_check_backdoors_title"] = "Backdoors",
    ["health_check_backdoors_desc"] = "Backdoors können sich auf dem Server befinden um einem Angreifer jederzeit unbefugten Zugriff zu ermöglichen.",
    ["health_check_backdoors_desc_long"] =
[[Backdoors können u. a. auf folgende Weise auf einen Server gelangen:
   1. Schädliche Workshop-Addons
   2. Eine Person bittet dich, eine Lua-Datei auf den Server zu laden
      die "extra für dich" erstellt wurde
   3. Ein Entwickler mit Zugang zu deinem Server hat eine Backdoor für sich eingebaut
   4. Der Server selbst wurde kompromittiert (Sicherheitslücke im Betriebssystem,
      Schwachstelle in der Software)

Möglichkeiten, eine Backdoor zu entfernen:
   1. Falls vorhanden, den angegebenen Pfad überprüfen
      (wenn der Pfad mit 'lua/' beginnt, stammt er wahrscheinlich aus dem Workshop)
   2. Scanne deinen Server mit z.B. https://github.com/THABBuzzkill/nomalua
   3. Entferne alle Skripte, die kürzlich hinzugefügt wurden und prüfe,
      ob diese Meldung erneut erscheint
   4. Lade alle Dateien auf deinem Server herunter und führe eine Textsuche
      nach der aufgeführten Hintertür durch
   5. HARTER WEG: Entferne ALLE Addons, bis diese Meldung nicht mehr erscheint,
      füge sie dann nacheinander wieder ein und suche das Addon,
      bei dem die Meldung wieder erscheint.]],
    ["health_check_mysql_pass_title"] = "Schwaches Datenbank Passwort",
    ["health_check_mysql_pass_desc"] = "Datenbank Passwort für Nova Defender ist zu schwach.",
    ["health_check_mysql_pass_desc_long"] =
[[Wenn du MySQL verwendest, brauchst du ein sicheres Passwort.
Auch wenn es nicht über das Internet zugänglich ist.

So sicherst du deine Datenbank:
   1. Ein sicheres Datenbank-Passwort ist nichts, was man sich merken muss
   2. Verwende einen Passwort-Generator
   3. Verwende für jede Datenbank ein anderes Passwort
   4. Verwende eine andere Datenbank für jedes Addon (oder gute Datenbank Benutzerrechte)]],
    ["health_check_nova_errors_title"] = "Nova Defender Fehler",
    ["health_check_nova_errors_desc"] = "Fehler-Logs von Nova Defender",
    ["health_check_nova_errors_desc_long"] =
[[Lese sie durch. Kontaktiere mich, wenn du unsicher bist,
wie du ein bestimmtes Problem lösen kannst. Wenn eine Fehlermeldung für
dich schlüssig ist und die Funktionalität nicht beeinträchtigt,
kannst du diese Meldung ruhig ignorieren.]],
    ["health_check_nova_vpn_title"] = "Nova Defender VPN-Schutz",
    ["health_check_nova_vpn_desc"] = "Der VPN-Schutz muss eingerichtet werden um Länder zu sperren und VPNs zu erkennen.",
    ["health_check_nova_vpn_desc_long"] =
    [[Im Tab "Netzwerk" muss du deinen API-Key einfügen,
den du nach der kostenlosen Anmeldung auf ipqualityscore.com erhälst.
Mit diesem kann Nova-Defender dann über diese Seite IP-Adressen untersuchen.
   1. Gehe auf https://www.ipqualityscore.com/create-account
   2. Kopiere hier deinen API-Key https://www.ipqualityscore.com/user/settings
   3. Füge ihn im Tab "Netzwerk" unter "VPN API-Key" ein]],
    ["health_check_nova_steamapi_title"] = "Nova Defender Steamprofil-Schutz",
    ["health_check_nova_steamapi_desc"] = "Der Steamprofil-Schutz muss eingerichtet sein um verdächige Profile von Spielern zu erkennen.",
    ["health_check_nova_steamapi_desc_long"] =
    [[Im Tab "Ban System" musst du deinen API-Key einfügen,
   1. Gehe auf https://steamcommunity.com/dev/apikey
   2. Gebe den Domainnamen deines Servers ein
   3. Kopiere deinen API-Key
   4. Füge ihn im Tab "Netzwerk" unter "Steam API-Key" ein]],
   ["health_check_nova_anticheat_title"] = "Nova Defender Anticheat Erweiterung",
   ["health_check_nova_anticheat_desc"] = "Das Anticheat benötigt eine Erweiterung um mehr Cheats zu erkennen.",
   ["health_check_nova_anticheat_desc_long"] =
   [[Aktuell werden nur einige einfache Cheats erkannt. Da der Quellcode von Nova Defender offen
und einsehbar ist, können Cheats leicht angepasst werden um nicht erkannt zu werden.
Daher können Besitzer von Servern die Erweiterung des Anticheats anfordern,
welche auch externe, neue oder bezahlte Cheats namentlich erkennt.
Klicke auf den entsprechenden Button am oberen Rand des Menüs
oder trete unserem Discord bei, um mehr zu erfahren.]],
   ["health_check_nova_anticheat_version_title"] = "Nova Defender Anticheat veraltete Version",
   ["health_check_nova_anticheat_version_desc"] = "Das Anticheat ist nicht auf dem neusten Stand.",
   ["health_check_nova_anticheat_version_desc_long"] =
   [[Bitte lade die neuste Version auf GitHub herunter:
https://github.com/Freilichtbuehne/nova-defender-anticheat/releases/latest]],
   ["health_check_nova_ddos_protection_title"] = "Nova Defender DDoS-Schutz Erweiterung",
   ["health_check_nova_ddos_protection_desc"] = "Verteidige Deinen Linux-Server vor DDoS-Angriffen.",
   ["health_check_nova_ddos_protection_desc_long"] =
   [[Host-basierter DDoS-Schutz für Linux-Server.
Servereigentümer können diese Erweiterung anfordern.
Klicke auf den entsprechenden Button am oberen Rand des Menüs
oder trete unserem Discord bei, um mehr zu erfahren.]],
   ["health_check_nova_ddos_protection_version_title"] = "Nova Defender DDoS-Schutz veraltete Version",
   ["health_check_nova_ddos_protection_version_desc"] = "Der DDoS-Schutz ist nicht auf dem neusten Stand.",
   ["health_check_nova_ddos_protection_version_desc_long"] =
   [[Bitte lade die neuste Version auf GitHub herunter:
https://github.com/Freilichtbuehne/nova-defender-ddos/releases/latest]],
    /*
        Server
    */
    ["server_general_suffix"] = "Text, der an jede Kick-, Ban- oder Ablehnungsnachricht angehängt wird. Zum Beispiel dein Teamspeak, Discord oder eine andere Supportseite.",

    ["server_access_maintenance_enabled"] = "Wartungsmodus:\nNur geschützte Spieler und Spieler mit Passwort können den Server betreten.",
    ["server_access_maintenance_allowed"] = "Wer kann dem Server im Wartungsmodus beitreten? Geschützte Spieler sind immer erlaubt und brauchen kein Passwort.",
    ["server_access_maintenance_password"] = "Passwort für den Wartungsmodus, wenn du in der obigen Einstellung 'password' gewählt hast.",
    ["server_access_maintenance_reason"] = "Grund der dem Spieler angezeigt wird, wenn er währen der Wartung versucht, dem Server beizutreten.",
    ["server_access_password_lock"] = "Sperre bei Fehlversuchen:\nWenn ein Spieler das Passwort zu oft eingibt, wird er blockiert bis kein Passwort mehr auf dem Server ist.",
    ["server_access_password_lock_reason"] = "Grund der dem Spieler angezeigt wird, wenn er durch falsche Passworteingabe gesperrt wurde.",
    ["server_access_password_max_attempts"] = "Maximale Anzahl an Fehlversuchen",

    ["server_lockdown_enabled"] = "Lockdown Modus:\nNUR Teammitglieder, geschützte und vertrauenswürdige Personen können dem Server beitreten. Verwende dies, wenn viele neue Accounts erstellt werden, um auf dem Server zu Trollen, Griefen oder  den Server zum Absturz zu bringen. Spieler, die bereits auf dem Server sind, sind davon nicht betroffen. Stelle sicher, dass zuerst in der Config Datei von Nova Defender festlegt wird, wer vertrauenswürdig ist. Dies sollte nur für eine kurze Zeit verwendet werden.",
    ["server_lockdown_reason"] = "Grund für den Kick eines Spielers, wenn er während des Lockdowns versucht dem Server beizutreten.",
    /*
        Admin Menu
    */
    ["menu_title_banbypass"] = "Ban System",
    ["menu_title_health"] = "Gesundheit",
    ["menu_title_network"] = "Netzwerk",
    ["menu_title_security"] = "Sicherheit",
    ["menu_title_menu"] = "Menü",
    ["menu_title_anticheat"] = "Anticheat",
    ["menu_title_detections"] = "Erkennungen",
    ["menu_title_bans"] = "Bans",
    ["menu_title_exploit"] = "Exploits",
    ["menu_title_players"] = "Spieler Online",
    ["menu_title_server"] = "Server",
    ["menu_title_inspection"] = "Spieler Untersuchen",
    ["menu_title_ddos"] = "DDoS Schutz",

    ["menu_desc_banbypass"] = "Techniken um Banumgehung von Nova Defender zu verhindern",
    ["menu_desc_network"] = "Netzwerkaktivitäten einschränken, kontrollieren und protokollieren",
    ["menu_desc_security"] = "Schutz vor Privilegienerweiterungen von Benutzern",
    ["menu_desc_menu"] = "Benachrichtigungen und Adminmenü verwalten",
    ["menu_desc_anticheat"] = "Aktivieren oder deaktiviere Funktionen des clientseitigen Anticheats",
    ["menu_desc_bans"] = "Finde Bans, entbanne oder banne Spieler",
    ["menu_desc_exploit"] = "Vermeide Exploits",
    ["menu_desc_players"] = "Übersicht aller Spieler auf dem Server",
    ["menu_desc_health"] = "Sehen den Zustand deines Servers auf einen Blick",
    ["menu_desc_detections"] = "Alle ausstehende Erkennung von Spielern die noch nicht behandelt wurden",
    ["menu_desc_server"] = "Verwalten den Zugang zu deinem Server",
    ["menu_desc_inspection"] = "Führe Befehle bei Spielern aus und durchsuche Dateien",
    ["menu_desc_ddos"] = "Live-Status des DDoS-Schutzes auf dem Linux-Server",

    ["menu_elem_extensions"] = "Erweiterungen:",
    ["menu_elem_disabled"] = "(deaktiviert)",
    ["menu_elem_outdated"] = "(veraltet)",
    ["menu_elem_add"] = "Hinzufügen",
    ["menu_elem_edit"] = "Bearbeiten",
    ["menu_elem_unban"] = "Entbannen",
    ["menu_elem_ban"] = "Ban",
    ["menu_elem_kick"] = "Kick",
    ["menu_elem_reconnect"] = "Reconnect",
    ["menu_elem_quarantine"] = "Quarantäne",
    ["menu_elem_unquarantine"] = "Quarantäne aufheben",
    ["menu_elem_verify_ac"] = "Anticheat prüfen",
    ["menu_elem_screenshot"] = "Screenshot",
    ["menu_elem_detections"] = "Erkennungen",
    ["menu_elem_indicators"] = "Indikatoren",
    ["menu_elem_commands"] = "Commands",
    ["menu_elem_netmessages"] = "Netmessages",
    ["menu_elem_ip"] = "IP Details",
    ["menu_elem_profile"] = "Steamprofil",
    ["menu_elem_rem"] = "Entfernen",
    ["menu_elem_reload"] = "Neu laden",
    ["menu_elem_advanced"] = "Erweiterte Einstellungen",
    ["menu_elem_miss_options"] = "Zu wenig Optionen?",
    ["menu_elem_copy"] = "Kopieren",
    ["menu_elem_view"] = "Ansehen",
    ["menu_elem_save"] = "In lokalen Dateien speichern",
    ["menu_elem_saved"] = "Gespeichert",
    ["menu_elem_settings"] = "Einstellungen:",
    ["menu_elem_general"] = "Allgemein:",
    ["menu_elem_discord"] = "Trete unserem Discord bei!",
    ["menu_elem_close"] = "Schließen",
    ["menu_elem_cancel"] = "Abbrechen",
    ["menu_elem_filter_by"] = "Filtern nach:",
    ["menu_elem_filter_text"] = "Filter Text:",
    ["menu_elem_reason"] = "Grund",
    ["menu_elem_comment"] = "Kommentar",
    ["menu_elem_bans"] = "Bans (Limitiert auf 150 Einträge):",
    ["menu_elem_new_value"] = "Neuer Wert",
    ["menu_elem_submit"] = "Absenden",
    ["menu_elem_no_bans"] = "Keine Bans gefunden",
    ["menu_elem_no_data"] = "Keine Daten",
    ["menu_elem_checkboxtext_checked"] = "Aktiv",
    ["menu_elem_checkboxtext_unchecked"] = "Inaktiv",
    ["menu_elem_search_term"] = "Suchbegriff...",
    ["menu_elem_unavailable"] = "Nicht Verfügbar",
    ["menu_elem_failed"] = "Nicht Bestanden",
    ["menu_elem_passed"] = "Bestanden",
    ["menu_elem_health_overview"] = "Prüfungen:\n  • Insgesamt: %d\n  • Bestanden: %d\n  • Nicht bestanden: %d",
    ["menu_elem_health_most_critical"] = "Am kritischten:\n",
    ["menu_elem_mitigation"] = "Wie behebe ich es?",
    ["menu_elem_list"] = "Details",
    ["menu_elem_ignore"] = "Ignorieren",
    ["menu_elem_reset"] = "Zurücksetzen",
    ["menu_elem_reset_all"] = "Ignorierungen zurücksetzen:",
    ["menu_elem_player_count"] = "Spieler online: %d",
    ["menu_elem_foundindicator"] = "Indikator gefunden",
    ["menu_elem_foundindicators"] = "%d Indikatoren gefunden",
    ["menu_elem_criticalindicators"] = "Kritische Indikatoren!",
    ["menu_elem_notauthed"] = "Authentifizieren...",

    ["menu_elem_mitigated"] = "Aktion getroffen",
    ["menu_elem_unmitigated"] = "Keine Aktion getroffen",
    ["menu_elem_next"] = "Weiter",
    ["menu_elem_prev"] = "Zurück",
    ["menu_elem_clear"] = "Behandelte löschen",
    ["menu_elem_clear_all"] = "Alle löschen",
    ["menu_elem_delete"] = "Löschen",
    ["menu_elem_stats"] = "Einträge: %d",
    ["menu_elem_page"] = "Seite: %d",

    ["menu_elem_nofocus"] = "In anderem Fenster",
    ["menu_elem_focus"] = "Im Spiel",
    ["menu_elem_connect"] = "Verbinden",
    ["menu_elem_disconnect"] = "Trennen",
    ["menu_elem_input_command"] = "Gebe Lua Code zum Ausführen ein...",
    ["menu_elem_select_player"] = "Wähle einen Spieler",
    ["menu_elem_disconnected"] = "Offline",
    ["menu_elem_exec_clientopen"] = "Spieler hat die Verbindung geöffnet",
    ["menu_elem_exec_clientclose"] = "Spieler hat die Verbindung geschlossen",
    ["menu_elem_exec_error"] = "Ein Server-Fehler ist aufgetreten",
    ["menu_elem_filetime"] = "Letzte Dateiänderung: %s",
    ["menu_elem_filesize"] = "Dateigröße: %s",
    ["menu_elem_download"] = "Download",
    ["menu_elem_download_confirm"] = "Bist du sicher dass du die folgende Datei herunterladen willst?\n%q",
    ["menu_elem_download_progress"] = "Lade Teil %i/%i...",
    ["menu_elem_download_finished_part"] = "Datei wurde teilweise heruntergeladen und in deinem lokalen Garry's Mod-Datenordner gespeichert:\n%q",
    ["menu_elem_download_finished"] = "Die Datei ist fertig heruntergeladen und wurde in deinem lokalen Garry's Mod Datenordner gespeichert:\n%q",
    ["menu_elem_download_failed"] = "Download fehlgeschlagen: %q",
    ["menu_elem_download_started"] = "Lade Datei herunter: %q",
    ["menu_elem_download_confirmbutton"] = "Download",
    ["menu_elem_canceldel"] = "Abbrechen und löschen",
    ["menu_elem_exec_help"] = [[Anwendung:
- Benutze es nur wenn du mit Lua vertraut bist
- Entwickelt für Debugging-Zwecke und die Suche nach Lua-Cheats

Allgemein:
- Gebe Lua-Code ein und drücke Enter, um ihn auf dem ausgewählten Client auszuführen.
- Lua-Fehler werden in der Konsole angezeigt
- Lua-Fehler sind für den Client unsichtbar

Anzeige von Werten:
- Um den Wert einer Tabelle oder eines Strings zu erhalten, verwende "print()" oder "PrintTable()"
- Die Ausgabe von "print" und "PrintTable" ist für den Client nicht sichtbar
- Die Ausgabe von "print" und "PrintTable" wird an deine Konsole weitergeleitet
- Beispiel 1: "PrintTable(hook.GetTable())"
- Beispiel 2: "local nick = LocalPlayer():Nick() print(nick)"

Verlauf:
- Verwende UP und DOWN, um durch die Historie zu navigieren
- Verwende TAB zum automatischen Vervollständigen

Sicherheit:
- Führe Lua-Code verantwortungsvoll aus
- Ausgeführter Code könnte für den Client sichtbar sein
- Ausgeführter Code könnte vom Client blockiert oder manipuliert werden]],
    ["menu_elem_help"] = "Hilfe",
    
    ["menu_elem_ddos_active"] = "DDoS-Schutz aktiv!",
    ["menu_elem_ddos_inactive"] = "DDoS-Schutz inaktiv",
    ["menu_elem_ddos_duration"] = "Dauer: %s",
    ["menu_elem_ddos_avg"] = "Durchschnitt RX: %s",
    ["menu_elem_ddos_max"] = "Max RX: %s",
    ["menu_elem_ddos_stopped"] = "Beendet am: %s",
    ["menu_elem_ddos_stats"] = "Statistik letzer Angriff:",
    ["menu_elem_ddos_cpu_util"] = "CPU Auslastung",
    ["menu_elem_ddos_net_util"] = "Netzwerk Auslastung",
    
    ["indicator_pending"] = "Spieler hat dem Server seine Indikatoren bisher nicht mitgeteilt. Entweder blockiert er diese oder benötigt noch etwas Zeit.",
    ["indicator_install_fresh"] = "Spieler hat dieses Spiel kürzlich installiert",
    ["indicator_install_reinstall"] = "Spieler hat das Spiel kürzlich neu installiert",
    ["indicator_advanced"] = "Spieler verwendet Debug-/Entwickler-Befehle (Er kennt sicht möglicherweise aus...)",
    ["indicator_first_connect"] = "Erstes Mal auf diesem Server (falls das Spiel nicht neu installiert wurde)",
    ["indicator_cheat_hotkey"] = "Spieler hat eine Taste (INSERT, HOME, PAGEUP, PAGEDOWN) gedrückt, die oft zum öffnen von Cheat Menüs verwendet werden",
    ["indicator_cheat_menu"] = "Spieler hat ein Menü über eine der Tasten INSERT, HOME, PAGEUP oder PAGEDOWN geöffnet",
    ["indicator_bhop"] = "Spieler hat einen Bunnyhop-Bind auf seinem Mausrad (z. B. 'bind mwheelup +jump')",
    ["indicator_memoriam"] = "Spieler hat den Cheat 'Memoriam' in der Vergangenheit genutzt oder tut es aktuell",
    ["indicator_multihack"] = "Spieler hat den Cheat 'Garrysmod 64-bit Visuals Multihack Reborn' in der Vergangenheit genutzt oder tut es aktuell",
    ["indicator_fenixmulti"] = "Spieler hat den Cheat 'FenixMulti' in der Vergangenheit genutzt oder tut es aktuell",
    ["indicator_interstate"] = "Spieler hat den Cheat 'interstate editor' in der Vergangenheit genutzt oder tut es aktuell",
    ["indicator_exechack"] = "Spieler hat den bezahlten Cheat 'exechack' in der Vergangenheit genutzt oder tut es aktuell",
    ["indicator_banned"] = "Spieler wurde von Nova Defender auf einem anderen Server gebannt",
    ["indicator_lua_binaries"] = "Spieler hat DLL-Dateien in dem Ordner 'garrysmod/lua/bin'. Hier werden oft Cheats platziert. Die Dateien konnen im 'Inspection'-Tab durchsucht werden. Diese Dateien müssen von Hand durch den Spieler erstellt worden sein.",
    ["indicator_profile_familyshared"] = "Spieler hat einen Familysharing-Account",
    ["indicator_profile_friend_banned"] = "Ein Steam-Freund dieses Spielers wurde von Nova Defender gebannt",
    ["indicator_profile_recently_created"] = "Steam-Profil wurde die letzten 7 Tage erstellt",
    ["indicator_profile_nogames"] = "Spieler hat auf seinem Steam-Profil noch keine Spiele gekauft",
    ["indicator_profile_new_player"] = "Spieler hat Garry’s Mod insgesamt noch nicht länger als 2 Stunden gespielt",
    ["indicator_profile_vac_banned"] = "Spieler hat bereits einen VAC-Ban",
    ["indicator_profile_vac_bannedrecent"] = "Spieler hat bereits einen VAC-Ban in den letzte 5 Monaten erhalten",
    ["indicator_profile_community_banned"] = "Spieler hat bereits von Steam einen Community-Ausschluss erhalten",
    ["indicator_profile_not_configured"] = "Spieler hat seinen Steam-Account noch nicht einmal eingerichtet",
    ["indicator_scenario_bypass_account"] = "Indikatoren deuten darauf hin, dass dieser Spieler extra einen neuen Steam-Account erstellt hat. Siehe Menütab 'Spieler Online'",
    ["indicator_scenario_cheatsuspect"] = "Indikatoren deuten darauf hin, dass dieser Spieler cheated. Siehe Menütab 'Spieler Online'",
    ["indicator_scenario_sum"] = "Spieler ist verdächtig, da er eine hohe Anzahl an typischen Indikatoren erfüllt. Siehe Menütab 'Spieler Online'",

    ["internal_reason"] = "Interner Grund",
    ["banned"] = "Gebannt",
    ["status"] = "Status",
    ["reason"] = "Grund",
    ["unban_on_sight"] = "Unban on sight",
    ["ip"] = "IP",
    ["ban_on_sight"] = "Ban on sight",
    ["time"] = "Zeit",
    ["comment"] = "Kommentar",
    ["steamid"] = "SteamID32",
    ["steamid64"] = "SteamID64",
    ["usergroup"] = "Benutzergruppe",
    ["familyowner"] = "Family Sharing Besitzer",
    ["group"] = "Gruppe",
    ["kick"] = "Kick",
    ["allow"] = "Diese Erkennung deaktivieren",
    ["reconnect"] = "Reconnect",
    ["ban"] = "Ban",
    ["notify"] = "Benachrichtigen",
    ["nothing"] = "Nichts",
    ["set"] = "Wieder setzen",
    ["disable"] = "Meldung Deaktivieren",
    ["ignore"] = "Kurzzeitig Ignorieren",
    ["dont_care"] = "Juckt mich net",
    ["action_taken_at"] = "Zeitpunkt der Aktion",
    ["action_taken_by"] = "Admin",

    ["sev_none"] = "Keine",
    ["sev_low"] = "Niedrig",
    ["sev_medium"] = "Mittel",
    ["sev_high"] = "Hoch",
    ["sev_critical"] = "Kritisch",
}

// DO NOT CHANGE ANYTHING BELOW THIS
if SERVER then
    Nova["languages_" .. lang] = function() return phrases end
else
    NOVA_SHARED = NOVA_SHARED or {}
    NOVA_SHARED["languages_" .. lang] = phrases
end