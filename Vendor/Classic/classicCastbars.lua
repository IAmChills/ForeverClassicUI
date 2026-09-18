-- Classic cast bars.
--
-- Target/focus cast values are secret. Never replace ShowSpark/HideSpark/OnUpdate
-- on those bars — that taints HandleCastStart and breaks startTime arithmetic.
-- Never set classicStyleCastBar on them either (secret barTypeInfo colors).
-- Chrome + classic fill apply via hooksecurefunc / next-frame only. Keep .Spark
-- so Blizzard's secure OnUpdate can position it; restyle the texture after ShowSpark.

local CLASSIC_FILL = "Interface\\TargetingFrame\\UI-StatusBar"
local CLASSIC_SPARK = "Interface\\CastingBar\\UI-CastingBar-Spark"
local CLASSIC_BORDER = 130873
local CLASSIC_SHIELD = 311862

local CAST_YELLOW = { 1.0, 0.7, 0.0 }
local CAST_GREEN = { 0.0, 1.0, 0.0 }

local function IsPlayerCastBar(castBar)
  return castBar == PlayerCastingBarFrame or castBar == PetCastingBarFrame
end

local function IsUnitSpellBar(castBar)
  return castBar == TargetFrameSpellBar or castBar == FocusFrameSpellBar
end

local function GetCastbarSize(castBar)
  if IsPlayerCastBar(castBar) then
    local width = FCUIClassicDB.playerCastBarWidth or 205
    if castBar.attachedToPlayerFrame then
      width = width - 58
    end
    return width, FCUIClassicDB.playerCastBarHeight or 12.5
  elseif castBar == TargetFrameSpellBar then
    return FCUIClassicDB.targetCastBarWidth or 143, FCUIClassicDB.targetCastBarHeight or 10
  elseif castBar == FocusFrameSpellBar then
    return FCUIClassicDB.focusCastBarWidth or 143, FCUIClassicDB.focusCastBarHeight or 10
  end
  return 150, 10
end

local function ApplyCastbarSize(castBar)
  if not castBar then
    return
  end
  local width, height = GetCastbarSize(castBar)
  castBar:SetWidth(width)
  castBar:SetHeight(height)
  if castBar.Text and castBar.Text.SetWidth then
    castBar.Text:SetWidth(width)
  end
end

local function StyleUnitSpark(castBar)
  local spark = castBar and castBar.Spark
  if not spark then
    return
  end
  if spark.SetAtlas then
    spark:SetAtlas(nil)
  end
  spark:SetTexture(CLASSIC_SPARK)
  spark:SetTexCoord(0, 1, 0, 1)
  spark:SetSize(32, 32)
  spark:SetBlendMode("ADD")
  spark:SetDrawLayer("OVERLAY", 7)
  spark:SetAlpha(1)
  spark.offsetY = 0
end

local function ApplyClassicFill(castBar, isFull)
  if not castBar or not castBar.SetStatusBarTexture then
    return
  end
  castBar:SetStatusBarTexture(CLASSIC_FILL)
  local c = isFull and CAST_GREEN or CAST_YELLOW
  castBar:SetStatusBarColor(c[1], c[2], c[3])
end

local function AdjustBorderSize(castBar)
  if not castBar or not castBar.Border then
    return
  end
  local baseWidth, baseHeight = 150, 10
  local baseBorderWidth, baseBorderHeight = 200, 54.5
  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / baseWidth
  local heightScale = barHeight / baseHeight
  local borderTex = CLASSIC_BORDER
  if IsPlayerCastBar(castBar) and FCUIClassicDB.classicCastbarsPlayerBorder then
    borderTex = 130874
  end

  if castBar.Border.SetAtlas then
    castBar.Border:SetAtlas(nil)
  end
  castBar.Border:SetTexture(borderTex)
  castBar.Border:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
  castBar.Border:ClearAllPoints()
  castBar.Border:SetPoint("CENTER", castBar, "CENTER", 0, 0)
  castBar.Border:SetAlpha(1)
