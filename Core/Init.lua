local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.Title = "Forever Classic UI"
ns.Skins = ns.Skins or {}
ns.applied = {}
ns.compat = ns.compat or {}

-- Always-on profile. Disable the AddOn in the character list to restore Forever.
ns.db = {
  enabled = true,
  playerFrame = true,
  targetFrame = true,
  petFrame = true,
  partyFrames = true,
  castBars = true,
  minimap = true,
  objectiveTracker = true,
  classicTextures = true,
  classicComboPoints = true,
  hideLevelAlert = true,
}

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
  objectiveTracker = "objectiveTracker",
}

function ns.ApplySkins()
  if not ns.skinsLive then
    return
  end

  if ns.InCombat and ns.InCombat() then
    if ns.QueueReconcile then
      ns.QueueReconcile()
    end
    return
  end

  if ns.SyncClassicDBFromProfile then
    ns.SyncClassicDBFromProfile()
  end

  ns.layout = ns.DetectLayout()

  local classicKeys = { "player", "target", "pet", "party", "castbar" }
  if not ns.applied.classicBundle then
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
    ns.applied.classicBundle = ok and true or false
    for i = 1, #classicKeys do
      local name = classicKeys[i]
      ns.applied[name] = ok and true or false
      ns.compat[name] = ok and nil or tostring(err)
    end
  end

  local minimapApply = ns.Skins.minimap
  if minimapApply and not ns.applied.minimap then
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
  end

  local objectiveApply = ns.Skins.objectiveTracker
  if objectiveApply and not ns.applied.objectiveTracker then
    if ns.BeginSkin then
      ns.BeginSkin("objectiveTracker")
    end
    local ok, err = pcall(objectiveApply, ns)
    if ns.EndSkin then
      ns.EndSkin()
    end
    if ok then
      ns.applied.objectiveTracker = true
      ns.compat.objectiveTracker = nil
    else
      ns.applied.objectiveTracker = false
      ns.compat.objectiveTracker = tostring(err)
      ns.Print("Skin failed: objectiveTracker -", err)
    end
  end

  if ns.ApplyLevelAlertVisibility then
    ns.ApplyLevelAlertVisibility()
  end
end

local function OnPlayerLogin()
  ns.ApplySkins()
  ns.Print("Loaded. Disable the AddOn to restore Forever's default UI.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
eventFrame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then
    OnPlayerLogin()
  elseif event == "PLAYER_REGEN_ENABLED" then
    if ns.FlushPendingReconcile then
      ns.FlushPendingReconcile()
    else
      ns.ApplySkins()
    end
  elseif event == "PLAYER_ENTERING_WORLD" or event == "UNIT_EXITED_VEHICLE" then
    if event == "UNIT_EXITED_VEHICLE" then
      local unit = ...
      if unit ~= "player" then
        return
      end
    end
    ns.ApplySkins()
  end
end)

if C_EditMode and EventRegistry and EventRegistry.RegisterCallback then
  pcall(function()
    EventRegistry:RegisterCallback("EditMode.Exit", function()
      C_Timer.After(0, function()
        ns.ApplySkins()
      end)
    end, ADDON_NAME)
  end)
end

SLASH_FOREVERCLASSICUI1 = "/fcui"
SLASH_FOREVERCLASSICUI2 = "/foreverclassic"
SlashCmdList.FOREVERCLASSICUI = function(msg)
  msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "" or msg == "help" or msg == "status" then
    ns.Print("Layout:", ns.layout or "unknown")
    for name in pairs(ns.Skins) do
      local state = ns.applied[name] and "|cff00ff00applied|r" or "|cffff5555idle|r"
      local err = ns.compat[name]
      print("  " .. name .. ": " .. state .. (err and (" (" .. err .. ")") or ""))
    end
    ns.Print("All Classic skins are always on. Disable the AddOn to restore Forever.")
    return
  end

  ns.Print("Unknown command. /fcui")
end
