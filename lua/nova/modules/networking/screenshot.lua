local qualities = {
    ["low"] = 50,
    ["medium"] = 70,
    ["high"] = 90,
}

// we don't compress images, because the data will get even larger in some cases for complex images
local clientPayloadDefault = [[
    local _quality = %d
    hook.Add( "PostRender", %q, function()
		hook.Remove( "PostRender", %q)
		local data = render.Capture( {
			format = "jpg",x = 0,y = 0,w = ScrW(),h = ScrH(),quality = _quality,
		} )
        local netName = %q
        if not data then
            net.Start( netName , false)
                net.WriteUInt( 0, 6 )
            net.SendToServer()
            return
        end
		local netSize = 32000
		local numPackets = math.ceil(#data / netSize)
        for i = 1, numPackets do
            timer.Simple(i * 0.1, function()
                local dataChunk = data:sub((i - 1) * netSize + 1, i * netSize)
                net.Start( netName , false)
                    net.WriteUInt( numPackets, 6 )
                    net.WriteUInt( i, 6 )
                    net.WriteUInt( #dataChunk, 16 )
                    net.WriteData( dataChunk, #dataChunk )
                net.SendToServer()
            end)
        end
	end )
]]

local function SendTgtRequest(tgt)
    if not IsValid(tgt) or not tgt:IsPlayer() then return end
    local quality = qualities[Nova.getSetting("networking_screenshot_quality", "medium")] or qualities["medium"]
    local rndString = Nova.generateString(6, 12)
    local _payload = string.format(clientPayloadDefault, quality, rndString, rndString, Nova.netmessage("networking_screenshot"))
    Nova.sendLua(tgt, _payload, {protected = true, disable_express = true})
end

local function SaveScreenshot(data, tgt, manual, dbg)
    if manual and not Nova.getSetting("networking_screenshot_store_manual", false) then return end

    file.CreateDir("nova/ban_screenshots")
    file.CreateDir("nova/admin_screenshots")
    file.CreateDir("nova/debug_screenshots")

    local directory = manual and "nova/admin_screenshots" or "nova/ban_screenshots"
    if dbg then directory = "nova/debug_screenshots" end
    local limit = manual and Nova.getSetting("networking_screenshot_limit_manual", 100) or Nova.getSetting("networking_screenshot_limit_ban", 100)

    // check if we have too many screenshots
    local files,_ = file.Find(directory .. "/*.jpg", "DATA", "datedesc")
    if #files >= limit then
        local limitExceeded = #files + 1 - limit
        for i = 1, limitExceeded do
            file.Delete(directory .. "/" .. files[#files - i + 1])
        end
    end

    local tgtSteamID = tgt:SteamID64()
    local time = os.date("%Y-%m-%d_%H-%M-%S")

    local filename = string.format("%s/%s_%s.jpg", directory, tgtSteamID, time)

    // concat data
    local dataString = ""
    for i = 1, #data do
        dataString = dataString .. data[i]
    end

    file.Write(filename, dataString)

    Nova.log("i", string.format("Screenshot for %s saved: %q", Nova.playerName(tgt), filename))
end

local screenshotProgress = {}

Nova.takeScreenshot = function(tgt, client, dbg)
    if not IsValid(tgt) or not tgt:IsPlayer() then return end
    local tgtSteamID = tgt:SteamID()
    local requestedByServer = (not IsValid(client) or not client:IsPlayer())

    if not requestedByServer and not Nova.isStaff(client) then return end

    // screenshot for this person is already in progress
    if screenshotProgress[tgtSteamID] then
        if requestedByServer then
            Nova.log("e", string.format("Screenshot for %s failed: Other screenshot for this player in progress.", Nova.playerName(tgt)))
        else
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "screenshot",
                ["message"] = Nova.lang("notify_networking_screenshot_failed_progress", Nova.playerName(tgt)),
            }, client)
        end
        return
    end

    // player already requested a screenshot for another player
    if not requestedByServer then
        for k,v in pairs(screenshotProgress) do
            if v.client == client:SteamID() then
                Nova.notify({
                    ["severity"] = "e",
                    ["module"] = "screenshot",
                    ["message"] = Nova.lang("notify_networking_screenshot_failed_multiple", Nova.playerName(tgt)),
                }, client)
                return
            end
        end
    end

    local time = CurTime()
    screenshotProgress[tgtSteamID] = {
        ["data"] = {},
        ["id"] = time,
        ["received"] = 0,
        ["server"] = requestedByServer,
        ["client"] = not requestedByServer and client:SteamID(),
        ["dbg"] = dbg and true or false,
    }

    Nova.log("d", string.format("Screenshot for %s requested by %s.", Nova.playerName(tgt), requestedByServer and "server" or Nova.playerName(client)))

    SendTgtRequest(tgt)

    // timeout
    timer.Simple(30, function()
        if not screenshotProgress[tgtSteamID] then return end
        // check if id is still the same
        if screenshotProgress[tgtSteamID].id != time then return end

        if requestedByServer then
            Nova.log("e", string.format("Screenshot for %s failed: Timeout.", Nova.playerName(tgtSteamID)))
        elseif IsValid(client) then
            Nova.notify({
                ["severity"] = "e",
                ["module"] = "screenshot",
                ["message"] = Nova.lang("notify_networking_screenshot_failed_timeout", Nova.playerName(tgt)),
            }, client)
        end
        screenshotProgress[tgtSteamID] = nil
    end)
end

hook.Add("nova_init_loaded", "networking_screenshot", function()
    Nova.log("d", "Creating screenshot netmessages")
    Nova.netmessage("networking_screenshot")
    Nova.netReceive(Nova.netmessage("networking_screenshot"), function(len, ply)
        local plySteamID = ply:SteamID()
        // only accept if we have a screenshot in progress
        if not screenshotProgress[plySteamID] then return end

        local totalPackages = net.ReadUInt(6)               if not totalPackages then return end

        // check if screenshot failed
        if totalPackages == 0 then
            local requestedByServer = screenshotProgress[plySteamID]["server"]
            if requestedByServer then
                Nova.log("e", string.format("Screenshot for %s failed: No packages received. This can happen if it was blocked by cheat or player is inside escape menu", Nova.playerName(ply)))
            else
                local client = screenshotProgress[plySteamID]["client"] or ""
                client = Nova.fPlayerBySteamID(client)
                if IsValid(client) and client:IsPlayer() then
                    Nova.notify({
                        ["severity"] = "e",
                        ["module"] = "screenshot",
                        ["message"] = Nova.lang("notify_networking_screenshot_failed_empty", Nova.playerName(ply)),
                    }, client)
                end
            end

            screenshotProgress[plySteamID] = nil
            return
        end

        local index = net.ReadUInt(6)                       if not index then return end
        local partitionSize = net.ReadUInt(16)              if not partitionSize then return end
        local partitionData = net.ReadData(partitionSize)   if not partitionData then return end

        screenshotProgress[plySteamID]["received"] = screenshotProgress[plySteamID]["received"] + 1
        screenshotProgress[plySteamID]["data"][index] = partitionData

        Nova.log("d", string.format("Screenshot progress for %s: %d/%d", Nova.playerName(ply), screenshotProgress[plySteamID]["received"], totalPackages))

        // check who requested the screenshot
        local client = screenshotProgress[plySteamID]["client"] or ""
        client = Nova.fPlayerBySteamID(client)

        // send progress to request client
        if IsValid(client) and client:IsPlayer() then
            net.Start(Nova.netmessage("networking_screenshot"), true)
                net.WriteUInt(math.ceil(screenshotProgress[plySteamID]["received"] / (totalPackages * 2) * 100), 8)
            net.Send(client)
        end

        // packages are still missing, return
        if screenshotProgress[plySteamID]["received"] != totalPackages then return end

        local requestedByServer = screenshotProgress[plySteamID]["server"]

        SaveScreenshot(screenshotProgress[plySteamID]["data"], ply, not requestedByServer, screenshotProgress[plySteamID]["dbg"])

        // check if server requested the screenshot
        if requestedByServer then
            // cleanup
            screenshotProgress[plySteamID] = nil
            return
        end

        // check if request client is still online
        if not IsValid(client) or not client:IsPlayer() then return end
        Nova.log("d", string.format("Finished screenshot for %s. Sending back to %s", Nova.playerName(ply), Nova.playerName(client)))

        // send the screenshot to the client
        for i = 1, totalPackages do
            timer.Simple(i * 0.1, function()
                if not IsValid(client) or not client:IsPlayer() then return end
                Nova.log("d", string.format("Sending screenshot package %d/%d to %s", i, totalPackages, Nova.playerName(client)))
                net.Start(Nova.netmessage("networking_screenshot"))
                    net.WriteUInt(math.ceil((totalPackages + i) / (totalPackages * 2) * 100), 8)
                    net.WriteUInt(totalPackages, 6)
                    net.WriteUInt(i, 6)
                    net.WriteUInt(#screenshotProgress[plySteamID]["data"][i], 16)
                    net.WriteData(screenshotProgress[plySteamID]["data"][i], #screenshotProgress[plySteamID]["data"][i])
                net.Send(client)
                // cleanup
                if i == totalPackages then
                    screenshotProgress[plySteamID] = nil
                end
            end)
        end
    end)
end)

hook.Add("nova_banbypass_onplayerban", "networking_screenshot", function(ply_or_steamid, ban)
    if not Nova.getSetting("networking_screenshot_store_ban", true) then return end

    // convert steamid into right format
    local steamID = Nova.convertSteamID(ply_or_steamid)
    if not steamID or steamID == "" then return end

    // check if player is online
    local ply = Nova.fPlayerBySteamID(steamID)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    // take screenshot
    Nova.log("d", string.format("Taking screenshot for %s because of ban.", Nova.playerName(ply)))
    Nova.takeScreenshot(ply, nil)
end)