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
  MinimapZoomOutUp = "Interface\\Minimap\\UI-Minimap-ZoomOutButton-Up",
  MinimapZoomOutDown = "Interface\\Minimap\\UI-Minimap-ZoomOutButton-Down",
  PortraitMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
  GroupIndicator = "Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator",
  LeaderIcon = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
}

ns.Layout = {
  Player = {
    size = { 232, 100 },
    texturePoint = { "TOPLEFT", -19, -8 },
    textureSize = { 232, 100 },
    -- Mirrored vs the target frame sheet.
    texCoord = { 1, 0.09375, 0, 0.78125 },
    portrait = { size = 64, point = { "TOPLEFT", 27, -17 } },
  },
  Target = {
    size = { 232, 100 },
    texturePoint = { "TOPLEFT", 20, -8 },
    textureSize = { 232, 100 },
    texCoord = { 0.09375, 1, 0, 0.78125 },
    portrait = { size = 64, point = { "TOPRIGHT", -21, -17 } },
  },
  CastBar = {
    playerSize = { 195, 13 },
    borderSize = { 256, 64 },
    borderPoint = { "TOP", 0, 28 },
  },
}

function ns.Media(relativePath)
  return ns.MEDIA_ROOT .. relativePath:gsub("/", "\\")
end

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
    if type(_G[target]) == "function" then
      hooksecurefunc(target, handler)
    end
    return
  end
  if target and type(target[method]) == "function" then
    hooksecurefunc(target, method, handler)
  end
end

local function ClearTextureMasks(tex)
  if not tex or not tex.RemoveMaskTexture then
    return
  end
  if tex.GetNumMaskTextures and tex.GetMaskTexture then
    for i = tex:GetNumMaskTextures(), 1, -1 do
      local mask = tex:GetMaskTexture(i)
      if mask then
        tex:RemoveMaskTexture(mask)
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
      tex:RemoveMaskTexture(masks[i])
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
  -- PlayerFrameContainer is the retail-shaped HUD.
  if PlayerFrame and PlayerFrame.PlayerFrameContainer then
    return "retail10"
  end
  if _G.PlayerFrameTexture or (PlayerFrame and PlayerFrame.texture) then
    return "classic"
  end
  if PlayerFrame then
    return "unknown-playerframe"
  end
  return "missing"
end

function ns.SetStatusBarClassic(bar)
  if not bar then
    return
  end
  local texture = ns.ResolveArt("StatusBar")
  if bar.SetStatusBarTexture then
    bar:SetStatusBarTexture(texture)
  end
  if bar.Spark then
    bar.Spark:SetAlpha(0)
  end
  ns.HideBarMasks(bar)
end
