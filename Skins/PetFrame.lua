local _, ns = ...

local function Apply()
  local pet = ns.FirstExisting("PetFrame", PlayerFrame and PlayerFrame.petFrame)
  if not pet then
    ns.compat.pet = "PetFrame not present yet."
    return
  end

  local texture = pet.texture or pet.Texture or _G.PetFrameTexture
  if texture and texture.SetTexture then
    texture:SetTexture(ns.ResolveArt("SmallTarget"))
  end

  local health = pet.HealthBar or pet.healthbar or _G.PetFrameHealthBar
  local mana = pet.ManaBar or pet.manabar or _G.PetFrameManaBar
  ns.SetStatusBarClassic(health)
  ns.SetStatusBarClassic(mana)

  if ns.db.hideModernChrome then
    ns.Hide(pet.Flash)
    ns.Hide(pet.DebuffFrame)
  end
end

ns.RegisterSkin("pet", Apply)
