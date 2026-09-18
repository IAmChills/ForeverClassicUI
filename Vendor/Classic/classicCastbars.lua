local classicCastbarTexture = 137012

local function UpdateSparkPosition(castBar)
end

local function GetCastbarSize(castBar)
  if castBar == PlayerCastingBarFrame or castBar == PetCastingBarFrame then
    local width = FCUIClassicDB.playerCastBarWidth
    if castBar.attachedToPlayerFrame then
      width = width - 58
    end
    return width, FCUIClassicDB.playerCastBarHeight
  elseif castBar == TargetFrameSpellBar then
    return FCUIClassicDB.targetCastBarWidth, FCUIClassicDB.targetCastBarHeight
  elseif castBar == FocusFrameSpellBar then
    return FCUIClassicDB.focusCastBarWidth, FCUIClassicDB.focusCastBarHeight
  end
  return FCUIClassicDB.partyCastBarWidth, FCUIClassicDB.partyCastBarHeight
end

local function AdjustBorderSize(castBar)
  local baseWidth, baseHeight = 150, 10
  local baseBorderWidth, baseBorderHeight = 200, 54.5

  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / baseWidth
  local heightScale = barHeight / baseHeight

  castBar.Border:SetTexture(130873)
  castBar.Border:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
  castBar.Border:ClearAllPoints()
  castBar.Border:SetPoint("CENTER", castBar, "CENTER", 0, 0)
end

local function AdjustBorderShieldSize(castBar)
  local baseWidth, baseHeight = 150, 10
  local baseBorderWidth, baseBorderHeight = 196, 54.5
  local baseXOffset, baseYOffset = -28, 23
  local baseIconSize = 18
  local baseIconYOffset = 1

  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / baseWidth
  local heightScale = barHeight / baseHeight

  castBar.BorderShield:SetTexture(311862)
  castBar.BorderShield:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
  castBar.BorderShield:SetDrawLayer("OVERLAY")
  castBar.BorderShield:SetScale(1)
  castBar.BorderShield:ClearAllPoints()

  castBar.uninterruptibleIconSize = baseIconSize * ((widthScale + heightScale) / 2)
  castBar.adjustedIconYOffset = baseIconYOffset * heightScale

  castBar.BorderShield:SetPoint(
    "TOPLEFT", castBar, "TOPLEFT",
    baseXOffset * widthScale,
    baseYOffset * heightScale
  )
end

local function AdjustFlash(castBar)
  local baseWidth, baseHeight = 208, 11
  local baseOffsetX = 33
  local baseOffsetYTop = 23
  local baseOffsetYBottom = -23

  local barWidth, barHeight = GetCastbarSize(castBar)
  local widthScale = barWidth / baseWidth
  local heightScale = barHeight / baseHeight

  local offsetX = baseOffsetX * widthScale
  local offsetYTop = baseOffsetYTop * heightScale
  local offsetYBottom = baseOffsetYBottom * heightScale

  castBar.Flash:SetTexture(FCUIClassicDB.classicCastbarsPlayerBorder and 130876 or 130875)
  castBar.Flash:ClearAllPoints()
  castBar.Flash:SetPoint("TOPLEFT", castBar, "TOPLEFT", -offsetX, offsetYTop)
  castBar.Flash:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", offsetX, offsetYBottom)
  castBar.Flash:SetVertexColor(1, 0.702, 0, 1)
end

function FCUI.CastbarShakeAnimationCancel()
  if FCUI.castbarShakeAnimationCancel then
    return
  end
  hooksecurefunc(PlayerCastingBarFrame.InterruptShakeAnim, "Play", function(self)
    self:Stop()
  end)
  FCUI.castbarShakeAnimationCancel = true
end

