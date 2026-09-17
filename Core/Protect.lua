local _, ns = ...

-- Combat-safe mutation, forbidden-frame guards, and native-state revert.

local snapshots = {}
local owned = {}
local currentSkin
local pendingReconcile

local LAYOUT_TYPES = {
  Frame = true,
  Button = true,
  CheckButton = true,
  StatusBar = true,
  Slider = true,
  ScrollFrame = true,
  EditBox = true,
}

local function Public(value)
  if value ~= nil and type(issecretvalue) == "function" and issecretvalue(value) then
    return nil
  end
  return value
end

function ns.InCombat()
  return type(InCombatLockdown) == "function" and InCombatLockdown() and true or false
end

function ns.IsUsable(region)
  if not region then
    return false
  end
  local ok, forbidden = pcall(function()
    return region.IsForbidden and region:IsForbidden()
  end)
  if not ok or forbidden then
    return false
  end
  return true
end

function ns.IsProtectedFrame(region)
  if not ns.IsUsable(region) then
    return false
  end
  local ok, protected = pcall(function()
    return region.IsProtected and region:IsProtected()
  end)
  return ok and protected and true or false
end

local function ObjectType(region)
  if not region or not region.GetObjectType then
    return nil
  end
  local ok, otype = pcall(region.GetObjectType, region)
  if ok then
    return otype
  end
end

function ns.IsLayoutObject(region)
  local otype = ObjectType(region)
  return otype and LAYOUT_TYPES[otype] and true or false
end

function ns.CanLayout(region)
  if ns.InCombat() then
    return false
  end
  return ns.IsUsable(region)
end

function ns.QueueReconcile()
  pendingReconcile = true
end

function ns.BeginSkin(name)
  currentSkin = name
end

function ns.EndSkin()
  currentSkin = nil
end

function ns.CaptureFlags(region, flags)
  ns.Capture(region)
  local snap = snapshots[region]
  if not snap then
    return
  end
  snap.flags = snap.flags or {}
  for i = 1, #flags do
    local key = flags[i]
    if snap.flags[key] == nil then
      snap.flags[key] = region[key]
    end
  end
end

