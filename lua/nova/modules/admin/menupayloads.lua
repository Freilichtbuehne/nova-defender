Nova.getMenuPayload = function(ply_or_steamid)
    local isProtected = Nova.isProtected(ply_or_steamid)

    local playerAccess = Nova.getSetting("menu_access_player", false) or isProtected
    local detectionsAccess = Nova.getSetting("menu_access_detections", false) or isProtected
    local bansAccess = Nova.getSetting("menu_access_bans", false) or isProtected
    local healthAccess = Nova.getSetting("menu_access_health", false) or isProtected
    local inspectionAccess = Nova.getSetting("menu_access_inspection", false) or isProtected
    local ddosAccess = Nova.extensions["priv_ddos_protection"]["enabled"] and (Nova.getSetting("menu_access_ddos", false) or isProtected)

    if
          not isProtected
      and not playerAccess
      and not detectionsAccess
      and not bansAccess
      and not healthAccess
      and not inspectionAccess
      and not ddosAccess
    then
      return [[
        concommand.Remove("nova_defender")
        if IsValid(NOVA_MENU) then 
          NOVA_MENU:SetVisible( false )
          NOVA_MENU:Remove() 
        end
      ]]
    end

    // TODO: Better display of extensions 

    local payload = [[
  ------------------------------
  --  Global Variables
  ------------------------------
  NOVA_MENU = NOVA_MENU or nil
  NOVA_LANG = NOVA_LANG or nil
  NOVA_ACTIVE_TAB = NOVA_ACTIVE_TAB or nil
  NOVA_ACTIVE_CONTEXT = NOVA_ACTIVE_CONTEXT or nil
  NOVA_ADVANCED = NOVA_ADVANCED or nil
  NOVA_FRAMEPOS_X, NOVA_FRAMEPOS_Y = NOVA_FRAMEPOS_X or nil, NOVA_FRAMEPOS_Y or nil
  NOVA_PROTECTED = ]] .. (isProtected and "true" or "false") .. [[

  --------------------------------
  --  Config / Local Variables
  --------------------------------

  local dataTypesSave = {
    ["string"] = tostring,
    ["number"] = tostring,
    ["boolean"] = tostring,
    ["table"] = util.TableToJSON,
  }

  local dataTypesLoad = {
    ["string"] = tostring,
    ["number"] = tonumber,
    ["boolean"] = tobool,
    ["table"] = util.JSONToTable,
  }

  local sw, sh = ScrW(), ScrH()
  local style = {
    banner = Material("materials/nova/banner.png", "noclamp smooth"),
    frame = {
      w = 0.65 * sw, -- absolute width of the frame
      h = 0.7 * sh, -- absolute height of the frame
    },
    tab = {
      w = 0.55 * sw, -- absolute width of the tab
    },
    margins = {
      tb = 0.01 * sh, -- margin top and bottom
      lr = 0.01 * sw, -- margin left and right
    },
    color = {
      pri = Color(126, 38, 241), -- primary color
      pri2 = Color(86, 238, 244), -- primary color
      sec = Color(35, 39, 60), -- secondary color
      dis = Color(81, 88, 94), -- disabled color
      bg = Color(11, 12, 27, 250), -- background color
      ft = Color(255, 255, 255), -- font color
      dng = Color(220, 53, 69), -- danger color
      scc = Color(40, 167, 69), -- success color
      wrn = Color(198, 148, 0), -- warning color
      tr = Color(0, 0, 0, 0), -- transparent color
    }
  }

  local tabs = {
    ]] .. (not playerAccess and "" or
      [[["players"] = { title = "menu_title_players", description = "menu_desc_players", custom = "nova_admin_page_players", color = style.color.pri},]]) .. [[
    ]] .. (not bansAccess and "" or
      [[["bans"] = { title = "menu_title_bans", description = "menu_desc_bans", custom = "nova_admin_page_bans", color = style.color.pri},]]) .. [[
    ]] .. (not inspectionAccess and "" or
      [[["inspection"] = { title = "menu_title_inspection", description = "menu_desc_inspection", custom = "nova_admin_page_inspection", color = style.color.pri},]]) .. [[
    ]] .. (not ddosAccess and "" or
      [[["ddos"] = { title = "menu_title_ddos", description = "menu_desc_ddos", custom = "nova_admin_page_ddos", color = style.color.pri},]]) .. [[
    ]] .. (not healthAccess and "" or
      [[["health"] = { title = "menu_title_health", description = "menu_desc_health", custom = "nova_admin_page_health", color = style.color.pri},]]) .. [[
    ]] .. (not detectionsAccess and "" or
      [[["detections"] = { title = "menu_title_detections", description = "menu_desc_detections", custom = "nova_admin_page_detections", color = style.color.pri},]]) .. [[
    ]] .. (not isProtected and "" or
      [[["server"] = { title = "menu_title_server", description = "menu_desc_server"},
      ["banbypass"] = { title = "menu_title_banbypass", description = "menu_desc_banbypass"},
      ["exploit"] = { title = "menu_title_exploit", description = "menu_desc_exploit"},
      ["security"] = { title = "menu_title_security", description = "menu_desc_security"},
      ["networking"] = { title = "menu_title_network", description = "menu_desc_network"},
      ["menu"] = { title = "menu_title_menu" ,description = "menu_desc_menu"},
      ["anticheat"] = { title = "menu_title_anticheat", description = "menu_desc_anticheat"},]]) .. [[
  }

  --------------------------------
  --  Networking
  --------------------------------

  local function ChangeSetting(key, value)
    local dataType = type(value)
    local saveValue = dataTypesSave[dataType] and dataTypesSave[dataType](value) or value
    local compressedValue = util.Compress(saveValue)
    local compressedSize = #compressedValue
    net.Start("]] .. Nova.netmessage("admin_change_setting") .. [[")
      net.WriteString(key)
      net.WriteString(dataType)
      net.WriteUInt(compressedSize, 16)
      net.WriteData(compressedValue, compressedSize)
    net.SendToServer()
  end

  local function LoadData(message, params, callback)
    net.Receive(message, function()
      local dataType = net.ReadString()
      local compressedSize = net.ReadUInt(16)
      local convertedValue = net.ReadData(compressedSize)
      local decompressedValue = util.Decompress(convertedValue)
      local value = dataTypesLoad[dataType](decompressedValue)
      if type(value) == "table" then
        table.SortByMember(value, "key", true)
      end
      if callback then callback(value) end
    end)

    net.Start(message)
      -- we don't need to compress the data, because we only send small tables
      if params then net.WriteString(util.TableToJSON(params)) end
    net.SendToServer()
  end

  --------------------------------
  --  Frame Functions
  --------------------------------

  local function ReloadFrame()
    RunConsoleCommand("nova_defender")
  end

  local function Lang(lang_key)
    if not NOVA_LANG then return lang_key end
    if not NOVA_LANG[lang_key] then
      if lang_key then print("Nova Defender: Missing language key '" .. tostring(lang_key or "NO_VALUE") .. "'") end
      return lang_key
    end
    return NOVA_LANG[lang_key]
  end

  local function GetLangKey(translated)
    if not NOVA_LANG then return translated end
    for k, v in pairs(NOVA_LANG) do
      if v == translated then
        return k
      end
    end
    return translated
  end

  local function IsTableNumeric(tbl)
    if not tbl then return false end
    for k, v in pairs(tbl) do
      if type(k) ~= "number" then
        return false
      end
    end
    return true
  end

  local function SortData(data)
    local sorted = {}
    -- sort all options by category
    for k, v in ipairs(data or {}) do
      local key = v.key
      local prefixes = string.Split(key, "_")
      local prefix = #prefixes == 1 and "Misc" or prefixes[1] -- The tab in which the option is located
      local category = #prefixes >= 3 and string.upper(prefixes[2]) or "" -- The order in which the option is sorted
      v.category = category
      sorted[prefix] = sorted[prefix] or {}
      table.insert(sorted[prefix], v)
    end
    -- sort each optin within its category
    for k, v in pairs(sorted or {}) do
      table.SortByMember(v, "index", true)
      sorted[k] = v
    end
    return sorted
  end

  local function CreateOption(v, parent)
    local key = v.key
    local _type = v._type
    local value = v.value
    local default = v.default
    local options = v.options
    local description = Lang(v.description)
    if _type == "boolean" then
      local checkOption = vgui.Create( "nova_admin_option_checkbox", parent )
      checkOption:Dock( TOP )
      checkOption:SetSetting(key)
      checkOption.entry:SetChecked(value)
      checkOption.description:SetText(description)
      checkOption._finished = true
    elseif _type == "string" and options and table.IsEmpty(options) then
      local textOption = vgui.Create( "nova_admin_option_text", parent )
      textOption:Dock( TOP )
      textOption:SetSetting(key)
      textOption.entry:SetValue(value)
      textOption.description:SetText(description)
      textOption.entry._finished = true
    elseif _type == "string" and options and not table.IsEmpty(options) and IsTableNumeric(options) then
      local tableOption = vgui.Create( "nova_admin_option_list_select", parent )
      tableOption:Dock( TOP )
      tableOption:SetSetting(key, options)
      tableOption.description:SetText(description)
      tableOption.entry:SetValue(value)
      tableOption.entry._finished = true
    elseif _type == "number" then
      local numberOption = vgui.Create( "nova_admin_option_number", parent )
      numberOption:Dock( TOP )
      numberOption:SetSetting(key)
      numberOption.entry:SetValue(value)
      numberOption.description:SetText(description)
      numberOption.entry._finished = true
    elseif _type == "table" and v.value then
      local tableOption = vgui.Create( "nova_admin_option_list", parent )
      tableOption.entry:SetSortable(false)
      tableOption:Dock( TOP )
      tableOption:SetSetting(key, value, default)
      tableOption.description:SetText(description)
      tableOption.entry._finished = true
    elseif _type == "spacer" then
      local placeholder = vgui.Create( "DPanel", parent )
      placeholder:Dock( TOP )
      placeholder:DockMargin(0, style.margins.tb * 8, 0, 0)
      placeholder.Paint = function() end
      if NOVA_ADVANCED then return end
      local label = vgui.Create( "DLabel", placeholder )
      label:Dock( TOP )
      label:SetContentAlignment( 5 )
      label:SetFont("nova_font")
      label:SetTextColor(style.color.ft)
      label:SetText(Lang("menu_elem_miss_options"))
      local button = vgui.Create( "nova_admin_default_button", placeholder )
      button:Dock( TOP )
      button:SetFont("nova_font")
      button:SetText( Lang("menu_elem_advanced") )
      local textWidth = surface.GetTextSize( button:GetText() )
      button:DockMargin(parent:GetWide() / 2 - textWidth / 2 - style.margins.lr, style.margins.tb, parent:GetWide() / 2 - textWidth / 2 - style.margins.lr, 0)
      button.defaultColor = style.color.pri
      button.DoClick = function()
        NOVA_ADVANCED = true
        surface.PlaySound("UI/buttonclick.wav")
        if NOVA_ACTIVE_TAB then ReloadFrame() end
      end
      local tall = label:GetTall() + button:GetTall() + style.margins.tb * 2
      placeholder:DockMargin(0, (style.margins.tb * 8) - tall, 0, 0)
      placeholder:SetTall(tall + style.frame.h * 0.08 + style.margins.tb)
    elseif _type == "category" then
      local placeholder = vgui.Create( "DLabel", parent )
      placeholder:Dock( TOP )
      placeholder:SetText(v.value)
      placeholder:SetFont("nova_font")
      placeholder:SetTextColor( style.color.pri )
      placeholder:DockMargin(style.margins.lr, style.margins.tb * 2, style.margins.lr * 2, style.margins.tb)
      placeholder.Paint = function(_, w, h)
        draw.RoundedBox(0, 0, h - 1, w, h, style.color.pri)
      end
    end
  end

  local function ChangeTab(tabName, tabElement, tabData)
    NOVA_ACTIVE_TAB = tabName
    if not IsValid(tabElement) then return end
    tabElement:Clear()

    local description = vgui.Create( "DLabel", tabElement )
    description:Dock( TOP )
    description:SetFont("nova_font_l")
    description:SetTextColor(style.color.pri)
    description:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
    description:SetText(tabs[tabName] and Lang(tabs[tabName].description) or Lang("menu_elem_no_desc"))
    description:SizeToContents()
    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)

    NOVA_STYLE_TAB_INNERHEIGHT = tabElement:GetTall() - description:GetTall() - style.margins.tb * 2

    -- Existsing tab from configuration
    if not tabs[tabName] or not tabs[tabName].custom then
      -- check if there is more than one category
      local categories = {}
      for k, v in pairs(tabData or {}) do
        if v.category and v.category ~= "" then
          categories[v.category] = true
        end
      end
      local categoryCount = table.Count(categories)
      local lastCategory = ""
      for k, v in pairs(tabData or {}) do
        -- we only create subcategories if there is more than one category
        if categoryCount > 1 and v.category ~= lastCategory then
          if v.advanced and not NOVA_ADVANCED then continue end
          lastCategory = v.category
          CreateOption({_type = "category", value = lastCategory}, tabElement)
        end
        if v.advanced and not NOVA_ADVANCED then continue end
        CreateOption(v, tabElement)
      end
      CreateOption({_type = "spacer"}, tabElement)
    -- Custom tab
    else
      vgui.Create(tabs[tabName].custom, tabElement):Dock( TOP )
    end
  end

  local function CreateMenuButton(panel, tabElement, name, tabData)
    local btn = panel:Add( "nova_admin_menu_button" )
    btn:SizeToContents()
    btn:SetText( tabs[name] and Lang(tabs[name].title) or Lang(name) )
    btn:Dock( TOP )
    btn.defaultColor = tabData.color
    btn.tabname = name
    btn.DoClick = function()
      if NOVA_ACTIVE_TAB == name then return end
      surface.PlaySound("UI/buttonclick.wav")
      if tabData.custom then
        ChangeTab(name, tabElement)
      else
        LoadData("]] .. Nova.netmessage("admin_get_setting") .. [[", nil, function(data)
          local sortedData = SortData(data or {})
          ChangeTab(name, tabElement, sortedData[name])
        end)
      end
    end
  end

  -- Copied from DarkRP, see: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua#L44-L79
  local function CharWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)
        if totalWidth >= remainingWidth then
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
  end

  local function TextWrap(text, font, maxWidth, spacing)
    local totalWidth = 0
    surface.SetFont(font)
    local spaceWidth = surface.GetTextSize(' ')
    text = string.Replace(text, "\n", "\\n ")
    text = text:gsub("(%s?[%S]+)", function(word)
      if string.StartWith( word, "\\n" ) or string.EndsWith( word, "\\n" ) then
        totalWidth = 0
        word = string.Replace(word, "\\n", "\n")
      end

      local wordlen = surface.GetTextSize(word)
      totalWidth = totalWidth + wordlen

      if wordlen >= maxWidth then
        local splitWord, splitPoint = CharWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
        totalWidth = splitPoint
        return splitWord
      elseif totalWidth < maxWidth then
        return word
      end

      if char == ' ' then
        local spaces = string.rep(" ", spacing or 0)
        totalWidth = wordlen - spaceWidth
        return '\n' .. spaces .. string.sub(word, 2)
      end

      totalWidth = wordlen
      return '\n' .. word
    end)

    return text
  end

  --------------------------------
  --  Frame Components
  --------------------------------

  local MAIN_FRAME = {}
  function MAIN_FRAME:Init()
    self:SetSize(style.frame.w, style.frame.h)
    self:SetTitle("")
    self:ShowCloseButton(false)
    if not NOVA_FRAMEPOS_X then
      self:Center()
    else
      self:SetPos(NOVA_FRAMEPOS_X, NOVA_FRAMEPOS_Y)
    end
    self:MakePopup()
    -- close button
    local closeButton = vgui.Create( "nova_admin_default_button", self )
    closeButton:SetText( Lang("menu_elem_close") )
    closeButton:SetFont("nova_font")
    closeButton:SizeToContents()
    closeButton:SetPos( style.margins.lr, style.frame.h - style.margins.tb - closeButton:GetTall() )
    closeButton:SetZPos( 100 )
    closeButton.defaultColor = style.color.dng
    closeButton.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      if IsValid(NOVA_MENU) then
        NOVA_FRAMEPOS_X, NOVA_FRAMEPOS_Y = NOVA_MENU:GetPos()
      end
      self:Close()
    end

    -- refresh button
    local reloadButton = vgui.Create( "nova_admin_default_button", self )
    reloadButton:SetText( Lang("menu_elem_reload") )
    reloadButton:SetFont("nova_font")
    reloadButton:SizeToContents()
    reloadButton:SetZPos( 100 )
    reloadButton:SetPos( style.margins.lr * 2 + closeButton:GetWide(), style.frame.h - style.margins.tb - reloadButton:GetTall() )
    reloadButton.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      ReloadFrame()
    end

    local checkBox = vgui.Create("DCheckBoxLabel", self)
    checkBox:SetPos( style.margins.lr, style.frame.h - style.margins.tb * 2 - reloadButton:GetTall() * 2 )
    checkBox:SetZPos( 100 )
    checkBox:SetFont("nova_font")
    checkBox:SetTextColor( style.color.ft )
    checkBox:SetText(Lang("menu_elem_advanced"))
    checkBox:SizeToContents()
    checkBox:SetValue(NOVA_ADVANCED)
    checkBox.Button.Paint = function(_, _w, _h)
      local color = checkBox:GetChecked() and style.color.pri or style.color.sec
      if checkBox.Button:IsHovered() then 
        local lightenColor = color:ToVector()
        lightenColor:Mul(1.3)
        color = lightenColor:ToColor()
      end
      draw.RoundedBox(4, 0, 0, _w, _h, color)
    end
    checkBox.OnChange = function() surface.PlaySound("UI/buttonclick.wav") NOVA_ADVANCED = checkBox:GetChecked() if NOVA_ACTIVE_TAB then ReloadFrame() end end

  end

  local waveColorL = table.Copy(style.color.pri2)
  local waveColorR = table.Copy(style.color.pri)
  function MAIN_FRAME:Paint(_w, _h)
    draw.RoundedBox(4, 1, 1, _w-2, _h-2, style.color.bg)
    local time = RealTime() * 300
    local waveHeight = NOVA_ACTIVE_TAB and _h * 0.04 or _h * 0.08
    local density = NOVA_ACTIVE_TAB and 0.02 or 0.02

    waveColorL.a = NOVA_ACTIVE_TAB and 80 or 255
    waveColorR.a = NOVA_ACTIVE_TAB and 80 or 255

    draw.NoTexture()

    -- if not tab is open draw banner
    if not NOVA_ACTIVE_TAB then
      local w, h = 900, 415
      local bannerX = style.frame.w * 0.5 - w * 0.5
      local bannerY = _h * 0.5 - h * 0.5
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(style.banner)
      surface.DrawTexturedRect(bannerX, bannerY, w, h)
    end

    
    for i = _w - style.tab.w, _w, _w * density do
      local timeModifier = (i + time ) / 300
      local mod1 = math.sin( timeModifier )
      local mod2 = math.cos( timeModifier )
      local mod3 = math.cos( timeModifier - math.pi )
      local mod4 = math.cos( timeModifier - math.pi * 1.5 )
      local wave1 = mod1 * waveHeight + waveHeight + style.margins.tb
      local wave2 = mod2 * waveHeight + waveHeight + style.margins.tb
      local wave3 = mod3 * waveHeight + waveHeight + style.margins.tb
      local wave4 = mod4 * waveHeight + waveHeight + style.margins.tb

      local gradient = (i - (_w - style.tab.w)) / style.tab.w
      local xColor = Color(
        Lerp(gradient, waveColorL.r, waveColorR.r),
        Lerp(gradient, waveColorL.g, waveColorR.g),
        Lerp(gradient, waveColorL.b, waveColorR.b),
        Lerp(gradient, waveColorL.a, waveColorR.a)
      )

      surface.SetDrawColor(xColor)
      surface.DrawCircle(i, _h - wave1, 1)
      surface.DrawCircle(i, _h - wave2, 1)
      surface.DrawCircle(i, _h - wave3, 1)
      surface.DrawCircle(i, _h - wave4, 1)
    end

  end
  vgui.Register("nova_admin_menu", MAIN_FRAME, "DFrame")

  local SCROLLPANEL = {}
  function SCROLLPANEL:Init()
    self:SetSize(style.frame.w - style.tab.w, style.frame.h)
    local vbar = self.VBar
    local btnUp = self:GetChildren()[2]:GetChildren()[1]
    local btnDown = self:GetChildren()[2]:GetChildren()[2]
    local btnGrip = self:GetChildren()[2]:GetChildren()[3]
    vbar.Paint = function() end
    btnUp.Paint = vbar.Paint
    btnDown.Paint = btnUp.Paint
    btnGrip.Paint = function(s, _w, _h)
      if s.Depressed then draw.RoundedBox(4, _w / 8, 0, _w * 0.8, _h, style.color.pri)
      else draw.RoundedBox(4, _w / 8, 0, _w * 0.8, _h, style.color.sec) end
    end
  end
  function SCROLLPANEL:Paint(_w, _h) end
  vgui.Register("nova_admin_scroll_panel", SCROLLPANEL, "DScrollPanel")

  local MENU_BUTTON = {}
  function MENU_BUTTON:Init()
    self:DockMargin( style.margins.lr, 0, style.margins.lr, style.margins.tb )
    self:SetFont("nova_font")
    self:SetTextColor(style.color.ft)
    self.Paint = function(_, _w, _h)
      if not self:IsEnabled() or self.tabname == NOVA_ACTIVE_TAB then
        local darkenColor = (self.defaultColor or style.color.sec):ToVector()
        darkenColor:Mul(0.7)
        draw.RoundedBox(4, 1, 1, _w-2, _h-2, darkenColor:ToColor())
        self.playsound = false
      elseif self:IsHovered() then
        local darkenColor = (self.defaultColor or style.color.sec):ToVector()
        darkenColor:Mul(0.7)
        draw.RoundedBox(4, 1, 1, _w-2, _h-2, darkenColor:ToColor())
        if not self.playsound then surface.PlaySound("UI/buttonrollover.wav") self.playsound = true end
      else
        draw.RoundedBox(4, 0, 0, _w, _h, self.defaultColor or style.color.sec)
        self.playsound = false
      end
    end
  end
  function MENU_BUTTON:SetEvent(tab)
    self.tab = tab
    self.DoClick = function() 
      surface.PlaySound("UI/buttonclick.wav") 
      LoadData("]] .. Nova.netmessage("admin_get_setting") .. [[", nil, function(data)
        local sortedData = SortData(data or {})
        ChangeTab(name, nil, sortedData[name])
      end)
    end
  end
  vgui.Register("nova_admin_menu_button", MENU_BUTTON, "DButton")


  local DEFAULT_BUTTON = {}
  function DEFAULT_BUTTON:Init()
    self:DockMargin( style.margins.lr, 0, style.margins.lr, style.margins.tb )
    self:SetFont("nova_font")
    self:SetTextColor(style.color.ft)
    self.Paint = function(_, _w, _h)
      if not self:IsEnabled() then
        local darkenColor = (self.defaultColor or style.color.sec):ToVector()
        darkenColor:Mul(0.7)
        draw.RoundedBox(4, 1, 1, _w-2, _h-2, darkenColor:ToColor())
        self.playsound = false
      elseif self:IsHovered() then
        local darkenColor = (self.defaultColor or style.color.sec):ToVector()
        darkenColor:Mul(0.7)
        draw.RoundedBox(4, 1, 1, _w-2, _h-2, darkenColor:ToColor())
        if not self.playsound then surface.PlaySound("UI/buttonrollover.wav") self.playsound = true end
      else
        draw.RoundedBox(4, 0, 0, _w, _h, self.defaultColor or style.color.sec)
        self.playsound = false
      end
    end
  end
  vgui.Register("nova_admin_default_button", DEFAULT_BUTTON, "DButton")

  local DEFAULT_COMBOBOX = {}
  function DEFAULT_COMBOBOX:Init()
    self:SetSize(style.tab.w * 0.5, style.margins.tb * 2)
    self:DockMargin(style.margins.lr, 0, style.margins.lr,0)
    self:SetFont("nova_font")
    self:SetTextColor( style.color.ft )
    self:SetPaintBackground(true)
    self:SetTextColor( style.color.ft )
    self.Paint = function(_, _w, _h)
      draw.RoundedBox(2, 0, 0, _w, _h, style.color.sec)
    end

    local oldDoClick = self.DoClick
    self.DoClick = function(panel)
      oldDoClick(panel)
      if not IsValid(panel) then return end
      if not IsValid(panel.Menu) then return end
      panel.Menu.Paint = function(_, _w, _h) draw.RoundedBox(2, 0, 0, _w, _h, style.color.sec) end
      for _, v in pairs(panel.Menu:GetChildren()[1]:GetChildren()) do
        v:SetTextColor(style.color.ft)
        v.Paint = function(_, _w, _h)
          if not v.Hovered then return end
          draw.RoundedBox(2, 0, 0, _w, _h, style.color.pri)
        end
      end
    end
  end
  vgui.Register("nova_admin_default_combobox", DEFAULT_COMBOBOX, "DComboBox")

  local OPTION_CHECKBOX = {}
  function OPTION_CHECKBOX:Init()
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
    self:SetSize(0, style.margins.tb * 5)
    local wide = self:GetParent():GetParent():GetWide() - style.margins.lr * 4

    local description = vgui.Create("DLabel", self)
    description:DockMargin(0, 0, 0, style.margins.tb)
    description:Dock(TOP)
    description:SetFont("nova_font")
    description:SetTextColor( style.color.ft )

    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)
    description:SetSize(style.tab.w , style.margins.tb * 2)

    local oldSetText = description.SetText
    description.SetText = function(_, text)
      surface.SetFont(description:GetFont() or "nova_font")
      oldSetText(description, tostring(text))
      local nlCount = #string.Explode("\n", tostring(text)) - 1
      local height = draw.GetFontHeight(description:GetFont()) * (math.ceil(surface.GetTextSize(text) / wide) + nlCount)
      self:SetSize(0, style.margins.tb * 3 + height)
    end

    local checkBox = vgui.Create("DCheckBoxLabel", self)
    checkBox:Dock(TOP)
    checkBox:SetSize(style.tab.w, style.margins.tb * 2)
    checkBox:DockMargin(style.margins.lr, 0, 0,0,0)
    checkBox:SetFont("nova_font")
    checkBox:SetTextColor( style.color.ft )
    checkBox:SetText(checkBox:GetChecked() and Lang("menu_elem_checkboxtext_checked") or Lang("menu_elem_checkboxtext_unchecked"))

    checkBox:SizeToContents()
    checkBox:SetValue(true)

    self.entry = checkBox
    self.description = description

    self.entry.Button.Paint = function(_, _w, _h)
      local color = self.entry:GetChecked() and style.color.pri or style.color.sec
      if self.entry.Button:IsHovered() then 
        local lightenColor = color:ToVector()
        lightenColor:Mul(1.3)
        color = lightenColor:ToColor()
      end
      draw.RoundedBox(4, 0, 0, _w, _h, color)
    end

  end
  function OPTION_CHECKBOX:SetSetting(setting)
    self.setting = setting
    local oldSetChecked = self.entry.SetChecked
    self.entry.SetChecked = function(_, checked)
      oldSetChecked(self.entry, checked)
      self.entry:SetText(checked and Lang("menu_elem_checkboxtext_checked") or Lang("menu_elem_checkboxtext_unchecked"))
    end
    self.entry.OnChange = function(val)
      surface.PlaySound("UI/buttonclick.wav")
      self.entry:SetText(val:GetChecked() and Lang("menu_elem_checkboxtext_checked") or Lang("menu_elem_checkboxtext_unchecked"))
      if not self._finished then return end
      ChangeSetting(self.setting, val:GetChecked())
    end
  end
  function OPTION_CHECKBOX:Paint(_w, _h) end

  vgui.Register("nova_admin_option_checkbox", OPTION_CHECKBOX, "DPanel")


  local OPTION_TEXT = {}
  function OPTION_TEXT:Init()
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
    self:SetSize(0, style.margins.tb * 5)
    local wide = self:GetParent():GetParent():GetWide() - style.margins.lr * 4

    local description = vgui.Create("DLabel", self)
    description:DockMargin(0, 0, 0, style.margins.tb)
    description:Dock(TOP)
    description:SetFont("nova_font")
    description:SetTextColor( style.color.ft )
    description:SetSize(style.tab.w, style.margins.tb * 2)

    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)

    local oldSetText = description.SetText
    description.SetText = function(_, text)
      surface.SetFont(description:GetFont() or "nova_font")
      oldSetText(description, tostring(text))
      local nlCount = #string.Explode("\n", tostring(text)) - 1
      local height = draw.GetFontHeight(description:GetFont()) * (math.ceil(surface.GetTextSize(text) / wide) + nlCount)
      self:SetSize(0, style.margins.tb * 3 + height)
    end

    local textEntry = vgui.Create("DTextEntry", self)
    textEntry:Dock(TOP)
    textEntry:SetSkin("Default")
    textEntry:SetSize(style.tab.w, style.margins.tb * 2)
    textEntry:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    textEntry:SetFont("nova_font")
    textEntry:SetPaintBackground(true)
    textEntry:SetCursorColor( style.color.bg )
    textEntry:SetTextColor( style.color.bg )

    self.entry = textEntry
    self.description = description

    self.entry.timeToSave = 0
    self.entry.activeDelay = false
    self.entry.defaultColor = style.color.ft

    self.entry.OnChange = function(val)
      if not self.entry._finished then return end
      self.entry.timeToSave = self.entry.timeToSave or 0
      if CurTime() > self.entry.timeToSave then
        self.entry.activeDelay = false
        self.entry.timeToSave = CurTime() + 1
        if self.entry.OnChangeDelayed then self.entry:OnChangeDelayed(val:GetValue()) end
      else
        self.entry.activeDelay = true
        timer.Simple(1.01, function()
          if not self or not self.entry then return end
          if not self.entry.activeDelay then return end
          self.entry.activeDelay = false
          if self.entry.OnChangeDelayed then self.entry:OnChangeDelayed(val:GetValue()) end
        end)
      end
    end

    self.entry.Paint = function(panel, w, h)
      draw.RoundedBox(4, 0, 0, w, h, style.color.sec)
      panel:DrawTextEntryText(self.entry.defaultColor, style.color.pri, style.color.pri)
    end

  end
  function OPTION_TEXT:SetSetting(setting)
    self.entry.setting = setting
    self.entry.OnChangeDelayed = function(_,val)
      ChangeSetting(self.entry.setting, val)
    end
  end
  function OPTION_TEXT:Paint(_w, _h) end
  vgui.Register("nova_admin_option_text", OPTION_TEXT, "DPanel")


  local OPTION_NUMBER = {}
  function OPTION_NUMBER:Init()
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
    self:SetSize(0, style.margins.tb * 5)
    local wide = self:GetParent():GetParent():GetWide() - style.margins.lr * 4

    local description = vgui.Create("DLabel", self)
    description:DockMargin(0, 0, 0, style.margins.tb)
    description:Dock(TOP)
    description:SetFont("nova_font")
    description:SetTextColor( style.color.ft )
    description:SetSize(style.tab.w , style.margins.tb * 2)

    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)

    local oldSetText = description.SetText
    description.SetText = function(_, text)
      surface.SetFont(description:GetFont() or "nova_font")
      oldSetText(description, tostring(text))
      local nlCount = #string.Explode("\n", tostring(text)) - 1
      local height = draw.GetFontHeight(description:GetFont()) * (math.ceil(surface.GetTextSize(text) / wide) + nlCount)
      self:SetSize(0, style.margins.tb * 3 + height)
    end
    self.description = description


    local numberWang = vgui.Create("DNumberWang", self)
    numberWang:Dock(TOP)
    numberWang:SetSize(style.tab.w * 0.2, style.margins.tb * 2)
    numberWang:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    numberWang:SetFont("nova_font")
    numberWang:SetTextColor( style.color.bg )
    numberWang:SetPaintBackground(true)
    numberWang:SetMinMax(1, 9999999)

    self.entry = numberWang
    self.description = description

    self.entry.Paint = function(panel, w, h)
      draw.RoundedBox(4, 0, 0, w, h, style.color.sec)
      panel:DrawTextEntryText(style.color.ft, style.color.pri, style.color.pri)
    end
  end
  function OPTION_NUMBER:SetSetting(setting)
    self.entry.setting = setting
    self.entry.timeToSave = 0
    self.entry.activeDelay = false
    self.entry.OnValueChanged = function(val)
      if not self.entry._finished then return end
      self.entry.timeToSave = self.entry.timeToSave or 0
      
      if CurTime() > self.entry.timeToSave then
        self.entry.activeDelay = false
        ChangeSetting(self.entry.setting, val:GetValue())
        self.entry.timeToSave = CurTime() + 1
      else
        self.entry.activeDelay = true
        timer.Simple(1.01, function()
          if not self or not self.entry then return end
          if not self.entry.activeDelay then return end
          self.entry.activeDelay = false
          ChangeSetting(self.entry.setting, val:GetValue())
        end)
      end
    end
  end

  function OPTION_NUMBER:Paint(_w, _h) end
  vgui.Register("nova_admin_option_number", OPTION_NUMBER, "DPanel")


  local OPTION_LIST_SELECT = {}
  function OPTION_LIST_SELECT:Init()
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
    self:SetSize(0, style.margins.tb * 5)
    local wide = self:GetParent():GetParent():GetWide() - style.margins.lr * 4

    local description = vgui.Create("DLabel", self)
    description:DockMargin(0, 0, 0, style.margins.tb)
    description:Dock(TOP)
    description:SetFont("nova_font")
    description:SetTextColor( style.color.ft )

    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)
    description:SetSize(style.tab.w , style.margins.tb * 2)

    local oldSetText = description.SetText
    description.SetText = function(_, text)
      surface.SetFont(description:GetFont() or "nova_font")
      oldSetText(description, tostring(text))
      local nlCount = #string.Explode("\n", tostring(text)) - 1
      local height = draw.GetFontHeight(description:GetFont()) * (math.ceil(surface.GetTextSize(text) / wide) + nlCount)
      self:SetSize(0, style.margins.tb * 3 + height)
    end

    local comboBox = vgui.Create("nova_admin_default_combobox", self)
    comboBox:Dock(TOP)
    comboBox:SetSize(style.tab.w * 0.5, style.margins.tb * 2)

    self.entry = comboBox
    self.description = description
  end

  function OPTION_LIST_SELECT:SetSetting(setting, settings)
    self.entry.options = settings
    self.entry.setting = setting
    self.entry.OnSelect = function(_, _, value)
      if not self.entry._finished then return end
      ChangeSetting(self.entry.setting, value)
    end
    for k,v in pairs(settings or {}) do
      self.entry:AddChoice(v)
    end
  end
  function OPTION_LIST_SELECT:Paint(_w, _h) end
  vgui.Register("nova_admin_option_list_select", OPTION_LIST_SELECT, "DPanel")

  local OPTION_LIST = {}
  function OPTION_LIST:Resize()
    if not self.entry then return end
    local wide = self:GetParent():GetParent():GetWide() - style.margins.lr * 4
    local nlCount = #string.Explode("\n", self.description:GetText()) - 1
    surface.SetFont(self.description:GetFont() or "nova_font")
    local descriptionSize = draw.GetFontHeight(self.description:GetFont()) * (math.ceil(surface.GetTextSize(self.description:GetText()) / wide) + nlCount)
    local entryHeight = self.entry:GetHeaderHeight() + self.entry:GetDataHeight() * math.max(#self.entry:GetLines(), 1)
    local buttonHeight = style.margins.tb * 6

    self.entry:SetSize(style.tab.w, entryHeight)
    self:SetSize(0, entryHeight + buttonHeight + descriptionSize)

    -- set add and remove button positions below the list
    --self.add:SetPos(style.margins.lr, entryHeight + descriptionSize + style.margins.tb * 3 )
    --self.remove:SetPos(self.add:GetWide() + style.margins.lr * 2, entryHeight + descriptionSize + style.margins.tb * 3)
    --self.edit:SetPos(self.add:GetWide() + self.remove:GetWide() + style.margins.lr * 3, entryHeight + descriptionSize + style.margins.tb * 3)
    return entryHeight
  end
  function OPTION_LIST:Init()
    self:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    self:SetSize(0, style.margins.tb * 4)

    local description = vgui.Create("DLabel", self)
    description:Dock(TOP)
    description:DockMargin(0, 0, 0, style.margins.tb)
    description:SetFont("nova_font")
    description:SetTextColor( style.color.ft )
    description:SetSize(style.tab.w , style.margins.tb * 2)

    -- enable line wrapping
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)
    description:SetSize(style.tab.w , style.margins.tb * 2)

    local oldSetText = description.SetText
    description.SetText = function(_, text)
      surface.SetFont(description:GetFont() or "nova_font")
      oldSetText(description, tostring(text))
      self:Resize()
    end

    local listView = vgui.Create("DListView", self)
    listView:Dock(TOP)
    listView:SetSize(style.tab.w, 0)
    listView:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    listView:SetMultiSelect(false)
    listView:SetDataHeight( style.margins.tb * 2 )

    local nav = vgui.Create("DPanel", self)
    nav:Dock(BOTTOM)
    nav:DockMargin(0, 0, 0, style.margins.tb)
    nav.Paint = function(_, _w, _h) end

    local add, remove, edit =	vgui.Create("nova_admin_default_button", nav),
              vgui.Create("nova_admin_default_button", nav),
              vgui.Create("nova_admin_default_button", nav)

    add:SetText(Lang("menu_elem_add"))
    add:SetPos(style.margins.lr, 0)
    add:SizeToContents()
    add.defaultColor = style.color.scc
    add:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)

    remove:SetText(Lang("menu_elem_rem"))
    remove:SetPos(add:GetWide() + style.margins.lr * 2, 0)
    remove:SizeToContents()
    remove.defaultColor = style.color.dng
    remove:SetEnabled( false )
    remove:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)

    edit:SetText(Lang("menu_elem_edit"))
    edit:SetPos(add:GetWide() + remove:GetWide() + style.margins.lr * 3, 0)
    edit:DockMargin(style.margins.lr, 0, 0, 0)
    edit:SizeToContents()
    edit.defaultColor = style.color.wrn
    edit:SetEnabled( false )
    edit:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)

    self.entry = listView
    self.nav = nav
    self.description = description
    self.add = add
    self.remove = remove
    self.edit = edit

    self:Resize()

    self.entry.Paint = function(_, _w, _h) end

    self.remove.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      local selected = self.entry.Lines[self.entry:GetSelectedLine()]
      if not selected then return end
      local removeKey = selected._key
      self.entry.values[removeKey] = nil
      ChangeSetting(self.entry.setting, self.entry.values)
      ReloadFrame()
    end

    self.add.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      local dialog = vgui.Create("nova_admin_dialog", NOVA_MENU)
      local isNumeric = IsTableNumeric(not table.IsEmpty(self.entry.values or {}) and self.entry.values or (self.entry.default or {}))
      local dialogOptions = {}
      if isNumeric then
        dialogOptions = {["value"] = {["name"] = Lang("menu_elem_new_value"), ["value"] = nil},}
      else
        -- iterate over columns and add them as options
        for k,_ in pairs(self.entry.columns or {}) do
          dialogOptions[k] = {["name"] = k or "", ["value"] = nil}
        end
      end
      dialog:SetDialogCallback(dialogOptions, function(fields)
        if isNumeric then
          table.insert(self.entry.values, fields["value"]["value"])
          ChangeSetting(self.entry.setting, self.entry.values)
          ReloadFrame()
        else
          local newEntry = {}
          local possibleKeys = {"steamid", "ASN"} -- This is dumb but my sanity is not capable of fixing this anymore
          local key = ""
          for k,v in pairs(possibleKeys or {}) do
            if fields[v] and fields[v].value then key = fields[v].value break end
          end

          for k,v in pairs(fields or {}) do
            newEntry[k] = v.value
          end
          self.entry.values[key] = newEntry
          ChangeSetting(self.entry.setting, self.entry.values)
          ReloadFrame()
        end
      end)
    end

    self.edit.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      local selected = self.entry.Lines[self.entry:GetSelectedLine()]
      if not selected then return end

      local editKey = selected._key
      local dialog = vgui.Create("nova_admin_dialog", NOVA_MENU)
      local isNumeric = IsTableNumeric(self.entry.values)

      local dialogOptions = {}
      if isNumeric then
        dialogOptions = {["value"] = {["name"] = Lang("menu_elem_new_value"), ["value"] = self.entry.values[editKey] or ""},}
      else
        -- iterate over columns and add them as options
        for k,_ in pairs(self.entry.columns or {}) do
          dialogOptions[k] = {["name"] = k or "", ["value"] = self.entry.values[editKey][k] or ""}
        end
      end

      dialog:SetDialogCallback(dialogOptions, function(fields)
        if isNumeric then
          self.entry.values[editKey] = fields["value"]["value"]
          ChangeSetting(self.entry.setting, self.entry.values)
          ReloadFrame()
        else
          local newEntry = {}
          for k,v in pairs(fields or {}) do
            newEntry[k] = v.value
          end
          self.entry.values[editKey] = newEntry
          ChangeSetting(self.entry.setting, self.entry.values)
          ReloadFrame()
        end
      end)
    end
  end

  function OPTION_LIST:Style(swap)
    self.nav:Dock(swap and TOP or BOTTOM)
    self.entry:Dock(swap and BOTTOM or TOP)
    for _, v in ipairs(self.entry.Columns or {}) do
      local button = v:GetChildren()[1]
      button:SizeToContents()
      button:SetFont("nova_font")
      button:SetColor( style.color.ft )
      button.Paint = function(_, _w, _h)
        draw.RoundedBox(2, 1, 0, _w - 2, _h, style.color.pri)
      end
    end
    for i, v in ipairs(self.entry.Lines or {}) do
      v.Paint = function(_, _w, _h)
        if self.entry:GetSelectedLine() == i then draw.RoundedBox(2, 0, 0, _w, _h, style.color.pri)
        elseif v:IsHovered() then 
          draw.RoundedBox(2, 0, 0, _w, _h, style.color.pri)
          draw.RoundedBox(2, 1, 1, _w-2, _h-2, i % 2 == 1 and style.color.bg or style.color.sec)
        else draw.RoundedBox(2, 1, 1, _w-2, _h-2, i % 2 == 1 and style.color.bg or style.color.sec) end
      end
      for _, v2 in ipairs(v:GetChildren() or {}) do
        v2:SetFont("nova_font")
        v2:SetColor( style.color.ft )
      end
    end
  end

  function OPTION_LIST:SetSetting(setting, settings, default, banTable)
    self.entry:Clear()
    self.entry.values = settings
    self.entry.setting = setting
    self.entry.default = default
    local columns = {}
    local timeColumn = nil
    if not table.IsEmpty(settings or {}) and IsTableNumeric(settings) then
      self.entry:AddColumn("")
    elseif not table.IsEmpty(settings or {}) then
      -- add all existing columns
      for k,v in pairs(settings or {}) do 
        for k2,_ in pairs(v or {}) do
          if banTable and k2 == "unix" then continue end
          columns[k2] = true 
        end
        break 
      end

      for k,_ in pairs(columns) do
        local columnWidth = select(1, surface.GetTextSize(Lang(k) or ""))
        local col = self.entry:AddColumn(Lang(k))
        col:SetWidth( columnWidth )
        if banTable and k == "time" then timeColumn = col end
      end
      if banTable then
        local columnWidth = select(1, surface.GetTextSize(Lang("menu_elem_view") or ""))
        self.entry:AddColumn(""):SetFixedWidth( columnWidth + style.margins.lr )
      end
      self.entry.columns = columns
    end

    for k, v in pairs(settings or {}) do
      if IsTableNumeric(settings) then
        self.entry:AddLine(v)
      elseif v and type(v) == "table" then
        local unix = banTable and v.unix or nil
        local line = {}
        for k2,_ in pairs(columns or {}) do
          table.insert(line, v[k2] or "")
        end
        local panel = self.entry:AddLine(unpack(line))
        if banTable then
          panel:SetSortValue(timeColumn:GetColumnID(), unix)
        end
      end
      self.entry.Lines[#self.entry.Lines]._key = k
    end

    -- if no settings are set, use default
    if table.IsEmpty(settings or {}) and not table.IsEmpty(default or {}) then
      if IsTableNumeric(default) then
        self.entry:AddColumn("")
      else
        -- add all existing columns
        for k,v in pairs(default or {}) do for k2,_ in pairs(v or {}) do columns[k2] = true end break end
    
        for k,_ in pairs(columns) do
          local columnWidth = select(1, surface.GetTextSize(Lang(k) or ""))
          self.entry:AddColumn(Lang(k)):SetWidth( columnWidth )
        end
        if banTable then
          local columnWidth = select(1, surface.GetTextSize(Lang("menu_elem_view") or ""))
          self.entry:AddColumn(""):SetFixedWidth( columnWidth + style.margins.lr )
        end
        self.entry.columns = columns
      end
    end

    self.entry.OnRowSelected = function(_, rowIndex, row)
      if not self.entry._finished then return end
      if self.entry.CustomOnRowSelected then self.entry.CustomOnRowSelected(rowIndex, row) end
      self.entry._selected = rowIndex
      if IsValid(self.remove) then self.remove:SetEnabled(true) end
      if IsValid(self.edit) then self.edit:SetEnabled(true) end
    end
    self:Resize()
    self:Style()

  end
  function OPTION_LIST:Paint(_w, _h) end
  vgui.Register("nova_admin_option_list", OPTION_LIST, "DPanel")

  local MENU_TAB = {}
  function MENU_TAB:Init()
    self:SetSize(style.tab.w, style.frame.h)
    self:DockPadding(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
    self:Dock(FILL)
    local vbar = self.VBar
    local btnUp = self:GetChildren()[2]:GetChildren()[1]
    local btnDown = self:GetChildren()[2]:GetChildren()[2]
    local btnGrip = self:GetChildren()[2]:GetChildren()[3]
    vbar.Paint = function() end
    btnUp.Paint = vbar.Paint
    btnDown.Paint = btnUp.Paint
    btnGrip.Paint = function(s, _w, _h)
      if s.Depressed then draw.RoundedBox(4, _w / 8, 0, _w * 0.8, _h, style.color.pri)
      else draw.RoundedBox(4, _w / 8, 0, _w * 0.8, _h, style.color.sec) end
    end
  end
  function MENU_TAB:Paint(_w, _h) end
  vgui.Register("nova_admin_menu_tab", MENU_TAB, "DScrollPanel")

  local MENU_STATUS = {}
  function MENU_STATUS:Init()
    self:Dock(TOP)
  end
  function MENU_STATUS:Load()
    local function AddExtension(text, url)
      local extension = vgui.Create("DPanel", self)
      extension:DockPadding(style.margins.lr/2, 0, style.margins.lr/2, 0)
      extension:DockMargin(0, 0, style.margins.lr, 0)
      extension:Dock(LEFT)
      extension.color = style.color.sec
      extension.bgColor = style.color.bg
      extension.Paint = function(s, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, s.bgColor)
        draw.RoundedBox(0, _w-4, 0, 4, _h, s.color)
        --draw.RoundedBox(0, _w/4, _h-3, _w/2, 3, s.color)
      end
      
      local label = vgui.Create("DLabel", extension)
      label:SetFont("nova_font")
      label:SetText(text)
      label:SetTextColor(style.color.ft)
      label:SizeToContents()
      label:Dock(FILL)
      extension.text = label

      surface.SetFont("nova_font")
      local w, h = surface.GetTextSize(text) 
      extension:SetSize(w + style.margins.lr, style.margins.tb * 2)

      if url and url != "" then
        extension:SetCursor("hand")
        label:SetMouseInputEnabled( true )
        label.DoClick = function() gui.OpenURL(url) end
      end

      return extension
    end

    LoadData("]] .. Nova.netmessage("admin_get_status") .. [[", nil, function(data)
      if not IsValid(self) then return end
      self:Clear()

      local nova = AddExtension(string.format("Nova Defender v.%s", data.version))
      nova.color = style.color.tr
      nova:DockMargin(0, 0, style.margins.lr/2, 0)
      local exts = AddExtension(Lang("menu_elem_extensions"))
      exts.color = style.color.tr
      exts.bgColor = style.color.tr
      exts:DockMargin(0, 0, style.margins.lr/2, 0)
      for k, v in pairs(data.extensions or {}) do
        local text = v.name
        if v.enabled then
          text = text .. " v." .. v.version
          if not v.up_to_date then text = text .. " " .. Lang("menu_elem_outdated") end
        else text = text .. " " .. Lang("menu_elem_disabled") end
        local extension = AddExtension(text, v.url)
        if v.enabled then
          if v.up_to_date then extension.color = style.color.scc
          else extension.color = style.color.wrn end
        else
          extension.color = style.color.sec
          extension.text:SetTextColor(style.color.dis)
        end
      end

      if data["ddos"] and data["ddos"]["mode"] == "start" then
        local ddos = AddExtension(Lang("menu_elem_ddos_active"))
        ddos.color = style.color.dng
        ddos.bgColor = style.color.dng
      end
    end)
    
  end
  function MENU_STATUS:Paint(_w, _h) end
  vgui.Register("nova_admin_menu_status", MENU_STATUS, "DPanel")

  local DIALOG_BOX = {}
  function DIALOG_BOX:Init()
    if NOVA_ACTIVE_CONTEXT then NOVA_ACTIVE_CONTEXT:Remove() end
    NOVA_ACTIVE_CONTEXT = self
    self:SetPos(0,0)
    self:SetSize(style.frame.w / 2, style.frame.h / 1.5)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:MakePopup()

    local submit = vgui.Create("nova_admin_menu_button", self)
    submit:SetText(Lang("menu_elem_submit"))
    submit:SetEnabled(false)
    submit:SizeToContents()
    submit:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    self.submit = submit

    -- Cancel button
    local cancel = vgui.Create("nova_admin_menu_button", self)
    cancel.defaultColor = style.color.dng
    cancel:SetText(Lang("menu_elem_cancel"))
    cancel:SizeToContents()
    cancel:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    self.cancel = cancel
  end
  function DIALOG_BOX:SetDialogCallback(fields, callback)
    local fieldHeight = 0
    for k, v in pairs(fields or {}) do
      local textEntry = vgui.Create("nova_admin_option_text", self)
      textEntry:Dock(TOP)
      textEntry.description:SetText(v.name)
      if v.value then textEntry.entry:SetValue(v.value) end
      textEntry.entry.OnChange = function(val)
        v.value = val:GetValue()
        -- Check if all fields are filled
        for k2, v2 in pairs(fields or {}) do if not v2.value or v2.value == "" then self.submit:SetEnabled(false) return end end
        self.submit:SetEnabled(true)
      end
      fieldHeight = fieldHeight + textEntry:GetTall()
      textEntry.entry._finished = true
    end

    -- no fields need to be filled
    if fieldHeight == 0 then self.submit:SetEnabled(true) end

    self:SetSize(style.frame.w / 2,  fieldHeight + self.submit:GetTall() + self.cancel:GetTall() + style.margins.tb * 8)
    self.submit:SetPos((self:GetWide() / 2) - self.submit:GetWide() - style.margins.lr, self:GetTall() - self.submit:GetTall() - style.margins.tb)
    self.cancel:SetPos((self:GetWide() / 2) + style.margins.lr, self:GetTall() - self.cancel:GetTall() - style.margins.tb)
    self.submit.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      if callback then callback(fields) end
      self:Close()
    end
    self.cancel.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      self:Close()
    end
  end
  function DIALOG_BOX:Paint(_w, _h)
    -- draw bg with outline
    draw.RoundedBox(4, 0, 0, _w, _h, style.color.pri)
    draw.RoundedBox(4, 2, 2, _w-4, _h-4, style.color.bg)
  end
  vgui.Register("nova_admin_dialog", DIALOG_BOX, "DFrame")

  local TEXT_BOX = {}
  function TEXT_BOX:Init()
    self.text = Lang("menu_elem_no_data")
    
    self:SetSize(style.frame.w / 1.8, style.frame.h / 1.5)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self.Paint = function(_, _w, _h)
      draw.RoundedBox(4, 0, 0, _w, _h, style.color.pri)
      draw.RoundedBox(4, 2, 2, _w-4, _h-4, style.color.bg)
    end

    local title = vgui.Create("DLabel", self)
    title:SetFont("nova_font")
    title:SetText("")
    title:SetTextColor(style.color.ft)
    title:SizeToContents()
    title:SetPos(style.margins.lr, style.margins.tb)
    self.title = title

    local close = vgui.Create("nova_admin_menu_button", self)
    close.defaultColor = style.color.dng
    close:SetText(Lang("menu_elem_close"))
    close:SizeToContents()
    close:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    close:SetPos(self:GetWide() - close:GetWide() - style.margins.lr, style.margins.tb)
    close.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Close()
    end

    local copy = vgui.Create("nova_admin_menu_button", self)
    copy.defaultColor = style.color.scc
    copy:SetText(Lang("menu_elem_copy"))
    copy:SetTooltip(self.text)
    copy:SizeToContents()
    copy:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    copy:SetPos(close:GetX() - copy:GetWide() - style.margins.lr, style.margins.tb)
    copy.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      SetClipboardText(self.rawText)
    end
    self.copy = copy

    local textEntry = vgui.Create("DTextEntry", self)
    textEntry:SetMultiline(true)
    textEntry:SetFont("nova_font")
    textEntry:SetTextColor(style.color.ft)
    textEntry:SetValue(self.text)
    textEntry:SetPaintBackground( false )
    self.textEntry = textEntry

    textEntry.Paint = function(panel, w, h)
      draw.RoundedBox(0, 0, 0, w, h, style.color.tr)
      panel:DrawTextEntryText(style.color.ft, style.color.pri, style.color.pri)
    end

    local scroll = vgui.Create("nova_admin_menu_tab", self)
    scroll:SetPos(style.margins.lr, style.margins.tb * 2 + close:GetTall())
    scroll:SetSize(self:GetWide() - style.margins.lr * 2, self:GetTall() - style.margins.tb * 4 - close:GetTall())
    scroll:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
    
    scroll:AddItem(textEntry)
    
    textEntry:SetEditable(false)
    textEntry:SetSize(scroll:GetWide(), scroll:GetTall())

    self:CalcHeight()
    self:MakePopup()
  end
  function TEXT_BOX:CalcHeight()
    local nlCount = #string.Explode("\n", tostring(self.text)) - 1
    local height = (draw.GetFontHeight("nova_font") * nlCount) * 1.075 + style.margins.tb * 2
    self.textEntry:SetTall(height)
  end
  function TEXT_BOX:SetText(text, title)
    self.title:SetText(title or "")
    self.rawText = text or ""
    if not text or text == "" then text = Lang("menu_elem_no_data") end
    self.text = TextWrap(text, "nova_font", self:GetWide() - style.margins.lr * 2 )
    self.textEntry:SetValue(self.text)
    self.copy:SetTooltip(self.text)
    self:CalcHeight()
  end
  vgui.Register("nova_admin_detail_frame", TEXT_BOX, "DFrame")

  --------------------------------
  --  Custom Pages
  --------------------------------

  local PAGE_BANS_DETAIL = {}
  function PAGE_BANS_DETAIL:Init()
    self:SetSize(style.frame.w / 2, style.frame.h / 1.5)
    self:Center()
    self:SetTitle("")
    self:MakePopup()
    self:ShowCloseButton(false)
    self.Paint = function(_, _w, _h)
      draw.RoundedBox(4, 0, 0, _w, _h, style.color.pri)
      draw.RoundedBox(4, 2, 2, _w-4, _h-4, style.color.bg)
    end

    local close = vgui.Create("nova_admin_menu_button", self)
    close.defaultColor = style.color.dng
    close:SetText(Lang("menu_elem_close"))
    close:SizeToContents()
    close:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    close:SetPos(self:GetWide() - close:GetWide() - style.margins.lr, style.margins.tb)
    close.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Close()
    end
  end
  function PAGE_BANS_DETAIL:SetBan(ban)
    if not ban then return end

    local function CopyButton(yPos, val) 
      local copy = vgui.Create("nova_admin_menu_button", self)
      copy.defaultColor = style.color.scc
      copy:SetText(Lang("menu_elem_copy"))
      copy:SetTooltip(val)
      copy:SizeToContents()
      copy:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
      copy:SetPos(style.margins.lr, yPos)
      copy.DoClick = function()
        surface.PlaySound("buttons/button15.wav")
        SetClipboardText(val)
      end
      return copy
    end

    local function PropertyText(parent, yPos, val)
      local prop = vgui.Create("DLabel", self)
      local cpyButton = CopyButton(yPos, ban[val])

      local text = string.format("%s: %s", Lang(val), ban[val])
      text = TextWrap(text, "nova_font", parent:GetWide() - cpyButton:GetWide() - style.margins.lr * 3 )
      prop:SetText(text)
      prop:SetFont("nova_font")

      if GetLangKey(ban[val]) == "ban_on_sight" then
        prop:SetTextColor(Color(255, 0, 0))
      elseif GetLangKey(ban[val]) == "unban_on_sight" then
        prop:SetTextColor(Color(0, 255, 0))
      else
        prop:SetTextColor(style.color.ft)
      end

      prop:SizeToContents()
      prop:SetPos(cpyButton:GetWide() + style.margins.lr * 2, yPos)

      return prop
    end

    local lastYPos = style.margins.tb * 2
    local order = {"steamid", "time", "status", "ip", "reason", "internal_reason", "comment"}
    for k, v in pairs(order) do
      if not ban[v] or ban[v] == "" then continue end
      local prop = PropertyText(self, lastYPos, v)
      lastYPos = lastYPos + prop:GetTall() + style.margins.tb
    end

  end
  function PAGE_BANS_DETAIL:Paint(_w, _h) end
  vgui.Register("nova_admin_page_bans_detail", PAGE_BANS_DETAIL, "DFrame")


  local PAGE_BANS = {}
  function PAGE_BANS:FilterData(filter, search)
    if not filter or filter == "" or not search or search == "" then 
      LoadData("]] .. Nova.netmessage("admin_get_bans") .. [[", nil, function(data) if not IsValid(self) then return end self.bans = data or {} self:CheckNoBans() self:ReloadData() end)
    else 
      LoadData("]] .. Nova.netmessage("admin_get_bans") .. [[", {
        ["search"] = {
          {
            ["k"] = filter,
            ["v"] = search,
          },
        }
      }, function(data) if not IsValid(self) then return end self.bans = data or {} self:CheckNoBans() self:ReloadData() end)
    end
  end

  function PAGE_BANS:ReloadData()
    if self.banTable then self.banTable:Remove() self.banTable = nil end
    local noBans = table.IsEmpty(self.bans or {})
    local banTable = vgui.Create("nova_admin_option_list", self)
    if noBans then
      banTable.entry:SetVisible(false)
      banTable.description:SetVisible(false)
    end
    banTable.description:SetText(Lang("menu_elem_bans"))
    banTable.entry._finished = true
    self.banTable = banTable
    banTable:Dock(TOP)
    banTable:SetSetting("", self.bans, nil, true)
    banTable:Style(true)
    if banTable.edit then banTable.edit:Remove() end
    banTable.remove:SetText(Lang("menu_elem_unban"))
    banTable.remove.DoClick = function()
      if not banTable.entry:GetSelectedLine() then return end
      surface.PlaySound("UI/buttonclick.wav")
      local selected = banTable.entry.Lines[banTable.entry:GetSelectedLine()]
      if not selected then return end
      local removeKey = selected._key
      LoadData("]] .. Nova.netmessage("admin_get_bans") .. [[", {
        [banTable.remove.action] = {{ ["k"] = removeKey }}
      }, function() 
        if not IsValid(self) then return end
        local filter = self.filterSelection.entry:GetSelected()
        local search = self.filterText.entry:GetValue()
        filter = GetLangKey(filter)
        self:FilterData(filter, search)
      end)
    end

    banTable.add.DoClick = function()
      surface.PlaySound("UI/buttonclick.wav")
      local dialog = vgui.Create("nova_admin_dialog", NOVA_MENU)
      dialog:SetDialogCallback(
        {
          ["steamid"] = {["name"] = "SteamID32", ["value"] = nil},
          ["comment"] = {["name"] = Lang("menu_elem_comment"), ["value"] = nil},
        }, function(fields)
          local steamID = fields.steamid.value
          local comment = fields.comment.value
          local steamID32 = util.SteamIDFrom64(steamID)
          if steamID32 != "STEAM_0:0:0" then steamID = steamID32 end
          if not string.find(steamID, "STEAM_") then
            timer.Simple(0.1, function()
              surface.PlaySound("common/wpn_denyselect.wav")
            end)
            return
          end
          LoadData("]] .. Nova.netmessage("admin_get_bans") .. [[", {
            ["ban"] = {{ ["k"] = steamID, ["v"] = comment }}
          }, function() 
            if not IsValid(self) then return end
            local filter = self.filterSelection.entry:GetSelected()
            local search = self.filterText.entry:GetValue()
            filter = GetLangKey(filter)
            self:FilterData(filter, search)
          end)
        end
      )
    end

    banTable.entry.CustomOnRowSelected = function(_, lineID, line)
      local selectedBan = self.bans[banTable.entry.Lines[banTable.entry:GetSelectedLine()]._key]
      if not selectedBan then return end
      local langKey = GetLangKey(selectedBan.status)
      banTable.remove:SetEnabled(true)
      if langKey == "unban_on_sight" then
        banTable.remove.action = "ban"
        banTable.remove:SetText(Lang("menu_elem_ban"))
      elseif langKey == "ban_on_sight" or langKey == "banned" then
        banTable.remove.action = "unban"
        banTable.remove:SetText(Lang("menu_elem_unban"))
      end
    end

    local _, parentHeight = self:GetParent():GetParent():GetSize()
    local height = banTable:Resize()
    
    timer.Simple(0.2,function() if IsValid(self) then self:SizeToChildren(true, true) end end)

    if not self.filterSelection.entry:GetSelected() then
      self.filterSelection.entry:Clear()
      for k, v in pairs(#table.GetKeys(self.bans or {}) > 0 and self.bans[ table.GetKeys(self.bans)[1] ] or {}) do
        if type(v) ~= "string" then continue end
        self.filterSelection.entry:AddChoice(Lang(k))
      end
    end

    for k1, line in pairs(self.banTable.entry.Lines or {}) do
      for k2, label in pairs(line.Columns or {}) do
        local key = GetLangKey(label:GetText())
        if key == "ban_on_sight" then
          label:SetTextColor(Color(255, 0, 0))
        elseif key == "unban_on_sight" then
          label:SetTextColor(Color(0, 255, 0))
        end
        if k2 == #line.Columns then
          line.Columns[k2] = vgui.Create("nova_admin_menu_button", line)
          line.Columns[k2]:SetText(Lang("menu_elem_view"))
          line.Columns[k2].DoClick = function()
            local selected = banTable.entry.Lines[k1]
            if not selected then return end
            local ban = self.bans[selected._key]
            local detailPanel = vgui.Create("nova_admin_page_bans_detail", NOVA_MENU)
            detailPanel:SetBan(ban)
          end
        end
      end
    end
  end

  function PAGE_BANS:CheckNoBans()
    if self.noBans then self.noBans:Remove() self.noBans = nil end
    if not self.bans or table.Count(self.bans or {}) == 0 then
      local _, parentHeight = self:GetParent():GetParent():GetSize()
      self:SetSize(style.tab.w - (style.margins.lr * 6), parentHeight / 1.5 )
      local noBans = vgui.Create("DLabel", self)
      noBans:SetFont("nova_font")
      noBans:SetTextColor( style.color.dng )
      noBans:SetText(Lang("menu_elem_no_bans"))
      noBans:SizeToContents()
      noBans:Center()
      self.noBans = noBans
      return true
    end

    return false
  end

  function PAGE_BANS:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)

    local filterSelection = vgui.Create("nova_admin_option_list_select", self)
    filterSelection:Dock(TOP)
    filterSelection.description:SetText(Lang("menu_elem_filter_by"))
    filterSelection.entry.OnSelect = function(_, index, value)
      self.filterText.entry:SetText("")
    end
    self.filterSelection = filterSelection

    local filterText = vgui.Create("nova_admin_option_text", self)
    filterText:Dock(TOP)
    filterText.description:SetText("Filter text:")
    filterText.entry:SetPlaceholderText( Lang("menu_elem_search_term") )

    filterText.entry.OnChangeDelayed = function(_, val)
      if not val then return end
      local filter = filterSelection.entry:GetSelected()
      if not filter then return end
      filter = GetLangKey(filter)
      self:FilterData(filter, val)
    end
    filterText.entry._finished = true
    self.filterText = filterText

    if not self.bans then
      LoadData("]] .. Nova.netmessage("admin_get_bans") .. [[", nil, function(data) if not IsValid(self) then return end self.bans = data or {} self:CheckNoBans() self:ReloadData() end)
    end
  end
  function PAGE_BANS:Paint(_w, _h) end
  vgui.Register("nova_admin_page_bans", PAGE_BANS, "DPanel")

  local PAGE_PLAYERS = {}
  function PAGE_PLAYERS:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)
    
    LoadData("]] .. Nova.netmessage("admin_get_players") .. [[", nil, function(data)
      if not IsValid(self) then return end
      -- sort by permission
      table.SortByMember( data or {}, "index", false)

      local topNav = vgui.Create("DPanel", self)
      topNav:Dock(TOP)
      topNav:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
      topNav.Paint = function() end
      topNav:SetMinimumSize( nil, style.margins.tb * 3)

      -- label with player count
      local playerCount = vgui.Create("DLabel", topNav)
      playerCount:SetFont("nova_font")
      playerCount:SetText(string.format(Lang("menu_elem_player_count"), #data))
      playerCount:SetTextColor( style.color.ft )
      playerCount:SizeToContents()
      playerCount:Dock(LEFT)

      local search = vgui.Create("nova_admin_option_text", topNav)
      search:Dock(LEFT)
      search:DockMargin(0, 0, style.margins.lr, 0)
      search:GetChildren()[1]:Remove()
      search.entry:SetHeight(select(2, topNav:GetSize()))
      search.entry.defaultColor = style.color.dis
      search:SetSize(style.margins.lr * 12, style.margins.tb * 5)
      local placeholderText = "SteamID/Nick..."
      search.entry:SetValue(self.searchvalue and self.searchvalue or placeholderText)
      search.entry.OnGetFocus = function(val)
        if val:GetValue() == placeholderText then
          val:SetValue("") search.entry.defaultColor = style.color.ft
        end
      end
      search.entry.OnChange = function(val)
        if self.searchvalue == "" and val:GetValue() == "" then return end
        self.searchvalue = string.lower(val:GetValue())
        for _, v in ipairs(self:GetChildren()) do
          if not v.searchEntries then continue end
          if not string.find(v.searchEntries, self.searchvalue) then v:Hide()
          else v:Show() end
        end
        self:InvalidateLayout()
      end

      for k, v in ipairs(data or {}) do
        local ply = player.GetBySteamID(v.steamid) if not IsValid(ply) then continue end
        local plyNick = ply:Nick()
        v.steamid64 = ply:SteamID64()

        local collapse = vgui.Create( "DCollapsibleCategory", self )
        collapse.searchEntries = string.lower(v.steamid) .. v.steamid64 .. string.lower(plyNick)
        collapse:SetLabel("")
        collapse:Dock(TOP)
        collapse:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
        collapse:SetHeaderHeight(style.margins.tb * 4)
        collapse:SetExpanded(false)

        local headerHeight = collapse:GetHeaderHeight()
        local headerWidth = select(1, self:GetSize()) - style.margins.lr * 2

        collapse.Paint = function(_, _w, _h)
          local isHovered = collapse.Header:IsHovered()
          local isExpanded = collapse:GetExpanded()
          draw.RoundedBox(6, 0, 0, _w, headerHeight, (isHovered or isExpanded) and style.color.pri or style.color.sec)
          if isHovered then
            if not collapse.playsound then surface.PlaySound("UI/buttonrollover.wav") collapse.playsound = true end
          else
            collapse.playsound = false
          end
        end

        local avatar = vgui.Create("nova_staff_avatar", collapse)
        avatar:SetSize(style.margins.tb * 3, style.margins.tb * 3)
        avatar:SetMaskSize(style.margins.tb * 2 )
        avatar:SetPlayer(ply)
        avatar:SetPos(style.margins.lr, headerHeight / 2 - avatar:GetTall() / 2)

        local plyName = vgui.Create("DLabel", collapse)
        plyName:SetFont("nova_font")
        plyName:SetTextColor(style.color.ft)
        plyName:SetText( string.format("%s (%s)", plyNick or "", v.steamid) )
        plyName:SetPos(style.margins.lr * 2 + avatar:GetWide(), headerHeight / 2 - plyName:GetTall() / 2)
        plyName:SizeToContents()

        local permission = vgui.Create("nova_staff_tag", collapse)
        permission.label:SetFont("nova_font")
        permission.text = v.permission
        if v.permission == "Protected" then permission.color = style.color.scc
        elseif v.permission == "Staff" then permission.color = style.color.scc
        elseif v.permission == "Trusted" then permission.color = style.color.wrn
        else permission.color = style.color.dis end
        surface.SetFont("nova_font")
        local wide = surface.GetTextSize(permission.text) + style.margins.lr
        permission:SetSize(wide, style.margins.tb * 2)
        permission:SetPos(headerWidth - permission:GetWide() - style.margins.lr, headerHeight / 2 - permission:GetTall() / 2)

        local xOffset = permission:GetWide() + style.margins.lr

        if v.numdetections > 0 then
          local detections = vgui.Create("nova_staff_tag", collapse)
          detections.label:SetFont("nova_font")
          detections.text = string.format("%d Detection", v.numdetections)
          detections.color = style.color.dng
          local wide = surface.GetTextSize(detections.text) + style.margins.lr
          detections:SetSize(wide, style.margins.tb * 2)
          xOffset = xOffset + detections:GetWide()  + style.margins.lr
          detections:SetPos(headerWidth - xOffset, headerHeight / 2 - detections:GetTall() / 2)
        end

        if v.quarantine then
          local quarantined = vgui.Create("nova_staff_tag", collapse)
          quarantined.label:SetFont("nova_font")
          quarantined.text = "Quarantine"
          quarantined.color = style.color.dng
          local wide = surface.GetTextSize(quarantined.text) + style.margins.lr
          quarantined:SetSize(wide, style.margins.tb * 2)
          xOffset = xOffset + quarantined:GetWide()  + style.margins.lr
          quarantined:SetPos(headerWidth - xOffset, headerHeight / 2 - quarantined:GetTall() / 2)
        end

        if v.vpn then
          local vpn = vgui.Create("nova_staff_tag", collapse)
          vpn.label:SetFont("nova_font")
          vpn.text = "VPN"
          vpn.color = style.color.dng
          local wide = surface.GetTextSize(vpn.text) + style.margins.lr
          vpn:SetSize(wide,style.margins.tb * 2)
          xOffset = xOffset + vpn:GetWide()  + style.margins.lr
          vpn:SetPos(headerWidth - xOffset, headerHeight / 2 - vpn:GetTall() / 2)
        end

        if v.family then
          local family = vgui.Create("nova_staff_tag", collapse)
          family.label:SetFont("nova_font")
          family.text = "Family"
          family.color = style.color.wrn
          local wide = surface.GetTextSize(family.text) + style.margins.lr
          family:SetSize(wide,style.margins.tb * 2)
          xOffset = xOffset + family:GetWide()  + style.margins.lr
          family:SetPos(headerWidth - xOffset, headerHeight / 2 - family:GetTall() / 2)
        end

        if not v.authed then
          local authed = vgui.Create("nova_staff_tag", collapse)
          authed.label:SetFont("nova_font")
          authed.text = Lang("menu_elem_notauthed")
          authed.color = style.color.wrn
          local wide = surface.GetTextSize(authed.text) + style.margins.lr
          authed:SetSize(wide,style.margins.tb * 2)
          xOffset = xOffset + authed:GetWide()  + style.margins.lr
          authed:SetPos(headerWidth - xOffset, headerHeight / 2 - authed:GetTall() / 2)
        end

        if v.indicators and not table.IsEmpty(v.indicators) then
            surface.SetFont("nova_font")
            local sum = 0
            local cnt = table.Count(v.indicators)
            local text = ""
            local summary = ""
            local critical = false
            for k2, v2 in pairs(v.indicators) do
              summary = string.format("%s• %s\n", summary, Lang(k2))
              sum = sum + v2
              if v2 == 10 then
                critical = true
                text = "menu_elem_criticalindicators"
              end
            end
            summary = string.sub(summary, 1, -2)
            if sum > 10 and not critical then
              critical = true
              text = "menu_elem_criticalindicators"
            end
            if not critical then
              text = sum > 1 and "menu_elem_foundindicators" or "menu_elem_foundindicator"
            end
            local indicator = vgui.Create("nova_staff_tag", collapse)
            indicator:SetTooltip(summary)
            indicator.label:SetFont("nova_font")
            indicator.text = string.format(Lang(text), cnt)
            indicator.color = critical and style.color.dng or style.color.wrn
            local wide = surface.GetTextSize(indicator.text) + style.margins.lr
            indicator:SetSize(wide, style.margins.tb * 2)
            xOffset = xOffset + indicator:GetWide() + style.margins.lr
            indicator:SetPos(headerWidth - xOffset, headerHeight / 2 - indicator:GetTall() / 2)
        end

        local function CreateContent()
          if collapse._hasContent then return end
          collapse._hasContent = true

          local propList = vgui.Create( "DPanel", collapse )
          propList:Dock(FILL)
          propList:DockPadding(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
          propList.Paint = function(_, _w, _h)
            draw.RoundedBox(6, 0, 0, _w, _h, style.color.sec)
          end
          collapse:SetContents( propList )

          local lastYPos = style.margins.tb
          local function AddProperty(name, value)
            local prop = vgui.Create("DLabel", propList)
            prop:SetFont("nova_font")
            prop:SetText( string.format("%s: %s", name, value) )
            prop:SizeToContents()
            prop:SetTextColor(style.color.ft)
            
            local btn = vgui.Create("nova_admin_default_button", propList)
            btn:SetTooltip(value)
            btn.defaultColor = style.color.scc
            btn:SetText(Lang("menu_elem_copy"))
            btn:SizeToContents()
            btn:SetPos(style.margins.lr * 2 + prop:GetWide(), lastYPos)
            lastYPos = lastYPos + style.margins.tb + btn:GetTall()
            btn.DoClick = function()
              SetClipboardText(value)
              surface.PlaySound("buttons/button15.wav")
            end

            prop:SetPos(style.margins.lr, btn:GetY() + btn:GetTall() / 2 - prop:GetTall() / 2)
          end

          local lastXPos = style.margins.lr
          local function AddAction(name, identifier, color, customClick, callback)
            local btn = vgui.Create("nova_admin_default_button", propList)
            btn.defaultColor = color or style.color.pri
            btn:SetText(Lang(name))
            btn:SizeToContents()
            btn:SetPos(lastXPos, lastYPos + style.margins.tb)
            surface.SetFont("nova_font")
            local btnTextWide = surface.GetTextSize(btn:GetText()) + style.margins.lr * 2
            -- check if we need to move to the next line
            if lastXPos + btnTextWide > (headerWidth - style.margins.lr * 2) then
              lastXPos = style.margins.lr
              lastYPos = lastYPos + style.margins.tb + btn:GetTall()
            else
              lastXPos = lastXPos + btn:GetWide() + style.margins.lr
            end
            btn.DoClick = function()
              surface.PlaySound("buttons/button15.wav")
              if isfunction(customClick) then customClick() return end
              if not identifier then
                callback(nil, btn)
                return
              end
              LoadData("]] .. Nova.netmessage("admin_get_players") .. [[", {["action"] = identifier, ["steamID"] = v.steamid}, function(_data)
                if not IsValid(self) then return end
                callback(_data, btn)
              end)
            end
          end

          AddProperty(Lang("steamid"), v.steamid)
          AddProperty(Lang("steamid64"), v.steamid64)
          AddProperty(Lang("usergroup"), ply:GetUserGroup())
          if v.ip then AddProperty(Lang("ip"), v.ip) end
          if v.family and v.familyowner then AddProperty(Lang("familyowner"), v.familyowner) end
          AddAction("menu_elem_ban", "ban", style.color.dng, function()
            local dialog = vgui.Create("nova_admin_dialog", NOVA_MENU)
            dialog:SetDialogCallback(
              {
                ["reason"] = {["name"] = Lang("menu_elem_reason"), ["value"] = nil},
                ["comment"] = {["name"] = Lang("menu_elem_comment"), ["value"] = nil},
              }, function(fields)
                local reason = fields.reason.value
                local comment = fields.comment.value
                LoadData("]] .. Nova.netmessage("admin_get_players") .. [[",
                  {["action"] = "ban", ["steamID"] = v.steamid, ["reason"] = reason, ["comment"] = comment},
                  function() if not IsValid(self) then return end self:Clear() self:Init() end
                )
              end
            )
          end)
          AddAction("menu_elem_kick", "kick", style.color.dng, function()
            local dialog = vgui.Create("nova_admin_dialog", NOVA_MENU)
            dialog:SetDialogCallback(
              {
                ["reason"] = {["name"] = Lang("menu_elem_reason"), ["value"] = nil},
              }, function(fields)
                local reason = fields.reason.value
                LoadData("]] .. Nova.netmessage("admin_get_players") .. [[",
                  {["action"] = "kick", ["steamID"] = v.steamid, ["reason"] = reason},
                  function() if not IsValid(self) then return end self:Clear() self:Init() end
                )
              end
            )
          end)
          AddAction("menu_elem_reconnect", "reconnect", style.color.wrn, function()
            LoadData("]] .. Nova.netmessage("admin_get_players") .. [[",
              {["action"] = "reconnect", ["steamID"] = v.steamid},
              function() if not IsValid(self) then return end self:Clear() self:Init() end
            )
          end)
          if NOVA_ADVANCED then
            AddAction(v.quarantine and "menu_elem_unquarantine" or "menu_elem_quarantine", "quarantine", style.color.wrn, function()
              LoadData("]] .. Nova.netmessage("admin_get_players") .. [[",
                {["action"] = "quarantine", ["steamID"] = v.steamid, ["quarantine"] = not v.quarantine},
                function() 
                  if not IsValid(self) then return end 
                  v.quarantine = not v.quarantine 
                  collapse._hasContent = false
                  collapse.Contents = nil
                  CreateContent() 
                end)
            end)
          end
          AddAction("menu_elem_screenshot", "screenshot", style.color.wrn, nil, function(_data, btn)
            local function OpenScreenshot(scData)
              local frame = vgui.Create("DFrame", NOVA_MENU)
              frame:SetSize(sw, sh)
              frame:SetTitle("")
              frame:MakePopup()
              frame:SetDraggable(false)
              frame:ShowCloseButton(false)
              frame.Paint = function(_, _w, _h)
                draw.RoundedBox(4, 0, 0, _w, _h, style.color.bg)
              end
              local fileName = string.format("nova_tmp_%s.jpg", os.date("%Y-%m-%d_%H-%M-%S"))
              file.Write(fileName, scData)

              local image = vgui.Create("DImage", frame)
              image:Dock(FILL)
              image:DockMargin(0, style.margins.tb, 0, 0)
              image:SetImage("data/" .. fileName)
              file.Delete(fileName)

              local close = vgui.Create("nova_admin_menu_button", frame)
              close.defaultColor = style.color.dng
              close:SetText(Lang("menu_elem_close"))
              close:SizeToContents()
              close:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
              close:SetPos(frame:GetWide() - close:GetWide() - style.margins.lr, style.margins.tb)
              close.DoClick = function()
                surface.PlaySound("buttons/button15.wav")
                frame:Close()
              end

              local save = vgui.Create("nova_admin_menu_button", frame)
              save.defaultColor = style.color.scc
              save:SetText(Lang("menu_elem_save"))
              save:SizeToContents()
              save:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
              save:SetPos(close:GetX() - save:GetWide() - style.margins.lr, style.margins.tb)
              save.DoClick = function()
                surface.PlaySound("buttons/button15.wav")
                local dir = "nova/local_screenshots/"
                file.CreateDir(dir)
                local savePath = dir .. os.date("%Y-%m-%d_%H-%M-%S") .. ".jpg"
                file.Write(savePath, scData)
                save:SetEnabled(false)
                save:SetText(Lang("menu_elem_saved"))
                LocalPlayer():ChatPrint(string.format("[Nova Defender] %s: STEAMFOLDER/GarrysMod/garrysmod/data/nova/local_screenshots/%s", Lang("menu_elem_saved"), savePath))
              end
            end

            local chunkData = {}
            local packetCount = 0
            local progress = 4

            btn:SetEnabled(false)
            if not btn.oldPaint then btn.oldPaint = btn.Paint end
            btn.Paint = function(_, _w, _h)
              draw.RoundedBox(4, 0, 0, _w * (progress / 100), _h, style.color.scc)
            end
            local reveived = false
            timer.Simple(60,function() 
              if reveived or not IsValid(btn) then return end
              btn:SetEnabled(true)
              btn.Paint = btn.oldPaint
            end)

            net.Receive("]] .. Nova.netmessage("networking_screenshot") .. [[", function()
              progress = net.ReadUInt(8)	if not progress then return end

              if progress <= 50 then return end

              local total = net.ReadUInt(6)		if not total then return end
              local index = net.ReadUInt(6)		if not index then return end
              local size = net.ReadUInt(16)		if not size then return end
              local chunk = net.ReadData(size)   	if not chunk then return end

              chunkData[index] = chunk
              packetCount = packetCount + 1

              if packetCount ~= total then return end
              chunkData = table.concat(chunkData)
              timer.Simple(1, function() OpenScreenshot(chunkData) reveived = true end)

              if not IsValid(btn) then return end
              btn:SetEnabled(true)
              btn.Paint = btn.oldPaint
            end)
          end)
          AddAction("menu_elem_detections", "detections", nil, nil, function(_data)
            local text = ""
            table.SortByMember(_data or {}, "time_unix", false)
            for _, detectionTable in ipairs(_data or {}) do
              local time = detectionTable["time"]
              local detection = detectionTable["identifier"]
              local description = detectionTable["description"]
              local descriptionText = ""
              if description and description ~= "" then
                descriptionText = string.format("\n   • %s", description)
              end
              text = string.format("%s %s: %s%s \n", text, time, Lang("config_detection_" .. detection), descriptionText)
            end
            local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
            detailFrame:SetText(text, Lang("menu_elem_detections"))
          end)
          AddAction("menu_elem_netmessages", "netmessages", nil, nil, function(_data)
            _data["___total_messages"] = nil
            local text = ""
            -- sort by value
            local sorted = {}
            for _k, _v in pairs(_data or {}) do table.insert(sorted, {_k, _v}) end
            table.sort(sorted, function(a, b) return a[2] > b[2] end)
            for _, _v in pairs(sorted or {}) do
              text = string.format("%s• %s (%dx)\n", text, _v[1], _v[2])
            end
            local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
            detailFrame:SetText(text, Lang("menu_elem_netmessages"))
          end)
          if v.ip then
            AddAction("menu_elem_ip", "ip", nil, nil, function(_data)
              if not _data then return end
              local text = ""
              for k, v in pairs(_data or {}) do
                text = string.format("%s• %s: %s\n", text, k, v)
              end
              local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
              detailFrame:SetText(text, Lang("menu_elem_ip"))
            end)
          end
          AddAction("menu_elem_commands", "commands", nil, nil, function(_data)
            local text = ""
            local lastTime = 0
            table.SortByMember(_data or {}, "last_execution_unix", false)
            for _, val in ipairs(_data or {}) do
              if val.last_execution == lastTime then
                text = string.format("%s • %s (%dx)\n", text, val.command, val.total_executions)
              else
                lastTime = val.last_execution
                text = string.format("%s\n%s:\n • %s (%dx)\n", text, val.last_execution, val.command, val.total_executions)
              end
              if not val.recent_arguments then continue end
              for _, value in ipairs(val.recent_arguments or {}) do
                text = string.format("%s       • %s %s\n", text, val.command, value)
              end
            end
            local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
            detailFrame:SetText(text, Lang("menu_elem_commands"))
          end)
          AddAction("menu_elem_indicators", "indicators", nil, nil, function(_data)
            if not _data then return end
            local text = ""
            for k, _ in pairs(_data or {}) do
              text = string.format("%s• %s\n", text, Lang(k))
            end
            local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
            detailFrame:SetText(text, Lang("menu_elem_indicators"))
          end)
          AddAction("menu_elem_profile", nil, nil, nil, function(_data)
            gui.OpenURL(string.format("http://steamcommunity.com/profiles/%s", v.steamid64))
          end)
          if NOVA_ADVANCED then
            AddAction("menu_elem_verify_ac", "verify_ac", nil, nil, function(_data)
              if not _data then return end
              local text = ""
              for k, v in pairs(_data or {}) do
                text = string.format("%s• %s: %s\n", text, k, v)
              end
              local detailFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
              detailFrame:SetText(text, Lang("menu_elem_verify_ac"))
            end)
          end
        end
        collapse.OnToggle = function(_, expanded) 
          if expanded then CreateContent() end
          timer.Simple(collapse:GetAnimTime() + 0.1, function() if IsValid(self) then self:SizeToChildren(true, true) end end)
        end
      end

      timer.Simple(0.75,function() if IsValid(self) then self:SizeToChildren(true, true) end end)
    end)
  end
  function PAGE_PLAYERS:Paint(_w, _h) end
  vgui.Register("nova_admin_page_players", PAGE_PLAYERS, "DPanel")

  local PAGE_HEALTH = {}
  function PAGE_HEALTH:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)
    LoadData("]] .. Nova.netmessage("admin_get_health") .. [[", nil, function(data) 
      if not IsValid(self) then return end
      if not data then return end
      table.SortByMember(data.failed, "score", false)
      table.SortByMember(data.passed, "score", false)

      local percPanel = vgui.Create("DPanel", self)
      percPanel:SetPos(style.margins.lr, style.margins.tb)
      percPanel:SetSize(self:GetWide() * 0.30 - style.margins.lr, style.frame.h * 0.15)
      
      local percText = vgui.Create("DLabel", percPanel)
      percText:Dock(FILL)
      percText:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
      percText:SetContentAlignment(7)
      percText:SetFont("nova_font")
      percText:SetTextColor(style.color.ft)
      percText:SetText(string.format(Lang("menu_elem_health_overview"), data.total_checks, data.total_checks - data.total_impacted, data.total_impacted))

      local function DrawCircle( x, y, radius, from, to )
        local seg = 100
        local cir = {}
        table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
        for i = seg * from, seg * to do
          local a = math.rad( ( i / seg ) * -360 )
          table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
        end
      
        local a = math.rad( 0 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
      
        surface.DrawPoly( cir )
      end

      percPanel.Paint = function(_, _w, _h)
        local bgColor = style.color.sec

        if percPanel:IsHovered() then
          local lightenColor = style.color.sec:ToVector() lightenColor:Mul(1.2)
          bgColor = lightenColor:ToColor()
          draw.RoundedBox(8, 2, 2, _w-4, _h-4, bgColor)
        else draw.RoundedBox(8, 0, 0, _w, _h, bgColor) end

        local radius = (_h - style.margins.tb * 3) / 2
        local strength = style.margins.tb / 1.5
        local center = Vector(_w - (radius + style.margins.tb + strength / 2), _h - (radius + style.margins.tb + strength / 2), 0)
        local scale = Vector( radius, radius, 0 )
        local greenPerc = (data.total_checks - data.total_impacted) / data.total_checks
        local redPerc = data.total_impacted / data.total_checks
        local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )

        surface.SetDrawColor( style.color.dng) 
        draw.NoTexture()
        DrawCircle(center.x, center.y, radius, 0, redPerc)
        surface.SetDrawColor(style.color.scc)
        DrawCircle(center.x, center.y, radius, redPerc, 1)
        surface.SetDrawColor(bgColor)
        DrawCircle(center.x, center.y, radius - strength, 0, 1)
        -- draw percentage text in the middle
        local txtColor = redPerc >= 0.5 and style.color.dng or style.color.scc
        draw.SimpleText(string.format("%d%%", math.Round((data.total_checks - data.total_impacted) / data.total_checks * 100)), "nova_font", center.x, center.y, txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end

      local critPanel = vgui.Create("DPanel", self)
      critPanel:SetPos(percPanel:GetX() + percPanel:GetWide() +  style.margins.lr, style.margins.tb)
      critPanel:SetSize(self:GetWide() * 0.45 - style.margins.lr, style.frame.h * 0.15)
      critPanel.Paint = function(_, _w, _h)
        local bgColor = style.color.sec

        if critPanel:IsHovered() then
          local lightenColor = style.color.sec:ToVector() lightenColor:Mul(1.2)
          bgColor = lightenColor:ToColor()
          draw.RoundedBox(8, 2, 2, _w-4, _h-4, bgColor)
        else draw.RoundedBox(8, 0, 0, _w, _h, bgColor) end

        local boxSize = _h - style.margins.tb * 4
        local boxX = _w - boxSize - style.margins.lr
        local boxY = _h / 2 - boxSize / 2 + style.margins.tb
        draw.RoundedBox(8, boxX, boxY, boxSize, boxSize, data.max_severity_color)
        draw.SimpleText(string.format("%s", math.Truncate(data.max_score, 2)), "nova_font", boxX + boxSize / 2, boxY + boxSize / 2, style.color.ft, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.format("%s", Lang(data.max_severity)), "nova_font", boxX + boxSize / 2, boxY - style.margins.tb * 1.5, style.color.ft, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end

      local critText = vgui.Create("DLabel", critPanel)
      critText:Dock(FILL)
      critText:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
      critText:SetContentAlignment(7)
      critText:SetFont("nova_font")
      critText:SetTextColor(style.color.ft)
      local text = Lang("menu_elem_health_most_critical")
      local failed = data.failed
      for i = 1, 3 do
        local check = failed[i]
        if check then
          text = text .. string.format("  • %s: %s\n", check.name, math.Truncate(check.score,2))
        end
      end
      critText:SetText(text)

      local resetPanel = vgui.Create("DPanel", self)
      resetPanel:SetPos(critPanel:GetX() + critPanel:GetWide() +  style.margins.lr, style.margins.tb)
      resetPanel:SetSize(self:GetWide() * 0.25 - style.margins.lr, style.frame.h * 0.15)
      resetPanel.Paint = function(_, _w, _h)
        local bgColor = style.color.sec

        if resetPanel:IsHovered() then
          local lightenColor = style.color.sec:ToVector() lightenColor:Mul(1.2)
          bgColor = lightenColor:ToColor()
          draw.RoundedBox(8, 2, 2, _w-4, _h-4, bgColor)
        else draw.RoundedBox(8, 0, 0, _w, _h, bgColor) end
      end

      local resetText = vgui.Create("DLabel", resetPanel)
      resetText:Dock(TOP)
      resetText:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
      resetText:SetContentAlignment(7)
      resetText:SetFont("nova_font")
      resetText:SetTextColor(style.color.ft)
      resetText:SetText(string.format(Lang("menu_elem_reset_all"), data.total_checks, data.total_checks - data.total_impacted, data.total_impacted))

      local resetButton = vgui.Create("nova_admin_default_button", resetPanel)
      resetButton.defaultColor = style.color.dng
      resetButton:Dock(BOTTOM)
      resetButton:SetText(Lang("menu_elem_reset"))
      resetButton:SizeToContents()
      resetButton:DockMargin(style.margins.lr * 2, 0, style.margins.lr * 2, style.margins.tb * 3)
      resetButton.DoClick = function()
        LoadData("]] .. Nova.netmessage("admin_get_health") .. [[",
          { ["action"] = "reset" },
        function(data) if not IsValid(self) then return end ReloadFrame() end)
      end

      local function CreateCheck(check, passed) 
        local hasList = check.list and #check.list > 0
        local collapse = vgui.Create( "DCollapsibleCategory", self )
        collapse:SetLabel( "" )
        collapse:Dock(TOP)
        collapse:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
        collapse:SetHeaderHeight(style.margins.tb * 4)
        collapse:SetExpanded( false )

        collapse.OnToggle = function(_, expanded) 
          timer.Simple(collapse:GetAnimTime(),function() if IsValid(self) then self:SizeToChildren(false, true) end end)
        end
        local headerHeight = collapse:GetHeaderHeight()
        local headerWidth = select(1, self:GetSize()) - style.margins.lr * 2

        collapse.Paint = function(_, _w, _h)
          local isHovered = collapse.Header:IsHovered()
          local isExpanded = collapse:GetExpanded()
          draw.RoundedBox(6, 0, 0, _w, headerHeight, (isHovered or isExpanded) and style.color.pri or style.color.sec)
          if isHovered then
            if not collapse.playsound then surface.PlaySound("UI/buttonrollover.wav") collapse.playsound = true end
          else
            collapse.playsound = false
          end
        end

        local checkName = vgui.Create("DLabel", collapse)
        checkName:SetFont("nova_font")
        checkName:SetTextColor(style.color.ft)
        checkName:SetText( check.name )
        checkName:SetPos(style.margins.lr, style.margins.tb)
        checkName:SizeToContents()

        if not passed then
          local checkScore = vgui.Create("DPanel", collapse)
          local boxSize = headerHeight * 0.8
          checkScore:SetSize(boxSize, boxSize)
          checkScore:SetPos(headerWidth - boxSize - style.margins.lr, headerHeight / 2 - boxSize / 2)
          checkScore.Paint = function(_, _w, _h)
            local bgColor = check.color or style.color.dis
            draw.RoundedBox(6, 0, 0, _w, _h, bgColor)
            draw.SimpleText(string.format("%s", math.Truncate(check.score, 2)), "nova_font", _w / 2, _h / 2, style.color.ft, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end

          local ignoreButton = vgui.Create("nova_admin_default_button", collapse)
          ignoreButton.defaultColor = style.color.dng
          ignoreButton:SetText(Lang("menu_elem_ignore"))
          ignoreButton:SizeToContents()
          ignoreButton:SetPos(headerWidth - boxSize - style.margins.lr - ignoreButton:GetWide() - style.margins.lr, headerHeight / 2 - ignoreButton:GetTall() / 2)
          ignoreButton.DoClick = function()
            LoadData("]] .. Nova.netmessage("admin_get_health") .. [[",
              { ["action"] = "add", ["id"] = check.id},
            function(data) if not IsValid(self) then return end ReloadFrame() end)
          end
        end

        local detailPanel = vgui.Create( "DPanel", collapse )
        detailPanel:Dock( FILL )
        detailPanel:DockPadding(style.margins.lr, style.margins.tb * 8, style.margins.lr, style.margins.tb)
        local detailAspect = 0.65
        local mitigationText, listText = Lang("menu_elem_mitigation"), Lang("menu_elem_list")
        detailPanel.Paint = function(_, _w, _h)
          draw.RoundedBox(6, 0, 0, _w, _h, style.color.sec)
          -- draw description
          draw.SimpleText(check.desc, "nova_font", style.margins.lr, style.margins.tb, style.color.ft)
          if not passed and hasList then
            -- draw vertical separator line in center
            draw.RoundedBox(6, _w * detailAspect, style.margins.tb * 4, 2, _h - style.margins.tb * 5, style.color.pri)
            -- draw "description" text
            local descX = (_w * detailAspect) / 2
            draw.SimpleText(mitigationText, "nova_font_l", descX, style.margins.tb * 4, style.color.pri, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            -- draw "list" text
            local listX = _w - (_w * (1 - detailAspect)) / 2
            draw.SimpleText(listText, "nova_font_l", listX, style.margins.tb * 4, style.color.pri, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
          else 
            -- draw "description" text
            draw.SimpleText(mitigationText, "nova_font_l", _w * 0.5, style.margins.tb * 4, style.color.pri, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
          end
        end

        collapse:SetContents( detailPanel )
        
        if not passed and hasList then
          local propText = vgui.Create("DLabel")
          propText:SetFont("nova_font")
          propText:SetContentAlignment(7)
          propText:SetTextColor(style.color.ft)
          local text = ""
          for i = 1, #check.list do
            local prop = check.list[i]
            prop = TextWrap(prop, "nova_font", headerWidth * (1 - detailAspect) - style.margins.lr * 2, 4 )
            text = text .. string.format("  • %s\n", prop)
          end
          propText:SetText(text)
          propText:SizeToContents()
          propText:SetPos(headerWidth * detailAspect + style.margins.lr, style.margins.tb * 9)
          detailPanel:Add(propText)
        end

        local descText = vgui.Create("DLabel")
        descText:SetFont("nova_font")
        descText:SetContentAlignment(7)
        descText:SetTextColor(style.color.ft)
        descText:SetText(check.long_desc)
        descText:SizeToContents()
        if hasList then
          -- max width of detailAspect of the panel
          descText:SetWide(math.min(descText:GetWide(), headerWidth * detailAspect - style.margins.lr * 2))
        end
        descText:SetPos(style.margins.lr, style.margins.tb * 9)
        --descText:SetWrap(true)
        detailPanel:Add(descText)
        timer.Simple(1, function()if IsValid(detailPanel) then detailPanel:SizeToChildren(true, true) end end)
      end

      local failedTitle = vgui.Create("DLabel", self)
      failedTitle:Dock(TOP)
      failedTitle:DockMargin(style.margins.lr, percPanel:GetTall() + style.margins.tb * 2, style.margins.lr, 0)
      failedTitle:SetFont("nova_font_l")
      failedTitle:SetTextColor(style.color.pri)
      failedTitle:SetText(Lang("menu_elem_failed"))

      for k, v in pairs(data.failed, false) do
        CreateCheck(v)
      end

      local passedTitle = vgui.Create("DLabel", self)
      passedTitle:Dock(TOP)
      passedTitle:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
      passedTitle:SetFont("nova_font_l")
      passedTitle:SetTextColor(style.color.pri)
      passedTitle:SetText(Lang("menu_elem_passed"))

      for k, v in pairs(data.passed, true) do
        CreateCheck(v, true)
      end

      timer.Simple(0.1,function() if IsValid(self) then self:SizeToChildren(true, true) end end)
    end)
  end
  function PAGE_HEALTH:Paint(_w, _h) end
  vgui.Register("nova_admin_page_health", PAGE_HEALTH, "DPanel")

  local PAGE_INSPECTION = {}
  PAGE_INSPECTION.loading = true
  function PAGE_INSPECTION:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)
    local loading = vgui.Create( "DLabel", self )
    loading:Dock( TOP )
    loading:SetText("Loading code from server...")
    loading:SetFont("nova_font")
    loading:SetTextColor( style.color.pri )
    loading:DockMargin(style.margins.lr, style.margins.tb * 2, style.margins.lr * 2, style.margins.tb)
    net.Start("]] .. Nova.netmessage("admin_get_inspection") .. [[")
    net.SendToServer()
    timer.Create("nova_client_load_inspection", 0.1, 100, function()
      if vgui.Exists and not vgui.Exists("nova_admin_menu_inspection") then return end
      if vgui.GetControlTable and not vgui.GetControlTable("nova_admin_menu_inspection") then return end
      vgui.Register("nova_admin_page_inspection", vgui.GetControlTable("nova_admin_menu_inspection"), "DPanel")
      timer.Remove("nova_client_load_inspection")
      ReloadFrame()
    end)
    self:SizeToChildren(true, true)
  end
  function PAGE_INSPECTION:Paint(_w, _h) end
  vgui.Register("nova_admin_page_inspection", PAGE_INSPECTION, "DPanel")

  local PAGE_DETECTIONS = {}
  function PAGE_DETECTIONS:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)

    local curPage = 0
    local limitReached = false
    local HandlePageChange = nil

    local nav = vgui.Create("DPanel", self)
    nav:Dock(TOP)
    nav:SetMinimumSize( nil, style.margins.tb * 3)
    nav:DockMargin(0, 0, 0, style.margins.tb)
    nav.Paint = function(_, _w, _h) end

    local prevPage = vgui.Create("nova_admin_default_button", nav)
    prevPage:SetText(Lang("menu_elem_prev"))
    prevPage:SizeToContents()
    prevPage:Dock(LEFT)
    prevPage:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    surface.SetFont("nova_font")
    prevPage.DoClick = function()
      curPage = math.Clamp(curPage - 1, 0, 999999)
      LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage, ["steamid"] = self.searchvalue}, function(data)HandlePageChange(data) end)
    end

    local nextPage = vgui.Create("nova_admin_default_button", nav)
    nextPage:SetText(Lang("menu_elem_next"))
    nextPage:SizeToContents()
    surface.SetFont("nova_font")
    nextPage:Dock(LEFT)
    nextPage:DockMargin(0, 0, style.margins.lr, 0)
    nextPage.DoClick = function()
      curPage = curPage + 1
      LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage, ["steamid"] = self.searchvalue}, function(data)HandlePageChange(data) end)
    end

    local search = vgui.Create("nova_admin_option_text", nav)
    search:Dock(LEFT)
    search:DockMargin(0, 0, style.margins.lr, 0)
    search:GetChildren()[1]:Remove()
    search.entry:SetHeight(select(2, nav:GetSize()))
    search.entry.defaultColor = style.color.dis
    search:SetSize(style.margins.lr * 12, style.margins.tb * 5)
    local placeholderText = "SteamID32/SteamID64..."
    search.entry:SetValue(self.searchvalue and self.searchvalue or placeholderText)
    search.entry.OnGetFocus = function(val)
      if val:GetValue() == placeholderText then
        val:SetValue("") search.entry.defaultColor = style.color.ft
      end
    end
    search.entry.OnChangeDelayed = function(val)
      if self.searchvalue == "" and val:GetValue() == "" then return end
      self.searchvalue = val:GetValue()
      LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage, ["steamid"] = self.searchvalue}, function(data)HandlePageChange(data) end)
      curPage = 0 prevPage.DoClick(prevPage)
    end
    search.entry._finished = true

    local page = vgui.Create("DLabel", nav)
    page:DockMargin(0, 0, style.margins.lr, 0)
    page:Dock(LEFT)
    page:SetFont("nova_font")
    page:SetTextColor( style.color.ft )
    page:SetText(string.format(Lang("menu_elem_page"), self.page or 0))
    page:SizeToContents()

    local stats = vgui.Create("DLabel", nav)
    stats:DockMargin(0, 0, style.margins.lr, 0)
    stats:Dock(LEFT)
    stats:SetFont("nova_font")
    stats:SetTextColor( style.color.ft )
    stats:SetText(string.format(Lang("menu_elem_stats"), self.totalEntries or 0))
    stats:SizeToContents()

    local delete = vgui.Create("nova_admin_default_button", nav)
    delete.defaultColor = style.color.wrn
    delete:SetText(Lang("menu_elem_clear"))
    delete:SizeToContents()
    surface.SetFont("nova_font")
    delete:Dock(RIGHT)
    delete:DockMargin(0, 0, style.margins.lr, 0)
    delete.DoClick = function()
      LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage, ["action"] = "delete"}, function(data)HandlePageChange(data) end)
      curPage = 0 prevPage.DoClick(prevPage)
    end

    local deleteAll = vgui.Create("nova_admin_default_button", nav)
    deleteAll.defaultColor = style.color.dng
    deleteAll:SetText(Lang("menu_elem_clear_all"))
    deleteAll:SizeToContents()
    surface.SetFont("nova_font")
    deleteAll:Dock(RIGHT)
    deleteAll:DockMargin(0, 0, style.margins.lr, 0)
    deleteAll.DoClick = function()
      LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage, ["action"] = "delete_all"}, function(data)HandlePageChange(data) end)
      curPage = 0 prevPage.DoClick(prevPage) prevPage.DoClick(prevPage)
    end

    HandlePageChange = function(data)
      if not IsValid(self) then return end
      // clear old entries
      for k, v in pairs(self:GetChildren()) do
        if k > 1 and IsValid(v) then v:Remove() end
      end
      local curPage = data.page or curPage
      local numEntries = data.numEntries or 0
      limitReached = numEntries != #data.detections
      
      nextPage:SetDisabled(limitReached)
      prevPage:SetDisabled(curPage == 0)
      self.totalEntries = data.totalEntries
      self.page = data.page + 1
      page:SetText(string.format(Lang("menu_elem_page"), self.page or 0))
      page:SizeToContents()
      stats:SetText(string.format(Lang("menu_elem_stats"), self.totalEntries or 0))
      stats:SizeToContents()

      for k, v in ipairs(data.detections or {}) do
        local collapse = vgui.Create( "DCollapsibleCategory", self )
        collapse:SetLabel( "" )
        collapse:Dock(TOP)
        collapse:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
        collapse:SetHeaderHeight(style.margins.tb * 4)
        collapse:SetExpanded( false )

        local headerHeight = collapse:GetHeaderHeight()
        local headerWidth = select(1, self:GetSize()) - style.margins.lr * 2

        collapse.Paint = function(_, _w, _h)
          local isHovered = collapse.Header:IsHovered()
          local isExpanded = collapse:GetExpanded()
          draw.RoundedBox(6, 0, 0, _w, headerHeight, (isHovered or isExpanded) and style.color.pri or style.color.sec)
          if isHovered then
            if not collapse.playsound then surface.PlaySound("UI/buttonrollover.wav") collapse.playsound = true end
          else
            collapse.playsound = false
          end
        end
        local xPos = style.margins.lr
        local status = vgui.Create("nova_staff_tag", collapse)
        status.label:SetFont("nova_font")
        status.text = v.action_taken and Lang("menu_elem_mitigated") or Lang("menu_elem_unmitigated")
        status.color = v.action_taken and style.color.scc or style.color.dng
        status:SetPos(xPos, headerHeight / 2 - status:GetTall() / 2)
        surface.SetFont("nova_font")
        local wide = surface.GetTextSize(status.text) + style.margins.lr
        status:SetSize(wide,style.margins.tb * 2)
        xPos = xPos + wide + style.margins.lr

        local reason = vgui.Create("DLabel", collapse)
        reason:SetFont("nova_font")
        reason:SetTextColor(style.color.ft)
        reason:SetText( v.reason )
        reason:SetPos(xPos, headerHeight / 2 - reason:GetTall() / 2)
        reason:SizeToContents()
        wide = surface.GetTextSize(v.reason) + style.margins.lr
        xPos = xPos + wide + style.margins.lr

        local time = vgui.Create("DLabel", collapse)
        time:SetFont("nova_font")
        time:SetTextColor(style.color.ft)
        time:SetText( v.time )
        surface.SetFont("nova_font")
        local wide = surface.GetTextSize(v.time) + style.margins.lr
        time:SizeToContents()
        time:SetPos(headerWidth - wide, headerHeight / 2 - time:GetTall() / 2)

        local ply = player.GetBySteamID(v.steamid)
        xPos = xPos + style.margins.lr
        if IsValid(ply) then
          local avatar = vgui.Create("nova_staff_avatar", collapse)
          avatar:SetSize(style.margins.tb * 3, style.margins.tb * 3)
          avatar:SetMaskSize(style.margins.tb * 2 )
          avatar:SetPlayer(ply)
          avatar:SetPos(xPos, headerHeight / 2 - avatar:GetTall() / 2)
          xPos = xPos + avatar:GetWide() + style.margins.lr
        end
        
        local plyName = vgui.Create("DLabel", collapse)
        plyName:SetFont("nova_font")
        plyName:SetTextColor(IsValid(ply) and style.color.ft or style.color.dng)
        plyName:SetText( IsValid(ply) and ply:Nick() or "Offline" )
        plyName:SetPos(xPos, headerHeight / 2 - plyName:GetTall() / 2)
        plyName:SizeToContents()
        xPos = xPos + plyName:GetWide() + style.margins.lr

        local function CreateContent()
          if collapse._hasContent then return end
          collapse._hasContent = true

          local propList = vgui.Create( "DPanel", collapse )
          propList:Dock(FILL)
          propList:DockPadding(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
          propList.Paint = function(_, _w, _h)
            draw.RoundedBox(6, 0, 0, _w, _h, style.color.sec)
          end
          collapse:SetContents( propList )

          local lastYPos = style.margins.tb
          local function AddProperty(name, value)
            local prop = vgui.Create("DLabel", propList)
            prop:SetFont("nova_font")
            prop:SetText( string.format("%s: %s", name, value) )
            prop:SizeToContents()
            prop:SetTextColor(style.color.ft)
            local btn = vgui.Create("nova_admin_default_button", propList)
            btn:SetTooltip(value)
            btn.defaultColor = style.color.scc
            btn:SetText(Lang("menu_elem_copy"))
            btn:SizeToContents()
            prop:SetWide(math.Clamp(prop:GetWide(), 0, propList:GetWide() - style.margins.lr * 2 - btn:GetWide()))
            btn:SetPos(math.Clamp(style.margins.lr * 2 + prop:GetWide(), 0, propList:GetWide() - btn:GetWide() - style.margins.lr), lastYPos)
            lastYPos = lastYPos + style.margins.tb + btn:GetTall()
            btn.DoClick = function()
              SetClipboardText(value)
              surface.PlaySound("buttons/button15.wav")
            end

            prop:SetPos(style.margins.lr, btn:GetY() + btn:GetTall() / 2 - prop:GetTall() / 2)
          end

          local lastXPos = style.margins.lr
          
          local function AddAction(name, identifier, color, customClick, callback)
            local btn = vgui.Create("nova_admin_default_button", propList)
            btn.defaultColor = color or style.color.pri
            btn:SetText(Lang(name))
            btn:SizeToContents()
            btn:SetPos(lastXPos, lastYPos + style.margins.tb)
            surface.SetFont("nova_font")
            local btnTextWide = surface.GetTextSize(btn:GetText()) + style.margins.lr * 2
            -- check if we need to move to the next line
            if lastXPos + btnTextWide > (headerWidth - style.margins.lr * 2) then
              lastXPos = style.margins.lr
              lastYPos = lastYPos + style.margins.tb + btn:GetTall()
            else
              lastXPos = lastXPos + btn:GetWide() + style.margins.lr
            end
            btn.DoClick = function()
              surface.PlaySound("buttons/button15.wav")
              if isfunction(customClick) then customClick() return end
              if not identifier then
                callback(nil, btn)
                return
              end
              LoadData("]] .. Nova.netmessage("admin_get_players") .. [[", {["action"] = identifier, ["steamID"] = v.steamid}, function(_data)
                if not IsValid(self) then return end
                callback(_data, btn)
              end)
            end
          end

          AddProperty(Lang("steamid"), v.steamid)
          AddProperty(Lang("steamid64"), util.SteamIDTo64(v.steamid))
          AddProperty(Lang("comment"), v.comment)
          AddProperty(Lang("reason"), v.reason)
          if v.action_taken then 
            AddProperty(Lang("action_taken_at"), v.action_taken_at)
            AddProperty(Lang("action_taken_by"), v.action_taken_by)
          end
          AddAction("menu_elem_delete", "delete_id", style.color.dng, function()
            LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[",
            {["action"] = "delete_id", ["id"] = v.id, ["steamID"] = v.steamid},
            function(data)HandlePageChange(data) end)
            prevPage.DoClick(prevPage) prevPage.DoClick(prevPage)
          end)
          if not v.action_taken then 
            AddAction("menu_elem_ban", "ban", style.color.dng, function()
              LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[",
              {["action"] = "ban", ["id"] = v.id, ["steamID"] = v.steamid},
              function(data)HandlePageChange(data) end)
              prevPage.DoClick(prevPage) prevPage.DoClick(prevPage)
            end)
          end
          AddAction("menu_elem_profile", nil, nil, nil, function()
            gui.OpenURL(string.format("http://steamcommunity.com/profiles/%s", util.SteamIDTo64(v.steamid)))
          end)
        end
        collapse.OnToggle = function(_, expanded) 
          if expanded then CreateContent() end
          timer.Simple(collapse:GetAnimTime() + 0.1, function() if IsValid(self) then self:SizeToChildren(true, true) end end)
        end
      end
      timer.Simple(0.1,function() if IsValid(self) then self:SizeToChildren(true, true) end end)
    end

    LoadData("]] .. Nova.netmessage("admin_get_detections") .. [[", {["page"] = curPage}, function(data)HandlePageChange(data) end)
  end
  function PAGE_DETECTIONS:Paint(_w, _h) end
  vgui.Register("nova_admin_page_detections", PAGE_DETECTIONS, "DPanel")

  local PAGE_DDOS = {}
  PAGE_DDOS.loading = true
  function PAGE_DDOS:Init()
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)
    local loading = vgui.Create( "DLabel", self )
    loading:Dock( TOP )
    loading:SetText("Loading code from server...")
    loading:SetFont("nova_font")
    loading:SetTextColor( style.color.pri )
    loading:DockMargin(style.margins.lr, style.margins.tb * 2, style.margins.lr * 2, style.margins.tb)
    net.Start("]] .. Nova.netmessage("admin_get_ddos") .. [[")
    net.SendToServer()
    timer.Create("nova_client_load_ddos", 0.1, 100, function()
      if vgui.Exists and not vgui.Exists("nova_admin_menu_ddos") then return end
      if vgui.GetControlTable and not vgui.GetControlTable("nova_admin_menu_ddos") then return end
      vgui.Register("nova_admin_page_ddos", vgui.GetControlTable("nova_admin_menu_ddos"), "DPanel")
      timer.Remove("nova_client_load_ddos")
      ReloadFrame()
    end)
    self:SizeToChildren(true, true)
  end
  function PAGE_DDOS:Paint(_w, _h) end
  vgui.Register("nova_admin_page_ddos", PAGE_DDOS, "DPanel")

  

  --------------------------------
  --  Concommands
  --------------------------------

  concommand.Add("nova_defender", function()
    if NOVA_MENU or IsValid(NOVA_MENU) then
      NOVA_MENU:Remove()
      NOVA_MENU = nil
    end

    local function OpenMenu(data)
      NOVA_MENU = vgui.Create("nova_admin_menu")
      local content = vgui.Create("DPanel", NOVA_MENU)
      content:Dock(FILL)
      content.Paint = function(_, _w, _h) end

      local tab = vgui.Create( "nova_admin_menu_tab", content )
      tab:Dock( FILL )
      local sortedData = NOVA_PROTECTED and SortData(data) or {}

      local scrollPanel = vgui.Create( "nova_admin_scroll_panel", NOVA_MENU )
      scrollPanel:Dock( LEFT )

      local status = vgui.Create("nova_admin_menu_status", content)
      status:Load()

      -- add icon above menu buttons
      local icon = vgui.Create("DImageButton", scrollPanel)
      icon:SetImage("nova/icon.png")
      icon:Dock(TOP)
      icon:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
      icon:SetSize(scrollPanel:GetWide()-style.margins.lr*2, scrollPanel:GetWide()-style.margins.lr*2)
      icon.DoClick = function() if IsValid(tab) then tab:Clear() NOVA_ACTIVE_TAB = nil end end

      local icon = vgui.Create("DImageButton", tab)
      icon:SetPos(tab:GetWide() - 70 - style.margins.lr * 4, style.margins.tb * 2)
      icon:SetImage("nova/discord.png")
      icon:SetSize(70,70)
      icon:SetZPos( 100 )
      icon.DoClick = function() gui.OpenURL("https://discord.gg/zEMuB6kN9g") end

      local discordText = vgui.Create("DLabel", tab)
      discordText:SetFont("nova_font")
      discordText:SetTextColor(style.color.ft)
      discordText:SetText(Lang("menu_elem_discord"))
      surface.SetFont("nova_font")
      local textWide = surface.GetTextSize(discordText:GetText())
      discordText:SetPos(icon:GetX() + icon:GetWide() / 2 - textWide / 2, icon:GetY() + icon:GetTall() + style.margins.tb)
      discordText:SizeToContents()

      local generalLabel = vgui.Create("DLabel", scrollPanel)
      generalLabel:Dock(TOP)
      generalLabel:SetContentAlignment(5)
      generalLabel:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb)
      generalLabel:SetFont("nova_font")
      generalLabel:SetTextColor(style.color.ft)
      generalLabel:SetText(Lang("menu_elem_general"))
      
      for k, v in pairs(tabs or {}) do
        if not v.custom then continue end
        CreateMenuButton(scrollPanel, tab, k, v)
      end

      -- create settings label
      if NOVA_PROTECTED then
        local settingsLabel = vgui.Create("DLabel", scrollPanel)
        settingsLabel:Dock(TOP)
        settingsLabel:SetContentAlignment(5)
        settingsLabel:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
        settingsLabel:SetFont("nova_font")
        settingsLabel:SetTextColor(style.color.ft)
        settingsLabel:SetText(Lang("menu_elem_settings"))
      end

      -- create custom tabs
      for k, v in pairs(sortedData or {}) do
        CreateMenuButton(scrollPanel, tab, k, v)
      end

      -- if a tab was already opened, select it again
      if NOVA_ACTIVE_TAB and (sortedData[NOVA_ACTIVE_TAB] or tabs[NOVA_ACTIVE_TAB]) then
        timer.Simple(0.4, function()
          ChangeTab(NOVA_ACTIVE_TAB, tab, sortedData[NOVA_ACTIVE_TAB] or {})
        end)
      end
    end

    local function LoadSettings()
      if NOVA_PROTECTED then
        LoadData("]] .. Nova.netmessage("admin_get_setting") .. [[", nil, function(data) OpenMenu(data) end)
      else
        OpenMenu()
      end
    end

    -- if we don't have language data, we need to load it first
    if not NOVA_LANG then
      LoadData("]] .. Nova.netmessage("admin_get_language") .. [[", nil, function(data)
        if not isstring(data) then return end
        NOVA_LANG = NOVA_SHARED["languages_" .. data]  or {}
        LoadSettings()
      end)
    else
      LoadSettings()
    end
  end)]]
    return payload
