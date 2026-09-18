local _, ns = ...

local function SkinOn()
  return ns.db and ns.db.minimap and true or false
end

local function MapScale()
  local layout = ns.Layout.Minimap
  local mapSize = layout.classicMap
  if Minimap and Minimap.GetWidth then
    local ok, w = pcall(Minimap.GetWidth, Minimap)
    if ok then
      mapSize = ns.PublicNumber(w, mapSize) or mapSize
    end
  end
  return mapSize / layout.classicMap, mapSize
end

local function ScaleSize(size, scale)
  return { size[1] * scale, size[2] * scale }
end

local function ApplyClassicButton(button, upKey, downKey, disabledKey, highlightKey)
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
  if disabledKey and button.SetDisabledTexture then
    pcall(button.SetDisabledTexture, button, ns.ResolveArt(disabledKey))
  end
  if highlightKey and button.SetHighlightTexture then
    pcall(button.SetHighlightTexture, button, ns.ResolveArt(highlightKey), "ADD")
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

local function EnsureBorderTop(cluster)
  local tex = ns._classicMinimapBorderTop
  if tex then
    return tex
  end
  if not cluster or not cluster.CreateTexture then
    return nil
  end
  tex = cluster:CreateTexture("ForeverClassicUIMinimapBorderTop", "ARTWORK", nil, 5)
  ns._classicMinimapBorderTop = tex
  return tex
end

local function EnsureNorthTag(map)
  local tex = ns._classicMinimapNorth
  if tex then
    return tex
  end
  if not map or not map.CreateTexture then
    return nil
  end
  tex = map:CreateTexture("ForeverClassicUIMinimapNorth", "OVERLAY", nil, 6)
  ns._classicMinimapNorth = tex
  return tex
end

local function EnsureToggle(cluster)
  local btn = ns._classicMinimapToggle or _G.MinimapToggleButton
  if btn then
    ns._classicMinimapToggle = btn
    return btn
  end
  if not cluster then
    return nil
  end
  btn = CreateFrame("Button", "ForeverClassicUIMinimapToggle", cluster)
  ns._classicMinimapToggle = btn
  btn:SetScript("OnClick", function()
    if ToggleMinimap then
      ToggleMinimap()
    elseif Minimap and Minimap.SetShown then
      Minimap:SetShown(not Minimap:IsShown())
    end
  end)
  return btn
end

local function EnsureClockBackground(clock)
  if not clock then
    return nil
  end
  local bg = clock.fcuiClockBg
  if bg then
    return bg
  end
  bg = clock:CreateTexture(nil, "BORDER", nil, -1)
  clock.fcuiClockBg = bg
  bg:SetAllPoints(clock)
  return bg
end

local function EnsureGameTimeTexture(gt)
  if not gt then
    return nil
  end
  local tex = gt.fcuiTod or _G.GameTimeTexture
  if tex and tex.GetParent and tex:GetParent() == gt then
    gt.fcuiTod = tex
    return tex
  end
  tex = gt:CreateTexture("ForeverClassicUIGameTimeTexture", "ARTWORK")
  gt.fcuiTod = tex
  tex:SetAllPoints(gt)
  return tex
end

local function EnsureTrackingBorder(tracking)
  if not tracking then
    return nil
  end
  local border = tracking.fcuiBorder
  if border then
    return border
  end
  border = tracking:CreateTexture(nil, "ARTWORK", nil, 2)
  tracking.fcuiBorder = border
  return border
end

local function HideForeverCompass()
  local compass = _G.MinimapCompassTexture
  if compass then
    ns.SilenceNativeChrome(compass, SkinOn)
  end
  local underlay = _G.MinimapCompassTextureUnderlay
  if underlay then
    ns.SilenceNativeChrome(underlay, SkinOn)
  end
  local backdrop = _G.MinimapBackdrop
  if backdrop and backdrop.StaticOverlayTexture then
    ns.SilenceNativeChrome(backdrop.StaticOverlayTexture, SkinOn)
  end
end

local function SilenceNineSlice(frame)
  if not frame then
    return
  end
  ns.Capture(frame)
  if frame.SetAlpha then
    pcall(frame.SetAlpha, frame, 0)
  end
  local regions = { frame:GetRegions() }
  for i = 1, #regions do
    local region = regions[i]
    if region and region.GetObjectType and region:GetObjectType() == "Texture" then
      ns.SilenceNativeChrome(region, SkinOn)
    end
  end
  if frame.GetChildren then
    local children = { frame:GetChildren() }
    for i = 1, #children do
      SilenceNineSlice(children[i])
    end
  end
