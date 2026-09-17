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

local function SkinForeverCompass(compass)
  local texCoord = ns.Layout.Minimap.borderTexCoord
  ns.SetTextureKeepSize(compass, ns.ResolveArt("MinimapBorder"), texCoord)
  if compass.SetAlpha then
    pcall(compass.SetAlpha, compass, 1)
  end
  ns.Show(compass)

  if not ns._minimapAtlasHooked then
    ns._minimapAtlasHooked = true
    hooksecurefunc(compass, "SetAtlas", function(self)
      local ok, err = pcall(function()
        if ns.db and ns.db.minimap then
          ns.SetTextureKeepSize(self, ns.ResolveArt("MinimapBorder"), texCoord)
        end
      end)
      if not ok then
        ns.Debug("minimap SetAtlas hook:", err)
        ns.QueueReconcile()
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
