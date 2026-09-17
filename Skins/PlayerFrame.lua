local _, ns = ...

local function SkinPvp()
  local main = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentMain")
  local contextual = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentContextual")
  ns.SkinPvpIcon(main and main.PvpBackgroundIcon, "player")
  ns.SkinPvpIcon(contextual and contextual.PVPIcon, "player")
  ns.Hide(main and main.PvpBackgroundCircle)
end

local function SkinOrnaments()
  local contextual = ns.GetPath(PlayerFrame, "PlayerFrameContent.PlayerFrameContentContextual")
  if not contextual then
    return
  end
  ns.Hide(contextual.PlayerPortraitCornerIcon)
  if contextual.LeaderIcon then
    ns.SetTexture(contextual.LeaderIcon, ns.ResolveArt("LeaderIcon"))
  end
  local gi = contextual.GroupIndicator
  if gi and gi.GroupIndicatorLeft then
    ns.SetTexture(gi.GroupIndicatorLeft, ns.ResolveArt("GroupIndicator"))
  end
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

  local function playerOn()
    return ns.db and ns.db.playerFrame and true or false
  end

  -- Hide Forever retail chrome; place Classic art at Classic XML anchors.
  ns.SilenceNativeChrome(container.FrameTexture, playerOn)
  ns.Hide(container.AlternatePowerFrameTexture)
  ns.SilenceNativeChrome(container.FrameFlash, playerOn)

  -- Dark plate behind name/bars (Classic PlayerFrameBackground).
  ns.PlaceClassicUnitBackground(container, PlayerFrame, layout)

  local chrome = ns.EnsureUnitChrome(container, "fcuiChrome")
  ns.PlaceClassicChrome(chrome, PlayerFrame, layout, ns.ResolveArt("PlayerFrame"))
  if chrome then
    ns.Show(chrome)
  end
  if container.FrameTexture then
    ns.HookChromeReset(container.FrameTexture, SkinRetail10, playerOn)
  end

  ns.PlaceClassicPortrait(container.PlayerPortrait, container.PlayerPortraitMask, PlayerFrame, layout)

  local healthBox = main.HealthBarsContainer
  local manaBar = ns.GetPath(main, "ManaBarArea.ManaBar") or (main.ManaBarArea and main.ManaBarArea.ManaBar)
  ns.PlaceClassicBars(PlayerFrame, layout, healthBox, manaBar)

  local flash = ns.EnsureUnitChrome(container, "fcuiFlash")
  ns.PlaceClassicFlash(flash, PlayerFrame, layout, ns.ResolveArt("FrameFlash"))
  ns.SyncOverlayShown(container.FrameFlash, flash, playerOn)
  if container.FrameFlash then
    ns.HookChromeReset(container.FrameFlash, SkinRetail10, playerOn)
  end

  local status = main.StatusTexture
  if status then
    ns.SetTexture(status, ns.ResolveArt("PlayerStatus"))
    if layout.status then
      local point, x, y = unpack(layout.status.point)
      x, y = ns.LayoutXY(layout, x, y)
      local w, h = unpack(layout.status.size)
      ns.PlaceOn(status, PlayerFrame, point, "TOPLEFT", x, y, w, h)
      if layout.status.texCoord then
        ns.SetTexCoord(status, unpack(layout.status.texCoord))
      end
    end
  end

  ns.PlaceClassicName(_G.PlayerName, PlayerFrame, layout)
  ns.Hide(main.LevelBackgroundCircle)
  ns.PlaceClassicLevel(_G.PlayerLevelText, PlayerFrame, layout)

  SkinPvp()
  SkinOrnaments()
end

local function SkinUnknown()
  ns.compat.player = "PlayerFrame is missing PlayerFrameContainer."
  ns.Print(ns.compat.player)
end

local appliedHooks
local pending

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
    if not ns.db or not ns.db.playerFrame or pending then
      return
    end
    pending = true
    C_Timer.After(0, function()
      pending = nil
      if ns.db and ns.db.playerFrame then
        Apply()
      end
    end)
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
  ns.SafeHook("PlayerFrame_UpdateRolesAssigned", function()
    if ns.db and ns.db.playerFrame and PlayerFrame.state ~= "vehicle" then
      SkinOrnaments()
    end
  end)
end

ns.RegisterSkin("player", Apply)
