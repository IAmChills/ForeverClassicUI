local _, ns = ...

local hookedClassification = {}

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
  if container.FrameTexture then
    ns.SetTexture(container.FrameTexture, art)
    ns.SetTexCoord(container.FrameTexture, unpack(layout.texCoord))
    ns.SetSize(container.FrameTexture, unpack(layout.textureSize))
    ns.ClearAllPoints(container.FrameTexture)
    ns.SetPoint(container.FrameTexture, unpack(layout.texturePoint))
  end

  -- Dragon is part of the Elite/Rare Classic frame files.
  ns.Hide(container.BossPortraitFrameTexture)

  local portrait = container.Portrait
  if portrait then
    ns.SetSize(portrait, layout.portrait.size, layout.portrait.size)
    ns.ClearAllPoints(portrait)
    ns.SetPoint(portrait, unpack(layout.portrait.point))
  end

  local health = ns.GetPath(main, "HealthBarsContainer.HealthBar") or main.HealthBar
  local mana = ns.GetPath(main, "ManaBar") or main.ManaBar
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)

  local flashArt = classification == "minus" and "TargetMinusFlash" or "FrameFlash"
  ns.SkinFlash(container.Flash, layout.flashTexCoord, flashArt)

  local name = main.Name
  if name then
    ns.SetWidth(name, 100)
    if name.SetJustifyH then
      pcall(name.SetJustifyH, name, "CENTER")
    end
    ns.ClearAllPoints(name)
    ns.SetPoint(name, "TOPLEFT", 37, -34)
  end

  ns.Hide(main.LevelBackgroundCircle)
  if main.LevelText then
    ns.ClearAllPoints(main.LevelText)
    ns.SetPoint(main.LevelText, "CENTER", frame, "TOPRIGHT", -51, -21)
    ns.Show(main.LevelText)
  end

  SkinTargetPvp(frame)

  local tot = frame.totFrame
  if tot then
    local totArt = ns.ResolveArt("TargetOfTarget")
    if tot.FrameTexture then
      ns.SetTexture(tot.FrameTexture, totArt)
    end
    ns.SetStatusBarClassic(tot.HealthBar)
    ns.SetStatusBarClassic(tot.ManaBar)
  end

  if not hookedClassification[frame] then
    hookedClassification[frame] = true
    ns.SafeHook(frame, "CheckClassification", function(self)
      if not ns.db or not ns.db.targetFrame then
        return
      end
      SkinRetailUnit(self)
    end)
    ns.SafeHook(frame, "CheckFaction", function(self)
      if ns.db and ns.db.targetFrame then
        SkinTargetPvp(self)
      end
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
    ns.compat.target = "TargetFrame found but expected child paths were missing. Run /fcui probe."
    ns.Print(ns.compat.target)
  end
end

ns.RegisterSkin("target", Apply)
