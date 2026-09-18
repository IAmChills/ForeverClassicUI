local ADDON_NAME, ns = ...

ns.MEDIA_ROOT = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\"

ns.Art = {
  PlayerFrame = "Interface\\TargetingFrame\\UI-TargetingFrame",
  TargetFrame = "Interface\\TargetingFrame\\UI-TargetingFrame",
  TargetElite = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
  TargetRare = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
  TargetRareElite = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  TargetMinus = "Interface\\TargetingFrame\\UI-TargetingFrame-Minus",
  SmallTarget = "Interface\\TargetingFrame\\UI-SmallTargetingFrame",
  TargetOfTarget = "Interface\\TargetingFrame\\UI-TargetofTargetFrame",
  PartyFrame = "Interface\\TargetingFrame\\UI-PartyFrame",
  StatusBar = "Interface\\TargetingFrame\\UI-StatusBar",
  CastBorder = "Interface\\CastingBar\\UI-CastingBar-Border",
  CastBorderSmall = "Interface\\CastingBar\\UI-CastingBar-Border-Small",
  CastSpark = "Interface\\CastingBar\\UI-CastingBar-Spark",
  CastFlash = "Interface\\CastingBar\\UI-CastingBar-Flash",
  CastShield = "Interface\\CastingBar\\UI-CastingBar-Small-Shield",
  MinimapBorder = "Interface\\Minimap\\UI-Minimap-Border",
  MinimapZoomInUp = "Interface\\Minimap\\UI-Minimap-ZoomInButton-Up",
  MinimapZoomInDown = "Interface\\Minimap\\UI-Minimap-ZoomInButton-Down",
  MinimapZoomInDisabled = "Interface\\Minimap\\UI-Minimap-ZoomInButton-Disabled",
  MinimapZoomOutUp = "Interface\\Minimap\\UI-Minimap-ZoomOutButton-Up",
  MinimapZoomOutDown = "Interface\\Minimap\\UI-Minimap-ZoomOutButton-Down",
  MinimapZoomOutDisabled = "Interface\\Minimap\\UI-Minimap-ZoomOutButton-Disabled",
  MinimapZoomHighlight = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
  MinimapClockBg = "Interface\\TimeManager\\ClockBackground",
  MinimapTrackingBorder = "Interface\\Minimap\\MiniMap-TrackingBorder",
  MinimapTrackingNone = "Interface\\Minimap\\Tracking\\None",
  MinimapNorth = "Interface\\Minimap\\CompassNorthTag",
  MinimapTOD = "Interface\\Minimap\\UI-TOD-Indicator",
  MinimapToggleUp = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up",
  MinimapToggleDown = "Interface\\Buttons\\UI-Panel-MinimizeButton-Down",
  MinimapToggleHighlight = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight",
  PortraitMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
  GroupIndicator = "Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator",
  LeaderIcon = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
  PvpAlliance = "Interface\\TargetingFrame\\UI-PVP-Alliance",
  PvpHorde = "Interface\\TargetingFrame\\UI-PVP-Horde",
  PvpFFA = "Interface\\TargetingFrame\\UI-PVP-FFA",
  FrameFlash = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash",
  TargetMinusFlash = "Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash",
  PlayerStatus = "Interface\\CharacterFrame\\UI-Player-Status",
  PartyFlash = "Interface\\TargetingFrame\\UI-PartyFrame-Flash",
  NameBackground = "Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground",
}

