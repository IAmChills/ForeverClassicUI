local _, ns = ...

local hookedArt = {}

local function SkinMember(frame)
  if not frame then
    return
  end

  local texture = frame.Texture or frame.texture or ns.GetPath(frame, "Texture")
  if texture and texture.SetTexture then
    texture:SetTexture(ns.ResolveArt("PartyFrame"))
  end

  local health = frame.HealthBar
    or frame.healthbar
    or ns.GetPath(frame, "HealthBar")
    or ns.GetPath(frame, "HealthBarContainer.HealthBar")
    or ns.GetPath(frame, "HealthBarsContainer.HealthBar")
  local mana = frame.ManaBar or frame.manabar or ns.GetPath(frame, "ManaBar")
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)

  local mask = frame.PortraitMask
  if mask and mask.SetTexture then
    mask:SetTexture(ns.ResolveArt("PortraitMask"))
  end

  if ns.db.hideModernChrome then
    ns.Hide(frame.Flash)
    ns.Hide(frame.RoleIcon)
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
  if PartyFrame and PartyFrame.MemberFrame1 then
    for i = 1, 4 do
      SkinMember(PartyFrame["MemberFrame" .. i])
    end
    return
  end

  local found = false
  for i = 1, 4 do
    local frame = _G["PartyMemberFrame" .. i]
    if frame then
      found = true
      SkinMember(frame)
    end
  end

  if not found then
    ns.compat.party = "No party frames found. Forever may use a compact-only party UI."
  end
end

ns.RegisterSkin("party", Apply)
