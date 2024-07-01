<p align="center">
  🛡 Version Française de la solution de sécurité tout-en-un pour les serveurs Garry's Mod (Anticheat, contournement de bannissement, VPN et plus)
</p>
<p align="center">
  <!--<img src="https://i.imgur.com/GTY2nhn.png" width="412px" title="Banner">-->
  <img src="https://i.imgur.com/6z8hxLV.gif" width="412px" title="Banner">
</p>

<p align="center">
  <a href=https://discord.gg/zEMuB6kN9g>
    <img src="https://i.imgur.com/Qb6CVTY.png" width="412px" title="Banner">
  </a>
</p>

<p align="center">
  :computer: <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3069680995">Également disponible sur Steam Workshop</a>
  :open_file_folder: <a href="https://github.com/Freilichtbuehne/nova-defender/releases/latest">Téléchargement direct</a>
  :microphone: <a href="https://discord.gg/zEMuB6kN9g">Discord</a>
</p>

<p align="center">
<br>
Vous voulez soutenir mon travail ?
<br><br>
<a href="[https://www.buymeacoffee.com/gbraad](https://buymeacoffee.com/gowrbizyn)" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
</p>

## Démonstration des fonctionnalités
<a href="http://www.youtube.com/watch?feature=player_embedded&v=9xUF_B0s9Gk" target="_blank">
 <img src="https://i.ytimg.com/vi/9xUF_B0s9Gk/mqdefault.jpg" alt="Nova Defender Demo"  width="412px" />
</a>

<a href="http://www.youtube.com/watch?feature=player_embedded&v=9xUF_B0s9Gk" target="_blank"> Youtube Nova Defender Demo </a>

## Fonctionnalités principales

