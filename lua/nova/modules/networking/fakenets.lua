/*
    Most of the following exploits and backdoors are rare and even not in use anymore.
*/

Nova.fakeNetsLoaded = Nova.fakeNetsLoaded or false

// If Nova is installed in coexistence with SNTE, we ignore all exploits and backdoors
// that are already detected by SNTE
// https://steamcommunity.com/sharedfiles/filedetails/?id=1308262997
local function SNTEInstalled(arguments)
    if hook.GetTable()["CanTool"]["SNTE_KILL_BOUNCY_BALL_EXPLOIT"] then return true end
    local banMethodCallback = cvars.GetConVarCallbacks("snte_banmethod")
    if banMethodCallback and table.Count(banMethodCallback) > 0 then return true end
    return false
end

local function LoadFakeNets()
    if Nova.fakeNetsLoaded then return end

    local snte = SNTEInstalled()

    for key, value in pairs(Nova.fakenets_backdoors or {}) do
        // netmessage already exists on server
        if tobool(util.NetworkStringToID(key)) then
            if snte then
                Nova.log("w", string.format("Detected backdoor %q on the server! It is likely created by SNTE", key))
            else
                Nova.log("w", string.format("Detected backdoor %q on the server!", key))
                Nova.fakenets_backdoors[key] = false
            end
            continue
        end

        if Nova.getSetting("networking_fakenets_backdoors_load", false) then
            util.AddNetworkString(key)
        end
    end

    if Nova.getSetting("networking_fakenets_backdoors_load", false) then
        Nova.log("s", string.format("Loaded %d fake net strings for backdoors", table.Count(Nova.fakenets_backdoors)))
    end

    for key, value in pairs(Nova.fakenets_exploits or {}) do
        // netmessage already exists on server
        if tobool(util.NetworkStringToID(key)) then
            // exists on server and should not be detected as harmful
            // we assume these are already patched
            // Nova Defender does not protect you from not keeping your server up to date
            if snte then
                Nova.log("w", string.format("Detected potential exploit %q on the server! It is likely created by SNTE", key))
            else
                Nova.log("w", string.format("Detected potential exploit %q on the server! Please check if your scripts are up-to-date.", key))
                Nova.fakenets_exploits[key] = false
            end
            continue
        end

        if Nova.getSetting("networking_fakenets_exploits_load", false) then
            util.AddNetworkString(key)
        end
    end

    if Nova.getSetting("networking_fakenets_exploits_load", false) then
        Nova.log("s", string.format("Loaded %d fake net strings for exploits", table.Count(Nova.fakenets_exploits)))
    end
end

Nova.registerAction("networking_exploit", "networking_fakenets_exploits_action", {
    ["add"] = function(steamid, msg)
        Nova.addDetection(steamid, "networking_exploit", Nova.lang("notify_networking_exploit", Nova.playerName(steamid), msg))
    end,
    ["nothing"] = function(steamid, msg)
        Nova.log("i", string.format("%s used an network exploit %q. But no action was taken.", Nova.playerName(steamid), msg))
    end,
    ["notify"] = function(steamid, msg)
        Nova.log("w", string.format("%s used an network exploit %q", Nova.playerName(steamid), msg))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_exploit", Nova.playerName(steamid), msg),
            ["steamid"] = steamid,
        })
    end,
    ["kick"] = function(steamid, msg)
        Nova.kickPlayer(steamid, nil, "networking_exploit")
    end,
    ["ban"] = function(steamid, msg)
        Nova.banPlayer(steamid, nil, string.format("Using network exploit: %q", msg or "UNKNOWN"), "networking_exploit")
    end,
    ["allow"] = function(steamid, msg, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s used an network exploit %q", Nova.playerName(steamid), msg))
    end,
    ["ask"] = function(steamid, msg, actionKey, _actions)
        steamid = Nova.convertSteamID(steamid)
        Nova.log("w", string.format("%s used an network exploit %q", Nova.playerName(steamid), msg))
        Nova.askAction({
            ["identifier"] = "networking_exploit",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_exploit_action", msg or "UNKNOWN"),
            ["ply"] = steamid,
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamid,
                    comment = string.format("Using network exploit: %q", msg or "UNKNOWN"),
                    internal_reason = "networking_exploit"
                })
                Nova.startAction("networking_exploit", "nothing", steamid, msg)
                return
            end
            Nova.startAction("networking_exploit", answer, steamid, msg, admin)
        end)
    end,
})

