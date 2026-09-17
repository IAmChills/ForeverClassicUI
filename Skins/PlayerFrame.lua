local _, ns = ...

local function SkinPvp()
  local main = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain")
  local contextual = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentContextual")
  ns.SkinPvpIcon(main and main.PvpBackgroundIcon, "player")
  ns.SkinPvpIcon(contextual and contextual.PVPIcon, "player")
end

local function SkinRetail10()
  if PlayerFrame.state == "vehicle" then
    return
  end

  local layout = ns.Layout.Player
  local container = PlayerFrame.PlayerFrameContainer
  local content = PlayerFrame.PlayerFrameContent
  local main = content and content.PlayerFrameContentMain
  if not container or not main then
    error("retail10 player frame paths missing")
  end

  local art = ns.ResolveArt("PlayerFrame")
  if container.FrameTexture then
    ns.SetTexture(container.FrameTexture, art)
    ns.SetTexCoord(container.FrameTexture, unpack(layout.texCoord))
    ns.SetSize(container.FrameTexture, unpack(layout.textureSize))
    ns.ClearAllPoints(container.FrameTexture)
    ns.SetPoint(container.FrameTexture, unpack(layout.texturePoint))
    ns.SetDrawLayer(container.FrameTexture, "BORDER")
  end

  if container.AlternatePowerFrameTexture then
    ns.SetTexture(container.AlternatePowerFrameTexture, art)
    ns.SetTexCoord(container.AlternatePowerFrameTexture, unpack(layout.texCoord))
  end

  local portrait = container.PlayerPortrait
  if portrait then
    ns.SetSize(portrait, layout.portrait.size, layout.portrait.size)
    ns.ClearAllPoints(portrait)
    ns.SetPoint(portrait, unpack(layout.portrait.point))
  end

  local mask = container.PlayerPortraitMask
  if mask then
    ns.SetTexture(mask, ns.ResolveArt("PortraitMask"))
    ns.SetSize(mask, layout.portrait.size, layout.portrait.size)
    ns.ClearAllPoints(mask)
    ns.SetPoint(mask, unpack(layout.portrait.point))
  end

  local health = ns.GetPath(main, "HealthBarsContainer.HealthBar")
  local mana = ns.GetPath(main, "ManaBarArea.ManaBar")
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)
  if health then
    ns.Capture(health)
    pcall(health.SetStatusBarColor, health, 0, 1, 0)
  end

  ns.SkinFlash(container.FrameFlash, layout.flashTexCoord)

  local status = main.StatusTexture
  if status then
    ns.SetTexture(status, ns.ResolveArt("PlayerStatus"))
  end

  -- Forever HUD circle; Classic draws the number on the frame itself.
  ns.Hide(main.LevelBackgroundCircle)

  if PlayerName then
    ns.SetWidth(PlayerName, 100)
    if PlayerName.SetJustifyH then
      pcall(PlayerName.SetJustifyH, PlayerName, "CENTER")
    end
    ns.ClearAllPoints(PlayerName)
    ns.SetPoint(PlayerName, "TOPLEFT", 97, -34)
  end

  if PlayerLevelText then
    ns.ClearAllPoints(PlayerLevelText)
    ns.SetPoint(PlayerLevelText, "CENTER", PlayerFrame, "TOPLEFT", 51, -21)
    ns.Show(PlayerLevelText)
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
  ns.SafeHook("PlayerFrame_ToVehicleArt", function()
    -- Forever vehicle art stays. Classic player chrome is reapplied on exit.
  end)
  ns.SafeHook("PlayerFrame_UpdateStatus", function()
    if not ns.db or not ns.db.playerFrame or PlayerFrame.state == "vehicle" then
      return
    end
    local status = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain.StatusTexture")
    if status then
      ns.SetTexture(status, ns.ResolveArt("PlayerStatus"))
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePvPStatus", function()
    if ns.db and ns.db.playerFrame and PlayerFrame.state ~= "vehicle" then
      SkinPvp()
    end
  end)
  ns.SafeHook("PlayerFrame_UpdatePlayerNameTextAnchor", function()
    if ns.db and ns.db.playerFrame and PlayerName and PlayerFrame.state ~= "vehicle" then
      ns.SetWidth(PlayerName, 100)
      if PlayerName.SetJustifyH then
        pcall(PlayerName.SetJustifyH, PlayerName, "CENTER")
      end
      ns.ClearAllPoints(PlayerName)
      ns.SetPoint(PlayerName, "TOPLEFT", 97, -34)
    end
  end)
end

ns.RegisterSkin("player", Apply)