end

local function AdjustBorderShieldSize(castBar)
  if not castBar or not castBar.BorderShield then
    return
  end
  local baseWidth, baseHeight = 150, 10
  local baseBorderWidth, baseBorderHeight = 196, 54.5
  local baseXOffset, baseYOffset = -28, 23
  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / baseWidth
  local heightScale = barHeight / baseHeight

  if castBar.BorderShield.SetAtlas then
    castBar.BorderShield:SetAtlas(nil)
  end
  castBar.BorderShield:SetTexture(CLASSIC_SHIELD)
  castBar.BorderShield:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
  castBar.BorderShield:SetDrawLayer("OVERLAY")
  castBar.BorderShield:SetScale(1)
  castBar.BorderShield:ClearAllPoints()
  castBar.BorderShield:SetPoint(
    "TOPLEFT", castBar, "TOPLEFT",
    baseXOffset * widthScale,
    baseYOffset * heightScale
  )
end

local function AdjustFlash(castBar)
  if not castBar or not castBar.Flash then
    return
  end
  if IsUnitSpellBar(castBar) then
    castBar.Flash:SetAlpha(0)
    return
  end
  local baseOffsetX = 33
  local baseOffsetYTop = 23
  local baseOffsetYBottom = -23
  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / 208
  local heightScale = barHeight / 11

  castBar.Flash:SetTexture(FCUIClassicDB.classicCastbarsPlayerBorder and 130876 or 130875)
  castBar.Flash:ClearAllPoints()
  castBar.Flash:SetPoint("TOPLEFT", castBar, "TOPLEFT", -(baseOffsetX * widthScale), baseOffsetYTop * heightScale)
  castBar.Flash:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", baseOffsetX * widthScale, baseOffsetYBottom * heightScale)
  castBar.Flash:SetVertexColor(1, 0.702, 0, 1)
end

local function AdjustSpark(castBar)
  if IsUnitSpellBar(castBar) then
    StyleUnitSpark(castBar)
    return
  end
  if not castBar or not castBar.Spark then
    return
  end
  if FCUIClassicDB.classicCastbarsModernSpark then
    castBar.Spark:SetAtlas("UI-CastingBar-Pip")
    castBar.Spark:SetSize(6, 16)
  else
    if castBar.Spark.SetAtlas then
      castBar.Spark:SetAtlas(nil)
    end
    castBar.Spark:SetTexture(CLASSIC_SPARK)
    castBar.Spark:SetSize(32, 32)
  end
  castBar.Spark:SetBlendMode("ADD")
  castBar.Spark:SetDrawLayer("OVERLAY", 2)
end

local function AdjustIcon(castBar)
  if not castBar or not castBar.Icon then
    return
  end
  local x = castBar.iconXPos or 0
  local y = castBar.iconYPos or 0
  castBar.Icon:ClearAllPoints()
  castBar.Icon:SetPoint("RIGHT", castBar, "LEFT", -5 + x, -0.5 + y)
  castBar.Icon:SetSize(18, 18)
  castBar.Icon:SetDrawLayer("OVERLAY", 2)
end

local function AdjustBackground(castBar)
  if not castBar or not castBar.Background then
    return
  end
  if castBar.Background.SetAtlas then
    castBar.Background:SetAtlas(nil)
  end
  castBar.Background:SetTexture(CLASSIC_FILL)
  castBar.Background:SetVertexColor(0, 0, 0, 0.6)
end

local function SilenceModernFx(castBar)
  if not castBar.StandardGlow then
    return
  end
  castBar.StandardGlow:SetAtlas(nil)
  local keys = {
    "EnergyGlow", "EnergyMask", "ChargeFlash", "ChannelShadow", "BaseGlow",
    "WispGlow", "WispMask", "Shine", "CraftGlow",
  }
  for i = 1, #keys do
    local region = castBar[keys[i]]
    if region and region.SetAtlas then
      region:SetAtlas(nil)
    end
  end
  for i = 1, 3 do
    local flake = castBar["Flakes0" .. i]
    if flake and flake.SetAtlas then
      flake:SetAtlas(nil)
    end
  end
  for i = 1, 2 do
    local sparkle = castBar["Sparkles0" .. i]
    if sparkle and sparkle.SetAtlas then
      sparkle:SetAtlas(nil)
    end
  end
