local _, ns = ...

local applied
local partyHooked

local function HookPartyClassic()
  if partyHooked or not PartyFrame then
    return
  end
  partyHooked = true

  local function ReapplyParty()
    if not FCUIClassicDB or not FCUIClassicDB.classicFrames then
      return
    end
    if ns.EnsureClassicNames then
      ns.EnsureClassicNames()
    end
    if FCUI.MakeClassicPartyFrame then
      FCUI.MakeClassicPartyFrame()
    end
    if FCUI.HookClassicUnitFrameTextures then
      FCUI.HookClassicUnitFrameTextures()
    end
  end

  if PartyFrame.InitializePartyMemberFrames then
    hooksecurefunc(PartyFrame, "InitializePartyMemberFrames", ReapplyParty)
  end
  if PartyFrame.UpdateMemberFrames then
    hooksecurefunc(PartyFrame, "UpdateMemberFrames", ReapplyParty)
  end
end

function ns.ApplyClassicBundle()
  ns.SyncClassicDBFromProfile()
  local db = FCUIClassicDB
  if not db.classicFrames and not db.classicCastbars and not db.classicCastbarsPlayer then
    return
  end

  if ns.EnsureClassicNames then
    ns.EnsureClassicNames()
  end

  if db.classicFrames and FCUI.ClassicFrames and not applied then
    local ok, err = pcall(FCUI.ClassicFrames)
    if not ok then
      ns.Print("Classic Frames failed:", tostring(err))
      return
    end
    applied = true
    HookPartyClassic()
  elseif db.classicFrames and applied then
    HookPartyClassic()
    if FCUI.MakeClassicPartyFrame then
      FCUI.MakeClassicPartyFrame()
    end
  end

  if FCUI.HookClassicUnitFrameTextures then
    FCUI.HookClassicUnitFrameTextures()
  end

  if FCUI.ApplyClassicCastbars then
    FCUI.ApplyClassicCastbars()
  end

  if FCUI.ApplyClassicComboPoints then
    FCUI.ApplyClassicComboPoints()
  end

  if db.classicFrames then
    if FCUI.MoveToTFrames then
      FCUI.MoveToTFrames()
    end
    if FCUI.SetCenteredNamesCaller then
      FCUI.SetCenteredNamesCaller()
      C_Timer.After(0, function()
        if FCUI.MoveToTFrames then
          FCUI.MoveToTFrames()
        end
        if FCUI.SetCenteredNamesCaller then
          FCUI.SetCenteredNamesCaller()
        end
      end)
    end
  end
end
