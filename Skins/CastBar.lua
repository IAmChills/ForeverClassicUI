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
  ns.SetTexture(bar.Spark, ns.ResolveArt("CastSpark"))
  if bar.Spark.SetAlpha then
    pcall(bar.Spark.SetAlpha, bar.Spark, 1)
  end
  ns.SetSize(bar.Spark, 32, 32)
end

local function ApplyClassicCastFlag(bar)
  -- Blizzard's mixin uses Classic fill/border/spark when this is set.
  ns.CaptureFlags(bar, { "classicStyleCastBar", "playCastFX" })
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
    ns.SetTexture(bar.Border, ns.ResolveArt("CastBorder"))
    ns.SetSize(bar.Border, unpack(layout.borderSize))
    ns.ClearAllPoints(bar.Border)
    ns.SetPoint(bar.Border, unpack(layout.borderPoint))
  end
  if bar.BorderShield then
    local layout = ns.Layout.CastBar
    ns.SetTexture(bar.BorderShield, ns.ResolveArt("CastShield"))
    ns.SetSize(bar.BorderShield, unpack(layout.borderSize))
    ns.ClearAllPoints(bar.BorderShield)
    ns.SetPoint(bar.BorderShield, unpack(layout.borderPoint))
  end
  ApplyClassicCastFlag(bar)

  if bar.Icon then
    ns.Hide(bar.Icon)
  end

  if not hookedLook[bar] then
    hookedLook[bar] = true
    ns.SafeHook(bar, "SetLook", function(self)
      if not ns.db or not ns.db.castBars then
        return
      end
      ApplyClassicCastFlag(self)
      if self.look ~= "UNITFRAME" and self.Icon then
        ns.Hide(self.Icon)
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
    ns.SetTexture(bar.Border, ns.ResolveArt("CastBorderSmall"))
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
