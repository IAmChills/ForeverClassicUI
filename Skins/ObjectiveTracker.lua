local _, ns = ...

local function SkinOn()
  return true
end

local function Silence(region)
  if region then
    ns.SilenceNativeChrome(region, SkinOn)
  end
end

local function SilenceHeaderChrome(header)
  if not header then
    return
  end
  Silence(header.Background)
  Silence(header.Glow)
  Silence(header.Shine)
end

local function Apply()
  if not SkinOn() then
    return
  end

  -- Blizzard_ObjectiveTracker can load after us.
  if type(C_AddOns) == "table" and C_AddOns.LoadAddOn then
    pcall(C_AddOns.LoadAddOn, "Blizzard_ObjectiveTracker")
  elseif LoadAddOn then
    pcall(LoadAddOn, "Blizzard_ObjectiveTracker")
  end

  local tracker = ObjectiveTrackerFrame
  if tracker and tracker.Header then
    SilenceHeaderChrome(tracker.Header)
  end

  local quest = QuestObjectiveTracker
  if quest and quest.Header then
    SilenceHeaderChrome(quest.Header)
  end
end

ns.RegisterSkin("objectiveTracker", Apply)

if not ns._objectiveTrackerLoadHooked then
  ns._objectiveTrackerLoadHooked = true
  local f = CreateFrame("Frame")
  f:RegisterEvent("ADDON_LOADED")
  f:SetScript("OnEvent", function(_, _, name)
    if name == "Blizzard_ObjectiveTracker" and SkinOn() and ns.Skins.objectiveTracker then
      pcall(ns.Skins.objectiveTracker, ns)
    end
  end)
end
