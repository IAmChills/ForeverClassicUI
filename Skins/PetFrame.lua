local _, ns = ...

local hookedShow

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

  local mask = pet.PortraitMask or pet.portraitMask
  if mask and mask.SetTexture then
    mask:SetTexture(ns.ResolveArt("PortraitMask"))
  end

  if ns.db.hideModernChrome then
    ns.Hide(pet.Flash)
    ns.Hide(_G.PetFrameFlash)
    ns.Hide(_G.PetAttackModeTexture)
    ns.Hide(pet.DebuffFrame)
  end

  if not hookedShow then
    hookedShow = true
    pet:HookScript("OnShow", function()
      if ns.db and ns.db.petFrame then
        Apply()
      end
    end)
  end
end

ns.RegisterSkin("pet", Apply)

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

  local mask = pet.PortraitMask or pet.portraitMask
  if mask and mask.SetTexture then
    mask:SetTexture(ns.ResolveArt("PortraitMask"))
  end

  if ns.db.hideModernChrome then
    ns.Hide(pet.Flash)
    ns.Hide(_G.PetFrameFlash)
    ns.Hide(_G.PetAttackModeTexture)
    ns.Hide(pet.DebuffFrame)
  end
end

ns.RegisterSkin("pet", Apply)
