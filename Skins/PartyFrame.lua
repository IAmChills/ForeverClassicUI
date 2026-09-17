local _, ns = ...

local hookedArt = {}

local function ForEachPartyMember(callback)
  if not PartyFrame then
    return
  end
  local seen = {}
  if PartyFrame.PartyMemberFramePool and PartyFrame.PartyMemberFramePool.EnumerateActive then
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
      if frame and not seen[frame] then
        seen[frame] = true
        callback(frame)
      end
    end
  end
  for i = 1, 4 do
    local frame = PartyFrame["MemberFrame" .. i]
    if frame and not seen[frame] then
      seen[frame] = true
      callback(frame)
    end
  end
end

local function SkinMember(frame)
  if not frame then
    return
  end
  if frame.state == "vehicle" then
    return
  end

  local layout = ns.Layout.Party
  local function partyOn()
    return ns.db and ns.db.partyFrames and true or false
  end

  local texture = frame.Texture or frame.texture
  ns.SilenceNativeChrome(texture, partyOn)
  ns.SilenceNativeChrome(frame.Flash, partyOn)
  ns.Hide(frame.VehicleTexture)

  ns.PlaceClassicUnitBackground(frame, frame, layout)

  local chrome = ns.EnsureUnitChrome(frame, "fcuiChrome")
  -- Classic UI-PartyFrame is 128x64; Forever atlas collapse leaves it tiny.
  ns.PlaceClassicChrome(chrome, frame, layout, ns.ResolveArt("PartyFrame"))
  if chrome then
    ns.Show(chrome)
  end
  if texture then
    ns.HookChromeReset(texture, function()
      SkinMember(frame)
    end, partyOn)
  end

  ns.PlaceClassicPortrait(frame.Portrait, frame.PortraitMask, frame, layout)

  local healthBox = frame.HealthBarContainer
  local health = (healthBox and healthBox.HealthBar) or frame.HealthBar
  local mana = frame.ManaBar
  ns.HideBarMasks(health)
  ns.HideBarMasks(mana)
  if healthBox and layout.health then
    local point, x, y = unpack(layout.health.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(layout.health.size)
    ns.PlaceUnitSlot(healthBox, frame, point, point, x, y, w, h)
    if health then
      ns.PlaceUnitSlot(health, healthBox, "TOPLEFT", "TOPLEFT", 0, 0, w, h)
    end
  elseif health and layout.health then
    local point, x, y = unpack(layout.health.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(layout.health.size)
    ns.PlaceUnitSlot(health, frame, point, point, x, y, w, h)
  end
  if mana and layout.mana then
    local point, x, y = unpack(layout.mana.point)
    x, y = ns.LayoutXY(layout, x, y)
    local w, h = unpack(layout.mana.size)
    ns.PlaceUnitSlot(mana, frame, point, point, x, y, w, h)
  end

  if frame.Name and layout.name then
    local point, x, y = unpack(layout.name.point)
    x, y = ns.LayoutXY(layout, x, y)
    ns.PlaceOn(frame.Name, frame, point, "TOPLEFT", x, y, layout.name.width, 12)
  end

  local flash = ns.EnsureUnitChrome(frame, "fcuiFlash")
  ns.PlaceClassicFlash(flash, frame, layout, ns.ResolveArt("PartyFlash"))
  ns.SyncOverlayShown(frame.Flash, flash, partyOn)
  if frame.Flash then
    ns.HookChromeReset(frame.Flash, function()
      SkinMember(frame)
    end, partyOn)
  end

  if not hookedArt[frame] then
    hookedArt[frame] = true
    ns.SafeHook(frame, "UpdateArt", function(self)
      if not ns.db or not ns.db.partyFrames then
        return
      end
      SkinMember(self)
    end)
    ns.SafeHook(frame, "ToPlayerArt", function(self)
      if not ns.db or not ns.db.partyFrames then
        return
      end
      SkinMember(self)
    end)
  end
end

local function Apply()
  if not PartyFrame then
    ns.compat.party = "PartyFrame missing."
    return
  end
  local any
  ForEachPartyMember(function(frame)
    any = true
    SkinMember(frame)
  end)
  if not any then
    ns.compat.party = "No party member frames yet."
  end
end

ns.RegisterSkin("party", Apply)
