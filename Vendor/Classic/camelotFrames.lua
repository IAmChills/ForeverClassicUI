local boundRings = {}
local ringRefreshers = {}
local ringsForcedHidden = false

local function BindLevelRing(levelText, ring)
    if not levelText or not ring then return end
    if boundRings[ring] then return end
    boundRings[ring] = true

    local originalParent = levelText:GetParent()
    local anchoredToRing = true

    local function Refresh()
        if ring.fcuiRefreshing then return end
        ring.fcuiRefreshing = true
        local ownedByBlizzard = anchoredToRing and levelText:GetParent() == originalParent
        if ringsForcedHidden or not ownedByBlizzard then
            ring:Hide()
        else
            ring:Show()
            ring:SetAlpha(levelText:GetAlpha())
        end
        ring.fcuiRefreshing = false
    end

    tinsert(ringRefreshers, Refresh)

    hooksecurefunc(levelText, "SetPoint", function(_, _, relativeTo)
        anchoredToRing = (relativeTo == ring)
        Refresh()
    end)

    hooksecurefunc(levelText, "SetParent", Refresh)
    hooksecurefunc(levelText, "SetAlpha", Refresh)
    hooksecurefunc(ring, "Show", function()
        if ringsForcedHidden and not ring.fcuiRefreshing then
            Refresh()
        end
    end)

    Refresh()
end

function FCUI.SetLevelRingsHidden(hidden)
    ringsForcedHidden = hidden and true or false
    FCUI.BindLevelRings()
    for _, Refresh in ipairs(ringRefreshers) do
        Refresh()
    end
end

function FCUI.BindLevelRings()
    if FCUI.levelRingsBound then return end
    FCUI.levelRingsBound = true

    local playerMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    BindLevelRing(PlayerLevelText, playerMain.LevelBackgroundCircle)

    local function BindTargetStyle(frame)
        if not frame or not frame.TargetFrameContent then return end
        local main = frame.TargetFrameContent.TargetFrameContentMain
        BindLevelRing(main.LevelText, main.LevelBackgroundCircle)
    end

    BindTargetStyle(TargetFrame)
    BindTargetStyle(FocusFrame)
    for i = 1, MAX_BOSS_FRAMES or 5 do
        BindTargetStyle(_G["Boss" .. i .. "TargetFrame"])
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    FCUI.BindLevelRings()
    FCUI.ApplyPlayerLevelColor()
end)

local pvpBadgeCircles = {}

local function CollectPvpCircle(container)
    if container and container.PvpBackgroundCircle then
        tinsert(pvpBadgeCircles, container.PvpBackgroundCircle)
    end
end

local function ClassicPvpTexture(factionGroup, isFFA)
    if isFFA or factionGroup == "FFA" or factionGroup == "Neutral" or factionGroup == "neutral" then
        return "Interface\\TargetingFrame\\UI-PVP-FFA"
    end
    if factionGroup == "Horde" then
        return "Interface\\TargetingFrame\\UI-PVP-Horde"
    end
    if factionGroup == "Alliance" then
        return "Interface\\TargetingFrame\\UI-PVP-Alliance"
    end
end

-- Forever draws a small HUD circle + inset icon. Classic is a single 64x64 faction badge.
function FCUI.SkinClassicPvpBadge(circle, icon, factionGroup, isFFA, anchor, point, x, y)
    if circle then
        circle:Hide()
        if not circle.fcuiClassicPvpHooked then
            circle.fcuiClassicPvpHooked = true
            circle:HookScript("OnShow", function(self)
                if FCUIClassicDB and FCUIClassicDB.classicFrames then
                    self:Hide()
                end
            end)
        end
    end
    if not icon then
        return
    end
    local tex = ClassicPvpTexture(factionGroup, isFFA)
    if not tex then
        return
    end
    if icon.SetAtlas then
        pcall(icon.SetAtlas, icon, nil)
    end
    -- Sit on ClassicFrame so the badge draws above the portrait/chrome, not behind it.
    local layerParent = (anchor and anchor.ClassicFrame) or anchor
    if layerParent then
        icon:SetParent(layerParent)
    end
    icon:SetTexture(tex)
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetSize(64, 64)
    icon:SetScale(1)
    icon:ClearAllPoints()
    icon:SetPoint(point, anchor, point, x, y)
    icon:SetDrawLayer("OVERLAY", 7)
    icon:Show()
end