Nova.registerAction("networking_backdoor", "networking_fakenets_backdoors_action", {
    ["add"] = function(steamid, msg)
        Nova.addDetection(steamid, "networking_backdoor", Nova.lang("notify_networking_backdoor", Nova.playerName(steamid), msg))
    end,
    ["nothing"] = function(steamid, msg)
        Nova.log("i", string.format("%s used a network backdoor %q. But no action was taken.", Nova.playerName(steamid), msg))
    end,
    ["notify"] = function(steamid, msg)
        Nova.log("w", string.format("%s used a network backdoor %q", Nova.playerName(steamid), msg))
        Nova.notify({
            ["severity"] = "w",
            ["module"] = "network",
            ["message"] = Nova.lang("notify_networking_backdoor", Nova.playerName(steamid), msg),
            ["steamid"] = steamid,
        })
    end,
    ["kick"] = function(steamid, msg)
        Nova.kickPlayer(steamid, nil, "networking_backdoor")
    end,
    ["ban"] = function(steamid, msg)
        Nova.banPlayer(steamid, nil, string.format("Using network backdoor: %q", msg or "UNKNOWN"), "networking_backdoor")
    end,
    ["allow"] = function(steamid, msg, admin)
        Nova.notify({
            ["severity"] = "e",
            ["module"] = "action",
            ["message"] = Nova.lang("notify_functions_allow_failed"),
        }, admin)
        Nova.log("i", string.format("%s used a network backdoor %q", Nova.playerName(steamid), msg))
    end,
    ["ask"] = function(steamid, msg, actionKey, _actions)
        Nova.log("w", string.format("%s used a network backdoor %q", Nova.playerName(steamid), msg))
        Nova.askAction({
            ["identifier"] = "networking_backdoor",
            ["action_key"] = actionKey,
            ["reason"] = Nova.lang("notify_networking_backdoor_action", msg or "UNKNOWN"),
            ["ply"] = Nova.convertSteamID(steamid),
        }, function(answer, admin)
            if answer == false then return end
            if not answer then
                Nova.logDetection({
                    steamid = steamid,
                    comment = string.format("Using network backdoor: %q", msg or "UNKNOWN"),
                    internal_reason = "networking_backdoor"
                })
                Nova.startAction("networking_backdoor", "nothing", steamid, msg)
                return
            end
            Nova.startAction("networking_backdoor", answer, steamid, msg, admin)
        end)
    end,
})

Nova.isFakenet = function(name)
    // if a netmessage exists by default on the server, then it's not a fake netmessage
    if Nova.fakenets_exploits[name] == true then return true end
    if Nova.fakenets_backdoors[name] == true then return true end
    return false
end

Nova.getExistingBackdoors = function()
    local backdoors = {}
    for k, v in pairs(Nova.fakenets_backdoors or {}) do
        if v == false then table.insert(backdoors, k) end
    end
    return backdoors
end

Nova.getExistingExploits = function()
    local exploits = {}
    for k, v in pairs(Nova.fakenets_exploits or {}) do
        if v == false then table.insert(exploits, k) end
    end
    return exploits
end

hook.Add("nova_networking_incoming", "networking_fakenets", function(client, steamID, strName, len)
    // not loaded or unknown netmessage
    if not Nova.fakeNetsLoaded or (Nova.fakenets_exploits[strName] == nil and Nova.fakenets_backdoors[strName] == nil) then
        return
    end

    local isFakeNet = Nova.isFakenet(strName)
    local isExploit = Nova.fakenets_exploits[strName] != nil
    local isBackdoor = Nova.fakenets_backdoors[strName] != nil

    if isFakeNet then
        if isBackdoor then
            Nova.startDetection("networking_backdoor", steamID, strName, "networking_fakenets_backdoors_action")
        elseif isExploit then
            Nova.startDetection("networking_exploit", steamID, strName, "networking_fakenets_exploits_action")
        end
    end

    local blockExploits = Nova.getSetting("networking_fakenets_exploits_block", false)
    local blockBackdoors = Nova.getSetting("networking_fakenets_backdoors_block", false)
    if isBackdoor and blockBackdoors then
        Nova.log("i", string.format("Backdoor %q was blocked from being used by %s", strName, Nova.playerName(client)))
        return false
    elseif isExploit and blockExploits then
        Nova.log("i", string.format("Exploit %q was blocked from being used by %s", strName, Nova.playerName(client)))
        return false
    end
end)

