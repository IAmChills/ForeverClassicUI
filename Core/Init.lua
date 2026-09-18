local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.Title = "Forever Classic UI"
ns.Skins = ns.Skins or {}
ns.applied = {}
ns.compat = ns.compat or {}

local defaults = {
  profile = {
    enabled = true,
    playerFrame = true,
    targetFrame = true,
    petFrame = true,
    partyFrames = true,
    castBars = true,
    minimap = true,
    classicTextures = true,
    classicComboPoints = true,
    hideLevelAlert = false,
    settingsRevision = 2,
  },
}

local SETTINGS_REVISION = 2

local function CopyDefaults(src, dst)
  if type(src) ~= "table" then
    return {}
  end
  dst = dst or {}
  for key, value in pairs(src) do
    if type(value) == "table" then
      dst[key] = CopyDefaults(value, dst[key])
    elseif dst[key] == nil then
      dst[key] = value
    end
  end
  return dst
end

local function EnsureProfile()
  local db = _G.ForeverClassicUIDB
  if type(db) ~= "table" then
    db = {}
    _G.ForeverClassicUIDB = db
  end
  CopyDefaults(defaults, db)
  if type(db.profile) ~= "table" then
    db.profile = CopyDefaults(defaults.profile, {})
  end

  local profile = db.profile
  local rev = tonumber(profile.settingsRevision) or 0
  if rev < SETTINGS_REVISION then
    for key, value in pairs(defaults.profile) do
      if key ~= "settingsRevision" then
        profile[key] = value
      end
    end
    profile.settingsRevision = SETTINGS_REVISION
  end

  _G.ForeverClassicUIDB = db
  return profile
end

function ns.Print(...)
  local parts = { ... }
  for i = 1, #parts do
    parts[i] = tostring(parts[i])
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cffc79c6eForever Classic UI|r: " .. table.concat(parts, " "))
end

function ns.RegisterSkin(name, apply)
  ns.Skins[name] = apply
end

ns.skinsLive = true

ns.skinOptions = {
  player = "playerFrame",
  target = "targetFrame",
  pet = "petFrame",
  party = "partyFrames",
  castbar = "castBars",
  minimap = "minimap",
}

local RELOAD_POPUP = "FOREVERCLASSICUI_RELOAD"

local function EnsureReloadPopup()
  if not StaticPopupDialogs then
    return false
  end
  if not StaticPopupDialogs[RELOAD_POPUP] then
    StaticPopupDialogs[RELOAD_POPUP] = {
      text = "Reload the UI to restore Forever's default look.",
      button1 = RELOADUI or "Reload UI",
      button2 = CANCEL or "Later",
      OnAccept = function()
        ReloadUI()
      end,
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
      preferredIndex = 3,
    }
  end
  return true
end

function ns.PromptReload()
  if EnsureReloadPopup() and StaticPopup_Show then
    StaticPopup_Show(RELOAD_POPUP)
    return
  end
  ns.Print("Reload the UI to restore Forever's default look. Type /reload")
end

function ns.SetOption(key, value)
  local profile = EnsureProfile()
  ns.db = profile
  profile[key] = value and true or false
  if ns.RefreshEditModeOptions then
    ns.RefreshEditModeOptions()
  end
  if ns.ApplyLevelAlertVisibility then
    ns.ApplyLevelAlertVisibility()
  end
  if ns.skinsLive then
    ns.ApplySkins()
  end
end

