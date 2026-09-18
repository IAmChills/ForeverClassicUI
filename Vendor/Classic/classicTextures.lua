local MEDIA = "Interface\\AddOns\\ForeverClassicUI\\Media\\Units\\"
local STATUS_CF = MEDIA .. "ui-statusbar-cf"
local STATUS = MEDIA .. "ui-statusbar"
local BAR_FILL = MEDIA .. "ui-targetingframe-barfill"
local NAME_BG = "Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground"
local CLASSIC_FILL_ID = 798064

local hooked

local fancyManas = {
  INSANITY = true,
  MAELSTROM = true,
  FURY = true,
  LUNAR_POWER = true,
  SOUL_FRAGMENTS = true,
  STAGGER = true,
}

local function SafeSetStatusBarColor(statusBar, r, g, b, a)
  if not statusBar or not statusBar.SetStatusBarColor then
    return
  end
  pcall(statusBar.SetStatusBarColor, statusBar, r, g, b, a or 1)
end

local function SafeSetDesaturated(statusBar, desat)
  if statusBar and statusBar.SetStatusBarDesaturated then
    pcall(statusBar.SetStatusBarDesaturated, statusBar, desat and true or false)
  end
end

local function HealthTextureFor(statusBar, parent)
  if parent and parent.GetName and parent:GetName() == "PetFrame" then
    return STATUS_CF
  end
  if statusBar == (TargetFrame and TargetFrame.totFrame and TargetFrame.totFrame.HealthBar) then
    return STATUS_CF
  end
  if statusBar == (FocusFrame and FocusFrame.totFrame and FocusFrame.totFrame.HealthBar) then
    return STATUS_CF
  end
  return STATUS
end

local function ApplyPredictionFills(statusBar, tex)
  if not statusBar then
    return
  end
  local function setFill(region)
    if region and region.SetTexture then
      pcall(region.SetTexture, region, tex)
    end
  end
  if statusBar.MyHealPredictionBar then
    setFill(statusBar.MyHealPredictionBar.Fill)
  end
  if statusBar.OtherHealPredictionBar then
    setFill(statusBar.OtherHealPredictionBar.Fill)
  end
  if statusBar.HealAbsorbBar then
    setFill(statusBar.HealAbsorbBar.Fill)
  end
  if statusBar.TotalAbsorbBar then
    setFill(statusBar.TotalAbsorbBar.Fill)
  end
end

local function ApplyTextureChange(kind, statusBar, parent, classic, party, altBar)
  if not statusBar then
    return
  end

  -- ReputationColor / plain textures (name plate fill)
  if not statusBar.GetStatusBarTexture then
    if statusBar.SetTexture then
      statusBar:SetTexture(NAME_BG)
      if statusBar.SetTexCoord then
        statusBar:SetTexCoord(0, 1, 0, 1)
      end
    end
    return
  end

  local path = kind == "health" and HealthTextureFor(statusBar, parent) or STATUS
  if kind == "mana" then
    local keepFancy = FCUIClassicDB.changeUnitFrameManaBarTextureKeepFancy
      and ((statusBar.powerToken and fancyManas[statusBar.powerToken]) or (statusBar.powerName and fancyManas[statusBar.powerName]))
    if keepFancy then
      return
    end
  end

  local function apply()
    if statusBar.SetStatusBarTexture then
      statusBar:SetStatusBarTexture(path)
    end

    if kind == "health" then
      SafeSetDesaturated(statusBar, false)
      if not FCUIClassicDB.classColorFrames then
        SafeSetStatusBarColor(statusBar, 0, 1, 0)
      end
      ApplyPredictionFills(statusBar, CLASSIC_FILL_ID)
      local loss = PlayerFrame
        and PlayerFrame.PlayerFrameContent
        and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
        and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
        and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.PlayerFrameHealthBarAnimatedLoss
      if loss and statusBar == PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar then
        loss:SetStatusBarTexture(CLASSIC_FILL_ID)
      end
    else
      SafeSetDesaturated(statusBar, true)
      local colored
      if statusBar.unit then
        local _, powerToken = UnitPowerType(statusBar.unit)
        local c = PowerBarColor and PowerBarColor[powerToken]
        if c and c.r then
          SafeSetStatusBarColor(statusBar, c.r, c.g, c.b)
          colored = true
        end
      end
      if not colored then
        SafeSetStatusBarColor(statusBar, 0, 0, 1)
      end
    end
  end

  if parent and parent.GetName and parent:GetName() == "PetFrame" then
    C_Timer.After(0.1, apply)
  else
    apply()
  end

  if classic and kind == "mana" and not statusBar.fcuiTextureHook then
    statusBar.fcuiTextureHook = true
    hooksecurefunc(statusBar, "SetStatusBarTexture", function(self)
      if self.changing then
        return
      end
      self.changing = true
      self:SetStatusBarTexture(path)
      self.changing = false
    end)
  end

  if parent and kind == "health" and not parent.hookedHealthBarsTexture then
    local updateFunc = party and "ToPlayerArt" or "Update"
    if parent[updateFunc] then
      parent.hookedHealthBarsTexture = true
      hooksecurefunc(parent, updateFunc, function()
        statusBar:SetStatusBarTexture(HealthTextureFor(statusBar, parent))
      end)
    end
  end
