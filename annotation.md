# Hooks
SnakeCase:
`hook.Run("nova_module_name")`
`hook.Add("nova_module_name", "module_name_function", ...)`

# Timers
SnakeCase:
`timer.Create("nova_module_name", 1, 0, function() end)`

# Netmessages
SnakeCase:
`Nova.netmessage("module_messagename")`

# Config
Static settings:
`Nova.config["use_mysql"]`  

Get setting: 
`Nova.setSetting("module_setting", value, showInUI, ifNotExists, description)`  
Set setting: 
`Nova.getSetting("module_setting", defaultvalue)`

# Serverlog

`Nova.log(level, message)`

### Levels:
* d = [DEBUG]
* i = [INFO]
* w = [WARNING]
* e = [ERROR]
* s = [SUCCESS]

# Language
Get Phase:
`Nova.lang("module_phrase")`


# Comments in Code

/*
	Analyze all netmessages received by the client
*/

# SteamIDs

USE **STEAMID32**!!!