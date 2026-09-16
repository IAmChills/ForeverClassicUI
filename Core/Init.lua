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
    playerFrame = true,
    targetFrame = true,
    petFrame = true,
    partyFrames = true,
    castBars = true,
    minimap = true,
    hideModernChrome = true,
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

function ns.ApplySkins()
  local db = ForeverClassicUIDB and ForeverClassicUIDB.profile
  if not db or not db.enabled then
    return
  end

  ns.layout = ns.DetectLayout()
  ns.Debug("layout =", ns.layout)

  local order = { "player", "target", "pet", "party", "castbar", "minimap" }
  for i = 1, #order do
    local name = order[i]
    local apply = ns.Skins[name]
    if apply and db[ns.skinOptions[name]] then
      local ok, err = pcall(apply, ns)
      if ok then
        ns.applied[name] = true
      else
        ns.applied[name] = false
        ns.compat[name] = tostring(err)
        ns.Print("Skin failed:", name, "-", err)
      end
    end
  end
end

ns.skinOptions = {
  player = "playerFrame",
  target = "targetFrame",
  pet = "petFrame",
  party = "partyFrames",
  castbar = "castBars",
  minimap = "minimap",
}

local function OnAddonLoaded(_, addonName)
  if addonName ~= ADDON_NAME then
    return
  end

  ForeverClassicUIDB = CopyDefaults(defaults, ForeverClassicUIDB)
  ns.db = ForeverClassicUIDB.profile
  local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  if getMeta then
    ns.Version = getMeta(ADDON_NAME, "Version") or ns.Version
  end
end

local function OnPlayerLogin()
  ns.ApplySkins()
  ns.Print("Loaded.", "Layout:", ns.layout or "unknown", "- /fcui for commands.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    OnAddonLoaded(self, ...)
  elseif event == "PLAYER_LOGIN" then
    OnPlayerLogin()
  elseif event == "PLAYER_ENTERING_WORLD" then
    if ns.db then
      ns.ApplySkins()
    end
  end
end)

if C_EditMode and EventRegistry and EventRegistry.RegisterCallback then
  pcall(function()
    EventRegistry:RegisterCallback("EditMode.Enter", function()
      ns.Debug("Edit Mode entered; skins will reapply on exit.")
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
    print("  /fcui options   - open settings")
    print("  /fcui probe     - dump Forever frame names and texture availability")
    print("  /fcui status    - show detected layout and applied skins")
    print("  /fcui debug     - toggle debug chat")
    print("  /fcui reset     - restore default settings")
    return
  end

  if msg == "options" or msg == "config" then
    if ns.OpenOptions then
      ns.OpenOptions()
    end
    return
  end

  if msg == "probe" then
    if ns.RunProbe then
      ns.RunProbe(true)
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
    ns.db.debug = not ns.db.debug
    ns.Print("Debug", ns.db.debug and "on" or "off")
    return
  end

  if msg == "reset" then
    ForeverClassicUIDB = CopyDefaults(defaults, {})
    ns.db = ForeverClassicUIDB.profile
    ns.Print("Settings reset. /reload to reapply skins.")
    return
  end

  ns.Print("Unknown command. /fcui help")
end
