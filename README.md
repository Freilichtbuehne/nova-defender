<p align="center">
  🛡 All-in-One Security Solution for Garry’s Mod servers (Anticheat, Banbypass, VPN and more)
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
  :computer: <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3069680995">Also avaliable on Steam Workshop</a>
  :open_file_folder: <a href="https://github.com/Freilichtbuehne/nova-defender/releases/latest">Direct download</a>
  :microphone: <a href="https://discord.gg/zEMuB6kN9g">Discord</a>
</p>

<p align="center">
<br>
Want to support my work?
<br><br>
<a href="https://buymeacoffee.com/gowrbizyn" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
</p>

## Functionality Demo
<a href="http://www.youtube.com/watch?feature=player_embedded&v=9xUF_B0s9Gk" target="_blank">
 <img src="https://i.ytimg.com/vi/9xUF_B0s9Gk/mqdefault.jpg" alt="Nova Defender Demo"  width="412px" />
</a>

<a href="http://www.youtube.com/watch?feature=player_embedded&v=9xUF_B0s9Gk" target="_blank"> Youtube Nova Defender Demo </a>

## Primary Features

### ⚠️ Prevent players from messing with your server
- Using [cheat software](https://github.com/Freilichtbuehne/nova-defender#how-is-an-open-source-anticheat-supposed-to-work)
- Detects aimbot
- Cause Lags
- Crash Server
- Creation of multiple accounts to bypass bans
- Use Exploits/Backdoors
- Steal all your client AND SERVER files
- Somehow set themselves admin
- Using autoclick

### ⛔ Own banning system
- Prevent players to bypass a ban
- Detect which ban was bypassed
- Manage bans

### ✅ Detect issues with your server and explain how to fix
- Bad settings
- Bad performance
- Exploits
- Recommendations

### 🔍 Inspect players
- See players screen
- Search files
- Execute Lua with print callbacks
- Suspicious indicators
- Information about IP address
- Executed commands and sent netmessages

### 📚 Server Management
- Maintenance mode
- Server lockdown mode
- Prevent password guessing

### 💻 Compact Menu
- All settings in game
- Decide what to do in each individual detection case (Ask staff, ban, kick, nothing)
- Advanced settings for more technical persons
  
<p align="center">
  <img src="https://i.imgur.com/buaoJDg.png" width="550" title="Banner">
</p>

## Extensions

- **All extensions are private and exclusive for server owners!**
- For a donation I grant access to individual extensions.
- I reserve the right to refuse the request even without providing a reason.
- [Join our Discord](https://discord.gg/zEMuB6kN9g) to get instructions on how to request access.
- Feel free to contact me directly via Discord: `_samuel`

### ✨ Extended Anticheat

* Adds 25+ cheat detections (too lazy to update this number)
* Utilizes advanced methods for detecting populat cheats
* Adds new indicators for cheats (including by name) players have used in the past
* Contains both public and paid cheats
* Some cheats are fully detected, some only partially
* All cheats are detected by name, so that no one can argue their way out

### ✨ DDoS Protection

* Host-based DDoS protection for Linux servers
* Requires Root access!
* Integration into `!nova` menu with realtime status
* Supports tcpdump capturing
* Notifications via Nextcloud Talk

<img src="https://i.imgur.com/Oinv1EU.png" width="400" title="Preview">
<img src="https://i.imgur.com/a6poEXg.png" width="400" title="Preview">

## Installation

### 🔧 First Install
1. Unpack .zip file
2. Move folder `nova_defender_x.x.x` to `/garrysmod/addons/nova_defender_x.x.x`
3. It should look like this: `/garrysmod/addons/nova_defender_x.x.x/lua/nova/...`
4. Go to next step: Configuration


### 🔧 Configuration
1. Open file `/garrysmod/addons/nova_defender_x.x.x/lua/nova/sv_config.lua` and edit to your needs
2. Restart your server
3. Configure everything else in game with `!nova` or `nova_defender` in console
4. Go to next step: What should I change ingame?


### ❓ What should I change ingame?
By default, all admins who are online are asked what should be done each time a detection is triggered. If no admin is online, you can always review the detection afterward in the 'Detections' tab. If a detection does not cause any problems after a few days, you can set the action to 'ban' or 'kick'. If a message occurs frequently wrong, you can set the action to 'nothing'. If you experience problems with detections PLEASE let me know to improve them via an issue on GitHub or contact me directly.

If you are familiar with the settings, you can also switch to the 'advanced settings' to access many more features.


### 🔄 Update
1. Backup your config file: `/garrysmod/addons/nova_defender_x.x.x/lua/nova/sv_config.lua`
2. Delete old `nova_defender_x.x.x` folder and upload new one
3. Replace or reenter your old configs
4. Restart Server

### ❓ Anything not working?
Check troubleshooting page: https://freilichtbuehne.gitbook.io/nova-defender/troubleshooting

## FAQ

### How is an open source anticheat supposed to work?
Currently **only some simple cheats are detected**. Since the source code of Nova Defender is open and visible, cheats can be easily modified to be undetected again. **Therefore, serverowners can request the extension of the anticheat, which also detects external, new or paid cheats by name**. See "Extensions" section.

### Does it detect C++ cheats?
Yes. Of course not all, but many of the most commonly used cheats. However most advanced cheats are only detected with the extended version (see question above). It is not bound to the programming language like C++. It can also detect external cheats that are written in Rust.

### What it does not do?
No replacement for any admin menu (like ULX, sAdmin, xAdmin, ...)

### Does it work?
This addon was continuously tested on a large DarkRP and TTT server for over two year during the development phase to ensure the highest possible compatibility with players (always doing the weirdest stuff imaginable) and many other addons.

With an average of 50 players, cheaters were reliably banned, ban evasions were detected, and the servers were protected.

###  Can I use this addon alongside other anticheat addons?
Yes, but you shouldn't. The addon that detects the cheater first will ban him first. If you don't care that anticheat bans are spread over several addons, you can use more than one. Be careful, though, because anticheat systems often conflict with each other. This can cause performance issues and false positives.

### Can I use this addon alongside other admin tools?
Normal player bans can still be made via any existing admin tools. Cheaters, exploiters etc. will be banned automatically via Nova Defender. Ban evasions can only be detected if the ban originates from Nova Defender. You can use this addon perfectly alongside ULX.

### What if players are banned for no reason?
By default, a notification is sent before EVERY ban asking what action should be taken. If the notifications are reliable for a specific detection, 'Ban' or 'Kick' can be selected directly in the action settings. Detections like aimbot are intentionally disabled by default as they do not provide solid evidence that a player cheated.

Otherwise, feel free to report a false detection via a GitHub issue or cantact me directly.

### Where can I find saved screenshots on my server?
Screenshots before a ban will be saved on your server under the following folder: `/data/nova/ban_screenshots`. Screenshots of admins are stored on your server under the following folder: `/data/nova/admin_screenshots`.

Under the 'Networking' tab, you can configure everything.

### Question not listed?
See "Support" section.

## Known Issues
- Aimbot detection will (at the moment) cause false positives in rare conditions (it is disabled by default)
- With the anticheat enabled FProfiler will not work on the clientside anymore
- Ban evasions are only detected if ban originated from Nova Defender and even better if player was banned while being connected to the server

## Support
You are also welcome to contact me directly:
- Discord (prefered): _samuel
- Steam: https://steamcommunity.com/id/samuelweil/

## Credits
- [HMAC-SHA256 signature](https://github.com/jqqqi/Lua-HMAC-SHA256)
- [Backdoor and exploit netmessages](https://steamcommunity.com/sharedfiles/filedetails/?id=1308262997)
- [LZW Compression](https://github.com/Rochet2/lualzw)
- [Yueliang LuaVM](https://github.com/gamesys/moonshine/blob/master/extensions/luac/yueliang.lua)