end

local function ApplyChrome(castBar)
  ApplyCastbarSize(castBar)
  AdjustBorderSize(castBar)
  AdjustBorderShieldSize(castBar)
  AdjustSpark(castBar)
  AdjustIcon(castBar)
  AdjustBackground(castBar)
  AdjustFlash(castBar)
  if castBar.TextBorder then
    castBar.TextBorder:SetAlpha(0)
  end
end

local function DeferredUnitChrome(castBar, isFull)
  if not castBar or not FCUIClassicDB.classicCastbars then
    return
  end
  ApplyClassicFill(castBar, isFull)
  ApplyChrome(castBar)
end

local function QueueUnitChrome(castBar, isFull)
  if not C_Timer or not C_Timer.After then
    DeferredUnitChrome(castBar, isFull)
    return
  end
  C_Timer.After(0, function()
    DeferredUnitChrome(castBar, isFull)
  end)
end

-- Undo a prior bad replace that tainted HandleCastStart.
local function RestoreBlizzardSparkMethods(castBar)
  if not castBar or not castBar.fcuiSparkMethodsReplaced then
    return
  end
  local mixin = TargetSpellBarMixin or CastingBarMixin
  if mixin then
    if mixin.ShowSpark then
      castBar.ShowSpark = mixin.ShowSpark
    end
    if mixin.HideSpark then
      castBar.HideSpark = mixin.HideSpark
    end
  end
  castBar.fcuiSparkMethodsReplaced = nil
  -- Hide leftover addon spark if present.
  if castBar.fcuiSpark then
    castBar.fcuiSpark:Hide()
  end
  castBar.fcuiSparkDetached = nil
end

local function HookUpdateBarFill(target)
  if not target then
    return
  end
  hooksecurefunc(target, "UpdateBarFillTexture", function(self, isFull)
    if not IsUnitSpellBar(self) or not FCUIClassicDB.classicCastbars then
      return
    end
    QueueUnitChrome(self, isFull)
  end)
end

local function HookShowSpark(target)
  if not target then
    return
  end
  hooksecurefunc(target, "ShowSpark", function(self)
    if not IsUnitSpellBar(self) or not FCUIClassicDB.classicCastbars then
      return
    end
    StyleUnitSpark(self)
  end)
end

local function AnchorUnitCastbar(castBar)
  if not castBar or not IsUnitSpellBar(castBar) or not FCUIClassicDB.classicCastbars then
    return
  end
  local parent = castBar:GetParent()
  if not parent then
    return
  end
  -- Seat under the unit frame, not the aura container (that drops it much lower).
  local x = parent.smallSize and 38 or 43
  local y = parent.smallSize and 3 or 5
  if parent.haveToT then
    y = parent.smallSize and -40 or -38
  end
  if castBar.ClearPointsOffset then
    castBar:ClearPointsOffset()
  end
  castBar:ClearAllPoints()
  castBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", x, y)
end

local function QueueUnitCastbarAnchor(castBar)
  -- AdjustPosition runs in the same OnEvent as HandleCastStart — defer so we
  -- do not taint secret cast timing.
  if not C_Timer or not C_Timer.After then
    AnchorUnitCastbar(castBar)
    return
  end
  C_Timer.After(0, function()
    AnchorUnitCastbar(castBar)
  end)
end

local function HookAdjustPosition(castBar)
  if not castBar or castBar.fcuiAdjustPositionHooked or not castBar.AdjustPosition then
    return
  end
  castBar.fcuiAdjustPositionHooked = true
  hooksecurefunc(castBar, "AdjustPosition", function(self)
    QueueUnitCastbarAnchor(self)
  end)