ns.Layout = {
  -- Classic Era XML slots are absolute on the unit frame.
  -- nudge = {x,y} shifts the whole Classic assembly (chrome + children).
  -- texturePoint = Classic chrome anchor before nudge is applied.
  Player = {
    size = { 232, 100 },
    nudge = { -20, -5 },
    texturePoint = { "TOPLEFT", 0, 0 },
    textureSize = { 232, 100 },
    texCoord = { 1, 0.09375, 0, 0.78125 },
    portrait = { size = 64, point = { "TOPLEFT", 42, -12 } },
    flash = { size = { 242, 93 }, point = { "TOPLEFT", 13, 0 } },
    flashTexCoord = { 0.9453125, 0, 0, 0.181640625 },
    name = { width = 100, point = { "CENTER", 50, 19 } },
    -- Classic PlayerFrameBackground: dark plate behind name + bars.
    background = { size = { 119, 41 }, point = { "TOPLEFT", 106, -22 }, color = { 0, 0, 0, 0.5 } },
    level = { point = { "CENTER", -61, -16 } },
    health = { size = { 119, 12 }, point = { "TOPLEFT", 106, -41 } },
    mana = { size = { 119, 12 }, point = { "TOPLEFT", 106, -52 } },
    pvp = { point = { "TOPLEFT", 18, -20 } },
    leader = { point = { "TOPLEFT", 44, -10 } },
    group = { point = { "BOTTOMLEFT", "TOPLEFT", 97, -20 } },
    status = { size = { 190, 66 }, point = { "TOPLEFT", 35, -8 }, texCoord = { 0, 0.74609375, 0, 0.53125 } },
  },
  Target = {
    size = { 232, 100 },
    nudge = { 20, -5 },
    texturePoint = { "TOPLEFT", 0, 0 },
    textureSize = { 232, 100 },
    texCoord = { 0.09375, 1, 0, 0.78125 },
    portrait = { size = 64, point = { "TOPRIGHT", -42, -12 } },
    flash = { size = { 242, 93 }, point = { "TOPLEFT", -13, 0 } },
    flashTexCoord = { 0.09375, 1, 0, 0.181640625 },
    name = { width = 100, point = { "CENTER", -50, 19 } },
    -- Classic TargetFrame Background + NameBackground (faction strip).
    background = { size = { 119, 41 }, point = { "TOPRIGHT", -106, -22 }, color = { 0, 0, 0, 0.5 } },
    nameBackground = { size = { 119, 19 }, point = { "TOPRIGHT", -106, -22 } },
    level = { point = { "CENTER", 63, -16 } },
    health = { size = { 119, 12 }, point = { "TOPRIGHT", -106, -41 } },
    mana = { size = { 119, 12 }, point = { "TOPRIGHT", -106, -52 } },
    minusHealth = { size = { 119, 9 }, point = { "TOPRIGHT", -106, -41 } },
  },
  ToT = {
    -- Forever ToT is 120x49 (Classic was 93x45). Stretch Classic art to live size
    -- so the chrome ring matches Forever's larger portrait.
    size = { 120, 49 },
    texturePoint = { "TOPLEFT", 0, 0 },
    textureSize = { 120, 49 },
    texCoord = { 0.015625, 0.7265625, 0, 0.703125 },
    portrait = { size = 37, point = { "TOPLEFT", 5, -5 } },
    background = { size = { 70, 18 }, point = { "BOTTOMLEFT", 42, 13 }, color = { 0, 0, 0, 0.5 } },
    health = { size = { 70, 10 }, point = { "TOPRIGHT", -6, -15 } },
    mana = { size = { 74, 7 }, point = { "TOPLEFT", 42, -26 } },
    name = { width = 68, point = { "TOPLEFT", 44, -5 } },
  },
  Pet = {
    portrait = { size = 32, point = { "TOPLEFT", 7, -6 } },
    health = { size = { 69, 8 }, point = { "TOPLEFT", 47, -22 } },
    mana = { size = { 69, 8 }, point = { "TOPLEFT", 47, -29 } },
  },
  Party = {
    -- Forever member is 120x53; Classic chrome is 128x64. Use Classic chrome size
    -- so the ring matches the 37px portrait (bare SetTexture collapses it).
    size = { 120, 53 },
    texturePoint = { "TOPLEFT", 0, -2 },
    textureSize = { 128, 64 },
    portrait = { size = 37, point = { "TOPLEFT", 7, -6 } },
    background = { size = { 72, 20 }, point = { "TOPLEFT", 45, -11 }, color = { 0, 0, 0, 0.5 } },
    flash = { size = { 128, 64 }, point = { "TOPLEFT", -3, 2 } },
    health = { size = { 70, 8 }, point = { "TOPLEFT", 47, -12 } },
    mana = { size = { 70, 8 }, point = { "TOPLEFT", 47, -21 } },
    name = { width = 57, point = { "TOPLEFT", 46, -5 } },
  },
  CastBar = {
    playerSize = { 195, 13 },
    borderSize = { 256, 64 },
    borderPoint = { "TOP", 0, 28 },
  },
  Minimap = {
    -- Classic Vanilla Minimap.xml: 140 map, 192 backdrop/border cell.
    classicMap = 140,
    classicBorder = 192,
    -- Classic compass ring used a -2 x nudge; live art also sits high/right.
    borderOffset = { -12, -34 },
    texCoord = { 0.25, 1, 0.125, 0.875 },
    -- Raise Forever's map container toward the zone banner (default y = -30).
    containerPoint = { "TOP", 10, -4 },
    -- Pin banner to cluster top so raising the map doesn't shove it off-screen.
    borderTop = {
      size = { 192, 32 },
      texCoord = { 0.25, 1, 0, 0.125 },
      relative = "cluster",
      point = { "TOP", "TOP", 6, 2 },
    },
    zoneText = { size = { 140, 12 }, point = { "CENTER", 0, 2 } },
    -- Toggle sits in the right cap of MinimapBorderTop; nudge up/left vs raw RIGHT.
    toggle = { size = { 42, 42 }, point = { "CENTER", "RIGHT", -22, 4 }, scaleSize = false, scaleOffset = false },
    -- Classic zoom slots shifted down/left to sit on Forever's larger ring.
    zoomIn = { size = { 32, 32 }, point = { "CENTER", 68, -36 } },
    zoomOut = { size = { 32, 32 }, point = { "CENTER", 42, -64 } },
    tracking = {
      size = { 22, 22 },
      point = { "TOPLEFT", -20, -30 },
      icon = { 16, 16 },
      iconOffset = { 2, -3 },
      border = { 50, 50 },
    },
    north = { size = { 16, 16 }, point = { "CENTER", 0, 67 } },
    -- Classic TOD is ~50px on a 140 map; keep near that visual size on Forever.
    gameTime = { size = { 58, 58 }, point = { "CENTER", 65, 48 }, scaleSize = false },
    clock = {
      size = { 60, 28 },
      point = { "CENTER", 0, -75 },
      texCoord = { 0.015625, 0.8125, 0.015625, 0.390625 },
      textScale = 1.15,
    },
  },
}
function ns.Media(relativePath)
  return ns.MEDIA_ROOT .. relativePath:gsub("/", "\\")
