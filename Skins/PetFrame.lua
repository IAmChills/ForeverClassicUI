local _, ns = ...

local hookedShow

local function Apply()
  if PlayerFrame and PlayerFrame.state == "vehicle" then
    return
  end

  local pet = ns.FirstExisting("PetFrame", PlayerFrame and PlayerFrame.petFrame)
  if not pet then
    ns.compat.pet = "PetFrame not present yet."
    return
  end

  local texture = pet.texture or pet.Texture or _G.PetFrameTexture
  if texture then
    ns.SetTexture(texture, ns.ResolveArt("SmallTarget"))
  end

  local mask = pet.PortraitMask or pet.portraitMask
  if mask then
    ns.SetTexture(mask, ns.ResolveArt("PortraitMask"))
  end

  ns.SkinFlash(pet.Flash or _G.PetFrameFlash)
  local attack = _G.PetAttackModeTexture
  if attack then
    ns.SetTexture(attack, ns.ResolveArt("PlayerStatus"))
  end

  if not hookedShow then
    hookedShow = true
    ns.SafeHook(pet, "OnShow", function()
      if ns.db and ns.db.petFrame then
        Apply()
      end
    end)
  end
end

ns.RegisterSkin("pet", Apply)
