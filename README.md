# nova-defender
🛡 All-in-One Security Solution for Garry’s Mod servers (Anticheat, Banbypass, VPN and more)

<p align="center">
  <img src="https://i.imgur.com/GTY2nhn.png" width="350" title="Banner">
</p>

## Primary Features

### ⚠️ Prevent players from messing with your server
- Using cheat software
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
By default, all admins who are online are asked what should be done each time a detection is triggered. If no admin is online, you can always review the detection afterward in the 'Detections' tab. If a detection does not cause any problems after a few days, you can set the action to 'ban' or 'kick'. If a message occurs frequently wrong, you can set the action to 'nothing' and write a support ticket if necessary.

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
Currently **only some simple cheats are detected**. Since the source code of Nova Defender is open and and visible, cheats can be easily modified to be undetectable. Therefore, **owners of large servers can request the extension of the anticheat, which also detects external, new or paid cheats by name**. Feel free to contact me directly via Steam for this. However, I reserve the right to refuse the request even without providing a reason.

### What it does not do?
No replacement for any admin menu (like ULX, sAdmin, xAdmin, ...)

### Does it work?
This addon was continuously tested on a large DarkRP and TTT server for over two year during the development phase to ensure the highest possible compatibility with players (always doing the weirdest stuff imaginable) and many other addons.

With an average of 50 players, cheaters were reliably banned, ban evasions were detected, and the servers were protected.

###  Can I use this addon alongside other anticheat addons?
Yes, the addon that detects the cheater first will ban him first. If you don't care that anticheat bans are spread over several addons, you can use more than one. Be careful, though, because anticheat systems often conflict with each other. 

### Can I use this addon alongside other admin tools?
Normal player bans can still be made via any existing admin tools. Cheaters, exploiters etc. will be banned automatically via Nova Defender. Ban evasions can only be detected if the ban originates from Nova Defender. You can use this addon perfectly alongside ULX.

### What if players are banned for no reason?
By default, a notification is sent before EVERY ban asking what action should be taken. If the notifications are reliable for a specific detection, 'Ban' or 'Kick' can be selected directly in the action settings.

Otherwise, feel free to report a false detection via the ticket system, and it will be improved.


### Where can I find saved screenshots on my server?
Screenshots before a ban will be saved on your server under the following folder: `/data/nova/ban_screenshots`. Screenshots of admins are stored on your server under the following folder: `/data/nova/admin_screenshots`.

Under the 'Networking' tab, you can configure everything.

## Known Issues
- Aimbot detection will (at the moment) cause false positives in rare conditions (it is disabled by default)
- With the anticheat enabled FProfiler will not work on the clientside anymore
- Ban evasions are only detected if ban originated from Nova Defender and even better if player was banned while being connected to the server

## Support
You are also welcome to contact me directly:
- Discord (prefered): _samuel
- Steam: https://steamcommunity.com/id/samuelweil/

## Credits
- HMAC-SHA256 signature: https://github.com/jqqqi/Lua-HMAC-SHA256
- Backdoor and exploit netmessages: https://steamcommunity.com/sharedfiles/filedetails/?id=1308262997
- LZW Compression: https://github.com/Rochet2/lualzw
- Yueliang LuaVM: https://github.com/gamesys/moonshine/blob/master/extensions/luac/yueliang.lua