-- Legacy helper: only the Forever circle is suppressed; the icon is Classic-skinned.
function FCUI.SetPvpBadgeShown(shown)
    if #pvpBadgeCircles == 0 then
        CollectPvpCircle(PlayerFrame and PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
        CollectPvpCircle(TargetFrame and TargetFrame.TargetFrameContent and TargetFrame.TargetFrameContent.TargetFrameContentContextual)
        if FocusFrame and FocusFrame.TargetFrameContent then
            CollectPvpCircle(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
        end
    end
    for _, circle in ipairs(pvpBadgeCircles) do
        if shown then
            -- Forever may re-show; OnShow hook keeps it hidden while classicFrames is on.
            circle:Hide()
        else
            circle:Hide()
        end
    end
end

local function ApplyTargetClassicPvp(frame)
    if not FCUIClassicDB or not FCUIClassicDB.classicFrames or not frame or not frame.unit then
        return
    end
    local contextual = frame.TargetFrameContent and frame.TargetFrameContent.TargetFrameContentContextual
    if not contextual then
        return
    end
    local circle = contextual.PvpBackgroundCircle
    local icon = contextual.PvpBackgroundIcon
    if not icon then
        return
    end

    if not UnitExists(frame.unit) or not frame.showPVP then
        if circle then
            circle:Hide()
        end
        icon:Hide()
        return
    end

    local factionGroup = UnitFactionGroup(frame.unit)
    local isFFA = UnitIsPVPFreeForAll(frame.unit)
    if isFFA then
        FCUI.SkinClassicPvpBadge(circle, icon, "FFA", true, frame, "TOPRIGHT", 3, -20)
    elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(frame.unit) then
        FCUI.SkinClassicPvpBadge(circle, icon, factionGroup, false, frame, "TOPRIGHT", 20, -28)
    else
        if circle then
            circle:Hide()
        end
        icon:Hide()
    end
end

local function HookClassicPvpBadges()
    if FCUI._classicPvpBadgesHooked then
        return
    end
    FCUI._classicPvpBadgesHooked = true

    if type(PlayerFrame_ShowPvPIcon) == "function" then
        hooksecurefunc("PlayerFrame_ShowPvPIcon", function(factionGroup, ffaState)
            if not FCUIClassicDB or not FCUIClassicDB.classicFrames then
                return
            end
            local main = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
            FCUI.SkinClassicPvpBadge(
                main.PvpBackgroundCircle,
                main.PvpBackgroundIcon,
                factionGroup,
                ffaState == "FFA",
                PlayerFrame,
                "TOPLEFT",
                -2,
                -30
            )
        end)
    end

    if TargetFrameMixin then
        if TargetFrameMixin.ShowPvPIcon then
            hooksecurefunc(TargetFrameMixin, "ShowPvPIcon", function(self, parentFrame, factionGroup)
                if not FCUIClassicDB or not FCUIClassicDB.classicFrames or not self then
                    return
                end
                ApplyTargetClassicPvp(self)
            end)
        end
        if TargetFrameMixin.CheckFaction then
            hooksecurefunc(TargetFrameMixin, "CheckFaction", function(self)
                ApplyTargetClassicPvp(self)
            end)
        end
        if TargetFrameMixin.HidePvPFrames then
            hooksecurefunc(TargetFrameMixin, "HidePvPFrames", function(self, parentFrame)
                if not FCUIClassicDB or not FCUIClassicDB.classicFrames or not parentFrame then
                    return
                end
                if parentFrame.PvpBackgroundCircle then
                    parentFrame.PvpBackgroundCircle:Hide()
                end
                if parentFrame.PvpBackgroundIcon then
                    parentFrame.PvpBackgroundIcon:Hide()
                end
            end)
        end
    end

    FCUI.ApplyTargetClassicPvp = ApplyTargetClassicPvp
end

local pvpLoader = CreateFrame("Frame")
pvpLoader:RegisterEvent("PLAYER_LOGIN")
pvpLoader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    HookClassicPvpBadges()
    if FCUIClassicDB and FCUIClassicDB.classicFrames then
        if PlayerFrame_UpdatePvPStatus then
            PlayerFrame_UpdatePvPStatus()
        end
        if TargetFrame and TargetFrame.CheckFaction then
            TargetFrame:CheckFaction()
        end
        if FocusFrame and FocusFrame.CheckFaction then
            FocusFrame:CheckFaction()
        end
    end
end)
local specInfo = C_SpecializationInfo

function FCUI.GetSpecialization()
    if GetSpecialization then return GetSpecialization() end
    if specInfo and specInfo.GetSpecialization then return specInfo.GetSpecialization() end
    return nil
end

function FCUI.GetSpecializationInfo(specIndex)
    if not specIndex then return nil end
    if GetSpecializationInfo then return GetSpecializationInfo(specIndex) end
    if specInfo and specInfo.GetSpecializationInfo then return specInfo.GetSpecializationInfo(specIndex) end
    return nil
end

local PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B = 1.0, 0.82, 0.0

local function FCUIOwnsLevelColor()
    local db = FCUIClassicDB
    if not db then return false end
    if db.unitFrameFontColor and db.unitFrameFontColorLvl then return true end
    if db.classColorTargetNames and db.classColorLevelText then return true end
    return false
end

function FCUI.ApplyPlayerLevelColor()
    if not UnitExists("player") then return end
    if FCUIOwnsLevelColor() then return end
    local unit = PlayerFrame.unit
    if UnitLevel(unit) ~= UnitEffectiveLevel(unit) then return end
    PlayerLevelText:SetVertexColor(PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B, 1.0)
end

hooksecurefunc("PlayerFrame_UpdateLevel", FCUI.ApplyPlayerLevelColor)
