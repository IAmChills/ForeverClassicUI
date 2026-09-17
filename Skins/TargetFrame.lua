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

  local art = ns.ResolveArt("TargetFrame")
  if frame.unit then
    local classification = UnitClassification(frame.unit)
    if classification == "worldboss" or classification == "elite" then
      art = ns.ResolveArt("TargetElite")
    elseif classification == "rareelite" then
      art = ns.ResolveArt("TargetRareElite")
    elseif classification == "rare" then
      art = ns.ResolveArt("TargetRare")
    elseif classification == "minus" then
      art = ns.ResolveArt("TargetMinus")
    end
  end
  if container.FrameTexture then
    container.FrameTexture:SetTexture(art)
    container.FrameTexture:SetTexCoord(unpack(layout.texCoord))
    container.FrameTexture:SetSize(unpack(layout.textureSize))
    container.FrameTexture:ClearAllPoints()
    container.FrameTexture:SetPoint(unpack(layout.texturePoint))
  end

  -- Dragon is part of the Elite/Rare Classic frame files.
  ns.Hide(container.BossPortraitFrameTexture)

  local portrait = container.Portrait
  if portrait then
    portrait:SetSize(layout.portrait.size, layout.portrait.size)
    portrait:ClearAllPoints()
    portrait:SetPoint(unpack(layout.portrait.point))
  end

  local health = ns.GetPath(main, "HealthBarsContainer.HealthBar") or main.HealthBar
  local mana = ns.GetPath(main, "ManaBar") or main.ManaBar
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)
  if health then
    health:SetStatusBarColor(0, 1, 0)
  end

  ns.SkinFlash(container.Flash, layout.flashTexCoord)

  local name = main.Name
  if name then
    name:SetWidth(100)
    name:SetJustifyH("CENTER")
    name:ClearAllPoints()
    name:SetPoint("TOPLEFT", 37, -34)
  end

  ns.Hide(main.LevelBackgroundCircle)
  if main.LevelText then
    main.LevelText:ClearAllPoints()
    main.LevelText:SetPoint("CENTER", frame, "TOPRIGHT", -51, -21)
    main.LevelText:Show()
  end

  SkinTargetPvp(frame)

  local tot = frame.totFrame
  if tot then
    local totArt = ns.ResolveArt("TargetOfTarget")
    if tot.FrameTexture then
      tot.FrameTexture:SetTexture(totArt)
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
