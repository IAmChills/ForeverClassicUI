local _, ns = ...

local hookedLook = {}

local followerFx = {
  "BaseGlow",
  "WispGlow",
  "Sparkles01",
  "Sparkles02",
  "Shine",
  "StandardGlow",
  "ChannelShadow",
  "CraftGlow",
  "CraftingGlow",
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

local function StripModernCastArt(bar)
  if not bar then
    return
  end
  for i = 1, #followerFx do
    ns.Hide(bar[followerFx[i]])
  end
end

local function RestoreClassicSpark(bar)
  local spark = bar and bar.Spark
  if not spark then
    return
  end
  ns.SetTexture(spark, ns.ResolveArt("CastSpark"))
  ns.SetTexCoord(spark, 0, 1, 0, 1)
  if spark.SetBlendMode then
    pcall(spark.SetBlendMode, spark, "ADD")
  end
  ns.SetSize(spark, 32, 32)
  spark.offsetY = -1
  if spark.SetAlpha then
    pcall(spark.SetAlpha, spark, 1)
  end
end

-- Player bar only. Target/focus barType is secret; classicStyleCastBar
-- makes Blizzard index that secret table while this addon has tainted the click.
local function ApplyPlayerClassicCast(bar)
  ns.CaptureFlags(bar, { "classicStyleCastBar", "playCastFX" })
  bar.classicStyleCastBar = true
  bar.playCastFX = false
  StripModernCastArt(bar)
  RestoreClassicSpark(bar)
end

local function HookPlayerBar(bar)
  if hookedLook[bar] then
    return
  end
  hookedLook[bar] = true
  ns.SafeHook(bar, "SetLook", function(self)
    if not ns.db or not ns.db.castBars then
      return
    end
    ApplyPlayerClassicCast(self)
    if self.look ~= "UNITFRAME" and self.Icon then
      ns.Hide(self.Icon)
    end
  end)
  ns.SafeHook(bar, "ShowSpark", function(self)
    if not ns.db or not ns.db.castBars then
      return
    end
    RestoreClassicSpark(self)
    StripModernCastArt(self)
  end)
end

local function SkinPlayerBar(bar)
  if not bar then
    return
  end

  ApplyPlayerClassicCast(bar)
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
  if bar.Icon then
    ns.Hide(bar.Icon)
  end
  HookPlayerBar(bar)
end

local function SkinUnitBar(bar)
  if not bar then
    return
  end
  -- Texture-only. Do not set classicStyleCastBar or hook ShowSpark:
  -- target casts use secret barType and UpdateBarFillTexture errors if tainted.
  if bar.Border then
    ns.SetTexture(bar.Border, ns.ResolveArt("CastBorderSmall"))
  end
  StripModernCastArt(bar)
  RestoreClassicSpark(bar)
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
