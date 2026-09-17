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
  if bar.SetLook then
    bar:SetLook(bar.look or "CLASSIC")
  else
    local layout = ns.Layout.CastBar
    bar:SetSize(unpack(layout.playerSize))
    if bar.Border then
      bar.Border:SetTexture(ns.ResolveArt("CastBorder"))
      bar.Border:SetSize(unpack(layout.borderSize))
      bar.Border:ClearAllPoints()
      bar.Border:SetPoint(unpack(layout.borderPoint))
    end
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
  if bar.SetLook then
    bar:SetLook(bar.look or "UNITFRAME")
  elseif bar.Border then
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
  local playerBar = ns.FirstExisting("PlayerCastingBarFrame", "CastingBarFrame")
  if playerBar then
    SkinPlayerBar(playerBar)
  else
    ns.compat.castbar = "No player cast bar global found."
  end

  if TargetFrame and TargetFrame.spellbar then
    SkinUnitBar(TargetFrame.spellbar)
  elseif _G.TargetFrameSpellBar then
    SkinUnitBar(_G.TargetFrameSpellBar)
  end

  if FocusFrame and FocusFrame.spellbar then
    SkinUnitBar(FocusFrame.spellbar)
  elseif _G.FocusFrameSpellBar then
    SkinUnitBar(_G.FocusFrameSpellBar)
  end
end

ns.RegisterSkin("castbar", Apply)