// other addons might still need time to load their netmessages
timer.Simple(15, function()
    LoadFakeNets()
    Nova.fakeNetsLoaded = true
end)

if not Nova.fakeNetsLoaded then
    Nova.fakenets_exploits = {
        ["pplay_addrow"] = true,
        ["pplay_sendtable"] = true,
        ["writequery"] = true,
        ["sendmoney"] = true,
        ["bailout"] = true,
        ["customprinter_get"] = true,
        ["textstickers_entdata"] = true,
        ["nc_getnamechange"] = true,
        ["ats_warp_remove_client"] = true,
        ["ats_warp_from_client"] = true,
        ["ats_warp_viewowner"] = true,
        ["cfremovegame"] = true,
        ["cfjoingame"] = true,
        ["cfendgame"] = true,
        ["createcase"] = true,
        ["rprotect_terminal_settings"] = true,
        ["stackghost"] = true,
        ["reviveplayer"] = true,
        ["armory_retrieveweapon"] = true,
        ["transferreport"] = true,
        ["simplicityac_aysent"] = true,
        ["pac_to_contraption"] = true,
        ["sendtable"] = true,
        ["steamid2"] = true,
        ["kun_selldrug"] = true,
        ["net_psunboxserver"] = true,
        ["pplay_deleterow"] = true,
        ["craftsomething"] = true,
        ["banleaver"] = true,
        ["75_plus_win"] = true,
        ["atmdepositmoney"] = true,
        ["taxi_add"] = true,
        ["kun_selloil"] = true,
        ["sellminerals"] = true,
        ["takebetmoney"] = true,
        ["policejoin"] = true,
        ["cpform_answers"] = true,
        ["depositmoney"] = true,
        ["mde_removestuff_c2s"] = true,
        ["net_ss_dobuytakeoff"] = true,
        ["net_ecsettax"] = true,
        ["rp_accept_fine"] = true,
        ["rp_fine_player"] = true,
        ["rxcar_shop_store_c2s"] = true,
        ["rxcar_sellinvcar_c2s"] = true,
        ["drugseffect_remove"] = true,
        ["drugs_money"] = true,
        ["craftingmod_shop"] = true,
        ["drugs_ignite"] = true,
        ["drugseffect_hpremove"] = true,
        ["darkrp_kun_forcespawn"] = true,
        ["drugs_text"] = true,
        ["nlrkick"] = true,
        ["reckickafker"] = true,
        ["gmbg:pickupitem"] = true,
        ["dl_answering"] = true,
        ["data_check"] = true,
        ["plywarning"] = true,
        ["nlr.actionplayer"] = true,
        ["timebombdefuse"] = true,
        ["start_wd_emp"] = true,
        ["kart_sell"] = true,
        ["farmingmodsellitems"] = true,
        ["clickeraddtopoints"] = true,
        ["bodyman_model_change"] = true,
        ["tow_paythefine"] = true,
        ["fire_createfiretruck"] = true,
        ["hitcomplete"] = true,
        ["hhh_request"] = true,
        ["dahit"] = true,
        ["tcbbuyammo"] = true,
        ["datasend"] = true,
        ["gban.banbuffer"] = true,
        ["fp_as_doorhandler"] = true,
        ["upgrade"] = true,
        ["towtruck_createtowtruck"] = true,
        ["tow_submitwarning"] = true,
        ["duelrequestguiyes"] = true,
        ["joinorg"] = true,
        ["pac_submit"] = true,
        ["ndes_selectedemblem"] = true,
        ["join_disconnect"] = true,
        ["morpheus.stafftracker"] = true,
        ["casinokit_chipexchange"] = true,
        ["buykey"] = true,
        ["buycrate"] = true,
        ["factioninviteconsole"] = true,
        ["1942_fuhrer_submitcandidacy"] = true,
        ["pogcp_report_submitreport"] = true,
        ["hsend"] = true,
        ["builderxtogglekill"] = true,
        ["chatbox_playerchat"] = true,
        ["reports.submit"] = true,
        ["services_accept"] = true,
        ["warn_createwarn"] = true,
        ["newreport"] = true,
        ["soez"] = true,
        ["givehealthnpc"] = true,
        ["darkrp_ss_gamble"] = true,
        ["buyinghealth"] = true,
        ["whk_setart"] = true,
        ["withdrewbmoney"] = true,
        ["duelmessagereturn"] = true,
        ["ban_rdm"] = true,
        ["buycar"] = true,
        ["ats_send_toserver"] = true,
        ["dlogsgetcommand"] = true,
        ["disguise"] = true,
        ["gportal_rpname_change"] = true,
        ["abilityuse"] = true,
        ["race_accept"] = true,
        ["give_me_weapon"] = true,
        ["finishcontract"] = true,
        ["nlr_spawn"] = true,
        ["kun_ziptiestruggle"] = true,
        ["jb_votekick"] = true,
        ["letthisdudeout"] = true,
        ["ckit_roul_bet"] = true,
        ["pac.net.touchflexes.clientnotify"] = true,
        ["ply_pick_shit"] = true,
        ["tfa_attachment_requestall"] = true,
        ["buyfirsttovar"] = true,
        ["buysecondtovar"] = true,
        ["money_system_getweapons"] = true,
        ["mcon_demote_toserver"] = true,
        ["withdrawp"] = true,
        ["pcadd"] = true,
        ["activatepc"] = true,
        ["pcdelall"] = true,
        ["viv_hl2rp_disp_message"] = true,
        ["atm_depositmoney_c2s"] = true,
        ["bm2.command.sellbitcoins"] = true,
        ["bm2.command.eject"] = true,
        ["tickbooksendfine"] = true,
        ["egg"] = true,
        ["rhc_jail_player"] = true,
        ["playeruseitem"] = true,
        ["chess top10"] = true,
        ["itemstoreuse"] = true,
        ["ezs_playertag"] = true,
        ["simfphys_gasspill"] = true,
        ["sphys_dupe"] = true,
        ["sw_gokart"] = true,
        ["wordenns"] = true,
        ["attemptsellcar"] = true,
        ["uplywarning"] = true,
        ["atlaschat.rqclrcfg"] = true,
        ["dlib.getinfo.replicate"] = true,
        ["setpermaknife"] = true,
        ["enterprisewithdraw"] = true,
        ["sbp_addtime"] = true,
        ["netdata"] = true,
        ["cw20_preset_load"] = true,
        ["minigun_drones_switch"] = true,
        ["net_am_makepotion"] = true,
        ["bitcoins_request_turn_off"] = true,
        ["bitcoins_request_turn_on"] = true,
        ["bitcoins_request_withdraw"] = true,
        ["permwepsnpcsellweapon"] = true,
        ["ncpstoredoact"] = true,
        ["duelrequestclient"] = true,
        ["beginspin"] = true,
        ["tickbookpayfine"] = true,
        ["fg_printer_money"] = true,
        ["igs.getpaymenturl"] = true,
        ["airdrops_startplacement"] = true,
        ["slotsremoved"] = true,
        ["farmingmod_dropitem"] = true,
        ["cab_sendmessage"] = true,
        ["cab_cd_testdrive"] = true,
        ["blueatm"] = true,
        ["scp-294sv"] = true,
        ["dronesrewrite_controldr"] = true,
        ["desktopprinter_withdraw"] = true,
        ["removetag"] = true,
        ["idinv_requestbank"] = true,
        ["usemedkit"] = true,
        ["wipemask"] = true,
        ["swapfilter"] = true,
        ["removemask"] = true,
        ["deploymask"] = true,
        ["zed_spawncar"] = true,
        ["levelup_useperk"] = true,
        ["passmayorexam"] = true,
        ["selldatride"] = true,
        ["org_vaultdonate"] = true,
        ["org_neworg"] = true,
        ["scannermenu"] = true,
        ["misswd_accept"] = true,
        ["d3a_message"] = true,
        ["lawstoserver"] = true,
        ["shop_buy"] = true,
        ["d3a_createorg"] = true,
        ["gb_gasstation_buygas"] = true,
        ["gb_gasstation_buyjerrycan"] = true,
        ["mineserver"] = true,
        ["acceptbailoffer"] = true,
        ["lawyerofferbail"] = true,
        ["buy_bundle"] = true,
        ["askpickupiteminv"] = true,
        ["donatorshop_itemtobuy"] = true,
        ["netorgvoteinvite_server"] = true,
        ["chess clientwager"] = true,
        ["acceptrequest"] = true,
        ["deposit"] = true,
        ["cuberiot capturezone update"] = true,
        ["npcshop_buyitem"] = true,
        ["spawnprotection"] = true,
        ["hoverboardpurchase"] = true,
        ["soundarrestcommit"] = true,
        ["lotterymenu"] = true,
        ["updatelaws"] = true,
        ["tmc_net_fireplayer"] = true,
        ["thiefnpc"] = true,
        ["tmc_net_makeplayerwanted"] = true,
        ["syncremoveaction"] = true,
        ["hv_ammobuy"] = true,
        ["net_cr_takestoredmoney"] = true,
        ["nox_addpremadepunishment"] = true,
        ["grabmoney"] = true,
        ["lawyer.getbailout"] = true,
        ["lawyer.bailfelonout"] = true,
        ["br_send_pm"] = true,
        ["get_admin_msgs"] = true,
        ["open_admin_chat"] = true,
        ["lb_addban"] = true,
        ["redirectmsg"] = true,
        ["rdmreason_explain"] = true,
        ["jb_selectwarden"] = true,
        ["jb_givecubics"] = true,
        ["sendsteamid"] = true,
        ["wyozimc_playply"] = true,
        ["specdm_sendloadout"] = true,
        ["sv_saveweapons"] = true,
        ["dl_startreport"] = true,
        ["dl_reportplayer"] = true,
        ["dl_asklogslist"] = true,
        ["dailyloginclaim"] = true,
        ["giveweapon"] = true,
        ["govstation_spawnvehicle"] = true,
        ["invitetoorganization"] = true,
        ["createfaction"] = true,
        ["sellitem"] = true,
        ["givearrestreason"] = true,
        ["unarrestperson"] = true,
        ["joinfirstss"] = true,
        ["bringnfreeze"] = true,
        ["start_wd_hack"] = true,
        ["destroytable"] = true,
        ["nctieupstart"] = true,
        ["ivebeenrdmed"] = true,
        ["fightclub_startfight"] = true,
        ["fightclub_kickplayer"] = true,
        ["respawn"] = true,
        ["cp_test_results"] = true,
        ["is_submitsid_c2s"] = true,
        ["is_getreward_c2s"] = true,
        ["changeorgname"] = true,
        ["disbandorganization"] = true,
        ["createorganization"] = true,
        ["newterritory"] = true,
        ["invitemember"] = true,
        ["sendduelinfo"] = true,
        ["dodealerdeliver"] = true,
        ["purchaseweed"] = true,
        ["guncraft_removeworkbench"] = true,
        ["useracceptprestige"] = true,
        ["vj_npcspawner_sv_create"] = true,
        ["client_to_server_openeditor"] = true,
        ["givescp294cup"] = true,
        ["givearmor100"] = true,
        ["sprintspeedset"] = true,
        ["armorbutton"] = true,
        ["healbutton"] = true,
        ["srequest"] = true,
        ["clickerforcesave"] = true,
        ["rpi_trade_end"] = true,
        ["net_bailplayer"] = true,
        ["vj_testentity_runtextsd"] = true,
        ["vj_fireplace_turnon2"] = true,
        ["requestmoneyforvk"] = true,
        ["gprinters.sendid"] = true,
        ["fire_removefiretruck"] = true,
        ["drugs_effect"] = true,
        ["drugs_give"] = true,
        ["net_doprinteraction"] = true,
        ["opr_withdraw"] = true,
        ["money_clicker_withdraw"] = true,
        ["ngii_takemoney"] = true,
        ["gprinters.retrievemoney"] = true,
        ["revival_revive_accept"] = true,
        ["chname"] = true,
        ["newrpnamesql"] = true,
        ["updaterpumodelsql"] = true,
        ["settabletarget"] = true,
        ["squadgiveweapon"] = true,
        ["buyupgradesstuff"] = true,
        ["repadminchangelvl"] = true,
        ["sendmail"] = true,
        ["demoteplayer"] = true,
        ["opengates"] = true,
        ["vehicleunderglow"] = true,
        ["hopping_test"] = true,
        ["create_report"] = true,
        ["createentity"] = true,
        ["firemanleave"] = true,
        ["darkrp_defib_forcespawn"] = true,
        ["resupply"] = true,
        ["btttstartvotekick"] = true,
        ["_nondbvmvote"] = true,
        ["reppurchase"] = true,
        ["deathrag_takeitem"] = true,
        ["faccreate"] = true,
        ["informplayer"] = true,
        ["lockpick_sound"] = true,
        ["setplayermodel"] = true,
        ["changetophysgun"] = true,
        ["votebanno"] = true,
        ["votekickno"] = true,
        ["shopguild_buyitem"] = true,
        ["mg2.request.gangrankings"] = true,
        ["requestmapsize"] = true,
        ["gmining.sellmineral"] = true,
        ["itemstoredrop"] = true,
        ["optarrest"] = true,
        ["talkiconchat"] = true,
        ["updateadvbonesettings"] = true,
        ["viralsscoreboardadmin"] = true,
        ["powerroundsforcepr"] = true,
        ["showdisguisehud"] = true,
        ["withdrawmoney"] = true,
        ["phone"] = true,
        ["stloantoserver"] = true,
        ["tcbdealerstore"] = true,
        ["tcbdealerspawn"] = true,
        ["gmining.registerachievement"] = true,
        ["gprinters.openupgrades"] = true,
        ["darkrp_preferredjobmodel"] = true,
        ["ts_buytitle"] = true
    }

    Nova.fakenets_backdoors = {
        ["sbox_gm_attackofnullday_key"] = true,
        ["enablevac"] = true,
        ["ulxquery2"] = true,
        ["im_socool"] = true,
        ["moonman"] = true,
        ["lickmeout"] = true,
        ["sessionbackdoor"] = true,
        ["odiumbackdoor"] = true,
        ["ulx_query2"] = true,
        ["sbox_itemstore"] = true,
        ["sbox_darkrp"] = true,
        ["sbox_message"] = true,
        ["_blacksmurf"] = true,
        ["nostrip"] = true,
        ["remove_exploiters"] = true,
        ["sandbox_armdupe"] = true,
        ["rconadmin"] = true,
        ["jesuslebg"] = true,
        ["disablebackdoor"] = true,
        ["blacksmurfbackdoor"] = true,
        ["jeveuttonrconleul"] = true,
        ["lag_ping"] = true,
        ["memedoor"] = true,
        ["darkrp_adminweapons"] = true,
        ["fix_keypads"] = true,
        ["noclipcloakaesp_chat_text"] = true,
        ["_cac_readmemory"] = true,
        ["ulib_message"] = true,
        ["ulogs_infos"] = true,
        ["item"] = true,
        ["nocheat"] = true,
        ["adsp_door_length"] = true,
        ["î¾psilon"] = true,
        ["jqerystrip.disable"] = true,
        ["sandbox_gayparty"] = true,
        ["darkrp_utf8"] = true,
        ["playerkilledlogged"] = true,
        ["oldnetreaddata"] = true,
        ["backdoor"] = true,
        ["cucked"] = true,
        ["nonerks"] = true,
        ["kek"] = true,
        ["darkrp_money_system"] = true,
        ["betstrep"] = true,
        ["zimbabackdoor"] = true,
        ["something"] = true,
        ["random"] = true,
        ["strip0"] = true,
        ["fellosnake"] = true,
        ["idk"] = true,
        ["||||"] = true,
        ["enigmaisthere"] = true,
        ["altered_carb0n"] = true,
        ["killserver"] = true,
        ["fuckserver"] = true,
        ["cvaraccess"] = true,
        ["_defcon"] = true,
        ["dontforget"] = true,
        ["aze46aez67z67z64dcv4bt"] = true,
        ["nolag"] = true,
        ["changename"] = true,
        ["music"] = true,
        ["_defqon"] = true,
        ["xenoexistscl"] = true,
        ["r8"] = true,
        ["analcavity"] = true,
        ["defqonbackdoor"] = true,
        ["fourhead"] = true,
        ["echangeinfo"] = true,
        ["playeritempickup"] = true,
        ["thefrenchenculer"] = true,
        ["elfamosabackdoormdr"] = true,
        ["stoppk"] = true,
        ["noprop"] = true,
        ["reaper"] = true,
        ["abcdefgh"] = true,
        ["jsquery.data(post(false))"] = true,
        ["pjhabrp9ey"] = true,
        ["_raze"] = true,
        ["88"] = true,
        ["dominos"] = true,
        ["noodium_readping"] = true,
        ["m9k_explosionradius"] = true,
        ["gag"] = true,
        ["_cac_"] = true,
        ["_battleye_meme_"] = true,
        ["legrandguzmanestla"] = true,
        ["ulogs_b"] = true,
        ["arivia"] = true,
        ["_warns"] = true,
        ["xuy"] = true,
        ["samosatracking57"] = true,
        ["striphelper"] = true,
        ["m9k_explosive"] = true,
        ["gaysploitbackdoor"] = true,
        ["_gaysploit"] = true,
        ["slua"] = true,
        ["bilboard.adverts:spawn(false)"] = true,
        ["boost_fps"] = true,
        ["fpp_antistrip"] = true,
        ["ulx_query_test2"] = true,
        ["fadmin_anticrash"] = true,
        ["ulx_anti_backdoor"] = true,
        ["ukt_momos"] = true,
        ["rcivluz"] = true,
        ["sendtest"] = true,
        ["mjkqswhqfz"] = true,
        ["inj3v4"] = true,
        ["_clientcvars"] = true,
        ["_main"] = true,
        ["gmod_netdbg"] = true,
        ["thereaper"] = true,
        ["audisquad_lua"] = true,
        ["anticrash"] = true,
        ["zernaxbackdoor"] = true,
        ["bdsm"] = true,
        ["waoz"] = true,
        ["stream"] = true,
        ["adm_network"] = true,
        ["antiexploit"] = true,
        ["readping"] = true,
        ["berettabest"] = true,
        ["componenttolua"] = true,
        ["theberettabcd"] = true,
        ["negativedlebest"] = true,
        ["mathislebg"] = true,
        ["sparkslebg"] = true,
        ["doge"] = true,
        ["fpsboost"] = true,
        ["n::b::p"] = true,
        ["pda_drm_request_content"] = true,
        ["shix"] = true,
        ["inj3"] = true,
        ["aidstacos"] = true,
        ["verifiopd"] = true,
        ["pwn_wake"] = true,
        ["pwn_http_answer"] = true,
        ["pwn_http_send"] = true,
        ["the_dankwoo"] = true,
        ["gm_lib_fastoperation"] = true,
        ["prdw_get"] = true,
        ["fancyscoreboard_leave"] = true,
        ["darkrp_gamemodes"] = true,
        ["darkrp_armors"] = true,
        ["yohsambresicianatik<3"] = true,
        ["enigmaproject"] = true,
        ["playercheck"] = true,
        ["ulx_error_88"] = true,
        ["fadmin_notification_receiver"] = true,
        ["darkrp_receivedata"] = true,
        ["weapon_88"] = true,
        ["__g____cac"] = true,
        ["absolut"] = true,
        ["mecthack"] = true,
        ["setplayerdeathcount"] = true,
        ["awarn_remove"] = true,
        ["fijiconn"] = true,
        ["nw.readstream"] = true,
        ["luacmd"] = true,
        ["the_dankwhy"] = true,
    }
end