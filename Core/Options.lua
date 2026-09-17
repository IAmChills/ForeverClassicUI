local ADDON_NAME, ns = ...

local panel

local function MakeCheckbox(parent, option, index)
  local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  box:SetPoint("TOPLEFT", 16, -16 - ((index - 1) * 32))
  local label = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  label:SetPoint("LEFT", box, "RIGHT", 4, 1)
  label:SetText(option.label)
  box.label = label
  box.tooltipText = option.help
  box:SetScript("OnEnter", function(self)
    if not self.tooltipText then
      return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(option.label, 1, 0.82, 0)
    GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  box:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  box:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if ns.SetOption then
      ns.SetOption(option.key, checked)
    else
      ns.db[option.key] = checked
    end
    if option.live then
      ns.Print("Saved.", option.label, checked and "on" or "off")
    elseif option.key ~= "debug" and not ns.skinsLive then
      ns.Print("Saved.", option.label, checked and "on" or "off", "- Classic art is not applied yet.")
    elseif option.key ~= "debug" then
      ns.Print("Change stored. /reload to fully reapply skins.")
    end
  end)
  box:SetScript("OnShow", function(self)
    self:SetChecked(ns.db and ns.db[option.key])
  end)
  return box
end

local function CreatePanel()
  if panel then
    return panel
  end

  panel = CreateFrame("Frame", "ForeverClassicUIOptionsPanel", UIParent)
  panel.name = ns.Title
  panel:Hide()

  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(ns.Title)

  local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  subtitle:SetJustifyH("LEFT")
  subtitle:SetWidth(500)
  subtitle:SetText("Classic frame skins are also toggled from HUD Edit Mode. These settings are stored now; Classic art is not applied until skins are wired up.")

  local container = CreateFrame("Frame", nil, panel)
  container:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
  container:SetPoint("BOTTOMRIGHT", -16, 50)

  for i = 1, #ns.OptionMeta do
    MakeCheckbox(container, ns.OptionMeta[i], i)
  end

  local probe = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  probe:SetSize(140, 24)
  probe:SetPoint("BOTTOMLEFT", 16, 16)
  probe:SetText("Run Probe")
  probe:SetScript("OnClick", function()
    ns.RunProbe(true)
  end)

  local reload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  reload:SetSize(140, 24)
  reload:SetPoint("LEFT", probe, "RIGHT", 8, 0)
  reload:SetText("Reload UI")
  reload:SetScript("OnClick", ReloadUI)

  return panel
end

function ns.OpenOptions()
  local frame = CreatePanel()
  if Settings and Settings.OpenToCategory then
    Settings.OpenToCategory(ns.settingsCategory and ns.settingsCategory.ID or frame.name)
    return
  end
  if InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(frame)
    InterfaceOptionsFrame_OpenToCategory(frame)
    return
  end
  frame:SetSize(540, 480)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  if not frame.bg then
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.85)
  end
  frame:Show()
end

local function RegisterSettings()
  local frame = CreatePanel()
  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(frame, ns.Title)
    category.ID = ns.Title
    Settings.RegisterAddOnCategory(category)
    ns.settingsCategory = category
    return
  end
  if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(frame)
  end
end

local waiter = CreateFrame("Frame")
waiter:RegisterEvent("PLAYER_LOGIN")
waiter:SetScript("OnEvent", function(self)
  self:UnregisterAllEvents()
  RegisterSettings()
end)
