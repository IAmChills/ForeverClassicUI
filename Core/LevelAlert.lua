local ADDON_NAME, ns = ...

-- Hide only the player level-up banner. Raid warnings and other toasts stay.

local SUPPRESS_SECONDS = 4
local LEVEL_UP_EVENT_TYPES = {
  LevelUp = true,
  LevelUpSpell = true,
  LevelUpOther = true,
}

local suppressUntil = 0
local suppressLevel
local lastRaidWarningAt = 0
local hookedShow = {}
local hookedDisplay = {}

local function ShouldHide()
  return ns.db and ns.db.hideLevelAlert
end

local function InLevelUpWindow()
  return GetTime() < suppressUntil
end

local function BeginLevelUpWindow(level)
  suppressUntil = GetTime() + SUPPRESS_SECONDS
  suppressLevel = level
  ns.Debug("Level-up window started.", "level", tostring(level))
end

local function IsLevelUpEventType(eventType)
  if eventType == nil then
    return false
  end

  local enum = Enum and Enum.EventToastEventType
  if enum then
    for name in pairs(LEVEL_UP_EVENT_TYPES) do
      if enum[name] ~= nil and eventType == enum[name] then
        return true
      end
    end
  end

  -- Fallback if Enum.EventToastEventType is missing.
  return eventType == 0 or eventType == 1 or eventType == 15
end

local function TextLooksLikeLevelUp(text)
  if type(text) ~= "string" or text == "" then
    return false
  end

  if text:find("levelup:", 1, true) then
    return true
  end

  local lower = string.lower(text)
  if suppressLevel and lower:find("level", 1, true) and lower:find(tostring(suppressLevel), 1, true) then
    return true
  end

  return false
end

local function GetCurrentToastInfo()
  local frame = EventToastManagerFrame
  if frame then
    local info = frame.currentDisplayingToast or frame.toastInfo or frame.currentToast
    if type(info) == "table" then
      return info
    end
  end

  if C_EventToastManager and C_EventToastManager.GetNextToastToDisplay then
    local ok, info = pcall(C_EventToastManager.GetNextToastToDisplay)
    if ok and type(info) == "table" then
      return info
    end
  end
end

local function ShouldDismissToast(info)
  if not ShouldHide() then
    return false
  end

  if type(info) == "table" then
    if IsLevelUpEventType(info.eventType) then
      return true
    end
    if TextLooksLikeLevelUp(info.title) or TextLooksLikeLevelUp(info.subtitle) then
      return true
    end
    if InLevelUpWindow() and info.eventType and not IsLevelUpEventType(info.eventType) then
      return false
    end
  end

  return InLevelUpWindow()
end

local function DismissLevelUpToast()
  if C_EventToastManager and C_EventToastManager.RemoveCurrentToast then
    pcall(C_EventToastManager.RemoveCurrentToast)
  end
  if EventToastManagerFrame then
    EventToastManagerFrame:Hide()
  end
end

local function After(fn)
  if C_Timer and C_Timer.After then
    C_Timer.After(0, fn)
  else
    fn()
  end
end

local function TryDismissEventToast()
  if not ShouldHide() then
    return
  end
  After(function()
    if ShouldDismissToast(GetCurrentToastInfo()) then
      ns.Debug("Dismissing level-up event toast.")
      DismissLevelUpToast()
    end
  end)
end

local function ShouldHideRaidWarning()
  if not ShouldHide() or not InLevelUpWindow() then
    return false
  end
  -- Keep real raid warnings that arrive during the level-up window.
  return (GetTime() - lastRaidWarningAt) >= 1
end

local function HookFrame(frame, onShow)
  if not frame or hookedShow[frame] then
    return
  end
  hookedShow[frame] = true
  frame:HookScript("OnShow", onShow)
end

local function HookEventToastManager(frame)
  HookFrame(frame, function()
    TryDismissEventToast()
  end)

  if frame and frame.DisplayToast and not hookedDisplay[frame] then
    hookedDisplay[frame] = true
    hooksecurefunc(frame, "DisplayToast", function()
      TryDismissEventToast()
    end)
  end
end

local function HookRaidWarning(frame)
  HookFrame(frame, function(self)
    if ShouldHideRaidWarning() then
      ns.Debug("Hiding level-up raid warning.")
      self:Hide()
    end
  end)
end

function ns.ApplyLevelAlertVisibility()
  HookEventToastManager(EventToastManagerFrame)
  HookRaidWarning(RaidWarningFrame)
  HookRaidWarning(RaidBossEmoteFrame)

  if ShouldHide() then
    TryDismissEventToast()
    if RaidWarningFrame and ShouldHideRaidWarning() then
      RaidWarningFrame:Hide()
    end
  end
end

local waiter = CreateFrame("Frame")
waiter:RegisterEvent("ADDON_LOADED")
waiter:RegisterEvent("PLAYER_LOGIN")
waiter:RegisterEvent("PLAYER_LEVEL_UP")
waiter:RegisterEvent("DISPLAY_EVENT_TOASTS")
waiter:RegisterEvent("CHAT_MSG_RAID_WARNING")
waiter:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 ~= ADDON_NAME
      and arg1 ~= "Blizzard_EventToastManager"
      and arg1 ~= "Blizzard_RaidWarning"
    then
      return
    end
    ns.ApplyLevelAlertVisibility()
    return
  end

  if event == "PLAYER_LOGIN" then
    ns.ApplyLevelAlertVisibility()
    return
  end

  if event == "PLAYER_LEVEL_UP" then
    BeginLevelUpWindow(arg1)
    ns.ApplyLevelAlertVisibility()
    TryDismissEventToast()
    return
  end

  if event == "DISPLAY_EVENT_TOASTS" then
    TryDismissEventToast()
    return
  end

  if event == "CHAT_MSG_RAID_WARNING" then
    lastRaidWarningAt = GetTime()
  end
end)