end

Nova.getInspectionPayload = function()
  local payload = [[
  NOVA_INSPECTION_HISTORY = NOVA_INSPECTION_HISTORY or {}
  local sw, sh = ScrW(), ScrH()
  local style = {
    banner = Material("materials/nova/banner.png", "noclamp smooth"),
    frame = {
      w = 0.65 * sw, -- absolute width of the frame
      h = 0.7 * sh, -- absolute height of the frame
    },
    tab = {
      w = 0.55 * sw, -- absolute width of the tab
    },
    margins = {
      tb = 0.01 * sh, -- margin top and bottom
      lr = 0.01 * sw, -- margin left and right
    },
    color = {
      pri = Color(126, 38, 241), -- primary color
      pri2 = Color(86, 238, 244), -- primary color
      sec = Color(35, 39, 60), -- secondary color
      dis = Color(81, 88, 94), -- disabled color
      bg = Color(11, 12, 27), -- background color
      ft = Color(255, 255, 255), -- font color
      dng = Color(220, 53, 69), -- danger color
      scc = Color(40, 167, 69), -- success color
      wrn = Color(198, 148, 0), -- warning color
      tr = Color(0, 0, 0, 0), -- transparent color
      paint_tr = function(_, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, Color(0, 0, 0, 0))
      end
    }
  }

  local timeShort = "]] .. Nova.config["language_time_short"] .. [["
  local timeLong = "]] .. Nova.config["language_time"] .. [["

  local function Lang(lang_key)
    if not NOVA_LANG then return lang_key end
    if not NOVA_LANG[lang_key] then
      if lang_key then print("Nova Defender: Missing language key '" .. tostring(lang_key or "NO_VALUE") .. "'") end
      return lang_key
    end
    return NOVA_LANG[lang_key]
  end

  local function DrawCircle( x, y, radius, seg )
    local cir = {}
    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
      local a = math.rad( ( i / seg ) * -360 )
      table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end
    local a = math.rad( 0 )
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    surface.DrawPoly( cir )
  end

  local function SendData(action, ...)
    net.Start("]] .. Nova.netmessage("admin_get_inspection") .. [[")
        net.WriteString(action)
        for k, v in ipairs({...}) do
          net.WriteString(v)
        end
    net.SendToServer()
  end

  local EDITOR_BOX = {}
  function EDITOR_BOX:Init()
    self.text = Lang("menu_elem_no_data")
    
    self:SetSize(style.frame.w, style.frame.h)
    self:Center()
    self:SetSizable(true)
    self:SetTitle("")
    self:ShowCloseButton(false)
    self.Paint = function(_, _w, _h)
      draw.RoundedBox(4, 0, 0, _w, _h, style.color.pri)
      draw.RoundedBox(4, 2, 2, _w-4, _h-4, style.color.bg)
    end

    local topContainer = vgui.Create("DPanel", self)
    topContainer:Dock(TOP)
    topContainer.Paint = style.color.paint_tr

    local path = vgui.Create("DLabel", topContainer)
    path:SetFont("nova_font")
    path:SetTextColor(style.color.ft)
    path:Dock(LEFT)
    path:DockMargin(style.margins.lr, 0, 0, 0)
    self.path = path
    local time = vgui.Create("DLabel", topContainer)
    time:SetFont("nova_font")
    time:SetTextColor(style.color.ft)
    time:Dock(LEFT)
    time:DockMargin(style.margins.lr, 0, 0, 0)
    self.time = time
    local size = vgui.Create("DLabel", topContainer)
    size:SetFont("nova_font")
    size:SetTextColor(style.color.ft)
    size:Dock(LEFT)
    size:DockMargin(style.margins.lr, 0, 0, 0)
    self.size = size


    local close = vgui.Create("nova_admin_menu_button", topContainer)
    close.defaultColor = style.color.dng
    close:SetText(Lang("menu_elem_close"))
    close:SizeToContents()
    close:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    close:Dock(RIGHT)
    close.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Close()
    end

    local copy = vgui.Create("nova_admin_menu_button", topContainer)
    copy.defaultColor = style.color.scc
    copy:SetText(Lang("menu_elem_copy"))
    copy:SetTooltip(self.text)
    copy:SizeToContents()
    copy:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    copy:Dock(RIGHT)
    copy.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      SetClipboardText(self.rawText or "")
    end
    self.copy = copy

    local textEntry = vgui.Create("RichText", self)
    textEntry:Dock(FILL)
    textEntry:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
    textEntry.Paint = function(self, w, h)
      draw.RoundedBox(4, 0, 0, w, h, style.color.sec)
    end
    self.textEntry = textEntry
    self:MakePopup()
  end
  function EDITOR_BOX:SetText(text)
    if not text or text == "" then text = Lang("menu_elem_no_data") end
    self.rawText = text
    self.textEntry:Clear()
    self.textEntry:InsertColorChange(255, 255, 255, 255)
    self.textEntry:AppendText(text)
    self.copy:SetTooltip(text)
  end
  function EDITOR_BOX:SetProperties(path, time, size)
    self.path:SetText(path)
    self.path:SizeToContents()
    self.time:SetText(string.format(Lang("menu_elem_filetime"), os.date(timeLong, time)))
    self.time:SizeToContents()
    local size = tonumber(size)
    if size < 1024 then
      size = string.format("%i B", size)
    elseif size < 1024 * 1024 then
      size = string.format("%.2f KB", size / 1024)
    elseif size < 1024 * 1024 * 1024 then
      size = string.format("%.2f MB", size / 1024 / 1024)
    else
      size = string.format("%.2f GB", size / 1024 / 1024 / 1024)
    end
    self.size:SetText(string.format(Lang("menu_elem_filesize"), size))
    self.size:SizeToContents()
  end
  function EDITOR_BOX:Error(err)
    self.rawText = err
    self.textEntry:Clear()
    self.textEntry:InsertColorChange(style.color.dng.r, style.color.dng.g, style.color.dng.b, style.color.dng.a)
    self.textEntry:AppendText(err)
    self.copy:SetTooltip(err)
  end
  vgui.Register("nova_admin_editor", EDITOR_BOX, "DFrame")

  local DOWNLOAD_BOX = {}
  function DOWNLOAD_BOX:Init()
    self:SetSize(style.frame.w / 1.5, style.frame.h / 3)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self.Paint = function(_, _w, _h)
      draw.RoundedBox(4, 0, 0, _w, _h, style.color.pri)
      draw.RoundedBox(4, 2, 2, _w-4, _h-4, style.color.bg)
    end
    self:MakePopup()
  end
  function DOWNLOAD_BOX:Download(path)
    local confirmationText = vgui.Create("DLabel", self)
    confirmationText:SetFont("nova_font")
    confirmationText:SetTextColor(style.color.ft)
    confirmationText:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, style.margins.tb)
    confirmationText:SetText(string.format(Lang("menu_elem_download_confirm"), path))
    confirmationText:SizeToContents()
    confirmationText:Dock(TOP)
    self.text = confirmationText

    local confirmation = vgui.Create("nova_admin_default_button", self)
    local cancel = vgui.Create("nova_admin_default_button", self)
    confirmation.defaultColor = style.color.scc
    confirmation:DockMargin( style.frame.w / 4, style.margins.tb, style.frame.w / 4 , 0 )
    confirmation:SetText(Lang("menu_elem_download_confirmbutton"))
    confirmation:SizeToContents()
    --confirmation:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    confirmation:Dock(TOP)
    confirmation.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      confirmation:Remove()
      cancel:Remove()
      self:StartDownload(path)
    end
    cancel.defaultColor = style.color.dng
    cancel:SetText(Lang("menu_elem_cancel"))
    cancel:DockMargin( style.frame.w / 4, style.margins.tb, style.frame.w / 4, 0 )
    cancel:SizeToContents()
    --cancel:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    cancel:Dock(TOP)
    cancel.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Close()
    end

  end
  function DOWNLOAD_BOX:Finish(dlPath, aborted, err)
    local text = aborted and "menu_elem_download_finished_part" or "menu_elem_download_finished"
    if err then
      text = string.format(Lang("menu_elem_download_failed"), err)
      self.text:SetTextColor(style.color.dng)
    end
    self.text:SetText(string.format(Lang(text), err and err or ("/data/" .. self.downloadPath)))
    self.text:SizeToContents()
    self.progress:Remove()
    self.progressText:Remove()
    self.cancel:Remove()
    if self.canceldel then self.canceldel:Remove() end
    local close = vgui.Create("nova_admin_default_button", self)
    close.defaultColor = style.color.scc
    close:SetText(Lang("menu_elem_close"))
    close:SizeToContents()
    --close:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    close:Dock(TOP)
    close:DockMargin( style.frame.w / 4, style.margins.tb, style.frame.w / 4, 0 )
    close.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Close()
    end
  end
  local writeableExtensions = {"txt", "dat", "json", "xml", "csv", "jpg", "jpeg", "png", "vtf", "vmt", "mp3", "wav", "ogg", "vcd", "dem"}
  function DOWNLOAD_BOX:StartDownload(path)
    SendData("download_file", path, "0")
    local dir = string.format("nova/downloads/%s", NOVA_INSPECTION:SteamID64())
    self.path = path
    self.downloadPath = string.format("nova/downloads/%s/%s", NOVA_INSPECTION:SteamID64(), self.path)
    local extension = string.GetExtensionFromFilename(self.downloadPath)
    if not table.HasValue(writeableExtensions, extension) then
      self.downloadPath = self.downloadPath .. ".txt"
    end
    file.CreateDir(dir)
    local pathDir = string.Explode("/", self.downloadPath)
    table.remove(pathDir, #pathDir)
    pathDir = table.concat(pathDir, "/")
    file.CreateDir(pathDir)
    self.text:SetText(string.format(Lang("menu_elem_download_started"), path))
    
    local progress = vgui.Create("DPanel", self)
    progress:DockMargin(style.margins.lr, style.margins.tb, style.margins.lr, 0)
    progress:Dock(TOP)
    progress:SetSize(0, style.margins.tb * 2)
    progress.progress = 0
    progress.Paint = function(_, _w, _h)
      draw.RoundedBox(2, 0, 0, _w, _h, style.color.sec)
      draw.RoundedBox(4, 0, 0, _w * progress.progress, _h, style.color.pri)
    end
    self.progress = progress
    local progressText = vgui.Create("DLabel", progress)
    progressText:SetFont("nova_font")
    progressText:SetTextColor(style.color.ft)
    progressText:SetText("...")
    progressText:Dock(TOP)
    progressText:DockMargin(style.margins.lr, 0, style.margins.lr, 0)
    self.progressText = progressText
    local cancel = vgui.Create("nova_admin_default_button", self)
    cancel.defaultColor = style.color.dng
    cancel:SetText(Lang("menu_elem_cancel"))
    cancel:SizeToContents()
    --cancel:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    cancel:Dock(TOP)
    cancel:DockMargin( style.frame.w / 4, style.margins.tb, style.frame.w / 4, 0 )
    cancel.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      self:Finish(self.downloadPath, true)
    end
    self.cancel = cancel
    local canceldel = vgui.Create("nova_admin_default_button", self)
    canceldel.defaultColor = style.color.dng
    canceldel:SetText(Lang("menu_elem_canceldel"))
    --canceldel:SetMinimumSize(style.margins.tb * 7,style.margins.tb * 2)
    canceldel:SizeToContents()
    canceldel:Dock(TOP)
    canceldel:DockMargin( style.frame.w / 4, style.margins.tb, style.frame.w / 4, 0 )
    canceldel.DoClick = function()
      surface.PlaySound("buttons/button15.wav")
      file.Delete(self.downloadPath)
      self:Close()
    end
    self.canceldel = canceldel
  end
  function DOWNLOAD_BOX:CheckStatus(current, total, dlPath)
    if not IsValid(self) then return end
    if not IsValid(self.progress) then return end
    self.progress.progress = current / total
    self.progressText:SetText(string.format(Lang("menu_elem_download_progress"), current, total))
    current = tonumber(current) + 1
    if current < total then
      timer.Simple(0.5, function()
        if not IsValid(self) then return end
        SendData("download_file", self.path, tostring(current))
      end)
    else
      self.Finish(self, dlPath)
    end
  end
  function DOWNLOAD_BOX:Update(current, total, chunkdata, err)
    if not IsValid(self) then return end
    if not self.progress then return end
    if err then
      self:Finish(self.downloadPath, true, err)
      return
    end
    if not file.Exists(self.downloadPath, "DATA") or current == 0 then
      file.Write(self.downloadPath, chunkdata)
    else
      file.Append(self.downloadPath, chunkdata)
    end
    self.CheckStatus(self, current, total, self.downloadPath)
  end
  vgui.Register("nova_admin_download", DOWNLOAD_BOX, "DFrame")

  local PAGE_INSPECTION = {}

  function PAGE_INSPECTION:Init()
    local function Reload()
      if not IsValid(self) then return end
      for k, v in pairs(self:GetChildren()) do if IsValid(v) then v:Remove() end end
      self:Init()
    end
  
    self:Dock(FILL)
    self:DockMargin(style.margins.lr, 0, style.margins.lr, style.margins.tb * 2)

    local container = vgui.Create("DPanel", self)
    container:SetSize(style.tab.w - style.margins.lr * 3, NOVA_STYLE_TAB_INNERHEIGHT - style.margins.tb * 2)
    container.Paint = style.color.paint_tr
    
    local statusBar = vgui.Create("DPanel", container)
    statusBar:Dock(TOP)
    statusBar:SetSize(0, style.margins.tb * 4)
    statusBar.Paint = function(_, _w, _h)
      draw.RoundedBox(0, 0, 0, _w, _h, style.color.sec)
    end

    local connect = vgui.Create("nova_admin_default_button", statusBar)
    connect:DockMargin( 0, style.margins.tb, style.margins.lr, style.margins.tb )
    connect:SetText(NOVA_INSPECTION and Lang("menu_elem_disconnect") or Lang("menu_elem_connect"))
    connect.defaultColor = style.color.pri
    connect:SizeToContents()
    connect:Dock(RIGHT)
    
    local playerSelection
    if not IsValid(NOVA_INSPECTION) then
      playerSelection = vgui.Create("nova_admin_default_combobox", statusBar)
      playerSelection:SetSize(style.margins.lr * 10, style.margins.tb * 2)
      playerSelection:Dock(RIGHT)
      playerSelection:SetValue(Lang("menu_elem_select_player"))
      for k, v in pairs(player.GetHumans()) do
        playerSelection:AddChoice(v:Nick(), v:SteamID())
      end
    end

    connect.DoClick = function()
      if not IsValid(NOVA_INSPECTION) then
        local _, steamid = playerSelection:GetSelected()
        if not steamid then return end
        local ply = player.GetBySteamID(steamid)
        if not IsValid(ply) then return end
        NOVA_INSPECTION = ply
        SendData("open", steamid)
      else
        NOVA_INSPECTION = nil
        SendData("close")
      end
      Reload()
    end

    if IsValid(NOVA_INSPECTION) then
      local avatar = vgui.Create("nova_staff_avatar", statusBar)
      avatar:Dock(LEFT)
      avatar:SetSize(statusBar:GetTall() * 0.9, statusBar:GetTall() * 0.9)
      avatar:SetMaskSize(statusBar:GetTall() * 0.55 )
      avatar:SetPlayer(NOVA_INSPECTION)
      avatar:DockMargin(style.margins.lr, statusBar:GetTall() * 0.1, style.margins.lr, statusBar:GetTall() * 0.1)
      
      local plyName = vgui.Create("DLabel", statusBar)
      plyName:Dock(LEFT)
      plyName:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      plyName:SetFont("nova_font")
      plyName:SetTextColor(style.color.ft)
      plyName:SetText(NOVA_INSPECTION:Nick())
      plyName:SizeToContents()

      local circle = vgui.Create("DPanel", statusBar)
      circle:Dock(LEFT)
      circle:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      circle:SetSize(statusBar:GetTall() * 0.9, statusBar:GetTall() * 0.9)
      circle.color = style.color.scc
      circle.Paint = function(self, _w, _h)
        draw.NoTexture()
        surface.SetDrawColor(self.color)
        if self.color == style.color.scc then
          DrawCircle(_w / 2, _h / 2, _w / 6, 10)
        else
          DrawCircle(_w / 2, _h / 2, _w / 6 + math.sin(RealTime() * 5) * _w / 19, 10)
        end
      end
      self.circle = circle

      local fps = vgui.Create("DLabel", statusBar)
      fps:Dock(LEFT)
      fps:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      fps:SetFont("nova_font")
      fps:SetTextColor(style.color.ft)
      fps:SetText("")
      self.fps = fps

      local ram = vgui.Create("DLabel", statusBar)
      ram:Dock(LEFT)
      ram:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      ram:SetFont("nova_font")
      ram:SetTextColor(style.color.ft)
      ram:SetText("")
      self.ram = ram

      local ping = vgui.Create("DLabel", statusBar)
      ping:Dock(LEFT)
      ping:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      ping:SetFont("nova_font")
      ping:SetTextColor(style.color.ft)
      ping:SetText("")
      self.ping = ping

      local active = vgui.Create("DLabel", statusBar)
      active:Dock(LEFT)
      active:DockMargin(0, style.margins.tb, style.margins.lr, style.margins.tb)
      active:SetFont("nova_font")
      active:SetTextColor(style.color.ft)
      active:SetText("")
      self.active = active
    end
    
    local content = vgui.Create("DPanel", container)
    content:Dock(FILL)
    content:DockMargin(0, style.margins.tb, 0, 0)
    content.Paint = style.color.paint_tr
  
    local fileexplorer = vgui.Create("DPanel", content)
    fileexplorer.Paint = style.color.paint_tr

    local humanReadable = {"lua", "txt", "cfg", "sh", "db", "bat", "xml", "json", "conf", "csv", "log"}
    local fileOperations = vgui.Create("DPanel", fileexplorer)
    fileOperations:Dock(BOTTOM)
    fileOperations:DockMargin(0, style.margins.tb, style.margins.lr, 0)
    fileOperations.Paint = style.color.paint_tr
    local view = vgui.Create("nova_admin_default_button", fileOperations)
    view:SetText(Lang("menu_elem_view"))
    view.defaultColor = style.color.pri
    view:SizeToContents()
    view:DockMargin(0, 0,0,0)
    view:Dock(LEFT)
    view:SetEnabled(false)
    view.DoClick = function(s)
      if not IsValid(s) then return end
      local path = s.path
      if not path then return end
      SendData("open_file", path)
    end
    local download = vgui.Create("nova_admin_default_button", fileOperations)
    download:DockMargin(style.margins.tb, 0,0,0)
    download:SetText(Lang("menu_elem_download"))
    download.defaultColor = style.color.pri
    download:SizeToContents()
    download:Dock(LEFT)
    download:SetEnabled(false)
    download.DoClick = function(s)
      if not IsValid(s) then return end
      local path = s.path
      if not path then return end
      local dlFrame = vgui.Create("nova_admin_download", NOVA_MENU)
      self.dlFrame = dlFrame
      dlFrame:Download(path)
    end
  
    local browser = vgui.Create("DTree", fileexplorer)
    browser:Dock(FILL)
    browser.Paint = function(_, _w, _h)
      draw.RoundedBox(4, 0, 0, _w, _h, style.color.sec)
    end
    browser.queue = {}
    browser.discovered = false
    browser.fullpath = ""

    -- paint scrollbar
    local sb = browser:GetVBar()
    sb.Paint = style.color.paint_tr
    sb.btnUp.Paint = sb.Paint
    sb.btnDown.Paint = sb.Paint
    sb.btnGrip.Paint = function(self, _w, _h)
      draw.RoundedBox(4, _w / 5, 0, _w * 0.5, _h, style.color.pri)
    end

    local blacklistDirs = {
      "^garrysmod/addons/",
    }
  
    local function OpenFolder(folderNode)
      if not IsValid(self) then return end
      if not IsValid(folderNode) then return end
      if folderNode.discovered or folderNode.awaiting then return end
      folderNode.awaiting = true
      local path = folderNode.fullpath
      if browser.queue[path] then return end
      local loading = folderNode:AddNode( "" )
      browser.queue[path] = {loading = loading, folder = folderNode}
      loading.Icon:SetImage( "icon16/arrow_refresh.png" )
      loading.Icon.PaintAt = function(self, x, y, dw, dh)
        dw, dh = dw or self:GetWide(), dh or self:GetTall()
        local rot = -RealTime() * 180 % 360
        self:LoadMaterial()
        if not self.m_Material then return true end
        surface.SetMaterial( self.m_Material )
        surface.SetDrawColor( self.m_Color.r, self.m_Color.g, self.m_Color.b, self.m_Color.a )
        surface.DrawTexturedRectRotated( x + dw / 2, y + dh / 2, dw, dh, rot )
        return true
      end
      -- block addons folder for privacy concerns
      -- this can easily get bypassed, but also implemented from scratch
      for k, pattern in ipairs(blacklistDirs) do
        if string.match( path, pattern) then
          local queue = browser.queue[path]
          if IsValid(loading) then loading:Remove() end
          folderNode.discovered = true
          folderNode.awaiting = nil
          local node = folderNode:AddNode( "Hidden by Nova Defender" )
          local fullPath = string.format("%s%s", path, v)
          node.fullpath = fullPath
          node.Icon:SetImage( "icon16/cancel.png" )
          return
        end
      end
      SendData("open_folder", path)
    end

    local fileExtensionIcons = {
      ["lua"] = "icon16/page_white_code.png",
      ["log"] = "icon16/chart_bar.png",
      ["txt"] = "icon16/page_white_text.png",
      ["db"] = "icon16/page_white_database.png",
      ["exe"] = "icon16/application_xp_terminal.png",
      ["so"] = "icon16/application_xp_terminal.png",
      ["sh"] = "icon16/application_xp_terminal.png",
      ["dat"] = "icon16/page_white_database.png",
      ["cfg"] = "icon16/page_white_gear.png",
      ["zip"] = "icon16/compress.png",
      ["ttf"] = "icon16/font.png",
      ["otf"] = "icon16/font.png",
      ["woff"] = "icon16/font.png",
      ["eot"] = "icon16/font.png",
      ["svg"] = "icon16/page_white_vector.png",
      ["jpg"] = "icon16/page_white_camera.png",
      ["png"] = "icon16/page_white_camera.png",
      ["jpeg"] = "icon16/page_white_camera.png",
      ["jpg"] = "icon16/page_white_camera.png",
      ["png"] = "icon16/page_white_camera.png",
      ["jpeg"] = "icon16/page_white_camera.png",
    }
    local function Append(path, folders, files)
      if not IsValid(self) or not path then return end
      local queue = browser.queue[path]
      if not queue then return end
      if IsValid(queue.loading) then queue.loading:Remove() end
      queue.folder.discovered = true
      queue.folder.awaiting = nil
      if table.Count(folders) == 0 then
        queue.folder.DoClick = function() end
      end
      for k, v in ipairs(folders or {}) do
        local node = queue.folder:AddNode( v )
        node.fullpath = string.format("%s%s/", path, v)
        node.Icon:SetImage( "icon16/folder.png" )
        node.Label.DoDoubleClick = function()end
        node.DoClick = function(self)
          view:SetEnabled(false)
          download:SetEnabled(false)
          if not self.discovered then OpenFolder(self) end
          if self.discovered and not self:GetChildNodeCount() == 0 then return end
          self:SetExpanded( not self:GetExpanded() )
        end
      end
      for k, v in ipairs(files or {}) do
        local node = queue.folder:AddNode( v )
        local fullPath = string.format("%s%s", path, v)
        node.fullpath = fullPath
        local ext = string.GetExtensionFromFilename(v)
        node.Icon:SetImage( fileExtensionIcons[ext] or "icon16/page_white.png" )
        node.Label.DoDoubleClick = function(self)
          if not IsValid(self) then return end
          local path = self:GetParent().fullpath
          if not path then return end
          SendData("open_file", path)
        end
        node.Label.DoClick = function()
          local ext = string.GetExtensionFromFilename(v) or ""
          view:SetEnabled(table.HasValue(humanReadable, ext))
          view.path = fullPath
          download:SetEnabled(true)
          download.path = fullPath
        end
      end
      browser.queue[path] = nil
    end

    local shell = vgui.Create("DPanel", content)
    shell.Paint = style.color.paint_tr
  
    local output = vgui.Create("RichText", shell)
    output:Dock(FILL)
    output:DockMargin(0, 0, 0, style.margins.tb)
    output.Paint = function(self, w, h)
      draw.RoundedBox(4, 0, 0, w, h, style.color.sec)
    end
    output.PerformLayout = function(self)
      self:SetFontInternal("nova_font")
    end
    local function AddOutput(text, response, success)
      if not IsValid(output) then return end
      if response then
        local color = success and style.color.pri2 or style.color.dng
        output:InsertColorChange(color.r, color.g, color.b, color.a)
        output:AppendText(string.format("%s\n", text))
      else
        local timeDisplay = os.date(timeShort, os.time())
        local color = style.color.dis
        output:InsertColorChange(color.r, color.g, color.b, color.a)
        output:AppendText(string.format("%s: ", timeDisplay))
        color = success and style.color.scc or style.color.dng
        if success == nil then color = style.color.ft end
        output:InsertColorChange(color.r, color.g, color.b, color.a)
        output:AppendText(string.format("%s\n", text))
      end
    end
    
    local _input = vgui.Create("DPanel", shell)
    _input:Dock(BOTTOM)
    _input.Paint = style.color.paint_tr
  
    local inputText = vgui.Create("DTextEntry", _input)
    local defaultText = Lang("menu_elem_input_command")
    inputText:Dock(FILL)
    inputText:DockMargin( 0, 0, style.margins.tb, 0 )
    inputText:SetSkin("Default")
    inputText:SetEnabled(IsValid(NOVA_INSPECTION) and true or false)
    inputText:SetText(defaultText)
    inputText:SetFont("nova_font")
    inputText:SetPaintBackground(true)
    inputText:SetCursorColor( style.color.bg )
    inputText:SetTextColor( style.color.bg )
    if not table.IsEmpty(NOVA_INSPECTION_HISTORY) then
      inputText.History = NOVA_INSPECTION_HISTORY
    end
    inputText.Paint = function(self, w, h)
      draw.RoundedBox(4, 0, 0, w, h, style.color.sec)
      self:DrawTextEntryText(style.color.ft, style.color.pri, style.color.pri)
    end
    inputText:SetHistoryEnabled(true)
    inputText.OnGetFocus = function(self)
      if not IsValid(NOVA_INSPECTION) then return end
      if self:GetText() == defaultText then self:SetText("") end
    end
    inputText.OnChange = function(self)
      if not IsValid(self) or not IsValid(self.Menu) then return end
      self.Menu.Paint = function(_, _w, _h) draw.RoundedBox(2, 0, 0, _w, _h, style.color.sec) end
      for _, v in pairs(self.Menu:GetChildren()[1]:GetChildren()) do
        v:SetTextColor(style.color.ft)
        v.Paint = function(_, _w, _h)
          if not v.Hovered then return end
          draw.RoundedBox(2, 0, 0, _w, _h, style.color.pri)
        end
      end
    end
    inputText.GetAutoComplete = function(self, text)
      NOVA_INSPECTION_HISTORY = self.History
      if not text or text == "" then return self.History end
      local text = string.Trim(string.lower(text))
      local suggestions = {}
      for k, v in pairs(self.History) do
        if string.find(string.lower(v), text, 1, true) then
          table.insert(suggestions, v)
        end
      end
      return suggestions
    end
    inputText.FocusNext = function() end
    inputText.OnEnter = function(self, val)
      if not IsValid(NOVA_INSPECTION) then return end
      if val == "" then return end
      self:AddHistory(val)
      self:SetText("")
      AddOutput(val, false)
      SendData("exec", val)
    end

    local help = vgui.Create("nova_admin_default_button", _input)
    help:DockMargin( 0, 0, style.margins.tb, 0 )
    help:SetText(Lang("menu_elem_help"))
    help.defaultColor = style.color.sec
    help:SizeToContents()
    help:Dock(RIGHT)
    help.DoClick = function()
      local helpFrame = vgui.Create("nova_admin_detail_frame", NOVA_MENU)
      helpFrame:SetText(Lang("menu_elem_exec_help"), Lang("menu_elem_help"))
    end

    local submit = vgui.Create("nova_admin_default_button", _input)
    submit:DockMargin( 0, 0, style.margins.tb, 0 )
    submit:SetText(Lang("menu_elem_submit"))
    submit.defaultColor = style.color.pri
    submit:SizeToContents()
    submit:Dock(RIGHT)
    submit:SetEnabled(IsValid(NOVA_INSPECTION) and true or false)
    submit.DoClick = function()
      if not IsValid(NOVA_INSPECTION) then return end
      inputText:OnEnter(inputText:GetText())
    end

    local div = vgui.Create( "DHorizontalDivider", content )
    div:Dock( FILL )
    div:SetDividerWidth( style.margins.tb )
    div:SetLeftWidth( style.tab.w / 4)
    div:SetLeftMin( style.tab.w / 8)
    div:SetRightMin( style.tab.w / 6)
    div.Paint = style.color.paint_tr
    -- paint the divider
    div.m_DragBar.Paint = function(self, _w, _h)
        surface.SetDrawColor(style.color.pri)
        -- draw line from middle top to middle bottom
        surface.DrawLine(_w / 2, _h * 0.35, _w / 2, _h * 0.65)
    end

	  div:SetLeft( fileexplorer )
    div:SetRight( shell )

    self:SizeToChildren(true, true)

    local actions = {
      ["close"] = function(response)
        NOVA_INSPECTION = nil
        Reload()
      end,
      ["status"] = function(response)
        if not IsValid(NOVA_INSPECTION) then return end
        if not IsValid(self) or not self.fps then
          NOVA_INSPECTION = nil
          SendData("close")
          return
        end
        if not response then return end
        local data = util.JSONToTable(response)
        if not data then return end
        if data.connected and data.activated then
          self.fps:SetText("FPS: " .. (data.fps or ""))
          self.fps:SizeToContents()
          self.ram:SetText(string.format("RAM: %.3f MB", (data.ram or 0) / 1024))
          self.ram:SizeToContents()
          self.ping:SetText("Ping: " .. (data.ping or "") .. " ms")
          self.ping:SizeToContents()
          self.circle.color = style.color.scc
          self.active:SetText(data.focus and Lang("menu_elem_focus") or Lang("menu_elem_nofocus"))
          self.active:SizeToContents()
        elseif data.connected and not data.activated then
          self.circle.color = style.color.dng
        elseif not data.connected then
          AddOutput(Lang("menu_elem_exec_clientclose"), false, false)
          self.circle.color = style.color.ft
          self.active:SetText(Lang("menu_elem_disconnected"))
          self.active:SizeToContents()
        end
        if not browser.discovered then OpenFolder(browser) end
      end,
      ["open_folder"] = function(response)
        local data = util.JSONToTable(response)
        if not data then return end
        Append(data.path, data.folders, data.files)
      end,
      ["open_file"] = function(response)
        local data = util.JSONToTable(response)
        if not data then return end
        local detailFrame = vgui.Create("nova_admin_editor", NOVA_MENU)
        detailFrame:SetProperties(data.path or "ERROR", data.time or 0, data.size or 0)
        if data.err then detailFrame:Error(data.err) return end
        detailFrame:SetText(data.content)
      end,
      ["download_file"] = function(response)
        local data = util.JSONToTable(response)
        if not data then return end
        if not IsValid(self.dlFrame) then return end
        self.dlFrame:Update(data.cur, data.total, data.content, data.err)
      end,
      ["ack"] = function(response)
        OpenFolder(browser)
        AddOutput(Lang("menu_elem_exec_clientopen"), false, true)
      end,
      ["exec"] = function(response)
        response = util.JSONToTable(response)
        if not response then AddOutput(Lang("menu_elem_exec_error"), true, false) return end
        local success = response[1]
        local output = response[2]
        AddOutput(output, true, success == "scc")
      end
    }

    net.Receive("]] .. Nova.netmessage("admin_get_inspection") .. [[", function(len)
      if len == 0 then return end
      local action = net.ReadString() or ""
      if not actions[action] then return end
      if net.BytesLeft() > 0 then
        local response = net.ReadData(net.BytesLeft()) or ""
        response = util.Decompress(response)
        actions[action](response)
      else
        actions[action]()
      end
    end)
  end
  function PAGE_INSPECTION:Paint(_w, _h) end
  vgui.Register("nova_admin_menu_inspection", PAGE_INSPECTION, "DPanel")]]
  return payload
