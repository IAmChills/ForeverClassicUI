local _, ns = ...

local function Apply()
  local cluster = MinimapCluster or Minimap
  if not cluster then
    ns.compat.minimap = "MinimapCluster / Minimap missing."
    return
  end

  local border = _G.MinimapBorder
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.MinimapBorder")
    or ns.GetPath(Minimap, "MinimapBorder")
  if border and border.SetTexture then
    border:SetTexture(ns.ResolveArt("MinimapBorder"))
    border:SetAlpha(1)
    if border.Show then
      border:Show()
    end
  end

  if ns.db.hideModernChrome then
    ns.Hide(_G.MinimapBorderTop)
    ns.Hide(_G.MiniMapWorldMapButton)
    ns.Hide(_G.ExpansionLandingPageMinimapButton)
    ns.Hide(ns.GetPath(MinimapCluster, "BorderTop"))
    ns.Hide(ns.GetPath(MinimapCluster, "ExpansionButton"))
  end

  local zoomIn = _G.MinimapZoomIn or ns.GetPath(Minimap, "ZoomIn")
  local zoomOut = _G.MinimapZoomOut or ns.GetPath(Minimap, "ZoomOut")
  if zoomIn then
    zoomIn:Show()
  end
  if zoomOut then
    zoomOut:Show()
  end
end

ns.RegisterSkin("minimap", Apply)
