local _, ns = ...

local function StripModernCastArt(bar)
  if not bar or not ns.db.hideModernChrome then
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
  }
  for i = 1, #extras do
    ns.Hide(bar[extras[i]])
  end
end

local function SkinPlayerBar(bar)
  if not bar then
    return
  end

  local layout = ns.Layout.CastBar
  bar:SetSize(unpack(layout.playerSize))
  ns.SetStatusBarClassic(bar)

  if bar.Background and bar.Background.SetColorTexture then
    bar.Background:SetColorTexture(0, 0, 0, 0.5)
  end

  if bar.Border then
    bar.Border:SetTexture(ns.ResolveArt("CastBorder"))
    bar.Border:SetSize(unpack(layout.borderSize))
    bar.Border:ClearAllPoints()
    bar.Border:SetPoint(unpack(layout.borderPoint))
  end

  if bar.BorderShield then
    bar.BorderShield:SetTexture(ns.ResolveArt("CastShield"))
    bar.BorderShield:SetSize(unpack(layout.borderSize))
    bar.BorderShield:ClearAllPoints()
    bar.BorderShield:SetPoint(unpack(layout.borderPoint))
  end

  if bar.Flash then
    bar.Flash:SetTexture(ns.ResolveArt("CastFlash"))
    bar.Flash:SetSize(unpack(layout.borderSize))
    bar.Flash:ClearAllPoints()
    bar.Flash:SetPoint(unpack(layout.borderPoint))
  end

  if bar.Spark then
    bar.Spark:SetTexture(ns.ResolveArt("CastSpark"))
    bar.Spark:SetAlpha(1)
  end

  if bar.Icon then
    bar.Icon:Hide()
  end

  if bar.Text then
    bar.Text:ClearAllPoints()
    bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 1)
  end

  StripModernCastArt(bar)

  ns.SafeHook(bar, "SetLook", function(self)
    SkinPlayerBar(self)
  end)
end

local function SkinUnitBar(bar)
  if not bar then
    return
  end

  ns.SetStatusBarClassic(bar)
  if bar.Background and bar.Background.SetColorTexture then
    bar.Background:SetColorTexture(0, 0, 0, 0.5)
  end
  if bar.Border then
    bar.Border:SetTexture(ns.ResolveArt("CastBorderSmall"))
  end
  if bar.TextBorder then
    ns.Hide(bar.TextBorder)
  end
  StripModernCastArt(bar)
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