end

-- Prefer bundled Classic minimap art when present.
ns.Art.MinimapBorder = ns.Media("Minimap\\ui-minimap-border.blp")
ns.Art.MinimapZoomInUp = ns.Media("Minimap\\ui-minimap-zoominbutton-up.blp")
ns.Art.MinimapZoomInDown = ns.Media("Minimap\\ui-minimap-zoominbutton-down.blp")
ns.Art.MinimapZoomInDisabled = ns.Media("Minimap\\ui-minimap-zoominbutton-disabled.blp")
ns.Art.MinimapZoomOutUp = ns.Media("Minimap\\ui-minimap-zoomoutbutton-up.blp")
ns.Art.MinimapZoomOutDown = ns.Media("Minimap\\ui-minimap-zoomoutbutton-down.blp")
ns.Art.MinimapZoomOutDisabled = ns.Media("Minimap\\ui-minimap-zoomoutbutton-disabled.blp")
ns.Art.MinimapZoomHighlight = ns.Media("Minimap\\ui-minimap-zoombutton-highlight.blp")
ns.Art.MinimapClockBg = ns.Media("Minimap\\clockbackground.blp")
ns.Art.MinimapTrackingBorder = ns.Media("Minimap\\minimap-trackingborder.blp")
ns.Art.MinimapTrackingNone = ns.Media("Minimap\\tracking-none.blp")
ns.Art.MinimapNorth = ns.Media("Minimap\\compassnorthtag.blp")
ns.Art.MinimapTOD = ns.Media("Minimap\\ui-tod-indicator.blp")
ns.Art.MinimapMail = ns.Media("Minimap\\mail.blp")

