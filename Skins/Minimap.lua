local _, ns = ...

local function ApplyClassicButton(button, upKey, downKey)
  if not button then
    return
  end
  ns.Capture(button)
  if button.SetNormalTexture then
    pcall(button.SetNormalTexture, button, ns.ResolveArt(upKey))
  end
  if button.SetPushedTexture then
    pcall(button.SetPushedTexture, button, ns.ResolveArt(downKey))
  end
end

local function EnsureClassicBorder()
  local border = ns._classicMinimapBorder
  if border then
    return border
  end
  if not Minimap or not Minimap.CreateTexture then
    return nil
  end
  border = Minimap:CreateTexture(nil, "OVERLAY", nil, 7)
  ns._classicMinimapBorder = border
  return border
end

local function HideForeverCompass()
  local function minimapOn()
    return ns.db and ns.db.minimap and true or false
  end
  local compass = _G.MinimapCompassTexture
  if compass then
    ns.SilenceNativeChrome(compass, minimapOn)
  end
  local underlay = _G.MinimapCompassTextureUnderlay
  if underlay then
    ns.SilenceNativeChrome(underlay, minimapOn)
  end
  local backdrop = _G.MinimapBackdrop
  if backdrop and backdrop.StaticOverlayTexture then
    ns.SilenceNativeChrome(backdrop.StaticOverlayTexture, minimapOn)
  end
end

local function Apply()
  local cluster = MinimapCluster or Minimap
  if not cluster then
    ns.compat.minimap = "MinimapCluster / Minimap missing."
    return
  end

  HideForeverCompass()

  local border = EnsureClassicBorder()
  if not border then
    ns.compat.minimap = "Could not create Classic minimap border."
    return
  end
  ns.PlaceMinimapBorder(border, Minimap)
  ns.Show(border)

  local zoomIn = _G.MinimapZoomIn
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomIn")
    or ns.GetPath(Minimap, "ZoomIn")
  local zoomOut = _G.MinimapZoomOut
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomOut")
    or ns.GetPath(Minimap, "ZoomOut")
  ApplyClassicButton(zoomIn, "MinimapZoomInUp", "MinimapZoomInDown")
  ApplyClassicButton(zoomOut, "MinimapZoomOutUp", "MinimapZoomOutDown")
end

ns.RegisterSkin("minimap", Apply)
