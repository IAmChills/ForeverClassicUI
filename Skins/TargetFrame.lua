local _, ns = ...

local function HideModernTargetChrome(frame)
  if not frame or not ns.db.hideModernChrome then
    return
  end
  local ctx = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentContextual")
  local main = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentMain")
  local container = frame.TargetFrameContainer
  ns.Hide(ctx and ctx.PvpIcon)
  ns.Hide(ctx and ctx.PrestigePortrait)
  ns.Hide(ctx and ctx.PrestigeBadge)
  ns.Hide(ctx and ctx.BossIcon)
  ns.Hide(main and main.ReputationColor)
  ns.Hide(container and container.Flash)
  ns.Hide(container and container.BossPortraitFrameTexture)
end

local function SkinRetailUnit(frame)
  if not frame or not frame.TargetFrameContainer then
    return false
  end

  local layout = ns.Layout.Target
  local container = frame.TargetFrameContainer
  local main = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentMain")
  local ctx = ns.GetPath(frame, "TargetFrameContent.TargetFrameContentContextual")
  if not main then
    return false
  end

  local art = ns.ResolveArt("TargetFrame")
  if container.FrameTexture then
    container.FrameTexture:SetTexture(art)
    container.FrameTexture:SetTexCoord(unpack(layout.texCoord))
    container.FrameTexture:SetSize(unpack(layout.textureSize))
    container.FrameTexture:ClearAllPoints()
    container.FrameTexture:SetPoint(unpack(layout.texturePoint))
  end

  local portrait = container.Portrait
  if portrait then
    portrait:SetSize(layout.portrait.size, layout.portrait.size)
    portrait:ClearAllPoints()
    portrait:SetPoint(unpack(layout.portrait.point))
  end

  local health = ns.GetPath(main, "HealthBarsContainer.HealthBar") or main.HealthBar
  local mana = main.ManaBar
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)
  if health then
    health:SetStatusBarColor(0, 1, 0)
  end

  local name = main.Name
  if name then
    name:SetWidth(100)
    name:SetJustifyH("CENTER")
    name:ClearAllPoints()
    name:SetPoint("TOPLEFT", 37, -34)
  end

  HideModernTargetChrome(frame)

  local tot = frame.totFrame
  if tot then
    local totArt = ns.ResolveArt("TargetOfTarget")
    if tot.FrameTexture then
      tot.FrameTexture:SetTexture(totArt)
    end
    ns.SetStatusBarClassic(tot.HealthBar)
    ns.SetStatusBarClassic(tot.ManaBar)
  end

  ns.SafeHook(frame, "CheckClassification", function()
    ns.SetStatusBarClassic(health)
    if health then
      health:SetStatusBarColor(0, 1, 0)
    end
  end)

  return true
end

local function SkinClassicUnit(prefix)
  local texture = _G[prefix .. "Texture"] or _G[prefix .. "TextureFrameTexture"]
  if texture then
    texture:SetTexture(ns.ResolveArt("TargetFrame"))
  end
  ns.SetStatusBarClassic(_G[prefix .. "HealthBar"])
  ns.SetStatusBarClassic(_G[prefix .. "ManaBar"])
  return texture ~= nil
end

local function Apply()
  local layout = ns.DetectLayout()
  local ok = false
  if layout == "retail10" then
    ok = SkinRetailUnit(TargetFrame)
    if FocusFrame then
      SkinRetailUnit(FocusFrame)
    end
  elseif layout == "classic" then
    ok = SkinClassicUnit("TargetFrame")
    if _G.FocusFrame then
      SkinClassicUnit("FocusFrame")
    end
  end

  if not ok and TargetFrame then
    ns.compat.target = "TargetFrame found but expected child paths were missing. Run /fcui probe."
    ns.Print(ns.compat.target)
  end
end

ns.RegisterSkin("target", Apply)