function ns.Capture(region)
  if not region or snapshots[region] or not ns.IsUsable(region) then
    return
  end

  local snap = {}
  pcall(function()
    if region.GetTexture then
      snap.texture = Public(region:GetTexture())
    end
    if region.GetAtlas then
      snap.atlas = Public(region:GetAtlas())
    end
    if region.GetTexCoord then
      snap.texCoord = { region:GetTexCoord() }
    end
    if region.GetWidth then
      snap.width = Public(region:GetWidth())
      snap.height = Public(region:GetHeight())
    end
    if region.GetAlpha then
      snap.alpha = Public(region:GetAlpha())
    end
    if region.IsShown then
      snap.shown = region:IsShown() and true or false
    end
    if region.GetDrawLayer then
      snap.layer, snap.sublevel = region:GetDrawLayer()
    end
    if region.GetFrameLevel then
      snap.frameLevel = Public(region:GetFrameLevel())
    end
    if region.GetVertexColor then
      snap.r, snap.g, snap.b, snap.a = region:GetVertexColor()
    end
    if region.GetStatusBarTexture then
      local fill = region:GetStatusBarTexture()
      if fill and ns.IsUsable(fill) then
        if fill.GetTexture then
          snap.statusBarTexture = Public(fill:GetTexture())
        end
        if fill.GetAtlas then
          snap.statusBarAtlas = Public(fill:GetAtlas())
        end
        if fill.GetNumMaskTextures and fill.GetMaskTexture then
          snap.masks = {}
          for i = 1, fill:GetNumMaskTextures() do
            snap.masks[#snap.masks + 1] = fill:GetMaskTexture(i)
          end
        end
      end
    elseif region.GetNumMaskTextures and region.GetMaskTexture then
      snap.masks = {}
      for i = 1, region:GetNumMaskTextures() do
        snap.masks[#snap.masks + 1] = region:GetMaskTexture(i)
      end
    end
    if region.GetStatusBarColor then
      snap.sbR, snap.sbG, snap.sbB, snap.sbA = region:GetStatusBarColor()
    end
    if region.GetNormalTexture then
      local tex = region:GetNormalTexture()
      if tex then
        snap.normalTexture = tex.GetTexture and Public(tex:GetTexture())
        snap.normalAtlas = tex.GetAtlas and Public(tex:GetAtlas())
      end
    end
    if region.GetPushedTexture then
      local tex = region:GetPushedTexture()
      if tex then
        snap.pushedTexture = tex.GetTexture and Public(tex:GetTexture())
        snap.pushedAtlas = tex.GetAtlas and Public(tex:GetAtlas())
      end
    end
    if region.GetNumPoints then
      local points = {}
      local valid = true
      for i = 1, region:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = region:GetPoint(i)
        if Public(point) == nil and point ~= nil then
          valid = false
          break
        end
        points[i] = { point, relativeTo, relativePoint, Public(x) or x, Public(y) or y }
      end
      if valid then
        snap.points = points
      end
    end
  end)

  snapshots[region] = snap
  owned[region] = currentSkin or owned[region] or "unknown"
end

local function RestoreRegion(region)
  local snap = snapshots[region]
  if not snap then
    return true
  end
  if not ns.IsUsable(region) then
    return false
  end

  local isStatusBar = ObjectType(region) == "StatusBar"

  local ok = pcall(function()
    -- StatusBars: layout only. Never touch fill textures/colors/values.
    if isStatusBar then
      if not ns.CanLayout(region) then
        return
      end
      if snap.width and snap.height and region.SetSize then
        region:SetSize(snap.width, snap.height)
      end
      if snap.points and region.ClearAllPoints and region.SetPoint then
        region:ClearAllPoints()
        for i = 1, #snap.points do
          local point = snap.points[i]
          if point and point[1] then
            region:SetPoint(unpack(point))
          end
        end
      end
      return
    end

    if snap.flags then
      for key, value in pairs(snap.flags) do
        region[key] = value
      end
    end

    if snap.frameLevel and region.SetFrameLevel then
      pcall(region.SetFrameLevel, region, snap.frameLevel)
    end

    if snap.atlas and snap.atlas ~= "" and region.SetAtlas then
      if not pcall(region.SetAtlas, region, snap.atlas, true) then
        region:SetAtlas(snap.atlas)
      end
    elseif region.SetTexture then
      region:SetTexture(snap.texture)
    end

    if snap.texCoord and region.SetTexCoord then
      region:SetTexCoord(unpack(snap.texCoord))
    end
    if snap.r and region.SetVertexColor then
      region:SetVertexColor(snap.r, snap.g, snap.b, snap.a)
    end
    if snap.alpha ~= nil and region.SetAlpha then
      region:SetAlpha(snap.alpha)
    end
    if snap.layer and region.SetDrawLayer then
      region:SetDrawLayer(snap.layer, snap.sublevel)
    end

    if snap.normalAtlas and snap.normalAtlas ~= "" and region.SetNormalAtlas then
      region:SetNormalAtlas(snap.normalAtlas)
    elseif snap.normalTexture and region.SetNormalTexture then
      region:SetNormalTexture(snap.normalTexture)
    end
    if snap.pushedAtlas and snap.pushedAtlas ~= "" and region.SetPushedAtlas then
      region:SetPushedAtlas(snap.pushedAtlas)
    elseif snap.pushedTexture and region.SetPushedTexture then
      region:SetPushedTexture(snap.pushedTexture)
    end

    -- Restore size/anchors for textures and for unit slot Frames
    -- (HealthBarsContainer). Skip protected unit Buttons (PlayerFrame itself).
    local otype = ObjectType(region)
    local allowLayout = otype ~= "Button" and otype ~= "CheckButton" and ns.CanLayout(region)
    if allowLayout then
      if snap.width and snap.height and region.SetSize then
        region:SetSize(snap.width, snap.height)
      end
      if snap.points and region.ClearAllPoints and region.SetPoint then
        region:ClearAllPoints()
        for i = 1, #snap.points do
          local point = snap.points[i]
          if point and point[1] then
            region:SetPoint(unpack(point))
          end
        end
      end
    end

    if snap.shown ~= nil and region.Show and region.Hide then
      if snap.shown then
        region:Show()
      else
        region:Hide()
      end
    end
  end)

  return ok
end

function ns.RestoreSkin(name)
  local okAll = true
  local was = ns._chromeSkinning
  ns._chromeSkinning = true
  local regions = {}
  for region, skin in pairs(owned) do
    if skin == name then
      regions[#regions + 1] = region
    end
  end
  for i = 1, #regions do
    local region = regions[i]
    if not RestoreRegion(region) then
      okAll = false
    end
    snapshots[region] = nil
    owned[region] = nil
  end
  ns._chromeSkinning = was
  if ns.RefreshNative then
    pcall(ns.RefreshNative, name)
  end
  return okAll
end

function ns.SetTexture(region, path)
  if not ns.IsUsable(region) or not region.SetTexture then
    return
  end
  ns.Capture(region)
  -- Forever HUD pieces are atlases. SetTexture does not always replace an atlas.
  -- Guard so SetAtlas hooks cannot re-enter skinning (infinite timer/GPU loop).
  local was = ns._chromeSkinning
  ns._chromeSkinning = true
  if region.SetAtlas then
    pcall(region.SetAtlas, region, nil)
    pcall(region.SetAtlas, region, "")
  end
  pcall(region.SetTexture, region, path)
  ns._chromeSkinning = was
end

function ns.SetTexCoord(region, ...)
  if not ns.IsUsable(region) or not region.SetTexCoord then
    return
  end
  ns.Capture(region)
  pcall(region.SetTexCoord, region, ...)
end

function ns.SetDrawLayer(region, layer, sublevel)
  if not ns.IsUsable(region) or not region.SetDrawLayer then
    return
  end
  ns.Capture(region)
  pcall(region.SetDrawLayer, region, layer, sublevel)
end

function ns.TouchesSecretBars(region)
  if not ns.IsUsable(region) then
    return true
  end
  -- Only the StatusBar widgets themselves carry secret values.
  -- Parent containers (HealthBarsContainer, etc.) can be re-anchored.
  return ObjectType(region) == "StatusBar"
end

-- Layout-only move for unit-frame slots. Never reads bar values.
function ns.PlaceUnitSlot(region, relative, point, relativePoint, x, y, width, height)
  if not region or not ns.IsUsable(region) then
    return
  end
  ns.Capture(region)
  if not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  if width and height and region.SetSize then
    pcall(region.SetSize, region, width, height)
  elseif width and region.SetWidth then
    pcall(region.SetWidth, region, width)
  elseif height and region.SetHeight then
    pcall(region.SetHeight, region, height)
  end
  pcall(region.ClearAllPoints, region)
  if relative then
    pcall(region.SetPoint, region, point, relative, relativePoint, x, y)
  else
    pcall(region.SetPoint, region, point, relativePoint, x, y)
  end
end

function ns.SetSize(region, width, height)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  pcall(region.SetSize, region, width, height)
end

function ns.SetWidth(region, width)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  pcall(region.SetWidth, region, width)
end

function ns.ClearAllPoints(region)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  pcall(region.ClearAllPoints, region)
end

function ns.SetPoint(region, ...)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  pcall(region.SetPoint, region, ...)
end

function ns.PlaceOn(region, relative, point, relativePoint, x, y, width, height)
  if ns.TouchesSecretBars(region) then
    return
  end
  if width and height then
    ns.SetSize(region, width, height)
  end
  ns.ClearAllPoints(region)
  if relative then
    ns.SetPoint(region, point, relative, relativePoint, x, y)
  else
    ns.SetPoint(region, point, relativePoint, x, y)
  end
end

function ns.Show(region)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if ns.IsLayoutObject(region) and not ns.CanLayout(region) then
    ns.QueueReconcile()
    return
  end
  if region.Show then
    pcall(region.Show, region)
  end
end

local origHide = ns.Hide
function ns.Hide(region)
  if not ns.IsUsable(region) or ns.TouchesSecretBars(region) then
    return
  end
  ns.Capture(region)
  if ns.IsLayoutObject(region) and not ns.CanLayout(region) then
    if region.SetAlpha then
      pcall(region.SetAlpha, region, 0)
    end
    ns.QueueReconcile()
    return
  end
  origHide(region)
end

local origKeepSize = ns.SetTextureKeepSize
function ns.SetTextureKeepSize(region, path, texCoord)
  if not ns.IsUsable(region) then
    return
  end
  ns.Capture(region)
  if ns.CanLayout(region) then
    origKeepSize(region, path, texCoord)
    return
  end
  if region.SetTexture then
    pcall(region.SetTexture, region, path)
  end
  if texCoord and region.SetTexCoord then
    pcall(region.SetTexCoord, region, unpack(texCoord))
  elseif region.SetTexCoord then
    pcall(region.SetTexCoord, region, 0, 1, 0, 1)
  end
  ns.QueueReconcile()
end

local origStatusBar = ns.SetStatusBarClassic
function ns.SetStatusBarClassic(bar)
  -- Forever health/power bars use secret values. Mutating a StatusBar taints
  -- Blizzard's OnValueChanged and errors on every tick.
  if ns.TouchesSecretBars(bar) then
    return
  end
  if not ns.IsUsable(bar) then
    return
  end
  ns.Capture(bar)
  origStatusBar(bar)
end

local origHook = ns.SafeHook
function ns.SafeHook(target, method, handler)
  local hookfn
  if type(target) == "string" then
    hookfn = type(method) == "function" and method or handler
  else
    hookfn = handler
  end
  if type(hookfn) ~= "function" then
    return
  end
  local wrapped = function(...)
    local ok, err = pcall(hookfn, ...)
    if not ok then
      ns.Debug("hook error:", err)
      ns.QueueReconcile()
    end
  end
  if type(target) == "string" then
    origHook(target, wrapped)
  else
    origHook(target, method, wrapped)
  end
end

function ns.RefreshNative(name)
  -- Do not call Blizzard unit-frame art functions here. ToPlayerArt / UpdateArt /
  -- CheckClassification re-enter UnitFrameHealthBar_Update with secret values.
  if name == "minimap" and ns._classicMinimapBorder then
    pcall(ns._classicMinimapBorder.Hide, ns._classicMinimapBorder)
  end
  if name == "player" and PlayerFrame and PlayerFrame.PlayerFrameContainer then
    local c = PlayerFrame.PlayerFrameContainer
    if c.fcuiBackground then
      pcall(c.fcuiBackground.Hide, c.fcuiBackground)
    end
    if c.fcuiChrome then
      pcall(c.fcuiChrome.Hide, c.fcuiChrome)
    end
    if c.fcuiFlash then
      pcall(c.fcuiFlash.Hide, c.fcuiFlash)
    end
  end
  if name == "target" then
    local frames = { TargetFrame, FocusFrame }
    for i = 1, #frames do
      local frame = frames[i]
      local c = frame and frame.TargetFrameContainer
      if c then
        if c.fcuiBackground then
          pcall(c.fcuiBackground.Hide, c.fcuiBackground)
        end
        if c.fcuiChrome then
          pcall(c.fcuiChrome.Hide, c.fcuiChrome)
        end
        if c.fcuiFlash then
          pcall(c.fcuiFlash.Hide, c.fcuiFlash)
        end
      end
      local tot = frame and (frame.totFrame or (frame == FocusFrame and _G.FocusFrameToT) or _G.TargetFrameToT)
      if tot then
        if tot.fcuiBackground then
          pcall(tot.fcuiBackground.Hide, tot.fcuiBackground)
        end
        if tot.fcuiChrome then
          pcall(tot.fcuiChrome.Hide, tot.fcuiChrome)
        end
      end
    end
  end
  if name == "party" and PartyFrame then
    local function hidePartyOverlays(frame)
      if not frame then
        return
      end
      if frame.fcuiBackground then
        pcall(frame.fcuiBackground.Hide, frame.fcuiBackground)
      end
      if frame.fcuiChrome then
        pcall(frame.fcuiChrome.Hide, frame.fcuiChrome)
      end
      if frame.fcuiFlash then
        pcall(frame.fcuiFlash.Hide, frame.fcuiFlash)
      end
    end
    if PartyFrame.PartyMemberFramePool and PartyFrame.PartyMemberFramePool.EnumerateActive then
      for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hidePartyOverlays(frame)
      end
    end
    for i = 1, 4 do
      hidePartyOverlays(PartyFrame["MemberFrame" .. i])
    end
  end
end

function ns.FlushPendingReconcile()
  if not pendingReconcile then
    return
  end
  if ns.InCombat() then
    return
  end
  pendingReconcile = false
  if ns.ApplySkins then
    ns.ApplySkins()
  end
end
