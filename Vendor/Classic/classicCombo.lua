function FCUI.UpdateLegacyComboPosition()
  if not ComboFrame then
    return
  end
  local db = FCUIClassicDB
  local x = db.legacyComboXPos or -44
  local y = db.legacyComboYPos or -8
  local scale = db.legacyComboScale or 0.85
  ComboFrame:ClearAllPoints()
  ComboFrame:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", x, y)
  ComboFrame:SetScale(scale)
end

function FCUI.ApplyClassicComboPoints()
  if not FCUIClassicDB.enableLegacyComboPoints then
    return
  end
  if C_CVar and C_CVar.SetCVar then
    pcall(C_CVar.SetCVar, "comboPointLocation", "1")
  end
  if ComboFrame then
    ComboFrame:SetParent(TargetFrame)
    ComboFrame:SetFrameStrata("HIGH")
    FCUI.UpdateLegacyComboPosition()
  end
end