end

FCUI.ApplyTextureChange = ApplyTextureChange

local function RetextureNameBackground(tex)
  if not tex or not tex.SetTexture then
    return
  end
  tex:SetTexture(NAME_BG)
  if tex.SetTexCoord then
    tex:SetTexCoord(0, 1, 0, 1)
  end
end

function FCUI.HookClassicUnitFrameTextures()
  local db = FCUIClassicDB
  if not db.changeUnitFrameHealthbarTexture and not db.changeUnitFrameManabarTexture then
    return
  end

  if db.changeUnitFrameHealthbarTexture then
    local playerHp = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    ApplyTextureChange("health", playerHp)

    if PetFrame then
      ApplyTextureChange("health", PetFrame.healthbar or PetFrame.HealthBar or _G.PetFrameHealthBar, PetFrame)
    end

    ApplyTextureChange("health", TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, TargetFrame)
    if FocusFrame then
      ApplyTextureChange("health", FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, FocusFrame)
    end
    if TargetFrame.totFrame then
      ApplyTextureChange("health", TargetFrame.totFrame.HealthBar)
    end
    if FocusFrame and FocusFrame.totFrame then
      ApplyTextureChange("health", FocusFrame.totFrame.HealthBar)
    end
    local playerMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if playerMain and playerMain.ReputationColor then
      RetextureNameBackground(playerMain.ReputationColor)
    end
    RetextureNameBackground(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor)
    if FocusFrame then
      RetextureNameBackground(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor)
    end

    if PartyFrame and not (EditModeManagerFrame and EditModeManagerFrame.UseRaidStylePartyFrames and EditModeManagerFrame:UseRaidStylePartyFrames()) then
      for i = 1, 4 do
        local frame = PartyFrame["MemberFrame" .. i]
        if frame and frame.HealthBarContainer then
          ApplyTextureChange("health", frame.HealthBarContainer.HealthBar, frame, nil, true)
        end
      end
      if PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
          if frame.HealthBarContainer then
            ApplyTextureChange("health", frame.HealthBarContainer.HealthBar, frame, nil, true)
          end
        end
      end
    end
  end

  if db.changeUnitFrameManabarTexture then
    ApplyTextureChange("mana", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar)
    if PetFrame then
      ApplyTextureChange("mana", PetFrame.manabar or PetFrame.ManaBar or _G.PetFrameManaBar)
    end
    ApplyTextureChange("mana", TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar, nil, true)
    if FocusFrame then
      ApplyTextureChange("mana", FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar, nil, true)
    end
    if TargetFrame.totFrame then
      ApplyTextureChange("mana", TargetFrame.totFrame.ManaBar or TargetFrame.totFrame.manabar)
    end
    if FocusFrame and FocusFrame.totFrame then
      ApplyTextureChange("mana", FocusFrame.totFrame.ManaBar or FocusFrame.totFrame.manabar)
    end
    if AlternatePowerBar then
      ApplyTextureChange("mana", AlternatePowerBar, nil, nil, nil, true)
    end
    if PartyFrame then
      for i = 1, 4 do
        local frame = PartyFrame["MemberFrame" .. i]
        if frame then
          ApplyTextureChange("mana", frame.ManaBar)
        end
      end
      if PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
          ApplyTextureChange("mana", frame.ManaBar)
        end
      end
    end

    if not hooked and UnitFrameManaBar_UpdateType then
      hooksecurefunc("UnitFrameManaBar_UpdateType", function(manabar)
        if not manabar or not FCUIClassicDB.changeUnitFrameManabarTexture then
          return
        end
        ApplyTextureChange("mana", manabar, nil, true)
      end)
    end
  end

  if hooked then
    return
  end
  hooked = true
  if PlayerFrame_ToPlayerArt then
    hooksecurefunc("PlayerFrame_ToPlayerArt", function()
      if FCUIClassicDB.changeUnitFrameHealthbarTexture or FCUIClassicDB.changeUnitFrameManabarTexture then
        FCUI.HookClassicUnitFrameTextures()
      end
    end)
  end
end
