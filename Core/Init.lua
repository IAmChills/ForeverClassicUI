local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.Title = "Forever Classic UI"
ns.Version = "0.1.0"
ns.Skins = ns.Skins or {}
ns.applied = {}
ns.compat = ns.compat or {}

local defaults = {
  profile = {
    enabled = true,
    playerFrame = false,
    targetFrame = false,
    petFrame = false,
    partyFrames = false,
    castBars = false,
    minimap = false,
    hideLevelAlert = false,
    debug = false,
  },
}

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

function ns.Print(...)
  local parts = { ... }
  for i = 1, #parts do
    parts[i] = tostring(parts[i])
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cffc79c6eForever Classic UI|r: " .. table.concat(parts, " "))
end

function ns.Debug(...)
  if ForeverClassicUIDB and ForeverClassicUIDB.profile and ForeverClassicUIDB.profile.debug then
    ns.Print("|cff888888[debug]|r", ...)
  end
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
  if not ns.db then
    return
  end
  -- Always write through ForeverClassicUIDB so SavedVariables stay in sync.
  ForeverClassicUIDB = ForeverClassicUIDB or {}
  ForeverClassicUIDB.profile = ForeverClassicUIDB.profile or ns.db
  ns.db = ForeverClassicUIDB.profile
  ns.db[key] = value and true or false
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
    ns.Debug("skins deferred until combat ends")
    return
  end

  ns.layout = ns.DetectLayout()
  ns.Debug("layout =", ns.layout)

  local order = { "player", "target", "pet", "party", "castbar", "minimap" }
  local needReload = false
  for i = 1, #order do
    local name = order[i]
    local apply = ns.Skins[name]
    if apply then
      local want = db.enabled and db[ns.skinOptions[name]]
      if want then
        if ns.BeginSkin then
          ns.BeginSkin(name)
        end
        local ok, err = pcall(apply, ns)
        if ns.EndSkin then
          ns.EndSkin()
        end
        if ok then
          ns.applied[name] = true
          ns.compat[name] = nil
        else
          ns.applied[name] = false
          ns.compat[name] = tostring(err)
          ns.Print("Skin failed:", name, "-", err)
        end
      elseif ns.applied[name] then
        local restored = true
        if ns.RestoreSkin then
          local ok, result = pcall(ns.RestoreSkin, name)
          restored = ok and result ~= false
          if not ok then
            ns.Print("Revert failed:", name, "-", result)
          end
        end
        ns.applied[name] = false
        -- RefreshNative hides addon overlays. Avoid ToPlayerArt/UpdateArt (secret taint).
        if ns.RefreshNative then
          pcall(ns.RefreshNative, name)
        end
        if not restored then
          needReload = true
        end
      end
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

  ForeverClassicUIDB = CopyDefaults(defaults, ForeverClassicUIDB)
  -- Drop debug probe dumps if an older build wrote them into SV.
  ForeverClassicUIDB.lastProbe = nil
  ForeverClassicUIDB.lastGeom = nil
  ns.db = ForeverClassicUIDB.profile
  local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  if getMeta then
    ns.Version = getMeta(ADDON_NAME, "Version") or ns.Version
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
    EventRegistry:RegisterCallback("EditMode.Enter", function()
      ns.Debug("Edit Mode entered.")
    end, ADDON_NAME)
    EventRegistry:RegisterCallback("EditMode.Exit", function()
      if ns.db then
        ns.ApplySkins()
      end
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
    print("  /fcui debug     - toggle debug chat")
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

  if msg == "debug" then
    if not ns.db then
      return
    end
    ns.db.debug = not ns.db.debug
    ns.Print("Debug", ns.db.debug and "on" or "off")
    return
  end

  if msg == "reset" then
    ForeverClassicUIDB = CopyDefaults(defaults, {})
    ns.db = ForeverClassicUIDB.profile
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