function FCUI.ClassicCastbar(castBar, unitType)
  local isParty = unitType == "party"
  local isPlayer = unitType == "player"

  local textOffset
  if isPlayer then
    textOffset = FCUIClassicDB.classicCastbarsPlayerBorder and 0 or 0.5
  else
    textOffset = 0.5
  end

  castBar.Text:ClearAllPoints()
  castBar.Text:SetPoint("CENTER", castBar, "CENTER", 0, textOffset)

  castBar.Spark:SetBlendMode("ADD")
  castBar.Spark:SetDrawLayer("OVERLAY", 2)
  castBar.Icon:SetDrawLayer("OVERLAY", 2)

  if castBar.StandardGlow then
    castBar.StandardGlow:SetAtlas(nil)
    castBar.EnergyGlow:SetAtlas(nil)
    castBar.EnergyMask:SetAtlas(nil)
    castBar.ChargeFlash:SetAtlas(nil)
    castBar.ChannelShadow:SetAtlas(nil)
    castBar.BaseGlow:SetAtlas(nil)
    castBar.WispGlow:SetAtlas(nil)
    castBar.WispMask:SetAtlas(nil)
    castBar.Shine:SetAtlas(nil)
    castBar.CraftGlow:SetAtlas(nil)

    for i = 1, 3 do
      castBar["Flakes0" .. i]:SetAtlas(nil)
    end
    for i = 1, 2 do
      castBar["Sparkles0" .. i]:SetAtlas(nil)
    end
  end

  if isPlayer then
    FCUI.CastbarShakeAnimationCancel()
  end

  if not isParty then
    local unit = castBar.unit == "pet" and "player" or castBar.unit
    castBar.iconXPos = FCUIClassicDB[unit .. "CastbarIconXPos"] or 0
    castBar.iconYPos = FCUIClassicDB[unit .. "CastbarIconYPos"] or 0
  else
    castBar.iconXPos = FCUIClassicDB.partyCastbarIconXPos or 0
    castBar.iconYPos = FCUIClassicDB.partyCastbarIconYPos or 0
  end

  castBar.Icon:ClearAllPoints()
  castBar.Icon:SetPoint("RIGHT", castBar, "LEFT", -5 + castBar.iconXPos, -0.5 + castBar.iconYPos)
  castBar.Icon:SetSize(18, 18)

  AdjustBorderSize(castBar)
  AdjustBorderShieldSize(castBar)

  if not castBar.isClassicStyle then
    castBar:HookScript("OnEvent", function(self)
      self:SetStatusBarTexture(classicCastbarTexture)
      castBar.TextBorder:SetAlpha(0)
      if castBar == PlayerCastingBarFrame or castBar == PetCastingBarFrame then
        castBar.Text:ClearAllPoints()
        castBar.Text:SetPoint("CENTER", castBar, "CENTER", 0, textOffset)
        AdjustFlash(castBar)
      else
        castBar.Flash:SetAlpha(0)
      end

      self.Background:SetTexture(classicCastbarTexture)
      self.Background:SetVertexColor(0, 0, 0, 0.6)
      self.Border:SetAlpha(1)

      self.Icon:ClearAllPoints()
      self.Icon:SetPoint("RIGHT", self, "LEFT", -5 + castBar.iconXPos, -0.5 + castBar.iconYPos)
      self.Icon:SetSize(18, 18)

      AdjustBorderShieldSize(self)

      local notInterruptible
      local unitToken = self.unit
      if unitToken then
        if self.casting then
          _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unitToken)
        elseif self.channeling then
          _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unitToken)
        end
      end

      if not isPlayer then
        if notInterruptible ~= nil then
          self.Border:SetAlphaFromBoolean(notInterruptible, 0, 1)
        else
          self.Border:SetAlpha(1)
        end
      end
    end)

    hooksecurefunc(castBar.BorderShield, "SetAlpha", function()
      AdjustBorderShieldSize(castBar)
    end)

    if castBar == PlayerCastingBarFrame or castBar == PetCastingBarFrame then
      hooksecurefunc(castBar, "PlayFinishAnim", function(self)
        self:SetStatusBarTexture(classicCastbarTexture)
        AdjustFlash(castBar)
      end)
    end

    if FCUIClassicDB.classicCastbarsModernSpark then
      castBar:HookScript("OnUpdate", function(self)
        self.Spark:SetAtlas("UI-CastingBar-Pip")
        self.Spark:SetSize(6, 16)
        UpdateSparkPosition(castBar)
      end)
    else
      castBar:HookScript("OnUpdate", function(self)
        self.Spark:SetTexture(130877)
        self.Spark:SetSize(36, 36)
        UpdateSparkPosition(castBar)
      end)
    end

    castBar.textureChangedNeedsColor = true
    castBar.isClassicStyle = true
  end
end

function FCUI.ApplyClassicCastbars()
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
      if PlayerCastingBarFrame.Border then
        PlayerCastingBarFrame.Border:SetTexture(FCUIClassicDB.classicCastbarsPlayerBorder and 130874 or 130873)
      end
    end
    if PetCastingBarFrame then
      FCUI.ClassicCastbar(PetCastingBarFrame, "player")
      if PetCastingBarFrame.Border then
        PetCastingBarFrame.Border:SetTexture(FCUIClassicDB.classicCastbarsPlayerBorder and 130874 or 130873)
      end
    end
  end
end
