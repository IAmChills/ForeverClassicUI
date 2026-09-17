local _, ns = ...

local hookedClassification = {}
local pending = {}

local function SkinTargetPvp(frame)
  if not frame then
    return
  end
  local ctx = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentContextual")
  local unit = frame.unit
  ns.SkinPvpIcon(ctx and ctx.PvpBackgroundIcon, unit)
  ns.SkinPvpIcon(ctx and ctx.PvpIcon, unit)
end

local function ClassificationArt(classification)
  if classification == "worldboss" or classification == "elite" then
    return ns.ResolveArt("TargetElite")
  end
  if classification == "rareelite" then
    return ns.ResolveArt("TargetRareElite")
  end
  if classification == "rare" then
    return ns.ResolveArt("TargetRare")
  end
  if classification == "minus" then
    return ns.ResolveArt("TargetMinus")
  end
  return ns.ResolveArt("TargetFrame")
end

local function SkinToT(frame)
  local tot = frame.totFrame
  if not tot then
    tot = (frame == FocusFrame) and _G.FocusFrameToT or _G.TargetFrameToT
  end
  if not tot then
    return
  end

  local layout = ns.Layout.ToT
  local function targetOn()
    return ns.db and ns.db.targetFrame and true or false
  end

  -- Forever ToT FrameTexture uses useAtlasSize; a bare SetTexture leaves Classic
  -- art at its native ~93x45 cell while the portrait stays Forever-sized.
  ns.SilenceNativeChrome(tot.FrameTexture, targetOn)

  local tw = layout.textureSize[1]
  local th = layout.textureSize[2]
  if tot.GetWidth then
    local ok, w = pcall(tot.GetWidth, tot)
    if ok then
      tw = ns.PublicNumber(w, tw)
    end
  end
  if tot.GetHeight then
    local ok, h = pcall(tot.GetHeight, tot)
    if ok then
      th = ns.PublicNumber(h, th)
    end
  end

  ns.PlaceClassicUnitBackground(tot, tot, layout)

  local chrome = ns.EnsureUnitChrome(tot, "fcuiChrome")
  -- Stretch Classic art to Forever ToT bounds (120x49), not native ~93x45.
  ns.PlaceClassicChrome(chrome, tot, {
    texturePoint = layout.texturePoint,
    textureSize = { tw, th },
    texCoord = layout.texCoord,
  }, ns.ResolveArt("TargetOfTarget"))
  if chrome then
    ns.Show(chrome)
  end
  if tot.FrameTexture then
    ns.HookChromeReset(tot.FrameTexture, function()
      SkinToT(frame)
    end, targetOn)
  end

  ns.PlaceClassicPortrait(tot.Portrait, tot.PortraitMask, tot, layout)

  local health = tot.HealthBar
  local mana = tot.ManaBar
  ns.HideBarMasks(health)
  ns.HideBarMasks(mana)
  if health and layout.health then
    local point, x, y = unpack(layout.health.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(layout.health.size)
    ns.PlaceUnitSlot(health, tot, point, point, x, y, w, h)
  end
  if mana and layout.mana then
    local point, x, y = unpack(layout.mana.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(layout.mana.size)
    ns.PlaceUnitSlot(mana, tot, point, point, x, y, w, h)
  end

  if tot.Name and layout.name then
    local point, x, y = unpack(layout.name.point)
    x, y = ns.LayoutXY(layout, x, y)
    ns.PlaceOn(tot.Name, tot, point, "TOPLEFT", x, y, layout.name.width, 10)
  end
end

local function SkinRetailUnit(frame)
  if not frame or not frame.TargetFrameContainer then
    return false
  end

  local layout = ns.Layout.Target
  local container = frame.TargetFrameContainer
  local main = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentMain")
  if not main then
    return false
  end

  local classification = frame.unit and UnitClassification(frame.unit)
  local art = ClassificationArt(classification)

  local function targetOn()
    return ns.db and ns.db.targetFrame and true or false
  end

  ns.SilenceNativeChrome(container.FrameTexture, targetOn)
  ns.Hide(container.BossPortraitFrameTexture)
  ns.SilenceNativeChrome(container.Flash, targetOn)

  -- Dark plate + Classic NameBackground (replaces Forever ReputationColor atlas).
  ns.PlaceClassicUnitBackground(container, frame, layout)
  if main.ReputationColor then
    ns.PlaceClassicNameBackground(main.ReputationColor, frame, layout)
  end

  local chrome = ns.EnsureUnitChrome(container, "fcuiChrome")
  ns.PlaceClassicChrome(chrome, frame, layout, art)
  if chrome then
    ns.Show(chrome)
  end
  if container.FrameTexture then
    ns.HookChromeReset(container.FrameTexture, function()
      SkinRetailUnit(frame)
    end, targetOn)
  end

  ns.PlaceClassicPortrait(container.Portrait, container.PortraitMask, frame, layout)

  local healthBox = main.HealthBarsContainer
  local manaBar = main.ManaBar
  ns.PlaceClassicBars(frame, layout, healthBox, manaBar)

  local flashArt = classification == "minus" and "TargetMinusFlash" or "FrameFlash"
  local flash = ns.EnsureUnitChrome(container, "fcuiFlash")
  ns.PlaceClassicFlash(flash, frame, layout, ns.ResolveArt(flashArt))
  ns.SyncOverlayShown(container.Flash, flash, targetOn)

  ns.PlaceClassicName(main.Name, frame, layout)
  ns.Hide(main.LevelBackgroundCircle)
  ns.PlaceClassicLevel(main.LevelText, frame, layout)

  SkinTargetPvp(frame)
  SkinToT(frame)

  if not hookedClassification[frame] then
    hookedClassification[frame] = true
    ns.SafeHook(frame, "CheckClassification", function(self)
      if not ns.db or not ns.db.targetFrame or pending[self] then
        return
      end
      pending[self] = true
      C_Timer.After(0, function()
        pending[self] = nil
        if ns.db and ns.db.targetFrame then
          SkinRetailUnit(self)
        end
      end)
    end)
    ns.SafeHook(frame, "CheckFaction", function(self)
      if not ns.db or not ns.db.targetFrame then
        return
      end
      C_Timer.After(0, function()
        if ns.db and ns.db.targetFrame then
          SkinTargetPvp(self)
        end
      end)
    end)
  end

  return true
end

local function Apply()
  local ok = SkinRetailUnit(TargetFrame)
  if FocusFrame then
    SkinRetailUnit(FocusFrame)
  end

  if not ok and TargetFrame then
    ns.compat.target = "TargetFrame found but expected child paths were missing."
    ns.Print(ns.compat.target)
  end
end

ns.RegisterSkin("target", Apply)
