/*
	This clientside anticheat is far from perfect but it works surprisingly well for script kids.
	As soon as the author of a cheat is smart enough, we are basically blind as we are very limited
	by the Lua API we are provided with.

	Since the source code of Nova Defender is open and visible, cheats can be easily modified to be
	undetected again. Therefore, owners of large servers can request the extension of the anticheat,
	which also detects external, new or paid cheats by name. Feel free to contact me directly via Steam for this.
	However, I reserve the right to refuse the request even without providing a reason.
*/

local payloads = {
	["check"] = [==[function(b,c)local d=util.SHA256;local function e(f)local l=-1;local g,m={},jit.util.funck(f,l);while m do local n=type(m)if n=="number"then g[#g+1]=m elseif n=="string"then g[#g+1]=string.format("%q",m)elseif n=="boolean"then g[#g+1]=m and 1 or 0 end;l,m=l-1,jit.util.funck(f,l)end;return table.concat(g,",")end;local h=jit.util.funcinfo(d)local o="@addons/"local p=h.source;if p and string.sub(p,1,#o)~=o then return false,"sha detour"end;local q=type(b)local r=q=="function"and d(e(b))or q=="string"and d(b)or q=="table"and d(table.concat(b,","))or nil;if not r then return false,"invalid input"end;if r~=c then return false,"hash mismatch"end;return true end]==],
}

Nova.getAnticheatPayload = function()
	local vars = Nova.obfuscator.variable
	local lines = Nova.obfuscator.line:Register("ac_key", vars:Set("ac_key", Nova.netmessage("anticheat_detection"), false, true), 12)

	lines:Register("ac_key_cc", vars:Set("ac_key_cc", Nova.netmessage("anticheat_detection_concommand"), false, true), 3)

	lines:Register("ac_vs_key", vars:Set("ac_vs_key", Nova.netmessage("anticheat_verify_send"), false, true), 3)
	lines:Register("ac_vr_key", vars:Set("ac_vr_key", Nova.netmessage("anticheat_verify_response"), false, true), 3)
	lines:Register("ac_verify",
		string.format(
			"net_receive(%s, function() net_start(%s) net_writestring(net_readstring()) net_sendtoserver() %s() end)",
			vars:Get("ac_vs_key"),
			vars:Get("ac_vr_key"),
			vars:Get("ac_func_run_checks")
	), 4)

	for i = 1, 10 do
		lines:Register("ac_f_key_" .. i, vars:Set("ac_f_key_", Nova.generateString(16, 32), false, true))
	end

	local encryptionKey = Nova.generateString(16, 32)
	lines:Register("ac_encryption_key",  vars:Set("ac_encryption_key", encryptionKey, false, true), 3)

	// local integrity check
	lines:Register("integrityCheck", vars:Set("integrityCheck", payloads["check"], false))
	lines:Register("ac_concommands", vars:Set("ac_concommands", "NOVA_SHARED.ac_cc", false))
	lines:Register("integrity_cc", string.format("local s,e = %s(%s, %q) if not s then %s('anticheat_manipulate_ac','anticheat integrity check failed: ' .. e)  end ",
		vars:Get("integrityCheck"),
		vars:Get("ac_concommands"),
		Nova.obfuscator.getFunctionChecksum(NOVA_SHARED.ac_cc),
		vars:Get("ac_func_detection")
	))

	// autoclick settings
	local aclHookName = Nova.generateString(8, 16)
	lines:Register("ac_acl_hkname",  vars:Set("ac_acl_hkname", aclHookName, false, true), 3)
	local acl_sensivity = Nova.getSetting("anticheat_autoclick_sensivity", "low")
	local acl_params = {
		["high"] = {
			mdev = 0.003,
			devmc = 8,
			thres = 16,
			thresl = 6,
		},
		["medium"] = {
			mdev = 0.0025,
			devmc = 12,
			thres = 19,
			thresl = 8,
		},
		["low"] = {
			mdev = 0.002,
			devmc = 18,
			thres = 30,
			thresl = 10,
		},
	}
	acl_params = acl_params[acl_sensivity]

	local acl_payload = [[
		local delta = {
			size = 15,
			last = 0,
			sum = 0,
			average = 0,
			min_deviation = %f,
			deviation_pass_count = 0,
			deviation_pass_count_max = %d,
			deltaCounter = {},
		}
		
		for i = 1, delta.size do delta.deltaCounter[i] = 0 end
		
		local CPS = {
			thres_high = %d,
			thres_long = %d,
			max_longs = 60*5,
			longs = 0,
			cntr = 0,
			start = 0,
			cur = 0,
		}
	]]
	acl_payload = string.format(acl_payload, acl_params.mdev, acl_params.devmc, acl_params.thres, acl_params.thresl)

	local anticheatPayload_p1 = [[
		local bls = bit.lshift
		local brs = bit.rshift
		local net_start = net.Start
		local net_writestring = net.WriteString
		local net_receive = net.Receive
		local net_readstring = net.ReadString
		local net_sendtoserver = net.SendToServer
		local util_nwstring_to_id = util.NetworkStringToID
		local create_client_convar = CreateClientConVar
		]] .. lines:Insert("ac_key") .. [[
		]] .. lines:Insert("integrityCheck") .. [[
		]] .. lines:Insert("ac_key_cc") .. [[
		]] .. lines:Insert("ac_acl_hkname") .. [[
		]] .. lines:Insert("ac_f_key_1") .. [[
		]] .. lines:Insert("ac_vs_key") .. [[
		]] .. lines:Insert("ac_encryption_key") .. [[
		local concommand_gettable = concommand.GetTable
		local concommand_add = concommand.Add
		local concommand_run = concommand.Run
		local convar_exists = ConVarExists
		local debug_getinfo = debug.getinfo
		local debug_traceback = debug.traceback
		local vgui_create = vgui.Create
		local hook_add = hook.Add
		local hook_gettable = hook.GetTable
		local hook_remove = hook.Remove
		local isfunction = isfunction
		local module_require = require
		local run_string = RunString
		]] .. lines:Insert("ac_vr_key") .. [[
		]] .. lines:Insert("ac_f_key_2") .. [[
		]] .. lines:Insert("ac_acl_hkname") .. [[
		]] .. lines:Insert("ac_key") .. [[
		]] .. lines:Insert("ac_vs_key") .. [[
		local timer_create = timer.Create
		local timer_s = timer.Simple
		]] .. lines:Insert("ac_f_key_3") .. [[
		]] .. lines:Insert("ac_encryption_key") .. [[
		]] .. lines:Insert("ac_key_cc") .. [[
		local render_read_pixel = render.ReadPixel
		local runcc = RunConsoleCommand
		local funck = jit.util.funck
		local funcinfo = jit.util.funcinfo
		local loop_pairs = pairs
		local loop_ipairs = ipairs
		]] .. lines:Insert("ac_f_key_4") .. [[
		]] .. lines:Insert("ac_encryption_key") .. [[
		]] .. lines:Insert("ac_f_key_5") .. [[
		]] .. lines:Insert("ac_key_cc") .. [[
		]] .. lines:Insert("ac_acl_hkname") .. [[
		]] .. lines:Insert("ac_vs_key") .. [[
		]] .. lines:Insert("ac_key") .. [[
		local string_find = string.find
		local string_lower = string.lower
		local string_char = string.char
		local string_sub = string.sub
		local string_startswith = string.StartWith
		local table_insert = table.insert
		local table_hasvalue = table.HasValue
		local safe_pcall = pcall
		local math_random = math.random
		]] .. lines:Insert("ac_key") .. [[
		]] .. lines:Insert("ac_f_key_6") .. [[
		]] .. lines:Insert("ac_vr_key") .. [[
		local file_exists = file.Exists
		local file_find = file.Find
		local file_time = file.Time
		local file_open = file.Open
		local _type = type
		local _tostring = tostring
		local player_getall = player.GetAll
		local vgui_controltable = vgui.GetControlTable

		local bad_cheat_strings = {
			"ambush", "aimware", "snixzz", "antiaim", "memeware",
			"hlscripts", "exploit city", "odium", "local bxsmenu, MenuX"
		}]] .. lines:Insert("ac_f_key_7") .. [[
		]] .. lines:Insert("ac_key") .. [[
		]] .. lines:Insert("ac_vr_key") .. [[
		local bad_file_names = {
			"smeg", "bypass", "aimbot", "aimware", "snixzz", "antiaim", "memeware",
			"hlscripts", "exploitcity", "gmodhack", "scripthook", "ampris", "skidsmasher",
			"gdaap", "swag_hack", "pasteware", "unknowncheats", "mpgh", "defqon", "idiotbox",
			"ravehack", "murderhack", "cathack"
		}
		local bad_function_names = {
			"odium", "smeg", "aimbot", "antiaim", "autostrafe", "fakelag",
			"snixzz", "validnetstring", "addexploit", "cathack"
		}
		]] .. lines:Insert("ac_f_key_8") .. [[
		local bad_global_variables = {
			"antiafk", "aimbot", "wallhack", "mapex", "bunnyhop", "xray",
			"norecoil", "nospread", "decode", "drawesp", "doesp", "manipulate_spread",
			"hl2_shotmanip", "hl2_ucmd_getprediciton", "cf_manipulateshot", "zedhack",
			"triggerbot", "getpred", "odium", "bsendpacket", "validnetstring", "totalexploits",
			"addexploit", "autoreload", "circlestrafe", "toomanysploits", "sploit"
		} ]] .. lines:Insert("ac_key") .. [[
		local bad_module_names = {
			"dickwrap", "enginepred", "bsendpacket", "fhook", "name_enabler",
			"cvar3", "cv3", "nyx", "amplify", "mega", "pa4", "pspeed", "big",
			"snixzz2", "spreadthebutter", "stringtables", "svm", "swag", "external",
			"zxcmodule"
		}
		local bad_cvar_names = {
			"esp_enable", "smeg", "wallhack", "nospread", "antiaim", "hvh", "autostrafe",
			"circlestrafe", "spinbot", "odium", "ragebot", "legitbot", "fakeangles", "anticac",
			"antiscreenshot", "fakeduck", "lagexploit", "exploits_open", "gmodhack", "cathack",
			"aimbot_ignoreteam", "antiaim_walldtc_yaw", {"spin_enabled", "BhopVar"}, "th_setoverlaymat"
		} ]] .. lines:Insert("ac_key") .. [[
		]] .. lines:Insert("ac_f_key_9") .. [[

		]] .. lines:Insert("ac_concommands") .. [[

		local _check_function = ]] .. tostring(Nova.getSetting("anticheat_check_function", false)) .. [[
		local _check_globals = ]] .. tostring(Nova.getSetting("anticheat_check_globals", false)) .. [[
		local _check_modules = ]] .. tostring(Nova.getSetting("anticheat_check_modules", false)) .. [[
		local _check_cvars = ]] .. tostring(Nova.getSetting("anticheat_check_cvars", false)) .. [[ ]] .. lines:Insert("ac_key") .. [[
		local _check_external = ]] .. tostring(Nova.getSetting("anticheat_check_external", false)) .. [[
		local _check_runstring = ]] .. tostring(Nova.getSetting("anticheat_check_runstring", false)) .. [[
		local _check_detoured_functions = ]] .. tostring(Nova.getSetting("anticheat_check_detoured_functions", false)) .. [[
		local _check_concommands = ]] .. tostring(Nova.getSetting("anticheat_check_concommands", false)) .. [[
		local _check_files = ]] .. tostring(Nova.getSetting("anticheat_check_files", false)) .. [[ ]] .. lines:Insert("ac_f_key_10") .. [[
		local _check_net_scan = ]] .. tostring(Nova.getSetting("anticheat_check_net_scan", false)) .. [[
		local _check_manipulation = ]] .. tostring(Nova.getSetting("anticheat_check_manipulation", false)) .. [[
		local _check_autoclick = ]] .. tostring(Nova.getSetting("anticheat_autoclick_enabled", false)) .. [[
		local _check_autoclick_fast = ]] .. tostring(Nova.getSetting("anticheat_autoclick_check_fast", false)) .. [[
		local _check_autoclick_fastlong = ]] .. tostring(Nova.getSetting("anticheat_autoclick_check_fastlong", false)) .. [[
		local _check_autoclick_robotic = ]] .. tostring(Nova.getSetting("anticheat_autoclick_check_robotic", false)) .. [[
		local _spam_filestealers = ]] .. tostring(Nova.getSetting("anticheat_spam_filestealers", false)) .. [[
		_check_autoclick = _check_autoclick and (_check_autoclick_fast or _check_autoclick_fastlong or _check_autoclick_robotic)
		local scanned_net_strings = {}
		]] .. lines:Insert("ac_key") .. [[

		local function get_log_information(m_dbg_tbl)
			local info = ""
			if m_dbg_tbl.short_src then
				info = "Shortsource: " .. m_dbg_tbl.short_src
			end
			if m_dbg_tbl.name then
				info = info .. " Function: " .. (m_dbg_tbl.name == "func" and "Anonymous" or m_dbg_tbl.name)
			end
			if m_dbg_tbl.source then
				info = info .. " Source: " .. m_dbg_tbl.source
			end
			return info
		end
		]] .. lines:Insert("ac_key") .. [[

		local function generate_string(min, max)
			local string_length = (max == nil and min or math_random(min, max))
			local output_str = ""
			for i = 1, string_length do
				output_str = output_str .. string_char(math_random(97, 122))
			end
			return output_str
		end
		]] .. lines:Insert("ac_key") .. [[

		local int_hooks = {}
		local function secure_hook(event, id, name, func)
			if not func or not name or not id or not event then return end
			if not int_hooks[event] then int_hooks[event] = {} end
			if not id then id = generate_string(10,20) end
			if int_hooks[event][id] then return end
			int_hooks[event][id] = {
				["name"] = name,
				["func"] = func
			}
			hook_add(event, id, func)
		end

		]] .. lines:Insert("ac_key") .. [[

		local function is_string_bad(b_string, b_table)
			b_string = string_lower(b_string or "")
			for k, v in loop_ipairs(b_table or {}) do
				if _type(v) == "string" and string_find(b_string, v) then
					return true, v
				end
			end
			return false
		end

		local seed, mod = 0, 2 ^ 32
		local function blr(x, disp) return bls(x, disp) + brs(x, 32 - disp) end
		local function brr(x, disp) return brs(x, disp) + bls(x, 32 - disp) end
		local function xrshft() seed = blr(seed, 13) + brr(seed, 17) + blr(seed, 5) + seed return seed % 256 end

		local function enc(input)
			seed = tonumber(string.upper(string_sub(util.SHA1(]] .. vars:Get("ac_encryption_key") .. [[), 1, 8)),16) % mod
			local out = {}
			for i = 1, string.len(input) do
				local b = string.byte(input, i)
				local c = xrshft()
				local e = bit.bxor(c, b)
				out[i] = string.format("\\%03d", e)
			end
			return table.concat(out)
		end

		local function ]] .. vars:Get("ac_func_detection") .. [[(d_type, d_info)
			if not _type(d_type) == "string" then d_type = _tostring(d_type) end
			if not _type(d_info) == "string" then d_info = _tostring(d_info) end
			d_type, d_info = enc(d_type), enc(d_info)
			timer_s(1,function() net_start(]] .. vars:Get("ac_key") .. [[)
				net_writestring(d_type or "")
				net_writestring(d_info or "")
			net_sendtoserver() end)
			runcc(]] .. vars:Get("ac_key_cc") .. [[)
		end
		]] .. lines:Insert("integrity_cc") .. [[

		local function check_secure_hook()
			local hook_tbl = hook_gettable() or {}
			for event, ids in loop_pairs(int_hooks or {}) do
				for id, tbl in loop_pairs(ids or {}) do
					if not hook_tbl[event]
					or not hook_tbl[event][id]
					or hook_tbl[event][id] ~= tbl.func
					then
						]] .. vars:Get("ac_func_detection") .. [[("anticheat_manipulate_ac", "Removed/replaced anticheat hook: " .. tbl.name)
						hook_add(event, id, tbl.func)
						hook_gettable()[event][id] = tbl.func
					end
				end
			end
		end

		local function check_bad_concommands()
			if not _check_concommands then return end
			local c, _ = concommand_gettable()
			for k, v in loop_pairs(c or {}) do
				if is_string_bad(k, ]] .. vars:Get("ac_concommands") .. [[) then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_concommand", k)
				end
			end
		end

		local function check_global_variables()
			if not _check_globals then return end
			for k, v in loop_ipairs(bad_global_variables or {}) do
				if _G[v] then ]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_global", v) end
			end
		end

		local function check_convars()
			if not _check_cvars then return end
			for k, v in loop_ipairs(bad_cvar_names or {}) do
				if _type(v) ~= "table" then v = {v} end
				local f = true
				for _, c in loop_ipairs(v) do
					if not convar_exists(c) then f = false break end
				end
				if f then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_cvar", "CVarName: " .. table.concat(v, ", "))
				end
			end
		end

		local function check_external(m_dbg_tbl)
			if not _check_external then return end
			if not m_dbg_tbl or not m_dbg_tbl.short_src then return end

			if m_dbg_tbl.short_src == "external" then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_external_bypass", get_log_information(m_dbg_tbl))
			end
		end

		local function is_bad_function(m_dbg_tbl)
			if not _check_function then return end
			if not m_dbg_tbl or not m_dbg_tbl.name then return end
			if is_string_bad(m_dbg_tbl.name, bad_function_names) then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_function", get_log_information(m_dbg_tbl))
			end
		end

		local function is_bad_file_name(m_dbg_tbl)
			if not _check_files then return end
			if not m_dbg_tbl or not m_dbg_tbl.short_src then return end
			if is_string_bad(m_dbg_tbl.short_src, bad_file_names) then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_file", get_log_information(m_dbg_tbl))
			end
		end

		local function hook_tbl_hs_slen(hk, min_len, max_len)
			local hook_tbl = hook_gettable()[hk]
			for k, v in loop_pairs(hook_tbl or {}) do
				local s_len = #k
				if s_len >= min_len and s_len <= max_len then
					return true
				end
			end
			return false
		end
	]]

	local anticheatPayload_p2 = [[
		local function DefaultCheck(i)
			check_external(i)
			is_bad_file_name(i)
			is_bad_function(i)
		end

		function concommand.Run(ply, cmd, args, argstr, ...)
			local m_run_info = debug_getinfo(4)
			check_external(m_run_info)
			return concommand_run(ply, cmd, args, argstr, ...)
		end

		function concommand.Add(...)
			if not _check_concommands then concommand_add(...) return end

			local m_run_info = debug_getinfo(4)
			local tab = {...}
			DefaultCheck(m_run_info)

			if is_string_bad(tab[1], bad_concommands) then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_concommand", "Command: " .. tab[1] .. " " .. get_log_information(m_run_info))
				return
			end
			return concommand_add(...)
		end

		function require(args, ...)
			local m_run_info = debug_getinfo(4)
			if _check_modules and is_string_bad(args, bad_module_names) then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_module", "Modulename: " .. args .. " " .. get_log_information(m_run_info))
				return
			end
			DefaultCheck(m_run_info)
			module_require(args, ...)
		end

		function vgui.Create(...)
			local m_run_info = debug_getinfo(4)
			DefaultCheck(m_run_info)
			return vgui_create(...)
		end

		function hook.Add(...)
			local m_run_info = debug_getinfo(4)
			DefaultCheck(m_run_info)
			hook_add(...)
		end

		function RunString(code, identifier, HandleError, ...)
			if not _check_runstring then return run_string(code, identifier, HandleError, ...) end
			local m_run_info = debug_getinfo(4)
			local s, _ = string_find(debug_traceback() or "", "lua/includes/extensions/net.lua")
			if not s then
				local str, bad_string = is_string_bad(code, bad_cheat_strings)
				local func, bad_func = is_string_bad(code, bad_function_names)
				if str then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_runstring_bad_string", "String: '" .. bad_string .. "' " .. get_log_information(m_run_info))
					return
				end
				if func then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_runstring_bad_function", "Function: '" .. bad_func .. "' " .. get_log_information(m_run_info))
					return
				end
			end

			if m_run_info and m_run_info.short_src and m_run_info.short_src == "lua/vgui/dhtml.lua" then
				if is_string_bad(code, bad_cheat_strings) or is_string_bad(code, bad_function_names) then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_runstring_dhtml", get_log_information(m_run_info))
					return
				end
			end

			DefaultCheck(m_run_info)
			return run_string(code, identifier, HandleError, ...)
		end

		function CreateClientConVar(name, default, shouldsave, userdata, helptext, ...)
			local m_run_info = debug_getinfo(4)
			if _check_cvars and is_string_bad(name, bad_cvar_names) then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_known_cvar", "CVarName: " .. name .. " " .. get_log_information(m_run_info))
				return
			end
			DefaultCheck(m_run_info)
			return create_client_convar(name, default, shouldsave, userdata, helptext, ...)
		end

		if _check_external then
			function debug.getinfo(...)
				local m_run_info = debug_getinfo(4)
				check_external(m_run_info)
				return debug_getinfo(...)
			end
		end

		function timer.Create(id_str, ...)
			local m_run_info = debug_getinfo(4)
			DefaultCheck(m_run_info)
			return timer_create(id_str, ...)
		end

		function net.Start(...)
			local m_run_info = debug_getinfo(4)
			DefaultCheck(m_run_info)
			return net_start(...)
		end

		function util.NetworkStringToID(netstring, ...)
			if not _check_net_scan then return util_nwstring_to_id(netstring, ...) end
			local m_run_info = debug_getinfo(4)
			check_external(m_run_info)
			if not table_hasvalue(scanned_net_strings, netstring) then
				table_insert(scanned_net_strings, netstring)
			end
			if #scanned_net_strings == 40 then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_scanning_netstrings", "Total scanned: " .. #scanned_net_strings .. " " .. get_log_information(m_run_info))
			end
			if #scanned_net_strings >= 40 then return end
			return util_nwstring_to_id(netstring, ...)
		end

		]] .. acl_payload .. [[

		local modes = {
			[IN_JUMP] = {
				name = "Jump",
				delta = table.Copy(delta),
				CPS = table.Copy(CPS),
				isPressed = false
			},
			[IN_USE] = {
				name = "Use",
				delta = table.Copy(delta),
				CPS = table.Copy(CPS),
				isPressed = false
			},
			[IN_ATTACK] = {
				name = "Attack",
				delta = table.Copy(delta),
				CPS = table.Copy(CPS),
				isPressed = false
			},
			[IN_ATTACK2] = {
				name = "Attack2",
				delta = table.Copy(delta),
				CPS = table.Copy(CPS),
				isPressed = false
			}
		}
		local function CheckCPS(mode, c)
			if c - mode.CPS.start > 1 then
				mode.CPS.cur = mode.CPS.cntr
				mode.CPS.longs = mode.CPS.cur >= mode.CPS.thres_long and mode.CPS.longs + 1 or 0
				if _check_autoclick_fastlong and mode.CPS.longs == mode.CPS.max_longs then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_autoclick_fastlong", "More than " .. mode.CPS.thres_long .. " CPS over " .. mode.CPS.max_longs .. " seconds (current: " .. mode.CPS.cur .. ") Key: " .. mode.name)
				end
				if _check_autoclick_fast and mode.CPS.cntr >= mode.CPS.thres_high then
					]] .. vars:Get("ac_func_detection") .. [[("anticheat_autoclick_fast", "More than " .. mode.CPS.thres_high .. " CPS (current: " .. mode.CPS.cur .. ") Key: " .. mode.name)
				end
				mode.CPS.start = c
				mode.CPS.cntr = 0
			end
		
			mode.CPS.cntr = mode.CPS.cntr + 1
		end
		
		local function CheckDelta(mode, c)
			local d = c - mode.delta.last
			mode.delta.last = c
		
			table.insert(mode.delta.deltaCounter, d)
			local last = table.remove(mode.delta.deltaCounter, 1)
			mode.delta.sum = mode.delta.sum + d - last
			mode.delta.average = mode.delta.sum / mode.delta.size
		
			local deviation = math.abs(d - mode.delta.average)
			mode.delta.deviation_pass_count = deviation < mode.delta.min_deviation and mode.delta.deviation_pass_count + 1 or math.Clamp(mode.delta.deviation_pass_count - 1, 0, mode.delta.deviation_pass_count_max)
			if mode.delta.deviation_pass_count == mode.delta.deviation_pass_count_max then
				]] .. vars:Get("ac_func_detection") .. [[("anticheat_autoclick_robotic", "Delta time between clicks is too consistent over " .. mode.delta.deviation_pass_count_max .. " times (current deviation of " .. math.Round(deviation, 6) .. " seconds) Key: " .. mode.name)
			end
		end

		local lastVal = 0
		local acl_hk_name = ]] .. vars:Get("ac_vr_key") .. [[
		local acl_check = function(cmd)
			local btns = cmd:GetButtons()
			if btns == lastVal then return end
			lastVal = btns
			local c = SysTime()
			for k, v in pairs(modes) do
				-- check if bit is set at k
				if bit.band(btns, k) ~= 0 then
					if not v.isPressed then
						if _check_autoclick_robotic then CheckDelta(v, c) end
						CheckCPS(v, c)
						v.isPressed = true
					end
				elseif v.isPressed then
					v.isPressed = false
				end
			end
		end
	
		if _check_autoclick then
			secure_hook("CreateMove", acl_hk_name, "autoclick", acl_check)
		end

		local function ]] .. vars:Get("ac_func_run_checks") .. [[(s)
			if s then timer_s(]] .. math.random(20,300) .. [[, ]] .. vars:Get("ac_func_run_checks") .. [[) end
			check_bad_concommands()
			check_global_variables()
			check_convars()
			check_secure_hook()
		end
		]] .. lines:Insert("ac_verify") .. [[

		]] .. vars:Get("ac_func_run_checks") .. [[(true)
		]] .. lines:Insert("ac_verify") .. [[

		if _spam_filestealers then
			secure_hook("Think", "]] .. Nova.generateString(10,20) .. [[", "filestealer_spam", function()
				local code = "local _ = 'Q9Z47uAZy8iGZAC0J2rHaUT22DE8YQAzeTTM8ls/HfjpQO8GJtANl6FmGsvHyA' local __ = 'bH7wQb881M0+yCZGMcsAOE6AN0Ad8QoJGRaDCn8w/RN+7WD1pWo/dvZUtx==' local ___= 'WIPUdvh13ZQ6cPM2k+DK5BFaeofZi7tl3fndxg0u24Bx6hoIS'"
				code = code .. code
				code = code .. code
				run_string(code)
			end)
		end
		]] .. lines:Insert("ac_verify") .. [[

		_G.CAC = _G.CAC or true
		_G.GAC = _G.GAC or true
		_G.QAC = _G.QAC or true
		_G.SAC = _G.SAC or true
		_G.DAC = _G.DAC or true
		_G.TAC = _G.TAC or true
		_G.simplicity = _G.simplicity or true
		_G.SMAC = _G.SMAC or true
		]] .. lines:Insert("ac_verify") .. [[
		_G.MAC = _G.MAC or true
		_G.CardinalLib = _G.CardinalLib or true
		_G.WDAC = _G.WDAC or true
		_G.CherryAC = _G.CherryAC or true
		_G._ACCvarData = _G._ACCvarData or true
	]]

	// avoid syntax level limit
	local finishedPayload = anticheatPayload_p1 .. anticheatPayload_p2

	return finishedPayload, encryptionKey
end