local _, ns = ...

local hookedArt = {}

local function SkinMember(frame)
  if not frame then
    return
  end
  if frame.state == "vehicle" then
    return
  end

  local texture = frame.Texture or frame.texture or ns.GetPath(frame, "Texture")
  if texture then
    ns.SetTexture(texture, ns.ResolveArt("PartyFrame"))
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
  if mask then
    ns.SetTexture(mask, ns.ResolveArt("PortraitMask"))
  end

  if frame.Flash then
    ns.SetTexture(frame.Flash, ns.ResolveArt("PartyFlash"))
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
  if not PartyFrame or not PartyFrame.MemberFrame1 then
    ns.compat.party = "PartyFrame.MemberFrame1 missing."
    return
  end
  for i = 1, 4 do
    SkinMember(PartyFrame["MemberFrame" .. i])
  end
end

ns.RegisterSkin("party", Apply)
