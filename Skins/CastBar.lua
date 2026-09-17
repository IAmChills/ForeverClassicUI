local _, ns = ...

local hookedLook = {}

local function StripModernCastArt(bar)
  if not bar then
    return
  end
  local extras = {
    "BaseGlow",
    "WispGlow",
    "Sparkles01",
    "Sparkles02",
    "Shine",
    "StandardGlow",
    "ChannelShadow",
    "CraftGlow",
    "EnergyGlow",
    "Flakes01",
    "Flakes02",
    "Flakes03",
    "TextBorder",
    "DropShadow",
    "ChargeGlow",
    "ChargeFlash",
    "InterruptGlow",
  }
  for i = 1, #extras do
    ns.Hide(bar[extras[i]])
  end
end

local function RestoreClassicSpark(bar)
  if not bar or not bar.Spark then
    return
  end
  bar.Spark:SetTexture(ns.ResolveArt("CastSpark"))
  bar.Spark:SetAlpha(1)
  bar.Spark:SetSize(32, 32)
end

local function ApplyClassicCastFlag(bar)
  -- Blizzard's mixin uses Classic fill/border/spark when this is set.
  bar.classicStyleCastBar = true
  bar.playCastFX = false
  StripModernCastArt(bar)
  RestoreClassicSpark(bar)
end

local function SkinPlayerBar(bar)
  if not bar then
    return
  end

  ApplyClassicCastFlag(bar)
  if bar.Border then
    local layout = ns.Layout.CastBar
    bar.Border:SetTexture(ns.ResolveArt("CastBorder"))
    bar.Border:SetSize(unpack(layout.borderSize))
    bar.Border:ClearAllPoints()
    bar.Border:SetPoint(unpack(layout.borderPoint))
  end
  if bar.BorderShield then
    local layout = ns.Layout.CastBar
    bar.BorderShield:SetTexture(ns.ResolveArt("CastShield"))
    bar.BorderShield:SetSize(unpack(layout.borderSize))
    bar.BorderShield:ClearAllPoints()
    bar.BorderShield:SetPoint(unpack(layout.borderPoint))
  end
  ApplyClassicCastFlag(bar)

  if bar.Icon then
    bar.Icon:Hide()
  end

  if not hookedLook[bar] then
    hookedLook[bar] = true
    ns.SafeHook(bar, "SetLook", function(self)
      if not ns.db or not ns.db.castBars then
        return
      end
      ApplyClassicCastFlag(self)
      if self.look ~= "UNITFRAME" and self.Icon then
        self.Icon:Hide()
      end
    end)
  end
end

local function SkinUnitBar(bar)
  if not bar then
    return
  end

  ApplyClassicCastFlag(bar)
  if bar.Border then
    bar.Border:SetTexture(ns.ResolveArt("CastBorderSmall"))
  end
  ApplyClassicCastFlag(bar)

  if not hookedLook[bar] then
    hookedLook[bar] = true
    ns.SafeHook(bar, "SetLook", function(self)
      if not ns.db or not ns.db.castBars then
        return
      end
      ApplyClassicCastFlag(self)
    end)
  end
end

local function Apply()
  local playerBar = _G.PlayerCastingBarFrame
  if playerBar then
    SkinPlayerBar(playerBar)
  else
    ns.compat.castbar = "PlayerCastingBarFrame missing."
  end

  if TargetFrame and TargetFrame.spellbar then
    SkinUnitBar(TargetFrame.spellbar)
  end

  if FocusFrame and FocusFrame.spellbar then
    SkinUnitBar(FocusFrame.spellbar)
  end
end

ns.RegisterSkin("castbar", Apply)
