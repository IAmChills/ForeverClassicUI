local _, ns = ...

local function SkinPvp()
  local main = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain")
  local contextual = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentContextual")
  ns.SkinPvpIcon(main and main.PvpBackgroundIcon, "player")
  ns.SkinPvpIcon(contextual and contextual.PVPIcon, "player")
end

local function SkinRetail10()
  local layout = ns.Layout.Player
  local container = PlayerFrame.PlayerFrameContainer
  local content = PlayerFrame.PlayerFrameContent
  local main = content and content.PlayerFrameContentMain
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

  ns.SkinFlash(container.FrameFlash, layout.flashTexCoord)

  local status = main.StatusTexture
  if status and status.SetTexture then
    status:SetTexture(ns.ResolveArt("PlayerStatus"))
  end

  -- Forever HUD circle; Classic draws the number on the frame itself.
  ns.Hide(main.LevelBackgroundCircle)

  if PlayerName then
    PlayerName:SetWidth(100)
    PlayerName:SetJustifyH("CENTER")
    PlayerName:ClearAllPoints()
    PlayerName:SetPoint("TOPLEFT", 97, -34)
  end

  if PlayerLevelText then
    PlayerLevelText:ClearAllPoints()
    PlayerLevelText:SetPoint("CENTER", PlayerFrame, "TOPLEFT", 51, -21)
    PlayerLevelText:Show()
  end

  SkinPvp()
end

local function SkinUnknown()
  ns.compat.player = "PlayerFrame is missing PlayerFrameContainer. Run /fcui probe."
  ns.Print(ns.compat.player)
end

local appliedHooks

local function Apply()
  if ns.DetectLayout() ~= "retail10" then
    SkinUnknown()
    return
  end

  SkinRetail10()

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
    if not ns.db or not ns.db.playerFrame then
      return
    end
    local status = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain.StatusTexture")
    if status and status.SetTexture then
      status:SetTexture(ns.ResolveArt("PlayerStatus"))
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePvPStatus", function()
    if ns.db and ns.db.playerFrame then
      SkinPvp()
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