end

local unitSpellBarHooks
local function EnsureUnitSpellBarHooks()
  if unitSpellBarHooks then
    return
  end
  unitSpellBarHooks = true

  if CastingBarMixin then
    HookUpdateBarFill(CastingBarMixin)
    HookShowSpark(CastingBarMixin)
  end
  if TargetFrameSpellBar then
    HookUpdateBarFill(TargetFrameSpellBar)
    HookShowSpark(TargetFrameSpellBar)
    HookAdjustPosition(TargetFrameSpellBar)
  end
  if FocusFrameSpellBar then
    HookUpdateBarFill(FocusFrameSpellBar)
    HookShowSpark(FocusFrameSpellBar)
    HookAdjustPosition(FocusFrameSpellBar)
  end
end

function FCUI.CastbarShakeAnimationCancel()
  if FCUI.castbarShakeAnimationCancel then
    return
  end
  if PlayerCastingBarFrame and PlayerCastingBarFrame.InterruptShakeAnim then
    hooksecurefunc(PlayerCastingBarFrame.InterruptShakeAnim, "Play", function(self)
      self:Stop()
    end)
  end
  FCUI.castbarShakeAnimationCancel = true
end

function FCUI.ClassicCastbar(castBar, unitType)
  if not castBar then
    return
  end

  local isUnit = unitType == "target" or unitType == "focus" or IsUnitSpellBar(castBar)
  local isPlayer = unitType == "player" or IsPlayerCastBar(castBar)

  if isUnit then
    RestoreBlizzardSparkMethods(castBar)
    -- Do not set classicStyleCastBar — secret barTypeInfo path.
    castBar.classicStyleCastBar = nil
    HookAdjustPosition(castBar)
  else
    castBar.classicStyleCastBar = true
  end

  local textOffset = 0.5
  if isPlayer and FCUIClassicDB.classicCastbarsPlayerBorder then
    textOffset = 0
  end
  if castBar.Text then
    castBar.Text:ClearAllPoints()
    castBar.Text:SetPoint("CENTER", castBar, "CENTER", 0, textOffset)
  end

  SilenceModernFx(castBar)

  if isPlayer then
    FCUI.CastbarShakeAnimationCancel()
  end

  if not isUnit then
    local unit = castBar.unit == "pet" and "player" or (castBar.unit or "player")
    castBar.iconXPos = FCUIClassicDB[unit .. "CastbarIconXPos"] or 0
    castBar.iconYPos = FCUIClassicDB[unit .. "CastbarIconYPos"] or 0
  else
    local prefix = castBar == FocusFrameSpellBar and "focus" or "target"
    castBar.iconXPos = FCUIClassicDB[prefix .. "CastbarIconXPos"] or 0
    castBar.iconYPos = FCUIClassicDB[prefix .. "CastbarIconYPos"] or 0
  end

  ApplyChrome(castBar)

  if isUnit then
    ApplyClassicFill(castBar, false)
    AnchorUnitCastbar(castBar)
  elseif castBar.UpdateBarFillTexture then
    pcall(castBar.UpdateBarFillTexture, castBar, false)
  end
end

function FCUI.ApplyClassicCastbars()
  EnsureUnitSpellBarHooks()

  if FCUIClassicDB.classicCastbars then
    if TargetFrameSpellBar then
      FCUI.ClassicCastbar(TargetFrameSpellBar, "target")
    end
    if FocusFrameSpellBar then
      FCUI.ClassicCastbar(FocusFrameSpellBar, "focus")
    end
  end

  if FCUIClassicDB.classicCastbarsPlayer then
    if PlayerCastingBarFrame then
      FCUI.ClassicCastbar(PlayerCastingBarFrame, "player")
    end
    if PetCastingBarFrame then
      FCUI.ClassicCastbar(PetCastingBarFrame, "player")
    end
  end
end