### ⚠️ Empêcher les joueurs de perturber votre serveur
- Utilisation de [logiciels de triche](https://github.com/Freilichtbuehne/nova-defender#how-is-an-open-source-anticheat-supposed-to-work)
- Détection d'aimbot
- Provoquer des lags
- Faire planter le serveur
- Création de multiples comptes pour contourner les bannissements
- Utilisation d'exploits/backdoors
- Vol de tous vos fichiers client ET SERVEUR
- Se donner des droits d'administrateur
- Utilisation d'autoclick

### ⛔ Système de bannissement propre
- Empêcher les joueurs de contourner un bannissement
- Détecter quel bannissement a été contourné
- Gérer les bannissements

### ✅ Détecter les problèmes de votre serveur et expliquer comment les résoudre
- Mauvaises configurations
- Mauvaises performances
- Exploits
- Recommandations

### 🔍 Inspecter les joueurs
- Voir l'écran des joueurs
- Rechercher des fichiers
- Exécuter du Lua avec des retours de print
- Indicateurs suspects
- Informations sur l'adresse IP
- Commandes exécutées et messages réseau envoyés

### 📚 Gestion du serveur
- Mode maintenance
- Mode verrouillage du serveur
- Empêcher le devinage de mot de passe

### 💻 Menu compact
- Tous les paramètres en jeu
- Décider quoi faire dans chaque cas de détection individuel (Demander au personnel, bannir, expulser, rien)
- Paramètres avancés pour les personnes plus techniques
  
<p align="center">
  <img src="https://i.imgur.com/buaoJDg.png" width="550" title="Banner">
</p>

## Installation

### 🔧 Première installation
1. Décompresser le fichier .zip
2. Déplacer le dossier `nova_defender_x.x.x` vers `/garrysmod/addons/nova_defender_x.x.x`
3. Cela devrait ressembler à ceci : `/garrysmod/addons/nova_defender_x.x.x/lua/nova/...`
4. Passer à l'étape suivante : Configuration


### 🔧 Configuration
1. Ouvrir le fichier `/garrysmod/addons/nova_defender_x.x.x/lua/nova/sv_config.lua` et éditer selon vos besoins
2. Redémarrer votre serveur
3. Configurer tout le reste en jeu avec `!nova` ou `nova_defender` dans la console
4. Passer à l'étape suivante : Que dois-je changer en jeu ?


### ❓ Que dois-je changer en jeu ?
Par défaut, tous les administrateurs en ligne sont interrogés sur ce qu'il faut faire chaque fois qu'une détection est déclenchée. Si aucun administrateur n'est en ligne, vous pouvez toujours revoir la détection par la suite dans l'onglet 'Détections'. Si une détection ne cause aucun problème après quelques jours, vous pouvez définir l'action sur 'bannir' ou 'expulser'. Si un message se produit fréquemment à tort, vous pouvez définir l'action sur 'rien'. Si vous rencontrez des problèmes avec les détections, VEUILLEZ me le faire savoir pour les améliorer via un problème sur GitHub ou me contacter directement.

Si vous êtes familier avec les paramètres, vous pouvez également passer aux 'paramètres avancés' pour accéder à de nombreuses autres fonctionnalités.


### 🔄 Mise à jour
1. Sauvegardez votre fichier de configuration : `/garrysmod/addons/nova_defender_x.x.x/lua/nova/sv_config.lua`
2. Supprimez l'ancien dossier `nova_defender_x.x.x` et téléchargez le nouveau
3. Remplacez ou réentrez vos anciennes configurations
4. Redémarrez le serveur

### ❓ Quelque chose ne fonctionne pas ?
Consultez la page de dépannage : https://freilichtbuehne.gitbook.io/nova-defender/troubleshooting

## FAQ

### Comment un anticheat open source est-il censé fonctionner ?
Actuellement, **seuls quelques cheats simples sont détectés**. Comme le code source de Nova Defender est ouvert et visible, les cheats peuvent être facilement modifiés pour ne plus être détectés. Par conséquent, **les propriétaires de grands serveurs peuvent demander l'extension de l'anticheat, qui détecte également les cheats externes, nouveaux ou payants par leur nom**. N'hésitez pas à me contacter directement via Steam pour cela. Cependant, je me réserve le droit de refuser la demande sans fournir de raison.

### Détecte-t-il les cheats en C++ ?
Oui. Bien sûr, pas tous, mais beaucoup des cheats les plus couramment utilisés. Cependant, les cheats les plus avancés ne sont détectés qu'avec la version étendue (voir question ci-dessus). Il n'est pas lié au langage de programmation comme le C++. Il peut également détecter les cheats externes écrits en Rust.

### Que ne fait-il pas ?
Il ne remplace aucun menu d'administration (comme ULX, sAdmin, xAdmin, ...)

### Est-ce que ça marche ?
Cet addon a été continuellement testé sur un grand serveur DarkRP et TTT pendant plus de deux ans pendant la phase de développement pour assurer la plus grande compatibilité possible avec les joueurs (faisant toujours les choses les plus étranges imaginables) et de nombreux autres addons.

Avec une moyenne de 50 joueurs, les tricheurs ont été bannis de manière fiable, les contournements de bannissement ont été détectés et les serveurs ont été protégés.

### Puis-je utiliser cet addon avec d'autres addons anticheat ?
Oui, mais vous ne devriez pas. L'addon qui détecte le tricheur en premier le bannira en premier. Si vous ne vous souciez pas que les bannissements anticheat soient répartis sur plusieurs addons, vous pouvez en utiliser plusieurs. Faites attention, cependant, car les systèmes anticheat entrent souvent en conflit les uns avec les autres. Cela peut causer des problèmes de performance et des faux positifs.

### Puis-je utiliser cet addon avec d'autres outils d'administration ?
Les bannissements de joueurs normaux peuvent toujours être effectués via n'importe quel outil d'administration existant. Les tricheurs, les exploiteurs, etc. seront automatiquement bannis via Nova Defender. Les contournements de bannissement ne peuvent être détectés que si le bannissement provient de Nova Defender. Vous pouvez utiliser cet addon parfaitement avec ULX.

### Que faire si des joueurs sont bannis sans raison ?
Par défaut, une notification est envoyée avant CHAQUE bannissement demandant quelle action doit être prise. Si les notifications sont fiables pour une détection spécifique, 'Bannir' ou 'Expulser' peut être sélectionné directement dans les paramètres d'action. Les détections comme l'aimbot sont intentionnellement désactivées par défaut car elles ne fournissent pas de preuves solides qu'un joueur a triché.

Sinon, n'hésitez pas à signaler une fausse détection via un problème GitHub ou à me contacter directement.

### Où puis-je trouver les captures d'écran enregistrées sur mon serveur ?
Les captures d'écran avant un bannissement seront enregistrées sur votre serveur dans le dossier suivant : `/data/nova/ban_screenshots`. Les captures d'écran des administrateurs sont enregistrées sur votre serveur dans le dossier suivant : `/data/nova/admin_screenshots`.

Sous l'onglet 'Networking', vous pouvez tout configurer.

### Question non listée ?
Voir la section "Support".

## Problèmes connus
- La détection d'aimbot provoquera (pour le moment) des faux positifs dans de rares conditions (elle est désactivée par défaut)
- Avec l'anticheat activé, FProfiler ne fonctionnera plus côté client
- Les contournements de bannissement ne sont détectés que si le bannissement provient de Nova Defender et encore mieux si le joueur a été banni alors qu'il était connecté au serveur

## Support
Vous êtes également invité à me contacter directement :
- Discord (préféré) : _samuel
- Steam : https://steamcommunity.com/id/samuelweil/
- Rappel : le support "français" n'est pas disponible sauf sous la demannde du créateur de nova defender.

## Crédits
- [VentiStudio | Hikari Umaishi - Traduction Française](https://discord.gg/kQF7ehCJ3S)
- [Nova Defender ( Officiel )](https://github.com/Freilichtbuehne/nova-defender)
- [HMAC-SHA256 signature](https://github.com/jqqqi/Lua-HMAC-SHA256)
- [Backdoor and exploit netmessages](https://steamcommunity.com/sharedfiles/filedetails/?id=1308262997)
- [LZW Compression](https://github.com/Rochet2/lualzw)
- [Yueliang LuaVM](https://github.com/gamesys/moonshine/blob/master/extensions/luac/yueliang.lua)
