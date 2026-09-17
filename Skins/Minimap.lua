local _, ns = ...

local function ApplyClassicButton(button, upKey, downKey)
  if not button then
    return
  end
  if button.SetNormalTexture then
    button:SetNormalTexture(ns.ResolveArt(upKey))
  end
  if button.SetPushedTexture then
    button:SetPushedTexture(ns.ResolveArt(downKey))
  end
end

local function SkinForeverCompass(compass)
  local texCoord = ns.Layout.Minimap.borderTexCoord
  ns.SetTextureKeepSize(compass, ns.ResolveArt("MinimapBorder"), texCoord)
  compass:SetAlpha(1)
  if compass.Show then
    compass:Show()
  end

  if not ns._minimapAtlasHooked then
    ns._minimapAtlasHooked = true
    hooksecurefunc(compass, "SetAtlas", function(self)
      if ns.db and ns.db.minimap then
        ns.SetTextureKeepSize(self, ns.ResolveArt("MinimapBorder"), texCoord)
      end
    end)
  end
end

local function Apply()
  local cluster = MinimapCluster or Minimap
  if not cluster then
    ns.compat.minimap = "MinimapCluster / Minimap missing."
    return
  end

  local compass = _G.MinimapCompassTexture
  if compass then
    SkinForeverCompass(compass)
  else
    ns.compat.minimap = "MinimapCompassTexture missing."
  end

  ns.Hide(_G.MinimapCompassTextureUnderlay)

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