function ns.TextureExists(path)
  if not path then
    return false
  end
  if GetFileIDFromPath then
    local fileID = GetFileIDFromPath(path)
    return fileID ~= nil and fileID ~= 0
  end
  return true
end

function ns.ResolveArt(key)
  local path = ns.Art[key]
  if ns.TextureExists(path) then
    return path
  end
  local fallback = ns.Media(key .. ".blp")
  if ns.TextureExists(fallback) then
    return fallback
  end
  return path
end

function ns.GetPath(root, path)
  if not root then
    return nil
  end
  if not path or path == "" then
    return root
  end
  local node = root
  for segment in string.gmatch(path, "[^%.]+") do
    if type(node) ~= "table" and type(node) ~= "userdata" then
      return nil
    end
    node = node[segment]
    if not node then
      return nil
    end
  end
  return node
end

function ns.FirstExisting(...)
  for i = 1, select("#", ...) do
    local candidate = select(i, ...)
    if type(candidate) == "string" then
      candidate = _G[candidate]
    end
    if candidate then
      return candidate
    end
  end
end

function ns.SetTextureKeepSize(region, path, texCoord)
  if not region or not region.SetTexture then
    return
  end
  local width, height = region:GetWidth(), region:GetHeight()
  region:SetTexture(path)
  if texCoord and region.SetTexCoord then
    region:SetTexCoord(unpack(texCoord))
  elseif region.SetTexCoord then
    region:SetTexCoord(0, 1, 0, 1)
  end
  if width and height and width > 0 and height > 0 then
    region:SetSize(width, height)
  end
end

function ns.Hide(region)
  if not region then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region.SetAlpha then
    region:SetAlpha(0)
  end
end

function ns.HideTree(parent, names)
  if not parent then
    return
  end
  for i = 1, #names do
    ns.Hide(ns.GetPath(parent, names[i]))
  end
end

function ns.SafeHook(target, method, handler)
  if type(target) == "string" then
    local hookfn = type(method) == "function" and method or handler
    if type(_G[target]) == "function" and type(hookfn) == "function" then
      hooksecurefunc(target, hookfn)
    end
    return
  end
  if target and type(method) == "string" and type(target[method]) == "function" and type(handler) == "function" then
    hooksecurefunc(target, method, handler)
  end
end

local function ClearTextureMasks(tex)
  if not tex or not tex.RemoveMaskTexture then
    return
  end
  if ns.Capture then
    ns.Capture(tex)
  end
  if tex.GetNumMaskTextures and tex.GetMaskTexture then
    for i = tex:GetNumMaskTextures(), 1, -1 do
      local mask = tex:GetMaskTexture(i)
      if mask then
        pcall(tex.RemoveMaskTexture, tex, mask)
      end
    end
  end
end

