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
  button:Show()
end

local function Apply()
  local cluster = MinimapCluster or Minimap
  if not cluster then
    ns.compat.minimap = "MinimapCluster / Minimap missing."
    return
  end

  local compass = _G.MinimapCompassTexture
  local border = compass
    or _G.MinimapBorder
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.MinimapBorder")
    or ns.GetPath(Minimap, "MinimapBorder")
  if border and border.SetTexture then
    border:SetTexture(ns.ResolveArt("MinimapBorder"))
    if border.SetTexCoord then
      border:SetTexCoord(0, 1, 0, 1)
    end
    border:SetAlpha(1)
    if border.Show then
      border:Show()
    end
  end

  ns.Hide(_G.MinimapCompassTextureUnderlay)

  if ns.db.hideModernChrome then
    ns.Hide(_G.MinimapBorderTop)
    ns.Hide(_G.MiniMapWorldMapButton)
    ns.Hide(_G.ExpansionLandingPageMinimapButton)
    ns.Hide(ns.GetPath(MinimapCluster, "BorderTop"))
    ns.Hide(ns.GetPath(MinimapCluster, "ExpansionButton"))
    ns.Hide(ns.GetPath(MinimapCluster, "ExpansionLandingPageMinimapButton"))
  end

  local zoomIn = _G.MinimapZoomIn
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomIn")
    or ns.GetPath(Minimap, "ZoomIn")
  local zoomOut = _G.MinimapZoomOut
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomOut")
    or ns.GetPath(Minimap, "ZoomOut")
  ApplyClassicButton(zoomIn, "MinimapZoomInUp", "MinimapZoomInDown")
  ApplyClassicButton(zoomOut, "MinimapZoomOutUp", "MinimapZoomOutDown")

  if compass and not ns._minimapAtlasHooked then
    ns._minimapAtlasHooked = true
    hooksecurefunc(compass, "SetAtlas", function(self)
      if ns.db and ns.db.minimap then
        self:SetTexture(ns.ResolveArt("MinimapBorder"))
        if self.SetTexCoord then
          self:SetTexCoord(0, 1, 0, 1)
        end
      end
    end)
  end
end

ns.RegisterSkin("minimap", Apply)