end

local function KeepZoomVisible(button)
  if not button or button.fcuiZoomKeepShown then
    return
  end
  button.fcuiZoomKeepShown = true
  button:HookScript("OnHide", function(self)
    if not SkinOn() or self.fcuiZoomSuppress then
      return
    end
    self.fcuiZoomSuppress = true
    pcall(self.Show, self)
    self.fcuiZoomSuppress = nil
  end)
end

local function ClearButtonArt(button)
  if not button then
    return
  end
  if button.ClearNormalTexture then
    pcall(button.ClearNormalTexture, button)
  elseif button.SetNormalTexture then
    pcall(button.SetNormalTexture, button, "")
  end
  if button.ClearPushedTexture then
    pcall(button.ClearPushedTexture, button)
  elseif button.SetPushedTexture then
    pcall(button.SetPushedTexture, button, "")
  end
  if button.ClearHighlightTexture then
    pcall(button.ClearHighlightTexture, button)
  elseif button.SetHighlightTexture then
    pcall(button.SetHighlightTexture, button, "")
  end
  if button.ClearDisabledTexture then
    pcall(button.ClearDisabledTexture, button)
  end
  local getters = { "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }
  for i = 1, #getters do
    local getter = button[getters[i]]
    if type(getter) == "function" then
      local tex = getter(button)
      if tex then
        ns.SilenceNativeChrome(tex, SkinOn)
      end
    end
  end
end

local function UpdateGameTimeTod(gt)
  if not SkinOn() or not gt or not gt.fcuiTod or gt.fcuiTodUpdating then
    return
  end
  gt.fcuiTodUpdating = true
  ClearButtonArt(gt)
  local hour, minute = 12, 0
  if GetGameTime then
    hour, minute = GetGameTime()
  end
  local time = (hour * 60) + minute
  local dawn = (5 * 60) + 30
  local dusk = 21 * 60
  local minx, maxx, miny, maxy = 0, 50 / 128, 0, 50 / 64
  if time < dawn or time >= dusk then
    minx = minx + 0.5
    maxx = maxx + 0.5
  end
  ns.SetTexture(gt.fcuiTod, ns.ResolveArt("MinimapTOD"))
  ns.SetTexCoord(gt.fcuiTod, minx, maxx, miny, maxy)
  if gt.fcuiTod.SetDrawLayer then
    pcall(gt.fcuiTod.SetDrawLayer, gt.fcuiTod, "OVERLAY", 7)
  end
  ns.Show(gt.fcuiTod)
  gt.fcuiTodUpdating = nil
end

local function HookGameTime()
  if ns._classicMinimapGameTimeHooked then
    return
  end
  ns._classicMinimapGameTimeHooked = true
  if type(GameTimeFrame_SetDate) == "function" then
    hooksecurefunc("GameTimeFrame_SetDate", function()
      UpdateGameTimeTod(GameTimeFrame)
    end)
  end
  local gt = GameTimeFrame
  if gt and not gt.fcuiTodArtHooked then
    gt.fcuiTodArtHooked = true
    if type(gt.SetNormalAtlas) == "function" then
      hooksecurefunc(gt, "SetNormalAtlas", function(self)
        if SkinOn() then
          UpdateGameTimeTod(self)
        end
      end)
    end
    if type(gt.SetNormalTexture) == "function" then
      hooksecurefunc(gt, "SetNormalTexture", function(self)
        if SkinOn() then
          UpdateGameTimeTod(self)
        end
      end)
    end
  end
end

local function StyleZoneCluster(cluster, scale)
  local layout = ns.Layout.Minimap
  SilenceNineSlice(cluster.BorderTop)

  local borderTop = EnsureBorderTop(cluster)
  if borderTop then
    local size = ScaleSize(layout.borderTop.size, scale)
    local point = layout.borderTop.point
    local relative = layout.borderTop.relative == "cluster" and cluster or Minimap
    ns.SetTexture(borderTop, ns.ResolveArt("MinimapBorder"))
    ns.SetTexCoord(borderTop, unpack(layout.borderTop.texCoord))
    ns.PlaceOn(borderTop, relative, point[1], point[2], point[3] * scale, point[4] * scale, size[1], size[2])
    ns.Show(borderTop)
  end

  local zoneBtn = cluster.ZoneTextButton or _G.MinimapZoneTextButton
  if zoneBtn and borderTop then
    local size = ScaleSize(layout.zoneText.size, scale)
    local point = layout.zoneText.point
    ns.Capture(zoneBtn)
    ns.PlaceOn(zoneBtn, borderTop, "CENTER", "CENTER", point[2] * scale, point[3] * scale, size[1], size[2])
    ns.Show(zoneBtn)
  end

  local zoneText = _G.MinimapZoneText
  if zoneText then
    ns.Capture(zoneText)
    if zoneText.SetJustifyH then
      pcall(zoneText.SetJustifyH, zoneText, "CENTER")
    end
    ns.ClearAllPoints(zoneText)
    ns.SetPoint(zoneText, "CENTER", zoneBtn or borderTop, "CENTER", 0, 1)
  end

  local toggle = EnsureToggle(cluster)
  if toggle and borderTop then
    local t = layout.toggle
    local size = t.scaleSize == false and { t.size[1], t.size[2] } or ScaleSize(t.size, scale)
    local ox = (t.point[3] or 0) * (t.scaleOffset == false and 1 or scale)
    local oy = (t.point[4] or 0) * (t.scaleOffset == false and 1 or scale)
    ns.Capture(toggle)
    ApplyClassicButton(toggle, "MinimapToggleUp", "MinimapToggleDown", nil, "MinimapToggleHighlight")
    ns.PlaceOn(toggle, borderTop, t.point[1], t.point[2], ox, oy, size[1], size[2])
    ns.Show(toggle)
  end
end

local function StyleTracking(cluster, scale)
  local tracking = cluster.Tracking
  if not tracking then
    return
  end
  local layout = ns.Layout.Minimap.tracking
  local size = ScaleSize(layout.size, scale)
  ns.Capture(tracking)
  if tracking.Background then
    ns.SilenceNativeChrome(tracking.Background, SkinOn)
  end
  ns.ClearAllPoints(tracking)
  ns.SetPoint(tracking, layout.point[1], Minimap, layout.point[1], layout.point[2] * scale, layout.point[3] * scale)
  ns.SetSize(tracking, size[1], size[2])
  -- Sibling of MinimapContainer: raise above it so the ring isn't under the classic border.
  local container = cluster.MinimapContainer
  if container and ns.RaiseAbove then
    ns.RaiseAbove(tracking, container)
  elseif tracking.SetFrameLevel then
    local base = 0
    if container and container.GetFrameLevel then
      local ok, level = pcall(container.GetFrameLevel, container)
      if ok then
        base = ns.PublicNumber(level, 0) or 0
      end
    end
    pcall(tracking.SetFrameLevel, tracking, base + 8)
  end
  ns.Show(tracking)

  local button = tracking.Button
  if button then
    local iconOffset = layout.iconOffset or { 1, -1 }
    ns.Capture(button)
    ns.ClearAllPoints(button)
    ns.SetPoint(button, "CENTER", tracking, "CENTER", iconOffset[1] * scale, iconOffset[2] * scale)
    ns.SetSize(button, layout.icon[1] * scale, layout.icon[2] * scale)
    if button.SetFrameLevel and tracking.GetFrameLevel then
      local ok, level = pcall(tracking.GetFrameLevel, tracking)
      if ok then
        pcall(button.SetFrameLevel, button, (ns.PublicNumber(level, 0) or 0) + 1)
      end
    end
    if button.SetNormalTexture then
      pcall(button.SetNormalTexture, button, ns.ResolveArt("MinimapTrackingNone"))
    end
    if button.SetPushedTexture then
      pcall(button.SetPushedTexture, button, ns.ResolveArt("MinimapTrackingNone"))
    end
    if button.SetHighlightTexture then
      pcall(button.SetHighlightTexture, button, ns.ResolveArt("MinimapZoomHighlight"), "ADD")
    end
    local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
    if highlight then
      ns.Capture(highlight)
      -- Match the tracking ring, not the smaller icon hitbox.
      local ring = layout.border[1] * scale
      highlight:ClearAllPoints()
      highlight:SetSize(ring * 0.55, ring * 0.55)
      highlight:SetPoint("CENTER", button, "CENTER", 3, -3)
    end
  end

  local border = EnsureTrackingBorder(tracking)
  if border then
    ns.SetTexture(border, ns.ResolveArt("MinimapTrackingBorder"))
    if border.SetDrawLayer then
      pcall(border.SetDrawLayer, border, "OVERLAY", 7)
    end
    ns.PlaceOn(border, tracking, "TOPLEFT", "TOPLEFT", 0, 0, layout.border[1] * scale, layout.border[2] * scale)
    ns.Show(border)
  end
end

local function StyleZoom(scale)
  local layout = ns.Layout.Minimap
  local zoomIn = _G.MinimapZoomIn
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomIn")
    or ns.GetPath(Minimap, "ZoomIn")
  local zoomOut = _G.MinimapZoomOut
    or ns.GetPath(MinimapCluster, "MinimapContainer.Minimap.ZoomOut")
    or ns.GetPath(Minimap, "ZoomOut")

  if zoomIn then
    local size = ScaleSize(layout.zoomIn.size, scale)
    local point = layout.zoomIn.point
    ApplyClassicButton(zoomIn, "MinimapZoomInUp", "MinimapZoomInDown", "MinimapZoomInDisabled", "MinimapZoomHighlight")
    ns.PlaceOn(zoomIn, Minimap, "CENTER", "CENTER", point[2] * scale, point[3] * scale, size[1], size[2])
    KeepZoomVisible(zoomIn)
    ns.Show(zoomIn)
  end

  if zoomOut then
    local size = ScaleSize(layout.zoomOut.size, scale)
    local point = layout.zoomOut.point
    ApplyClassicButton(zoomOut, "MinimapZoomOutUp", "MinimapZoomOutDown", "MinimapZoomOutDisabled", "MinimapZoomHighlight")
    ns.PlaceOn(zoomOut, Minimap, "CENTER", "CENTER", point[2] * scale, point[3] * scale, size[1], size[2])
    KeepZoomVisible(zoomOut)
    ns.Show(zoomOut)
  end

  local hit = Minimap and Minimap.ZoomHitArea
  if hit then
    ns.Capture(hit)
    pcall(hit.EnableMouse, hit, false)
  end
end

local function StyleGameTime(cluster, scale)
  local gt = _G.GameTimeFrame
  if not gt then
    return
  end
  local layout = ns.Layout.Minimap.gameTime
  local size = layout.scaleSize == false and { layout.size[1], layout.size[2] } or ScaleSize(layout.size, scale)
  local ox, oy = layout.point[2] * scale, layout.point[3] * scale
  ns.Capture(gt)
  ns.ClearAllPoints(gt)
  ns.SetPoint(gt, layout.point[1], Minimap, layout.point[1], ox, oy)
  ns.SetSize(gt, size[1], size[2])
  if gt.SetHitRectInsets then
    pcall(gt.SetHitRectInsets, gt, 4, 4, 4, 4)
  end
  local tex = EnsureGameTimeTexture(gt)
  if tex then
    tex:ClearAllPoints()
    tex:SetAllPoints(gt)
    ns.Show(tex)
  end
  UpdateGameTimeTod(gt)
  HookGameTime()
  ns.Show(gt)

  if _G.GameTimeCalendarInvitesTexture then
    ns.SilenceNativeChrome(_G.GameTimeCalendarInvitesTexture, SkinOn)
  end
  if _G.GameTimeCalendarInvitesGlow then
    ns.SilenceNativeChrome(_G.GameTimeCalendarInvitesGlow, SkinOn)
  end
  if _G.GameTimeCalendarEventAlarmTexture then
    ns.SilenceNativeChrome(_G.GameTimeCalendarEventAlarmTexture, SkinOn)
  end

  local compartment = _G.AddonCompartmentFrame
  if compartment then
    ns.Hide(compartment)
  end

  local diel = cluster and cluster.DielFrame
  if diel then
    ns.Hide(diel)
    if not diel.fcuiHiddenHooked then
      diel.fcuiHiddenHooked = true
      diel:HookScript("OnShow", function(self)
        if SkinOn() then
          self:Hide()
        end
      end)
    end
  end

  if not ns._classicMinimapTodTicker and C_Timer and C_Timer.NewTicker then
    ns._classicMinimapTodTicker = C_Timer.NewTicker(30, function()
      if SkinOn() then
        UpdateGameTimeTod(GameTimeFrame)
      end
    end)
  end
end

local function StyleClock(scale)
  local clock = _G.TimeManagerClockButton
  if not clock then
    if C_AddOns and C_AddOns.LoadAddOn then
      pcall(C_AddOns.LoadAddOn, "Blizzard_TimeManager")
    elseif LoadAddOn then
      pcall(LoadAddOn, "Blizzard_TimeManager")
    end
    clock = _G.TimeManagerClockButton
  end
  if not clock then
    return
  end

  local layout = ns.Layout.Minimap.clock
  local size = ScaleSize(layout.size, scale)
  local point = layout.point
  ns.Capture(clock)
  if clock.SetParent and Minimap then
    pcall(clock.SetParent, clock, Minimap)
  end
  ns.PlaceOn(clock, Minimap, "CENTER", "CENTER", point[2] * scale, point[3] * scale, size[1], size[2])

  local bg = EnsureClockBackground(clock)
  if bg then
    ns.SetTexture(bg, ns.ResolveArt("MinimapClockBg"))
    ns.SetTexCoord(bg, unpack(layout.texCoord))
    ns.Show(bg)
  end

  local ticker = _G.TimeManagerClockTicker
  if ticker then
    ns.Capture(ticker)
    ns.ClearAllPoints(ticker)
    ns.SetPoint(ticker, "CENTER", clock, "CENTER", 1 * scale, 0)
    local textScale = layout.textScale or 1
    if textScale ~= 1 and ticker.GetFont and ticker.SetFont then
      local font, height, flags = ticker:GetFont()
      if font and height then
        pcall(ticker.SetFont, ticker, font, height * textScale, flags)
      end
    end
  end
  ns.Show(clock)
end

local function StyleNorth(scale)
  local north = EnsureNorthTag(Minimap)
  if not north then
    return
  end
  local layout = ns.Layout.Minimap.north
  local size = ScaleSize(layout.size, scale)
  local point = layout.point
  ns.SetTexture(north, ns.ResolveArt("MinimapNorth"))
  ns.PlaceOn(north, Minimap, "CENTER", "CENTER", point[2] * scale, point[3] * scale, size[1], size[2])
  -- Hide when rotate minimap is on (classic hides N tag while rotating).
  local rotate = GetCVar and GetCVar("rotateMinimap") == "1"
  if rotate then
    ns.Hide(north)
  else
    ns.Show(north)
  end
end

local function StyleMail(scale)
  local mail = ns.GetPath(MinimapCluster, "IndicatorFrame.MailFrame") or _G.MiniMapMailFrame
  if not mail then
    return
  end
  ns.Capture(mail)
  local icon = mail.MailIcon or _G.MiniMapMailIcon
  if icon then
    ns.SetTexture(icon, ns.ResolveArt("MinimapMail"))
  end
  local border = mail.fcuiBorder
  if not border and mail.CreateTexture then
    border = mail:CreateTexture(nil, "OVERLAY")
    mail.fcuiBorder = border
  end
  if border then
    ns.SetTexture(border, ns.ResolveArt("MinimapTrackingBorder"))
    ns.PlaceOn(border, mail, "TOPLEFT", "TOPLEFT", 0, 0, 52 * scale, 52 * scale)
  end
end

local function StyleMapContainer(cluster, scale)
  local container = cluster.MinimapContainer
  local layout = ns.Layout.Minimap.containerPoint
  if not container or not layout then
    return
  end
  ns.Capture(container)
  ns.ClearAllPoints(container)
  ns.SetPoint(container, layout[1], cluster, layout[1], layout[2], layout[3])
end

local function Apply()
  local cluster = MinimapCluster or Minimap
  if not cluster or not Minimap then
    ns.compat.minimap = "MinimapCluster / Minimap missing."
    return
  end

  local scale = MapScale()
  HideForeverCompass()
  StyleMapContainer(cluster, scale)

  local border = EnsureClassicBorder()
  if not border then
    ns.compat.minimap = "Could not create Classic minimap border."
    return
  end
  ns.PlaceMinimapBorder(border, Minimap)
  ns.Show(border)

  StyleZoneCluster(cluster, scale)
  StyleTracking(cluster, scale)
  StyleZoom(scale)
  StyleGameTime(cluster, scale)
  StyleClock(scale)
  StyleNorth(scale)
  StyleMail(scale)

  -- Keep Forever coords under the clock instead of overlapping it.
  local coords = ns.GetPath(cluster, "MinimapContainer.PlayerCoords")
  if coords then
    ns.Capture(coords)
    ns.ClearAllPoints(coords)
    ns.SetPoint(coords, "TOP", Minimap, "BOTTOM", 0, -18 * scale)
  end
end

ns.RegisterSkin("minimap", Apply)
