local _, ns = ...

local MODERN_CHROME = {
  "PlayerFrameContent.PlayerFrameContentContextual.RoleIcon",
  "PlayerFrameContent.PlayerFrameContentContextual.AttackIcon",
  "PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon",
  "PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait",
  "PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge",
  "PlayerFrameContent.PlayerFrameContentContextual.PVPIcon",
  "PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop",
  "PlayerFrameContent.PlayerFrameContentMain.StatusTexture",
  "PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle",
  "PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle",
  "PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon",
  "PlayerFrameContainer.FrameFlash",
}

local function SkinRetail10()
  local layout = ns.Layout.Player
  local container = PlayerFrame.PlayerFrameContainer
  local content = PlayerFrame.PlayerFrameContent
  local main = content and content.PlayerFrameContentMain
  local contextual = content and content.PlayerFrameContentContextual
  if not container or not main then
    error("retail10 player frame paths missing")
  end

  local art = ns.ResolveArt("PlayerFrame")
  if container.FrameTexture then
    container.FrameTexture:SetTexture(art)
    container.FrameTexture:SetTexCoord(unpack(layout.texCoord))
    container.FrameTexture:SetSize(unpack(layout.textureSize))
    container.FrameTexture:ClearAllPoints()
    container.FrameTexture:SetPoint(unpack(layout.texturePoint))
    container.FrameTexture:SetDrawLayer("BORDER")
  end

  if container.AlternatePowerFrameTexture then
    container.AlternatePowerFrameTexture:SetTexture(art)
    container.AlternatePowerFrameTexture:SetTexCoord(unpack(layout.texCoord))
  end

  local portrait = container.PlayerPortrait
  if portrait then
    portrait:SetSize(layout.portrait.size, layout.portrait.size)
    portrait:ClearAllPoints()
    portrait:SetPoint(unpack(layout.portrait.point))
  end

  local mask = container.PlayerPortraitMask
  if mask then
    mask:SetTexture(ns.ResolveArt("PortraitMask"))
    mask:SetSize(layout.portrait.size, layout.portrait.size)
    mask:ClearAllPoints()
    mask:SetPoint(unpack(layout.portrait.point))
  end

  local health = ns.GetPath(main, "HealthBarsContainer.HealthBar")
  local mana = ns.GetPath(main, "ManaBarArea.ManaBar")
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)
  if health then
    health:SetStatusBarColor(0, 1, 0)
  end

  ns.Hide(ns.GetPath(main, "LevelBackgroundCircle"))

  if PlayerName then
    PlayerName:SetWidth(100)
    PlayerName:SetJustifyH("CENTER")
    PlayerName:ClearAllPoints()
    PlayerName:SetPoint("TOPLEFT", 97, -34)
  end

  if ns.db.hideModernChrome then
    ns.HideTree(PlayerFrame, MODERN_CHROME)
    ns.Hide(_G.PlayerPVPTimerText)
    if contextual and contextual.PlayerRestLoop and contextual.PlayerRestLoop.PlayerRestLoopAnim then
      contextual.PlayerRestLoop.PlayerRestLoopAnim:Stop()
    end
  end

  -- Level number sits on the Classic frame, not in the HUD circle.
  if PlayerLevelText then
    PlayerLevelText:ClearAllPoints()
    PlayerLevelText:SetPoint("CENTER", PlayerFrame, "TOPLEFT", 51, -21)
    PlayerLevelText:Show()
  end
end

local function SkinClassic()
  -- Frame is already Classic-shaped; only strip extra overlays.
  if ns.db.hideModernChrome then
    ns.Hide(_G.PlayerFrameGroupIndicatorLeft)
    ns.Hide(_G.PlayerPVPIcon)
  end
  ns.SetStatusBarClassic(_G.PlayerFrameHealthBar)
  ns.SetStatusBarClassic(_G.PlayerFrameManaBar)
end

local function SkinUnknown()
  ns.compat.player = "PlayerFrame exists but neither retail10 nor classic paths matched. Run /fcui probe."
  ns.Print(ns.compat.player)
end

local appliedHooks

local function Apply()
  local layout = ns.DetectLayout()
  if layout == "retail10" then
    SkinRetail10()
  elseif layout == "classic" then
    SkinClassic()
  else
    SkinUnknown()
    return
  end

  if appliedHooks then
    return
  end
  appliedHooks = true

  ns.SafeHook("PlayerFrame_ToPlayerArt", function()
    if ns.db and ns.db.playerFrame then
      Apply()
    end
  end)
  ns.SafeHook("PlayerFrame_UpdateStatus", function()
    if ns.db and ns.db.hideModernChrome then
      ns.Hide(ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain.StatusTexture"))
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePlayerRestLoop", function()
    if ns.db and ns.db.hideModernChrome then
      local rest = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop")
      if rest then
        rest:Hide()
        if rest.PlayerRestLoopAnim then
          rest.PlayerRestLoopAnim:Stop()
        end
      end
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePvPStatus", function()
    if ns.db and ns.db.hideModernChrome then
      ns.Hide(ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle"))
      ns.Hide(ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon"))
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePlayerNameTextAnchor", function()
    if ns.db and ns.db.playerFrame and PlayerName then
      PlayerName:SetWidth(100)
      PlayerName:SetJustifyH("CENTER")
      PlayerName:ClearAllPoints()
      PlayerName:SetPoint("TOPLEFT", 97, -34)
    end
  end)
end

ns.RegisterSkin("player", Apply)