end

Nova.getNotifyPayload = function()
    local payload = [[
  --------------------------------
  --  Config / Local Variables
  --------------------------------
  NOVA_LANG = NOVA_LANG or nil

  local maxNotifies = 4
  local notifyQueue = {}

  -- copied from modules/functions/logging.lua
  local logLevels = {
    ["d"] = {
      tag = "DEBUG",
      color = Color(161, 161, 161),
    },
    ["i"] = {
      tag = "INFO",
      color = Color(0, 174, 255),
    },
    ["w"] = {
      tag = "WARNING",
      color = Color(255, 157, 0),
    },
    ["e"] = {
      tag = "ERROR",
      color = Color(255, 0, 0),
    },
    ["s"] = {
      tag = "SUCCESS",
      color = Color(0, 255, 0),
    },
    ["a"] = {
      tag = "ACTION",
      color = Color(255, 204, 0),
    },
  }

  local sw, sh = ScrW(), ScrH()
  local style = {
    notify = {
      w = 0.2 * sw,
      wl = 0.3 * sw,
      h = 0.12 * sh,
    },
    margins = {
      tb = 0.005 * sh,
      lr = 0.005 * sw,
    },
    color = {
      pri = Color(126, 38, 241),
      sec = Color(35, 39, 60),
      scc = Color(40, 167, 69),
      dis = Color(81, 88, 94),
      bg = Color(11, 12, 27, 233),
      ft = Color(255, 255, 255),
      dng = Color(220, 53, 69),
      tr = Color(0, 0, 0, 0),
    }
  }

  local dataTypesLoad = {
    ["string"] = tostring,
    ["number"] = tonumber,
    ["boolean"] = tobool,
    ["table"] = util.JSONToTable,
  }

  surface.CreateFont("nova_font", {
    font = "Roboto",
    size = math.ceil(sw * 0.008333),
    weight = 500,
    antialias = true,
    shadow = false,
  })

  surface.CreateFont("nova_font_l", {
    font = "Roboto",
    size = math.ceil(sw * 0.01354),
    weight = 500,
    antialias = true,
    shadow = true,
    blursize = 0.1,
  })

  local function Lang(lang_key)
    if not NOVA_LANG then return lang_key end
    if not NOVA_LANG[lang_key] then
      if lang_key then print("Nova Defender: Missing language key '" .. tostring(lang_key or "NO_VALUE") .. "'") end
      return lang_key
    end
    return NOVA_LANG[lang_key]
  end

  local function LoadData(message, params, callback)
    net.Receive(message, function()
      local dataType = net.ReadString()
      local compressedSize = net.ReadUInt(16)
      local convertedValue = net.ReadData(compressedSize)
      local decompressedValue = util.Decompress(convertedValue)
      local value = dataTypesLoad[dataType](decompressedValue)
      if type(value) == "table" then
        table.SortByMember(value, "key", true)
      end
      if callback then callback(value) end
    end)

    net.Start(message)
      if params then net.WriteString(util.TableToJSON(params)) end
    net.SendToServer()
  end

  if not NOVA_LANG then
    LoadData("]] .. Nova.netmessage("admin_get_language") .. [[", nil, function(data)
      if not isstring(data) then return end
      NOVA_LANG = NOVA_SHARED["languages_" .. data] or {}
    end)
  end

  local FRAME_PLAYER = {}
  local cos, sin, rad = math.cos, math.sin, math.rad
  AccessorFunc( FRAME_PLAYER, "m_masksize", "MaskSize", FORCE_NUMBER )
  function FRAME_PLAYER:Init()
    self.avatar = vgui.Create( "AvatarImage", self )
    self.avatar:SetPaintedManually( true )
    self:SetMaskSize( 24 )

  end
  function FRAME_PLAYER:PerformLayout()
    self.avatar:SetSize(self:GetWide(), self:GetTall())
  end
  function FRAME_PLAYER:SetPlayer( id )
    self.avatar:SetPlayer( id, self:GetWide() )
  end
  function FRAME_PLAYER:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask( 1 )
    render.SetStencilTestMask( 1 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
    render.SetStencilPassOperation( STENCILOPERATION_ZERO )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( 1 )

    local _m = self.m_masksize

    local circle, t = {}, 0

    for i = 1, 360 do
      t = rad(i * 720) / 720
      circle[i] = { x = w / 2 + cos(t) * _m, y = h / 2 + sin(t) * _m }
    end

    draw.NoTexture()
    surface.SetDrawColor(color_white)
    surface.DrawPoly(circle)
    render.SetStencilFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
    render.SetStencilReferenceValue( 1 )
    self.avatar:SetPaintedManually(false)
    self.avatar:PaintManual()
    self.avatar:SetPaintedManually(true)
    render.SetStencilEnable(false)
    render.ClearStencil()
  end
  vgui.Register( "nova_staff_avatar", FRAME_PLAYER )

  local FRAME_NOTIFY = {}
  function FRAME_NOTIFY:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetVisible(true)
    self:SetDraggable(false)
    self:SetSize(style.notify.w, style.notify.h)

    -- create countdown
    self.countdown = vgui.Create("DLabel", self)
    self.countdown:SetFont("nova_font")
    self.countdown:SetText(90)
    self.countdown:SetTextColor(style.color.ft)
    self.countdown:SizeToContents()
    timer.Simple(1, function()
      if not IsValid(self) then return end
      self.countdown:SetPos(self:GetWide() - self.countdown:GetWide() - style.margins.lr, self:GetTall() - self.countdown:GetTall() - style.margins.tb)
    end)
  end
  function FRAME_NOTIFY:SetQueuePos(y)
    self:SetPos(-select(1, self:GetParent():GetSize()), y)
    self:MoveTo(style.margins.lr, y, 1, 0, 0.5)
  end
  function FRAME_NOTIFY:Paint(_w, _h)
    draw.RoundedBox(4, 0, 0, _w, _h, self.bg or style.color.bg)
    if self.closeTime then self.countdown:SetText(math.ceil(self.closeTime - CurTime())) end
  end
  vgui.Register( "nova_staff_notify", FRAME_NOTIFY, "DFrame")


  local FRAME_TAG = {}
  function FRAME_TAG:Init()
    local width, height = select(1, self:GetParent():GetSize()) / 5.5, style.notify.h / 5
    self:SetMinimumSize(width, height)
    self.label = vgui.Create("DLabel", self)
    self.label:SetFont("nova_font")
    self.label:SetTextColor(style.color.ft)
    self.label:SetContentAlignment(5)
    self.label:Dock(FILL)
    self.label:DockMargin(0, 0, 0, 0)
    --self.label:SetContentAlignment(5)
  end
  function FRAME_TAG:Paint(_w, _h)
    if self.text != self.label:GetText() then
      self.label:SetText(self.text or "")
    end
    draw.RoundedBox(4, 0, 0, _w, _h, self.color)
  end
  vgui.Register( "nova_staff_tag", FRAME_TAG, "DPanel")

  local FRAME_BUTTON = {}
  function FRAME_BUTTON:Init()
    local width, height = select(1, self:GetParent():GetSize()) / 5, style.notify.h / 4.5
    self:SetSize(width, height)
    self:SetFont("nova_font")
    self:SetColor(style.color.ft)
  end
  function FRAME_BUTTON:Paint(_w, _h)
    draw.RoundedBox(4, 0, 0, _w, _h, self.defaultColor or style.color.pri)
  end
  vgui.Register( "nova_staff_button", FRAME_BUTTON, "DButton")

  local function GetYPos(position)
    position = math.Clamp(position - 1, 0, 99)
    return (style.notify.h * position) + (style.margins.tb * position) + style.margins.tb
  end

  local function RemoveFromQueue(frame)
    local index = table.KeyFromValue(notifyQueue, frame)
    if not index then return end
    -- highest index
    local highest = table.Count(notifyQueue)

    -- from index to highest move up by 1
    for i = index + 1, highest do
      notifyQueue[i]:MoveTo(style.margins.lr, GetYPos(i - 1), 1, 0, 0.5)
    end

    -- remove from queue
    if notifyQueue[index] then
      notifyQueue[index]:Close()
    end
    table.remove(notifyQueue, index)
  end

  local function ShowNotify(notify)
    if table.Count(notifyQueue) >= maxNotifies then
      -- search for the first notify that doesn't have .isAction
      for i = 1, table.Count(notifyQueue) do
        if not notifyQueue[i].isAction then
          RemoveFromQueue(notifyQueue[i])
          break
        end
      end
    end

    local frame = vgui.Create("nova_staff_notify")
    frame.isAction = notify.identifier ~= nil
    frame.uuid = notify.uuid
    frame.closeTime = CurTime() + (notify.timeopen or 10)
    local heightIndex = table.insert(notifyQueue, frame)
    frame:SetQueuePos(GetYPos(heightIndex))

    surface.PlaySound("UI/buttonrollover.wav")

    if frame.isAction then
      frame:SetSize(style.notify.wl, style.notify.h)
      --frame:MakePopup()
      frame.bg = style.color.dng
      timer.Create("nova_client_notify_blink_" .. heightIndex, 0.2, 9, function()
        if IsValid(frame) then
          frame.bg = (frame.bg == style.color.dng) and style.color.bg or style.color.dng
        end
      end)
    end
    timer.Simple(notify.timeopen or 10, function()
      RemoveFromQueue(frame)
    end)


    if notify.ply and notify.ply ~= "" then
      local ply = player.GetBySteamID(notify.ply)
      if not IsValid(ply) or not ply:IsPlayer() then ply = NULL end
      frame.avatar = vgui.Create("nova_staff_avatar", frame)
      frame.avatar:SetSize(style.notify.h / 4.5, style.notify.h / 4.5)
      frame.avatar:SetMaskSize( style.notify.h / 4.5 )
      frame.avatar:SetPlayer(ply)
      -- top right corner
      frame.avatar:SetPos(select(1, frame:GetSize()) - style.margins.lr - frame.avatar:GetWide(), style.margins.tb)

      -- label with name left of avatar
      local nick = IsValid(ply) and isfunction(ply.Nick) and ply:Nick() or "Unknown"
      -- truncate nick
      if string.len(nick) > 15 then nick = string.sub(nick, 1, 15) .. "..." end
      frame.name = vgui.Create( "DLabel", frame )
      frame.name:SetFont( "nova_font" )
      frame.name:SetTextColor( style.color.ft )
      frame.name:SetText(nick)
      frame.name:SizeToContents()
      frame.name:SetPos(select(1, frame:GetSize()) - style.margins.lr - frame.avatar:GetWide() - style.margins.lr - frame.name:GetWide(), (frame.avatar:GetTall() / 2) - frame.name:GetTall() / 4)
    end

    if not frame.isAction then
      frame.module = vgui.Create("nova_staff_tag", frame)
      frame.module.text = notify.module
      frame.module.color = style.color.pri
      frame.module:SetPos(style.margins.lr, style.margins.tb)
      frame.module.Paint(frame.module, 1, 1)
      frame.module.label:SizeToContents()
      frame.module:SizeToChildren(true)
      frame.module:SizeToContents()

      local tag_w, tag_h = frame.module:GetSize()
      frame.severity = vgui.Create("nova_staff_tag", frame)
      frame.severity.text = logLevels[notify.severity].tag
      frame.severity.color = logLevels[notify.severity].color
      frame.severity:SetPos(tag_w + style.margins.lr * 2, style.margins.tb)

      frame.text = vgui.Create("DLabel", frame)
      frame.text:SetFont("nova_font")
      frame.text:SetPos(style.margins.lr, style.margins.tb * 2 + tag_h)
      frame.text:SetSize(select(1, frame:GetSize()) - style.margins.lr * 2, style.notify.h - style.margins.tb * 3 - tag_h)
      frame.text:SetWrap(true)
      frame.text:SetTextColor(style.color.ft)
      frame.text:SetText(notify.message)
    else
      frame.severity = vgui.Create("nova_staff_tag", frame)
      frame.severity.text = logLevels[notify.severity].tag
      frame.severity.color = logLevels[notify.severity].color
      frame.severity:SetPos(style.margins.lr, style.margins.tb)
      local _, tag_h = frame.severity:GetSize()

      frame.text = vgui.Create("DLabel", frame)
      frame.text:SetFont("nova_font")
      frame.text:SetPos(style.margins.lr, style.margins.tb * 2)
      frame.text:SetSize(select(1, frame:GetSize()) - style.margins.lr * 2, style.notify.h - style.margins.tb * 3 - tag_h)
      frame.text:SetWrap(true)
      frame.text:SetTextColor(style.color.ft)
      frame.text:SetText(notify.message)

      local lastXPos = style.margins.lr
      for k, v in ipairs(notify.options or {}) do
        local button = vgui.Create("nova_staff_button", frame)
        if v == "kick" or v == "ban" then
          button.defaultColor = style.color.dng
          button:SetText(Lang(v))
        elseif v == "nothing" then
          button.defaultColor = style.color.scc
          button:SetText(Lang(v))
        else
          button:SetText(Lang(v))
        end
        button:SizeToContents()
        local width = select(1, button:GetSize())
        button:SetPos(lastXPos, style.notify.h - style.margins.tb - button:GetTall())
        lastXPos = lastXPos + width + style.margins.lr
        button.DoClick = function()
          RemoveFromQueue(frame)
          net.Start("]] .. Nova.netmessage("functions_answer_action") .. [[")
            net.WriteString(v)
            net.WriteString(notify.ply)
          net.SendToServer()
        end
      end
    end
  end

  net.Receive("]] .. Nova.netmessage("functions_sendnotify") .. [[", function()
    local notify = util.JSONToTable(net.ReadString() or "{}") or {}
    if not notify or table.IsEmpty(notify) then return end

    -- check if this is action to close notify
    if notify.close then
      for k, v in ipairs(notifyQueue) do
        if v.uuid == notify.uuid then
          RemoveFromQueue(v)
          break
        end
      end
      return
    end

    ShowNotify(notify)
  end)]]
    return payload
end