local function RemoveKnownMasks(tex, bar)
  if not tex or not tex.RemoveMaskTexture or not bar then
    return
  end
  local masks = {
    bar.PowerBarMask,
    bar.HealthBarMask,
    bar.ManaBarMask,
    bar.Mask,
  }
  local parent = bar.GetParent and bar:GetParent()
  if parent then
    masks[#masks + 1] = parent.HealthBarMask
    masks[#masks + 1] = parent.ManaBarMask
    masks[#masks + 1] = parent.PowerBarMask
  end
  for i = 1, #masks do
    if masks[i] then
      pcall(tex.RemoveMaskTexture, tex, masks[i])
    end
  end
end

function ns.HideBarMasks(bar)
  -- Retail masks clip Classic status-bar textures.
  if not bar then
    return
  end
  ns.Hide(bar.PowerBarMask)
  ns.Hide(bar.HealthBarMask)
  ns.Hide(bar.ManaBarMask)
  ns.Hide(bar.Mask)
  local parent = bar.GetParent and bar:GetParent()
  if parent then
    ns.Hide(parent.HealthBarMask)
    ns.Hide(parent.ManaBarMask)
    ns.Hide(parent.PowerBarMask)
  end
  local fill = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
  ClearTextureMasks(fill)
  RemoveKnownMasks(fill, bar)
  if bar.FeedbackFrame then
    ClearTextureMasks(bar.FeedbackFrame)
    RemoveKnownMasks(bar.FeedbackFrame, bar)
  end
end

function ns.DetectLayout()
  if PlayerFrame and PlayerFrame.PlayerFrameContainer then
    return "retail10"
  end
  if PlayerFrame then
    return "unknown-playerframe"
  end
  return "missing"
end

function ns.PublicNumber(value, fallback)
  if type(value) ~= "number" then
    return fallback
  end
  if type(issecretvalue) == "function" and issecretvalue(value) then
    return fallback
  end
  return value
end

function ns.RelativeTopLeft(region, root)
  if not region or not root or not region.GetLeft or not root.GetLeft then
    return
  end
  local okL, left = pcall(region.GetLeft, region)
  local okT, top = pcall(region.GetTop, region)
  local okRL, rootLeft = pcall(root.GetLeft, root)
  local okRT, rootTop = pcall(root.GetTop, root)
  left = okL and ns.PublicNumber(left)
  top = okT and ns.PublicNumber(top)
  rootLeft = okRL and ns.PublicNumber(rootLeft)
  rootTop = okRT and ns.PublicNumber(rootTop)
  if left and top and rootLeft and rootTop then
    return left - rootLeft, top - rootTop
  end
end

function ns.InheritBarBox(barBox, root, fallback)
  local x, y, w, h = unpack(fallback)
  if not barBox then
    return x, y, w, h
  end
  if barBox.GetWidth then
    local ok, width = pcall(barBox.GetWidth, barBox)
    if ok then
      w = ns.PublicNumber(width, w)
    end
  end
  if barBox.GetHeight then
    local ok, height = pcall(barBox.GetHeight, barBox)
    if ok then
      local liveH = ns.PublicNumber(height)
      if liveH and h then
        -- Health box is only the top bar; keep the XML stack height unless live is larger.
        if liveH > h then
          h = liveH
        end
      end
    end
  end
  local rx, ry = ns.RelativeTopLeft(barBox, root)
  if rx then
    return rx, ry, w, h
  end
  if not barBox.GetPoint then
    return x, y, w, h
  end
  local ok, point, _, relativePoint, px, py = pcall(barBox.GetPoint, barBox, 1)
  if not ok or type(point) ~= "string" then
    return x, y, w, h
  end
  px = ns.PublicNumber(px)
  py = ns.PublicNumber(py)
  if px == nil or py == nil then
    return x, y, w, h
  end
  if point == "TOPLEFT" then
    return px, py, w, h
  end
  if point == "BOTTOMRIGHT" and relativePoint == "LEFT" and root and root.GetHeight then
    local okH, rootH = pcall(root.GetHeight, root)
    local okBH, boxH = pcall(barBox.GetHeight, barBox)
    rootH = (okH and ns.PublicNumber(rootH)) or 100
    boxH = (okBH and ns.PublicNumber(boxH)) or 20
    local bottomRightY = (-rootH / 2) + py
    return px - w, bottomRightY + boxH, w, h
  end
  return x, y, w, h
end

function ns.EnsureUnitChrome(parent, key, sublevel)
  if not parent or not parent.CreateTexture then
    return nil
  end
  key = key or "fcuiChrome"
  local tex = parent[key]
  if tex then
    return tex
  end
  tex = parent:CreateTexture(nil, "BACKGROUND", nil, sublevel or 3)
  parent[key] = tex
  if tex.Hide then
    tex:Hide()
  end
  return tex
end

-- Classic PlayerFrameBackground / TargetFrame Background: solid dark plate
-- behind the name and status bars (chrome art is transparent there).
-- nudge = {x,y} shifts the whole Classic assembly. texturePoint is the Classic
-- chrome anchor on the frame before that nudge (e.g. party chrome at 0,-2).
function ns.ChromeOffset(layout)
  local n = layout and layout.nudge
  if type(n) == "table" then
    return n[1] or 0, n[2] or 0
  end
  return 0, 0
end

function ns.LayoutXY(layout, x, y)
  local ox, oy = ns.ChromeOffset(layout)
  return (x or 0) + ox, (y or 0) + oy
end

function ns.PlaceClassicUnitBackground(parent, root, layout)
  if not parent or not root or not layout or not layout.background then
    return nil
  end
  local spec = layout.background
  local bg = ns.EnsureUnitChrome(parent, "fcuiBackground", 1)
  if not bg then
    return nil
  end
  local point, x, y = unpack(spec.point)
  x, y = ns.LayoutXY(layout, x, y)
  local w, h = unpack(spec.size)
  local r, g, b, a = unpack(spec.color or { 0, 0, 0, 0.5 })
  ns._chromeSkinning = true
  if bg.SetColorTexture then
    pcall(bg.SetColorTexture, bg, r, g, b, a)
  elseif bg.SetTexture then
    pcall(bg.SetTexture, bg, "Interface\\Buttons\\WHITE8X8")
    if bg.SetVertexColor then
      pcall(bg.SetVertexColor, bg, r, g, b, a)
    end
  end
  ns.PlaceOn(bg, root, point, point, x, y, w, h)
  ns.Show(bg)
  ns._chromeSkinning = false
  return bg
end

-- Classic TargetFrame NameBackground (faction-colored strip over the dark plate).
function ns.PlaceClassicNameBackground(texture, root, layout)
  if not texture or not root or not layout or not layout.nameBackground then
    return
  end
  local spec = layout.nameBackground
  local point, x, y = unpack(spec.point)
  x, y = ns.LayoutXY(layout, x, y)
  local w, h = unpack(spec.size)
  ns._chromeSkinning = true
  ns.SetTexture(texture, ns.ResolveArt("NameBackground"))
  ns.PlaceOn(texture, root, point, point, x, y, w, h)
  ns.Show(texture)
  ns._chromeSkinning = false
end

function ns.SyncOverlayShown(native, overlay, isEnabled)
  if not overlay then
    return
  end
  local shown = native and native.IsShown and native:IsShown()
  if shown then
    ns.Show(overlay)
  else
    ns.Hide(overlay)
  end
  if not native or native.fcuiShownHooked then
    return
  end
  native.fcuiShownHooked = true
  if native.Show then
    hooksecurefunc(native, "Show", function()
      if overlay and (not isEnabled or isEnabled()) then
        ns.Show(overlay)
      end
    end)
  end
  if native.Hide then
    hooksecurefunc(native, "Hide", function()
      if overlay then
        ns.Hide(overlay)
      end
    end)
  end
end

function ns.SilenceNativeChrome(texture, isEnabled)
  if not texture then
    return
  end
  ns.Capture(texture)
  texture.fcuiSilenceEnabled = isEnabled
  if texture.SetAlpha then
    pcall(texture.SetAlpha, texture, 0)
  end
  if texture.Hide then
    pcall(texture.Hide, texture)
  end
  if texture.fcuiSilenceHooked then
    return
  end
  texture.fcuiSilenceHooked = true
  local function silence(self)
    if ns._chromeSkinning or self.fcuiSilencing then
      return
    end
    if self.fcuiSilenceEnabled and not self.fcuiSilenceEnabled() then
      return
    end
    self.fcuiSilencing = true
    if self.SetAlpha then
      pcall(self.SetAlpha, self, 0)
    end
    if self.Hide then
      pcall(self.Hide, self)
    end
    self.fcuiSilencing = nil
  end
  if type(texture.SetAtlas) == "function" then
    hooksecurefunc(texture, "SetAtlas", silence)
  end
  if type(texture.SetShown) == "function" then
    hooksecurefunc(texture, "SetShown", function(self, shown)
      if shown then
        silence(self)
      end
    end)
  end
end

-- Classic Era XML placement: exact size/point/texCoord from Blizzard Classic frames.
-- Does not move Forever StatusBars (secret values).
function ns.PlaceClassicChrome(texture, root, layout, art, _unused, texCoord)
  if not texture or not root or not layout then
    return
  end
  local point, x, y = unpack(layout.texturePoint)
  x, y = ns.LayoutXY(layout, x, y)
  local w, h = unpack(layout.textureSize)
  ns._chromeSkinning = true
  ns.CaptureFlags(texture, { "useAtlasSize" })
  texture.useAtlasSize = false
  ns.SetTexture(texture, art or ns.ResolveArt("PlayerFrame"))
  local coord = texCoord or layout.texCoord
  if coord then
    ns.SetTexCoord(texture, unpack(coord))
  end
  ns.PlaceOn(texture, root, point, "TOPLEFT", x, y, w, h)
  ns._chromeSkinning = false
end

function ns.PlaceClassicFlash(texture, root, layout, art, texCoord)
  if not texture or not root or not layout or not layout.flash then
    return
  end
  local point, x, y = unpack(layout.flash.point)
  x, y = ns.LayoutXY(layout, x, y)
  local w, h = unpack(layout.flash.size)
  ns._chromeSkinning = true
  ns.CaptureFlags(texture, { "useAtlasSize" })
  texture.useAtlasSize = false
  ns.SetTexture(texture, art or ns.ResolveArt("FrameFlash"))
  local coord = texCoord or layout.flashTexCoord
  if coord then
    ns.SetTexCoord(texture, unpack(coord))
  end
  ns.PlaceOn(texture, root, point, "TOPLEFT", x, y, w, h)
  ns._chromeSkinning = false
end

function ns.PlaceClassicPortrait(portrait, mask, root, layout)
  if not root or not layout or not layout.portrait then
    return
  end
  local size = layout.portrait.size
  local point, x, y = unpack(layout.portrait.point)
  x, y = ns.LayoutXY(layout, x, y)
  if portrait then
    ns.PlaceOn(portrait, root, point, point, x, y, size, size)
  end
  if mask then
    ns.SetTexture(mask, ns.ResolveArt("PortraitMask"))
    ns.PlaceOn(mask, root, point, point, x, y, size, size)
  end
end

function ns.PlaceClassicName(fontString, root, layout)
  if not fontString or not root or not layout or not layout.name then
    return
  end
  local point, x, y = unpack(layout.name.point)
  x, y = ns.LayoutXY(layout, x, y)
  ns.PlaceOn(fontString, root, point, "CENTER", x, y, layout.name.width, 12)
end

function ns.PlaceClassicLevel(fontString, root, layout)
  if not fontString or not root or not layout or not layout.level then
    return
  end
  local point, x, y = unpack(layout.level.point)
  x, y = ns.LayoutXY(layout, x, y)
  ns.PlaceOn(fontString, root, point, "CENTER", x, y)
end

function ns.PlaceClassicBars(root, layout, healthBox, manaBar)
  if not root or not layout then
    return
  end
  local health = layout.health
  if healthBox and health then
    local point, x, y = unpack(health.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(health.size)
    ns.PlaceUnitSlot(healthBox, root, point, point, x, y, w, h)
    -- Forever sizes the fill bar independently of the container.
    if healthBox.HealthBar then
      ns.PlaceUnitSlot(healthBox.HealthBar, healthBox, "TOPLEFT", "TOPLEFT", 0, 0, w, h)
    end
  end
  local mana = layout.mana
  if manaBar and mana then
    local point, x, y = unpack(mana.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(mana.size)
    -- Forever target mana is wider (134); Classic slot is 119 — must set size or it hangs left.
    ns.PlaceUnitSlot(manaBar, root, point, point, x, y, w, h)
  end
end
function ns.HookChromeReset(texture, reapply, isEnabled)
  if not texture or type(texture.SetAtlas) ~= "function" then
    return
  end
  texture.fcuiChromeEnabled = isEnabled
  if texture.fcuiChromeHooked then
    return
  end
  texture.fcuiChromeHooked = true
  hooksecurefunc(texture, "SetAtlas", function()
    if ns._chromeSkinning or not reapply or texture.fcuiChromePending then
      return
    end
    if texture.fcuiChromeEnabled and not texture.fcuiChromeEnabled() then
      return
    end
    texture.fcuiChromePending = true
    C_Timer.After(0, function()
      texture.fcuiChromePending = nil
      if ns._chromeSkinning then
        return
      end
      if texture.fcuiChromeEnabled and not texture.fcuiChromeEnabled() then
        return
      end
      if reapply then
        reapply()
      end
    end)
  end)
end

function ns.PlaceChromeLabel(fontString, root, texX, texY, scale, slot, width, height)
  if not fontString or not root or not slot or not texX then
    return
  end
  ns.PlaceOn(
    fontString,
    root,
    "CENTER",
    "TOPLEFT",
    texX + slot[1] * scale,
    texY + slot[2] * scale,
    width,
    height
  )
end

function ns.RaiseAbove(frame, other)
  if not frame or not other or not frame.SetFrameLevel then
    return
  end
  ns.Capture(frame)
  local ok, level = pcall(other.GetFrameLevel, other)
  level = ok and ns.PublicNumber(level)
  if not level then
    return
  end
  if ns.CanLayout and not ns.CanLayout(frame) then
    ns.QueueReconcile()
    return
  end
  pcall(frame.SetFrameLevel, frame, level + 4)
end

function ns.PlaceMinimapBorder(border, map)
  local layout = ns.Layout.Minimap
  local mapSize = layout.classicMap
  if map and map.GetWidth then
    local ok, w = pcall(map.GetWidth, map)
    if ok then
      mapSize = ns.PublicNumber(w, mapSize)
    end
  end
  local borderSize = mapSize * (layout.classicBorder / layout.classicMap)
  local ox, oy = 0, 0
  if layout.borderOffset then
    ox, oy = unpack(layout.borderOffset)
  end
  ns.SetTexture(border, ns.ResolveArt("MinimapBorder"))
  ns.SetTexCoord(border, unpack(layout.texCoord))
  ns.SetDrawLayer(border, "OVERLAY", 7)
  if border.SetParent and map then
    pcall(border.SetParent, border, map)
  end
  ns.PlaceOn(border, map or border, "CENTER", "CENTER", ox, oy, borderSize, borderSize)
end
function ns.SetStatusBarClassic(bar)
  if not bar or (ns.TouchesSecretBars and ns.TouchesSecretBars(bar)) then
    return
  end
  local texture = ns.ResolveArt("StatusBar")
  if bar.SetStatusBarTexture then
    pcall(bar.SetStatusBarTexture, bar, texture)
  end
  if bar.Spark then
    if ns.Capture then
      ns.Capture(bar.Spark)
    end
    pcall(bar.Spark.SetAlpha, bar.Spark, 0)
  end
end

function ns.LayoutStatusBar()
  -- Unit status bars cannot be moved or retextured without tainting Forever secret values.
end

function ns.ClassicPvpArt(unit)
  if not unit or not UnitExists(unit) then
    return nil
  end
  if UnitIsPVPFreeForAll(unit) then
    return ns.ResolveArt("PvpFFA")
  end
  if not UnitIsPVP(unit) then
    return nil
  end
  local faction = UnitFactionGroup(unit)
  if faction == "Alliance" then
    return ns.ResolveArt("PvpAlliance")
  end
  if faction == "Horde" then
    return ns.ResolveArt("PvpHorde")
  end
end

function ns.SkinPvpIcon(icon, unit)
  if not icon or not icon.SetTexture then
    return
  end
  local art = ns.ClassicPvpArt(unit)
  if art then
    if ns.SetTexture then
      ns.SetTexture(icon, art)
    else
      icon:SetTexture(art)
    end
  end
end

function ns.SkinFlash(flash, texCoord, artKey)
  if not flash or not flash.SetTexture then
    return
  end
  local path = ns.ResolveArt(artKey or "FrameFlash")
  if ns.SetTexture then
    ns.SetTexture(flash, path)
  else
    flash:SetTexture(path)
  end
  if texCoord then
    if ns.SetTexCoord then
      ns.SetTexCoord(flash, unpack(texCoord))
    elseif flash.SetTexCoord then
      flash:SetTexCoord(unpack(texCoord))
    end
  end
end
