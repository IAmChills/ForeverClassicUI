local _, ns = ...

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
    or ns.GetPath(frame, "HealthBarsContainer.HealthBar")
  local mana = frame.ManaBar or frame.manabar or ns.GetPath(frame, "ManaBar")
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)

  if ns.db.hideModernChrome then
    ns.Hide(frame.Flash)
    ns.Hide(frame.RoleIcon)
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
