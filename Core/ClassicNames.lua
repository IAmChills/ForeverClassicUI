local _, ns = ...

local function InitializeFontString(frame)
  if not frame or frame.fcuiName then
    return
  end
  local name = frame.name or frame.Name
  if frame == PlayerFrame and not name then
    name = _G.PlayerName
  end
  if not name or not name.GetParent or not name:GetParent() then
    return
  end

  frame.fcuiName = name:GetParent():CreateFontString(nil, name:GetDrawLayer() or "OVERLAY", "GameFontNormal")

  local font, fontHeight, fontFlags = name:GetFont()
  if font then
    frame.fcuiName:SetFont(font, fontHeight, fontFlags)
  end

  local justify = frame == PlayerFrame and "CENTER" or name:GetJustifyH()
  frame.fcuiName:SetJustifyH(justify)
  frame.fcuiName:SetJustifyV(name:GetJustifyV())
  frame.fcuiName:SetTextColor(name:GetTextColor())
  frame.fcuiName:SetShadowColor(name:GetShadowColor())
  frame.fcuiName:SetShadowOffset(name:GetShadowOffset())
  frame.fcuiName:SetWidth(name:GetWidth())
  frame.fcuiName:SetHeight(name:GetHeight())
  frame.fcuiName:SetWordWrap(false)

  local point, relativeTo, relativePoint, xOffset, yOffset = name:GetPoint()
  if point then
    frame.fcuiName:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
  end

  frame.fcuiName:SetText(name:GetText() or "")
  hooksecurefunc(name, "SetText", function(self)
    if frame.fcuiName then
      frame.fcuiName:SetText(self:GetText() or "")
    end
  end)

  name:SetAlpha(0)
end

function ns.EnsureClassicNames()
  local list = {
    PlayerFrame,
    TargetFrame,
    FocusFrame,
    TargetFrameToT or (TargetFrame and TargetFrame.totFrame),
    FocusFrameToT or (FocusFrame and FocusFrame.totFrame),
    PetFrame,
  }
  for i = 1, #list do
    InitializeFontString(list[i])
  end
  if PartyFrame then
    for i = 1, 4 do
      InitializeFontString(PartyFrame["MemberFrame" .. i])
    end
    if PartyFrame.PartyMemberFramePool and PartyFrame.PartyMemberFramePool.EnumerateActive then
      for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        InitializeFontString(frame)
      end
    end
  end
end

local function CenterPlayerName()
  local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
  local name = PlayerFrame.fcuiName
  if not name or not healthBar then
    return
  end
  name:SetJustifyH("CENTER")
  name:ClearAllPoints()
  local yPos = 7.5
  if FCUIClassicDB.classicFrames and FCUIClassicDB.bigPlayerHealthbar then
    yPos = yPos - 10
  end
  name:SetPoint("TOP", healthBar, "TOP", 1.5, yPos)
end

local function CenterXName(fontObject, healthBar, isToT)
  if not fontObject or not healthBar then
    return
  end
  fontObject:ClearAllPoints()
  if not isToT then
    fontObject:SetJustifyH("CENTER")
  end
  local xPos = isToT and 8 or 0
  local yPos = isToT and -18 or 6.3
  fontObject:SetPoint("TOP", healthBar, "TOP", xPos, yPos)
  if FCUIClassicDB.classicFrames and isToT then
    fontObject:SetJustifyH("LEFT")
  end
end

function FCUI.SetCenteredNamesCaller()
  if not FCUIClassicDB or not FCUIClassicDB.classicFrames then
    return
  end
  if PlayerFrame and PlayerFrame.fcuiName then
    CenterPlayerName()
  end
  if TargetFrame and TargetFrame.fcuiName then
    CenterXName(
      TargetFrame.fcuiName,
      TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer,
      false
    )
  end
  local tot = TargetFrameToT or (TargetFrame and TargetFrame.totFrame)
  if tot and tot.fcuiName and tot.HealthBar then
    CenterXName(tot.fcuiName, tot.HealthBar, true)
  end
  if FocusFrame and FocusFrame.fcuiName then
    CenterXName(
      FocusFrame.fcuiName,
      FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer,
      false
    )
  end
  local fot = FocusFrameToT or (FocusFrame and FocusFrame.totFrame)
  if fot and fot.fcuiName and fot.HealthBar then
    CenterXName(fot.fcuiName, fot.HealthBar, true)
  end
end

function FCUI.GetOppositeAnchor(anchor)
  local opposites = {
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOP = "BOTTOM",
    BOTTOM = "TOP",
    TOPLEFT = "BOTTOMRIGHT",
    TOPRIGHT = "BOTTOMLEFT",
    BOTTOMLEFT = "TOPRIGHT",
    BOTTOMRIGHT = "TOPLEFT",
  }
  return opposites[anchor] or "CENTER"
end

function FCUI.MoveToTFrames()
  if InCombatLockdown and InCombatLockdown() then
    C_Timer.After(1.5, FCUI.MoveToTFrames)
    return
  end
  local db = FCUIClassicDB
  local tot = TargetFrameToT or (TargetFrame and TargetFrame.totFrame)
  if tot and TargetFrame then
    tot:ClearAllPoints()
    local anchor = db.targetToTAnchor or "BOTTOMRIGHT"
    if anchor == "BOTTOMRIGHT" then
      tot:SetPoint(
        FCUI.GetOppositeAnchor(anchor),
        TargetFrame,
        anchor,
        (db.targetToTXPos or 0) - 108,
        (db.targetToTYPos or 0) + 10
      )
    else
      tot:SetPoint(FCUI.GetOppositeAnchor(anchor), TargetFrame, anchor, db.targetToTXPos or 0, db.targetToTYPos or 0)
    end
    if db.targetToTScale then
      tot:SetScale(db.targetToTScale)
    end
  end
  local fot = FocusFrameToT or (FocusFrame and FocusFrame.totFrame)
  if fot and FocusFrame then
    fot:ClearAllPoints()
    local anchor = db.focusToTAnchor or "BOTTOMRIGHT"
    if anchor == "BOTTOMRIGHT" then
      fot:SetPoint(
        FCUI.GetOppositeAnchor(anchor),
        FocusFrame,
        anchor,
        (db.focusToTXPos or 0) - 108,
        (db.focusToTYPos or 0) + 10
      )
    else
      fot:SetPoint(FCUI.GetOppositeAnchor(anchor), FocusFrame, anchor, db.focusToTXPos or 0, db.focusToTYPos or 0)
    end
    if db.focusToTScale then
      fot:SetScale(db.focusToTScale)
    end
  end
end
