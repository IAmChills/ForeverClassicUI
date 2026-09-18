local ADDON_NAME, ns = ...

local CHECKBOX_WIDTH = 225
local CHECKBOX_HEIGHT = 32
local SECTION_WIDTH = 450

local editModeCheckboxes = {}
local section
local refreshingChecks

local function PlayCheckSound()
  if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  end
end

local function ApplyCheckboxTextures(button)
  button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
  button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
  button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
  button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
  button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
end

local function TryCreate(parent, template, name)
  local ok, frame = pcall(CreateFrame, "Frame", name, parent, template)
  if ok and frame then
    return frame
  end
  return nil
end

local function SetChecked(box, checked)
  local wasRefreshing = refreshingChecks
  refreshingChecks = true
  if box.SetControlChecked then
    box:SetControlChecked(checked and true or false)
  elseif box.Button and box.Button.SetChecked then
    box.Button:SetChecked(checked and true or false)
  end
  refreshingChecks = wasRefreshing
end

local function WireCallback(box, handler)
  local button = box.Button or box
  if not button or not button.HookScript then
    return
  end
  button:HookScript("OnClick", function(self)
    if refreshingChecks then
      return
    end
    PlayCheckSound()
    local checked = self.GetChecked and self:GetChecked() and true or false
    handler(checked)
  end)
end

local function AddTooltip(box, option)
  local regions = { box.Button, box }
  for i = 1, #regions do
    local region = regions[i]
    if region and region.HookScript then
      region:HookScript("OnEnter", function(self)
        if not option.help then
          return
        end
        local tooltip = GameTooltip
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
        tooltip:SetText(option.label, 1, 0.82, 0)
        tooltip:AddLine(option.help, 1, 1, 1, true)
        tooltip:Show()
      end)
      region:HookScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    end
  end
end