function ns.ApplySkins()
  if not ns.skinsLive then
    return
  end

  local db = ForeverClassicUIDB and ForeverClassicUIDB.profile
  if not db then
    return
  end

  if ns.InCombat and ns.InCombat() then
    if ns.QueueReconcile then
      ns.QueueReconcile()
    end
    return
  end

  ns.layout = ns.DetectLayout()

  local classicKeys = { "player", "target", "pet", "party", "castbar" }
  local wantClassic = db.enabled and (
    db.playerFrame or db.targetFrame or db.petFrame or db.partyFrames or db.castBars
  )
  local needReload = false
  if wantClassic then
    if ns.BeginSkin then
      ns.BeginSkin("classic")
    end
    local ok, err = pcall(function()
      ns.ApplyClassicBundle()
    end)
    if ns.EndSkin then
      ns.EndSkin()
    end
    if not ok then
      ns.Print("Classic Frames failed:", tostring(err))
    end
    for i = 1, #classicKeys do
      local name = classicKeys[i]
      local key = ns.skinOptions[name]
      if db[key] then
        ns.applied[name] = ok and true or false
        ns.compat[name] = ok and nil or tostring(err)
      end
    end
  else
    for i = 1, #classicKeys do
      local name = classicKeys[i]
      if ns.applied[name] then
        ns.applied[name] = false
        needReload = true
      end
    end
  end

  -- Minimap
  local minimapApply = ns.Skins.minimap
  if minimapApply then
    local want = db.enabled and db.minimap
    if want then
      if ns.BeginSkin then
        ns.BeginSkin("minimap")
      end
      local ok, err = pcall(minimapApply, ns)
      if ns.EndSkin then
        ns.EndSkin()
      end
      if ok then
        ns.applied.minimap = true
        ns.compat.minimap = nil
      else
        ns.applied.minimap = false
        ns.compat.minimap = tostring(err)
        ns.Print("Skin failed: minimap -", err)
      end
    elseif ns.applied.minimap then
      ns.applied.minimap = false
      needReload = true
    end
  end

  if needReload then
    ns.PromptReload()
  end
end

local function OnAddonLoaded(_, addonName)
  if addonName ~= ADDON_NAME then
    return
  end

  ns.db = EnsureProfile()
  if _G.ForeverClassicUIDB then
    _G.ForeverClassicUIDB.lastProbe = nil
    _G.ForeverClassicUIDB.lastGeom = nil
  end
end

local function OnPlayerLogin()
  ns.ApplySkins()
  if ns.RefreshEditModeOptions then
    ns.RefreshEditModeOptions()
  end
  ns.Print("Loaded.", "Open HUD Edit Mode or /fcui options for Classic UI toggles.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    OnAddonLoaded(self, ...)
  elseif event == "PLAYER_LOGIN" then
    OnPlayerLogin()
  elseif event == "PLAYER_REGEN_ENABLED" then
    if ns.FlushPendingReconcile then
      ns.FlushPendingReconcile()
    elseif ns.db then
      ns.ApplySkins()
    end
  elseif event == "PLAYER_ENTERING_WORLD" or event == "UNIT_EXITED_VEHICLE" then
    if event == "UNIT_EXITED_VEHICLE" then
      local unit = ...
      if unit ~= "player" then
        return
      end
    end
    if ns.db then
      ns.ApplySkins()
    end
  end
end)

if C_EditMode and EventRegistry and EventRegistry.RegisterCallback then
  pcall(function()
    EventRegistry:RegisterCallback("EditMode.Exit", function()
      C_Timer.After(0, function()
        if ns.db then
          ns.ApplySkins()
        end
      end)
    end, ADDON_NAME)
  end)
end

SLASH_FOREVERCLASSICUI1 = "/fcui"
SLASH_FOREVERCLASSICUI2 = "/foreverclassic"
SlashCmdList.FOREVERCLASSICUI = function(msg)
  msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "" or msg == "help" then
    ns.Print("Commands:")
    print("  /fcui options   - HUD Edit Mode Classic UI checkboxes")
    print("  /fcui status    - show detected layout and applied skins")
    print("  /fcui reset     - restore default settings")
    return
  end

  if msg == "options" or msg == "config" then
    if ns.OpenEditMode and ns.OpenEditMode() then
      return
    end
    if ns.OpenOptions then
      ns.OpenOptions()
    end
    return
  end

  if msg == "status" then
    ns.Print("Layout:", ns.layout or "unknown")
    for name in pairs(ns.Skins) do
      local state = ns.applied[name] and "|cff00ff00applied|r" or "|cffff5555idle|r"
      local err = ns.compat[name]
      print("  " .. name .. ": " .. state .. (err and (" (" .. err .. ")") or ""))
    end
    return
  end

  if msg == "reset" then
    _G.ForeverClassicUIDB = CopyDefaults(defaults, {})
    _G.ForeverClassicUIDB.profile.settingsRevision = SETTINGS_REVISION
    ns.db = _G.ForeverClassicUIDB.profile
    if ns.RefreshEditModeOptions then
      ns.RefreshEditModeOptions()
    end
    if ns.ApplyLevelAlertVisibility then
      ns.ApplyLevelAlertVisibility()
    end
    if ns.skinsLive then
      ns.ApplySkins()
    end
    ns.Print("Settings reset.")
    return
  end

  ns.Print("Unknown command. /fcui help")
end
