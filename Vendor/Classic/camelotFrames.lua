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

local pvpBadgeRegions = {}
local pvpBadgeParents = {}

local function CollectPvpBadge(container)
    if not container then return end
    if container.PvpBackgroundCircle then
        tinsert(pvpBadgeRegions, container.PvpBackgroundCircle)
    end
    if container.PvpBackgroundIcon then
        tinsert(pvpBadgeRegions, container.PvpBackgroundIcon)
    end
end

function FCUI.SetPvpBadgeShown(shown)
    if #pvpBadgeRegions == 0 then
        CollectPvpBadge(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
        CollectPvpBadge(TargetFrame.TargetFrameContent.TargetFrameContentContextual)
        if FocusFrame then
            CollectPvpBadge(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
        end
        for _, region in ipairs(pvpBadgeRegions) do
            pvpBadgeParents[region] = region:GetParent()
        end
    end

    for _, region in ipairs(pvpBadgeRegions) do
        if shown then
            region:SetParent(pvpBadgeParents[region])
        else
            region:SetParent(FCUI.hiddenFrame)
        end
    end
end

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