local function CreateFallbackCheckbox(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetSize(CHECKBOX_WIDTH, CHECKBOX_HEIGHT)
  frame.fixedWidth = CHECKBOX_WIDTH
  frame.fixedHeight = CHECKBOX_HEIGHT

  local button = CreateFrame("CheckButton", nil, frame)
  button:SetSize(32, 32)
  button:SetPoint("LEFT")
  ApplyCheckboxTextures(button)
  frame.Button = button

  local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
  label:SetPoint("LEFT", button, "RIGHT", 5, 0)
  label:SetSize(CHECKBOX_WIDTH - 37, CHECKBOX_HEIGHT)
  label:SetJustifyH("LEFT")
  label:SetWordWrap(false)
  frame.Label = label

  function frame:SetCallback(callback)
    self._callback = callback
  end

  function frame:SetControlChecked(checked)
    local wasRefreshing = refreshingChecks
    refreshingChecks = true
    self.Button:SetChecked(checked)
    refreshingChecks = wasRefreshing
  end

  function frame:IsControlChecked()
    return self.Button:GetChecked()
  end

  return frame
end

local function CreateCheckbox(parent, option, layoutIndex)
  local box = TryCreate(parent, "EditModeManagerSettingCheckButtonTemplate")
    or TryCreate(parent, "EditModeCheckButtonTemplate")
    or CreateFallbackCheckbox(parent)

  box.layoutIndex = layoutIndex
  box.fixedWidth = CHECKBOX_WIDTH
  box.fixedHeight = CHECKBOX_HEIGHT
  box:SetSize(CHECKBOX_WIDTH, CHECKBOX_HEIGHT)
  box:Show()

  if box.Label then
    box.Label:SetText(option.label)
  end

  WireCallback(box, function(isChecked)
    if refreshingChecks then
      return
    end
    if ns.SetOption then
      ns.SetOption(option.key, isChecked)
    elseif ns.db then
      ns.db[option.key] = isChecked and true or false
    end
  end)

  AddTooltip(box, option)
  editModeCheckboxes[#editModeCheckboxes + 1] = { box = box, key = option.key }
  return box
end

local function CreateTitle(parent, text, layoutIndex, hint)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetSize(SECTION_WIDTH, CHECKBOX_HEIGHT)
  frame.layoutIndex = layoutIndex
  frame.fixedWidth = SECTION_WIDTH
  frame.fixedHeight = CHECKBOX_HEIGHT

  local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  label:SetPoint("LEFT", 5, 0)
  label:SetText(text)
  frame.Title = label

  if hint then
    local note = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    note:SetPoint("LEFT", label, "RIGHT", 8, 0)
    note:SetText(hint)
    note:SetTextColor(1, 0.2, 0.2)
    frame.Hint = note
  end
  return frame
end

local function CreateGrid(parent)
  local grid = TryCreate(parent, "EditModeManagerSettingsOptionsContainerTemplate")
  if grid then
    return grid
  end

  grid = TryCreate(parent, "GridLayoutFrame") or CreateFrame("Frame", nil, parent)
  grid.childXPadding = 0
  grid.childYPadding = 0
  grid.isHorizontal = true
  grid.stride = 2
  grid.layoutFramesGoingRight = true
  grid.layoutFramesGoingUp = false
  grid.alwaysUpdateLayout = true
  return grid
end

local function LayoutLocal(frame)
  if frame and frame.Layout then
    pcall(frame.Layout, frame)
  end
end

function ns.RefreshEditModeOptions()
  if refreshingChecks or not ns.db then
    return
  end
  refreshingChecks = true
  for i = 1, #editModeCheckboxes do
    local entry = editModeCheckboxes[i]
    SetChecked(entry.box, ns.db[entry.key])
  end
  refreshingChecks = false
end

local function LayoutGridManually(grid, count)
  local children = { grid:GetChildren() }
  for i = 1, #children do
    local child = children[i]
    local index = child.layoutIndex or i
    local col = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    child:ClearAllPoints()
    child:SetPoint("TOPLEFT", grid, "TOPLEFT", col * CHECKBOX_WIDTH, -row * CHECKBOX_HEIGHT)
  end
  local rows = math.max(1, math.ceil(count / 2))
  grid:SetSize(SECTION_WIDTH, rows * CHECKBOX_HEIGHT)
end

local function Attach()
  if section or not EditModeManagerFrame then
    return
  end

  local accountSettings = EditModeManagerFrame.AccountSettings
  if not accountSettings then
    return
  end

  local options = ns.GetEditModeOptions and ns.GetEditModeOptions() or {}
  if #options == 0 then
    return
  end

  section = TryCreate(accountSettings, "VerticalLayoutFrame", "ForeverClassicUIEditModeSection")
    or CreateFrame("Frame", "ForeverClassicUIEditModeSection", accountSettings)
  section.layoutIndex = 3
  section.spacing = 0
  section.expand = true
  section:SetWidth(SECTION_WIDTH)

  local title = CreateTitle(section, "Classic UI", 1)

  local grid = CreateGrid(section)
  grid.layoutIndex = 2
  grid:SetWidth(SECTION_WIDTH)

  for i = 1, #options do
    CreateCheckbox(grid, options[i], i)
  end

  ns.RefreshEditModeOptions()
  LayoutLocal(grid)
  if not grid.GetHeight or grid:GetHeight() < CHECKBOX_HEIGHT then
    LayoutGridManually(grid, #options)
  end
  LayoutLocal(section)

  if not section.Layout then
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", section, "TOPLEFT")
    grid:ClearAllPoints()
    grid:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
    section:SetSize(SECTION_WIDTH, CHECKBOX_HEIGHT + (grid:GetHeight() or CHECKBOX_HEIGHT))
  end

  if not accountSettings.Layout and accountSettings.Expander then
    section:ClearAllPoints()
    section:SetPoint("TOP", accountSettings.Expander, "BOTTOM", 0, -4)
  end
  if accountSettings.Layout then
    C_Timer.After(0, function()
      if accountSettings and accountSettings.Layout then
        pcall(accountSettings.Layout, accountSettings)
      end
    end)
  end
end

function ns.OpenEditMode()
  local load = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
  if load then
    pcall(load, "Blizzard_EditMode")
  end

  Attach()

  if not EditModeManagerFrame then
    return false
  end

  if ShowUIPanel then
    ShowUIPanel(EditModeManagerFrame)
  else
    EditModeManagerFrame:Show()
  end
  return true
end

local function RegisterWhenReady()
  if EditModeManagerFrame then
    Attach()
    return
  end

  if EventUtil and EventUtil.ContinueOnAddOnLoaded then
    EventUtil.ContinueOnAddOnLoaded("Blizzard_EditMode", Attach)
  end
end

local waiter = CreateFrame("Frame")
waiter:RegisterEvent("PLAYER_LOGIN")
waiter:RegisterEvent("ADDON_LOADED")
waiter:SetScript("OnEvent", function(_, event, addonName)
  if event == "ADDON_LOADED" and addonName ~= "Blizzard_EditMode" and addonName ~= ADDON_NAME then
    return
  end
  RegisterWhenReady()
end)

if EventRegistry and EventRegistry.RegisterCallback then
  pcall(function()
    EventRegistry:RegisterCallback("EditMode.Enter", function()
      C_Timer.After(0, function()
        Attach()
        ns.RefreshEditModeOptions()
      end)
    end, ADDON_NAME .. ".EditMode")
  end)
end
