local function SetXYPoint(frame, xOffset, yOffset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or xOfs, yOffset or yOfs)
end

local function SetManaTextParent(text, parent)
    if FCUIClassicDB.hideAllManabarText then
        text.fcuiOriginalParent = parent
        parent = FCUI.hiddenFrame
    end
    text:SetParent(parent)
end

local class = UnitClassBase("player")
local defaultTex = "Interface\\TargetingFrame\\UI-TargetingFrame"
local noLvlTex = "Interface\\TargetingFrame\\UI-FocusFrame-Large"
local flashTex = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local flashNoLvl = "Interface\\TargetingFrame\\UI-FocusFrame-Large-Flash"
local bigPath = "Interface\\AddOns\\ForeverClassicUI\\Media\\Units\\"
local bigTex = bigPath .. "UI-TargetingFrame-Retail.tga"
local bigNoLvlTex = bigPath .. "UI-TargetingFrame-NoLevel-Retail.tga"
local bigNoManaTex = bigPath .. "UI-TargetingFrame-Retail-NoMana.tga"
local bigNoManaNoLvlTex = bigPath .. "UI-TargetingFrame-NoLevel-Retail-NoMana.tga"
local bigStatusTex = bigPath .. "UI-Player-Status"

local function BigPlayerHealthbar()
    return FCUIClassicDB.bigPlayerHealthbar
end

local function BigPlayerHealthbarNoMana()
    return FCUIClassicDB.bigPlayerHealthbar and FCUIClassicDB.hideUnitFramePlayerMana
end

local function SetPlayerFrameTexture(texture, normal, big, bigNoMana)
    if not BigPlayerHealthbar() then
        texture:SetTexture(normal)
        return
    end
    texture:SetTexture(BigPlayerHealthbarNoMana() and (bigNoMana or big) or big)
end

local function SetStatusGlowTexture(texture, normal, big)
    if BigPlayerHealthbarNoMana() then
        texture:SetTexture(nil)
        return
    end
    SetPlayerFrameTexture(texture, normal, big)
end

local function MakeClassicFrame(frame)
    local db = FCUIClassicDB
    local hideLvl = db.hideLevelText
    local alwaysHideLvl = hideLvl and db.hideLevelTextAlways
    local hideDragon = db.hideRareDragonTexture
    if not frame.fcuiName then
        local name = frame.name or frame.Name or (frame == PlayerFrame and _G.PlayerName)
        if name and name.GetParent and name:GetParent() then
            frame.fcuiName = name:GetParent():CreateFontString(nil, name:GetDrawLayer() or "OVERLAY", "GameFontNormal")
            local font, fontHeight, fontFlags = name:GetFont()
            if font then
                frame.fcuiName:SetFont(font, fontHeight, fontFlags)
            end
            frame.fcuiName:SetText(name:GetText() or "")
            name:SetAlpha(0)
        else
            return
        end
    end

    local ClassResourceFrames = {
        ROGUE   = RogueComboPointBarFrame,
        DRUID   = DruidComboPointBarFrame,
        WARLOCK = WarlockPowerFrame,
        MAGE    = MageArcaneChargesFrame,
        PALADIN = PaladinPowerBarFrame,
    }
    local classFrame = ClassResourceFrames[class]

    if frame == TargetFrame or frame == FocusFrame then
        -- Frame
        local content = frame.TargetFrameContent
        local frameContainer = frame.TargetFrameContainer
        local contentMain = content.TargetFrameContentMain
        local contentContext = content.TargetFrameContentContextual

        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBar

        frame.ClassicFrame = CreateFrame("Frame")
        frame.ClassicFrame:SetParent(frame)
        frame.ClassicFrame:SetFrameStrata("MEDIUM")
        frame.ClassicFrame:SetFrameLevel(9996)
        frame.ClassicFrame:SetAllPoints(frame)
        frame.ClassicFrame.Texture = frame.ClassicFrame:CreateTexture(nil, "OVERLAY")
        frame.ClassicFrame.Texture:SetParent(frame.ClassicFrame)
        frame.ClassicFrame.Texture:SetSize(232, 100)
        frame.ClassicFrame.Texture:SetTexCoord(0.09375, 1, 0, 0.78125)
        frame.ClassicFrame.Texture:SetPoint("TOPLEFT", 20, -8)

        frame.fcuiName:SetParent(frame.ClassicFrame)
        frame.ClassicFrame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.ClassicFrame.Background:SetColorTexture(0,0,0,0.45)
        frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 3, 9)
        frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", contentMain.ManaBar, "BOTTOMRIGHT", -7, 0)

        local function GetFrameColor()
            local r,g,b = frameContainer.FrameTexture:GetVertexColor()
            frame.ClassicFrame.Texture:SetVertexColor(r,g,b)
            frameContainer.FrameTexture:SetAlpha(0)
        end
        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        hpContainer.LeftText:SetParent(frame.ClassicFrame)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 7, 2.8)
        hpContainer.RightText:SetParent(frame.ClassicFrame)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -108, 2.8)
        hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, 2.8)
        hpContainer.DeadText:SetParent(frame.ClassicFrame)
        hpContainer.DeadText:ClearAllPoints()
        hpContainer.DeadText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, 2.8)
        hpContainer.UnconsciousText:SetParent(frame.ClassicFrame)
        hpContainer.UnconsciousText:ClearAllPoints()
        hpContainer.UnconsciousText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, 2.8)
        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow, -7)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -7, 0)

        SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 7, -8.5)
        SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -108, -8.5)
        SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, -8.5)

        contentContext:SetParent(frame.ClassicFrame)
        contentContext.HighLevelTexture:ClearAllPoints()
        contentContext.HighLevelTexture:SetPoint("CENTER", frame, "BOTTOMRIGHT", -34, 25)
        contentContext.PetBattleIcon:ClearAllPoints()
        contentContext.PetBattleIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -35, 25)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPRIGHT", -84, -13.5)
        contentContext.GuideIcon:ClearAllPoints()
        contentContext.GuideIcon:SetPoint("TOPRIGHT", -20, -14)
        contentContext.RaidTargetIcon:ClearAllPoints()
        contentContext.RaidTargetIcon:SetPoint("CENTER", frameContainer.Portrait, "TOP", 1.5, 1)

        --AdjustFramePoint(frameContainer.Portrait, nil, -4)
        frameContainer.Portrait:SetPoint("TOPRIGHT", frameContainer, "TOPRIGHT", -26, -19)

        contentMain.LevelText:SetParent(frame.ClassicFrame)
        contentMain.LevelText:ClearAllPoints()
        contentMain.LevelText:SetPoint("CENTER", frame, "BOTTOMRIGHT", -34, 25.5)
        contentMain.ReputationColor:SetSize(119, 18)
        contentMain.ReputationColor:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        contentMain.ReputationColor:ClearAllPoints()
        contentMain.ReputationColor:SetPoint("TOPRIGHT", -87, -31)

        -- if true then
        --     contentMain.ReputationColor:SetSize(121, 18)
        --     contentMain.ReputationColor:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status")

        --     hooksecurefunc(contentMain.ReputationColor, "SetVertexColor", function(self)
        --         if self.changing then return end
        --         self.changing = true
        --         local r,g,b = self:GetVertexColor()
        --         if g == 1 then
        --             self:SetVertexColor(1,1,1)
        --             self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health")
        --         else
        --             self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status")
        --         end
        --         self.changing = false
        --     end)
        -- end

        frameContainer.Flash:SetDrawLayer("BACKGROUND")
        frameContainer.Flash:SetParent(db.hideCombatGlow and FCUI.hiddenFrame or frame)
        frameContainer.Portrait:SetSize(62,62)
        frameContainer.Portrait:ClearAllPoints()
        frameContainer.Portrait:SetPoint("TOPRIGHT", -23, -22)
        frameContainer.PortraitMask:SetSize(61,61)
        frameContainer.PortraitMask:ClearAllPoints()
        frameContainer.PortraitMask:SetPoint("CENTER", frameContainer.Portrait, "CENTER", 0, 0)
        frameContainer.BossPortraitFrameTexture:SetAlpha(0)


        -- frameContainer.PlayerPortrait:SetSize(62, 62)
        -- frameContainer.PlayerPortrait:ClearAllPoints()
        -- frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 25, -22)
        -- frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        -- frameContainer.PlayerPortraitMask:ClearAllPoints()
        -- frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)



        --------- these might need updates / different method
        local totFrame = frame.totFrame
        local totHpBar = totFrame.HealthBar
        local totManaBar = totFrame.ManaBar
        totFrame:SetFrameStrata("MEDIUM")
        totFrame:SetFrameLevel(9998)
        totHpBar:SetSize(47, 7)
        totHpBar:ClearAllPoints()
        totHpBar:SetPoint("TOPRIGHT", -29, -15)
        totHpBar:SetFrameLevel(9998)
        totManaBar:SetSize(49, 8)
        totManaBar:ClearAllPoints()
        totManaBar:SetPoint("TOPRIGHT", -29, -22)
        totManaBar:SetFrameLevel(9998)
        totFrame.Background = totFrame.HealthBar:CreateTexture(nil, "BACKGROUND")
        totFrame.Background:SetColorTexture(0,0,0,0.45)
        totFrame.Background:SetPoint("TOPLEFT", totFrame.HealthBar, "TOPLEFT", 1, -1)
        totFrame.Background:SetPoint("BOTTOMRIGHT", totFrame.manabar, "BOTTOMRIGHT", -1, 1)
        totFrame.FrameTexture:SetSize(93, 45)
        totFrame.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame")
        totFrame.FrameTexture:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
        totFrame.FrameTexture:ClearAllPoints()
        totFrame.FrameTexture:SetPoint("TOPLEFT", 0, 0)
        totFrame.FrameTexture:SetDrawLayer("OVERLAY", 7)
        totFrame.Portrait:SetSize(37, 37)
        totFrame.Portrait:ClearAllPoints()
        totFrame.Portrait:SetPoint("TOPLEFT", 4, -5)
        totFrame.HealthBar.DeadText:SetParent(totFrame)
        totFrame.HealthBar.DeadText:ClearAllPoints()
        totFrame.HealthBar.DeadText:SetPoint("LEFT", 48, 3)
        totFrame.HealthBar.DeadText:SetDrawLayer("OVERLAY", 7)
        totFrame.HealthBar.UnconsciousText:SetParent(totFrame)
        totFrame.HealthBar.UnconsciousText:ClearAllPoints()
        totFrame.HealthBar.UnconsciousText:SetPoint("LEFT", 48, 3)
        totFrame.HealthBar.UnconsciousText:SetDrawLayer("OVERLAY", 7)

        local hideToTDebuffs = (frame.unit == "target" and db.hideTargetToTDebuffs) or (frame.unit == "focus" and db.hideFocusToTDebuffs)
        if not hideToTDebuffs then
            -- totFrame.lastUpdate = 0
            -- totFrame:HookScript("OnUpdate", function(self, elapsed)
            --     self.lastUpdate = self.lastUpdate + elapsed
            --     if self.lastUpdate >= 0.2 then
            --         self.lastUpdate = 0
            --         AuraUtil.RefreshAuras(self, self.unit, nil, nil, true) -- procs secret errors now
            --     end
            -- end)
            local debuffFrameName = totFrame:GetName().."Debuff"
            for i = 1, 4 do
                local debuffFrame = _G[debuffFrameName..i]
                debuffFrame:ClearAllPoints()
                if i == 1 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -8)
                elseif i == 2 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -8)
                elseif i== 3 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -21)
                elseif  i==4  then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -21)
                end
            end
        end

        local function FrameAdjustments(frame, minus, normal)
            if minus then
                frame.FrameTexture:ClearAllPoints()
                frame.FrameTexture:SetPoint("TOPLEFT", 20, -4)
                frame.Flash:SetSize(253, 120)
                frame.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash")
                frame.Flash:SetTexCoord(0, 1, 0, 1)
                frame.Flash:ClearAllPoints()
                frame.Flash:SetPoint("TOPLEFT", -2.5, -10)
                contentMain.ReputationColor:Hide()
                contentMain.LevelText:SetAlpha(1)
            else
                frame.FrameTexture:ClearAllPoints()
                frame.FrameTexture:SetPoint("TOPLEFT", 20.5, -18)
                frame.Flash:SetSize(240.5, 93)
                frame.Flash:SetTexture(flashTex)
                frame.Flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
                frame.Flash:ClearAllPoints()
                frame.Flash:SetPoint("TOPLEFT", -2.5, -8)
                contentMain.LevelText:SetAlpha(1)
                if frame.unit == "target" then
                    contentMain.ReputationColor:SetShown(not FCUIClassicDB.hideTargetReputationColor)
                elseif frame.unit == "focus" then
                    contentMain.ReputationColor:SetShown(not FCUIClassicDB.hideFocusReputationColor)
                end
            end
        end

        local function ToggleNoLevelFrame(noLvl, skipTexture)
            if noLvl then
                if not skipTexture then
                    frame.ClassicFrame.Texture:SetTexture(noLvlTex)
                end
                frameContainer.Flash:SetTexture(flashNoLvl)
                frameContainer.Flash:SetTexCoord(0, 0.9553125, -0.01,0.733)
                contentMain.LevelText:SetAlpha(0)
            else
                if not skipTexture then
                    frame.ClassicFrame.Texture:SetTexture(defaultTex)
                end
                frameContainer.Flash:SetTexture(flashTex)
                frameContainer.Flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
                contentMain.LevelText:SetAlpha(1)
            end
        end

        hooksecurefunc(frame, "CheckClassification", function(self)
            local classification = UnitClassification(self.unit)

            -- Frame
            local content = self.TargetFrameContent
            local frameContainer = frameContainer
            local contentMain = content.TargetFrameContentMain
            -- Status
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar

            frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 3, 9)
            frameContainer.FrameTexture:SetAlpha(0)

            SetXYPoint(hpContainer.HealthBarMask, 1, -6)
            hpContainer.HealthBarMask:SetSize(125, 17)
            -- Match Forever health bar size (124–126 x 20); default mana is half-height and wider.
            local health = hpContainer.HealthBar
            local hw, hh = health:GetSize()
            manaBar:SetSize(hw -5, hh -5)
            manaBar:ClearAllPoints()
            manaBar:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 2, 5)
            manaBar.ManaBarMask:Hide()

            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", 20, -8)


            if ( classification == "rareelite" ) then
                FrameAdjustments(frameContainer)
                if hideDragon and alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideDragon then
                    frame.ClassicFrame.Texture:SetTexture(defaultTex)
                    ToggleNoLevelFrame(false, true)
                else
                    frame.ClassicFrame.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
                    ToggleNoLevelFrame(false, true)
                end
            elseif ( classification == "worldboss" or classification == "elite" ) then
                FrameAdjustments(frameContainer)
                if hideDragon and alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideDragon then
                    frame.ClassicFrame.Texture:SetTexture(defaultTex)
                    ToggleNoLevelFrame(false, true)
                else
                    frame.ClassicFrame.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
                    ToggleNoLevelFrame(false, true)
                end
            elseif ( classification == "rare" ) then
                FrameAdjustments(frameContainer)
                if hideDragon and alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideDragon then
                    frame.ClassicFrame.Texture:SetTexture(defaultTex)
                    ToggleNoLevelFrame(false, true)
                else
                    frame.ClassicFrame.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
                    ToggleNoLevelFrame(false, true)
                end
            elseif ( classification == "minus" ) then
                SetXYPoint(hpContainer.HealthBarMask, 1, -9)
                FrameAdjustments(frameContainer, true)
                frame.ClassicFrame.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus")
                frame.ClassicFrame.Background:SetPoint("TOPLEFT", self.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, "TOPLEFT", 3, -10)
            else
                FrameAdjustments(frameContainer)
                if frame.unit == "target" then
                    contentMain.ReputationColor:SetShown(not FCUIClassicDB.hideTargetReputationColor)
                elseif frame.unit == "focus" then
                    contentMain.ReputationColor:SetShown(not FCUIClassicDB.hideFocusReputationColor)
                end
                if alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideLvl then
                    if UnitLevel(frame.unit) == FCUI.GetMaxPlayerLevel() then
                        ToggleNoLevelFrame(true)
                    else
                        ToggleNoLevelFrame(false)
                    end
                else
                    ToggleNoLevelFrame(false)
                end
            end
        end)

        hooksecurefunc(frame, "CheckFaction", function(self)
            if FCUI.ApplyTargetClassicPvp then
                FCUI.ApplyTargetClassicPvp(self)
            end
            if (self.showPVP) then
                contentContext.PrestigePortrait:ClearAllPoints()
                contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
            end
        end)

        if FCUI.ApplyTargetClassicPvp then
            FCUI.ApplyTargetClassicPvp(frame)
        end

        if db.classicFramesDesaturated or db.classColorFrameTexture then
            frame.ClassicFrame.Texture:SetDesaturated(true)
            totFrame.FrameTexture:SetDesaturated(true)
        end

    elseif frame == PlayerFrame then
        -- PlayerFrame
        -- Frame
        local content = frame.PlayerFrameContent
        local frameContainer = frame.PlayerFrameContainer
        local contentMain = content.PlayerFrameContentMain
        local contentContext = content.PlayerFrameContentContextual
        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBarArea.ManaBar

        frame.ClassicFrame = CreateFrame("Frame")
        frame.ClassicFrame:SetParent(frame)
        frame.ClassicFrame:SetFrameStrata("MEDIUM")
        frame.ClassicFrame:SetFrameLevel(9996)
        frame.ClassicFrame:SetAllPoints(frame)
        frame.ClassicFrame.Texture = frame.ClassicFrame:CreateTexture(nil, "OVERLAY")
        frame.ClassicFrame.Texture:SetParent(frame.ClassicFrame)

        manaBar.FullPowerFrame:SetParent(frame.ClassicFrame)

        contentMain.HitIndicator.HitText:ClearAllPoints()
        contentMain.HitIndicator.HitText:SetPoint("CENTER", frameContainer.PlayerPortrait)
        contentMain.HitIndicator.HitText:SetScale(0.85)
        contentMain.HitIndicator:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)

        contentContext:SetParent(frame.ClassicFrame)
        contentContext.AttackIcon:ClearAllPoints()
        contentContext.AttackIcon:SetPoint("CENTER", -80, -23.5)
        contentContext.AttackIcon:SetSize(32, 31)
        contentContext.AttackIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        contentContext.AttackIcon:SetTexCoord(0.5, 1.0, 0, 0.484375)
        contentContext.AttackIcon:SetDrawLayer("OVERLAY")
        contentContext.PlayerPortraitCornerIcon:SetAtlas(nil)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPLEFT", -4, -17)
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPLEFT", 86, -14)
        contentContext.RoleIcon:ClearAllPoints()
        contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)

        --AdjustFramePoint(contentContext.GroupIndicator, nil, -3)

        frameContainer.PlayerPortrait:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frameContainer.PlayerPortraitMask:ClearAllPoints()
        frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)

        -- Resource frame positioning table
        local resourceFrameAnchorPositions = {
            default = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 25},
            [102] = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 15}, -- Balance Druid
        }

        frame.ClassicFrame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.ClassicFrame.Background:SetColorTexture(0,0,0,0.45)
        frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 11)
        frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", -3, 0)

        local function AdjustBackground()
            frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, BigPlayerHealthbar() and 0 or 11)
            frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", hpContainer, "BOTTOMRIGHT", BigPlayerHealthbar() and 0 or -2, BigPlayerHealthbarNoMana() and -1 or -11)
        end

        local function AdjustStatusBarText()
            local hpTextYOffset = 2.8
            if BigPlayerHealthbar() then
                hpTextYOffset = BigPlayerHealthbarNoMana() and 0.3 or 3.3
            end

            hpContainer.LeftText:SetParent(frame.ClassicFrame)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 108, hpTextYOffset)
            hpContainer.RightText:SetParent(frame.ClassicFrame)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -7, hpTextYOffset)
            hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, hpTextYOffset)

            SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 108, -8.5)
            SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -7, -8.5)
            SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, -8.5)
        end

        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow,-3)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -7, 0)

        if C_CVar.GetCVar("comboPointLocation") == "1" and ComboFrame then
            ComboFrame:SetParent(TargetFrame)
            ComboFrame:SetFrameStrata("HIGH")
            FCUI.UpdateLegacyComboPosition()
        end

        local function UpdateLevelDetails()
            PlayerLevelText:SetParent(frame.ClassicFrame)
            PlayerLevelText:SetDrawLayer("OVERLAY", 7)
            PlayerLevelText:Show()
            PlayerLevelText:ClearAllPoints()
            PlayerLevelText:SetPoint("CENTER", -81, -24.5)
        end

        local function UpdateLevel()
            if not db.playerEliteFrame then
                if alwaysHideLvl then
                    PlayerLevelText:SetParent(FCUI.hiddenFrame)
                    PlayerLevelText:ClearAllPoints()
                    PlayerLevelText:SetPoint("CENTER", -81, -24.5)
                elseif hideLvl then
                    if UnitLevel(frame.unit) == FCUI.GetMaxPlayerLevel() then
                        PlayerLevelText:SetParent(FCUI.hiddenFrame)
                        PlayerLevelText:ClearAllPoints()
                        PlayerLevelText:SetPoint("CENTER", -81, -24.5)
                    else
                        UpdateLevelDetails()
                    end
                else
                    UpdateLevelDetails()
                end
            else
                -- When playerEliteFrame is enabled, handle level text based on mode
                local mode = FCUIClassicDB.playerEliteFrameMode
                if mode > 3 then
                    -- Always hide level text for mode > 3 (using UI-FocusFrame-Large texture)
                    PlayerLevelText:SetParent(FCUI.hiddenFrame)
                elseif alwaysHideLvl or (hideLvl and UnitLevel(frame.unit) == FCUI.GetMaxPlayerLevel()) then
                    -- Hide level text based on hideLvl settings for mode <= 3
                    PlayerLevelText:SetParent(FCUI.hiddenFrame)
                else
                    -- Show level text for other cases
                    UpdateLevelDetails()
                end
            end
        end
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            UpdateLevel()
        end)
        UpdateLevel()

        hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)
            PlayerLevelText:SetShown(not UnitHasVehiclePlayerFrameUI("player"))
        end)

        if not db.hidePvpTimerText then
            hooksecurefunc("PlayerFrame_UpdatePvPStatus", function()
                contentContext.PvpTimerText:ClearAllPoints()
                contentContext.PvpTimerText:SetPoint("BOTTOMLEFT", 8, 8)
            end)
        end

        -- Apply Classic PvP badge immediately (circle hidden, Classic faction art).
        if PlayerFrame_UpdatePvPStatus then
            PlayerFrame_UpdatePvPStatus()
        end

        local function GetFrameColor()
            local r, g, b = frameContainer.FrameTexture:GetVertexColor()
            frame.ClassicFrame.Texture:SetVertexColor(r, g, b)

            if not db.darkModeUi then
                local soulShards = _G.WarlockPowerFrame
                if soulShards then
                    for _, v in pairs({soulShards:GetChildren()}) do
                        v.Background:SetVertexColor(
                            math.max(r - 0.35, 0),
                            math.max(g - 0.35, 0),
                            math.max(b - 0.35, 0)
                        )
                    end
                end
            end
            frameContainer.FrameTexture:SetAlpha(0)
        end

        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        local DEFAULT_X, DEFAULT_Y = 29, 28.5
        local resourceFramePositions = {
            WARRIOR = { x = 28, y = 30 },
            ROGUE   = { x = 48, y = 38, scale = 0.85 },
            MAGE    = { x = 32, y = 32, scale = 0.95 },
            PALADIN = { scale = 0.91 },
            DRUID   = { x = 31, y = 30 },
        }

        local function GetPlayerClassAndSpecPosition()
            local position = resourceFramePositions[class]

            if position then
                local x = position.x or DEFAULT_X
                local y = position.y or DEFAULT_Y
                local scale = position.scale or 1
                return x, y, scale
            end

            return DEFAULT_X, DEFAULT_Y, 1
        end

        local classConflicts = {
            ROGUE   = db.moveResourceToTargetRogue,
            DRUID   = db.moveResourceToTargetDruid,
            WARLOCK = db.moveResourceToTargetWarlock,
            MAGE    = db.moveResourceToTargetMage,
            PALADIN = db.moveResourceToTargetPaladin,
            SHAMAN  = db.moveResourceToTargetShaman,
            HUNTER  = db.moveResourceToTargetHunter,
        }

        local function UpdateResourcePosition(rogueCheck)
            if db["moveResource" .. class] or (db.moveResourceToTarget and classConflicts[class]) then
                return
            end

            if not InCombatLockdown() then
                PlayerBottomManagedFrameContainer:ClearAllPoints()

                local specID = FCUI.GetSpecialization() and FCUI.GetSpecializationInfo(FCUI.GetSpecialization())
                local posData = resourceFrameAnchorPositions[specID] or resourceFrameAnchorPositions.default
                local point = posData.point or "TOP"
                local relativeFrame = PlayerFrame
                local relativePoint = posData.relativePoint or "BOTTOM"
                local xOffset = posData.xOffset or 30
                local yOffset = posData.yOffset or 25

                local _, _, scale = GetPlayerClassAndSpecPosition()

                if rogueCheck then
                    local isRogueWith5Combos = UnitPowerMax("player", Enum.PowerType.ComboPoints) == 5
                    local isRogueWith6Combos = UnitPowerMax("player", Enum.PowerType.ComboPoints) == 6
                    if isRogueWith5Combos then
                        PlayerBottomManagedFrameContainer:SetPoint(point, relativeFrame, relativePoint, 31.5, 35)
                        PlayerBottomManagedFrameContainer:SetScale(0.95)
                    elseif isRogueWith6Combos then
                        PlayerBottomManagedFrameContainer:SetPoint(point, relativeFrame, relativePoint, 46, 37)
                        PlayerBottomManagedFrameContainer:SetScale(scale)
                    else
                        PlayerBottomManagedFrameContainer:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
                        PlayerBottomManagedFrameContainer:SetScale(scale)
                    end
                else
                    PlayerBottomManagedFrameContainer:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
                    PlayerBottomManagedFrameContainer:SetScale(scale)
                end
                PlayerBottomManagedFrameContainer:SetFrameStrata("HIGH")
            else
                PlayerBottomManagedFrameContainer.positionNeedsUpdate = true
                if not FCUI.CombatWaiter then
                    FCUI.CombatWaiter = CreateFrame("Frame")
                    FCUI.CombatWaiter:SetScript("OnEvent", function(self)
                        if PlayerBottomManagedFrameContainer.positionNeedsUpdate then
                            PlayerBottomManagedFrameContainer.positionNeedsUpdate = false
                            UpdateResourcePosition()
                        end
                        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    end)
                end
                if not FCUI.CombatWaiter:IsEventRegistered("PLAYER_REGEN_ENABLED") then
                    FCUI.CombatWaiter:RegisterEvent("PLAYER_REGEN_ENABLED")
                end
            end
        end

        local isRogue = class == "ROGUE"
        if isRogue then
            local specWatcher = CreateFrame("Frame")
            specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            specWatcher:RegisterEvent("TRAIT_CONFIG_UPDATED")
            specWatcher:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            specWatcher:SetScript("OnEvent", function(self, event, unit, powerType)
                local rogueCombos = UnitPowerMax("player", Enum.PowerType.ComboPoints)
                UpdateResourcePosition(rogueCombos)
            end)
        end

        local function PlayerEliteFrame()
            local playerElite = frame.ClassicFrame.Texture
            local mode = FCUIClassicDB.playerEliteFrameMode
            local hideLvl = FCUIClassicDB.hideLevelText
            local alwaysHideLvl = hideLvl and FCUIClassicDB.hideLevelTextAlways

            -- Set Elite style according to value
            if mode == 1 then -- Rare (Silver)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
                playerElite:SetDesaturated(true)
            elseif mode == 2 then -- Boss (Silver Winged)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
                playerElite:SetDesaturated(true)
            elseif mode == 3 then -- Boss (Gold Winged)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
                playerElite:SetDesaturated(false)
            elseif mode > 3 then -- For modes > 3, always use UI-FocusFrame-Large regardless of hideLvl
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-FocusFrame-Large")
                playerElite:SetDesaturated(false)
            else
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, defaultTex, bigTex, bigNoManaTex)
                frameContainer.FrameFlash:SetTexture(flashTex)
                frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\CharacterFrame\\UI-Player-Status", bigStatusTex)
            -- elseif mode == 4 then -- Only 3 available for classic
            --     db.playerEliteFrameMode = 3
            --     playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            --     playerElite:SetDesaturated(false)
            end
        end

        local function ToggleNoLevelFrame(noLvl)
            if noLvl then
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, noLvlTex, bigNoLvlTex, bigNoManaNoLvlTex)
                frameContainer.FrameFlash:SetTexture(flashNoLvl)
                frameContainer.FrameFlash:SetTexCoord(0.9553125,0, -0.01,0.733)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\\\AddOns\\\\ForeverClassicUI\\\\Media\\\\Units\\\\blizzTex\\classic-statustexture-nolevel", "Interface\\\\AddOns\\\\ForeverClassicUI\\\\Media\\\\Units\\\\blizzTex\\classic-statustexture-nolevel")
            else
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, defaultTex, bigTex, bigNoManaTex)
                frameContainer.FrameFlash:SetTexture(flashTex)
                frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\CharacterFrame\\UI-Player-Status", bigStatusTex)
            end
        end

        local function AdjustStatusGlow()
            contentMain.StatusTexture:SetSize(191, BigPlayerHealthbar() and 81 or 77)
        end

        local function UpdatePlayerFrameTexture()
            if db.playerEliteFrame then
                PlayerEliteFrame()
                frameContainer.FrameFlash:SetTexture(flashTex)
                frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\CharacterFrame\\UI-Player-Status", bigStatusTex)
                -- Handle level text for playerEliteFrame
                local mode = FCUIClassicDB.playerEliteFrameMode
                if mode > 3 and (alwaysHideLvl or (hideLvl and UnitLevel("player") == FCUI.GetMaxPlayerLevel())) then
                    -- Ensure level text is hidden when using UI-FocusFrame-Large
                    PlayerLevelText:SetParent(FCUI.hiddenFrame)
                end
            else
                if alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideLvl then
                    if UnitLevel("player") == FCUI.GetMaxPlayerLevel() then
                        ToggleNoLevelFrame(true)
                    else
                        ToggleNoLevelFrame(false)
                    end
                else
                    ToggleNoLevelFrame(false)
                end
            end
        end

        function FCUI.UpdateClassicPlayerArt()
            UpdatePlayerFrameTexture()
            AdjustStatusGlow()
            AdjustStatusBarText()
            AdjustBackground()
        end

        local function ToPlayerArt()
            UpdateResourcePosition(isRogue)

            --AdjustFramePoint(hpContainer.HealthBarMask, 0, -11)
            hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -2, -6)
            hpContainer.HealthBarMask:SetSize(126, 17)

            -- Match Forever health bar size (124 x 20); default mana is 124 x 10.
            local health = hpContainer.HealthBar
            local hw, hh = health:GetSize()
            manaBar:SetSize(hw -5, hh - 4)
            manaBar:ClearAllPoints()
            manaBar:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 2, 4)
            if manaBar.FullPowerFrame then
                manaBar.FullPowerFrame:SetSize(hw, hh)
            end
            if manaBar.ManaBarMask then
                manaBar.ManaBarMask:Hide()
            end

            frameContainer.FrameTexture:ClearAllPoints()
            frameContainer.FrameTexture:SetPoint("TOPLEFT", -19, 7)
            frameContainer.FrameTexture:SetAlpha(0)

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)

            contentContext.GroupIndicator:ClearAllPoints()
            contentContext.GroupIndicator:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -21, -33.5)
            PlayerFrameGroupIndicatorText:ClearAllPoints()
            PlayerFrameGroupIndicatorText:SetPoint("LEFT", contentContext.GroupIndicator.GroupIndicatorLeft, "LEFT", 20, 2.5)

            frame.ClassicFrame.Texture:SetSize(232, 100)
            UpdatePlayerFrameTexture()
            frame.ClassicFrame.Texture:SetTexCoord(1, 0.09375, 0, 0.78125)
            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", -19, -8)
            frame.ClassicFrame.Texture:SetDrawLayer("BORDER")

            frameContainer.AlternatePowerFrameTexture:ClearAllPoints()
            frameContainer.AlternatePowerFrameTexture:SetPoint("TOPLEFT", -9, -8)
            frameContainer.AlternatePowerFrameTexture:SetAlpha(0)

            frameContainer.FrameFlash:SetParent(db.hideCombatGlow and FCUI.hiddenFrame or frame)
            frameContainer.FrameFlash:SetSize(240.5, 93)
            --frameContainer.FrameFlash:SetTexture(flashTex)
            --frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -4.5, -8)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            AdjustStatusGlow()
            contentMain.StatusTexture:SetTexCoord(0, 0.74609375, 0, 0.58125)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", 17, -15)
            contentMain.StatusTexture:SetBlendMode("ADD")

            AdjustStatusBarText()

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 26, -23)
            frame.ClassicFrame.Texture:Show()

            AdjustBackground()
        end

        hooksecurefunc("PlayerFrame_ToPlayerArt", function()
            ToPlayerArt()
        end)
        ToPlayerArt()

        local function ToVehicleArt()
            frameContainer.VehicleFrameTexture:ClearAllPoints()
            frameContainer.VehicleFrameTexture:SetPoint("TOPLEFT", -3, 1)
            frameContainer.VehicleFrameTexture:SetAlpha(0)

            frame.ClassicFrame.Texture:SetSize(240, 120)
            frame.ClassicFrame.Texture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame")
            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", -3, 1)
            frame.ClassicFrame.Texture:SetTexCoord(0, 1, 0, 1)

            hpContainer.HealthBarMask:SetSize(120, 32)

            frameContainer.FrameFlash:SetParent(frame)
            frameContainer.FrameFlash:SetSize(240.5, 93)
            frameContainer.FrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            frameContainer.FrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -4.5, -4)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 186, -29)

            contentMain.StatusTexture:SetSize(242, 93)
            contentMain.StatusTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            contentMain.StatusTexture:SetTexCoord(-0.02, 1, 0.07, 0.86)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", -6, -4)
            contentMain.StatusTexture:SetDrawLayer("BACKGROUND")

            hpContainer.LeftText:SetParent(frame.ClassicFrame)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 101, 3)
            hpContainer.RightText:SetParent(frame.ClassicFrame)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -38, 3)
            hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 34, 3)

            SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 101, -9)
            SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -7, -9)
            SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, -9)

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -17)

            frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", contentMain.HealthBarsContainer, "BOTTOMRIGHT", -7, -12)
        end

        hooksecurefunc("PlayerFrame_ToVehicleArt", function(self)
            ToVehicleArt()
        end)

        hooksecurefunc(TotemFrame, "Update", function(self)
            for child in self.totemPool:EnumerateActive() do
                child.Border:SetSize(39, 39)
                child.Border:SetTexture("Interface\\CharacterFrame\\TotemBorder")
                child.Border:ClearAllPoints()
                child.Border:SetPoint("CENTER")
            end
        end)

        TotemFrame:SetScale(0.85)
        hooksecurefunc(TotemFrame, "SetPoint", function(self)
            if self.changing then return end
            if classFrame and classFrame:IsShown() then return end
            self.changing = true
            local a, b, c, d, e = self:GetPoint()
            self:ClearAllPoints()
            self:SetPoint(a, b, c, d, e - 5)
            self.changing = false
        end)

        if db.classicFramesDesaturated or db.classColorFrameTexture then
            frame.ClassicFrame.Texture:SetDesaturated(true)
        end

    elseif frame == PetFrame then
        PetFrame:SetSize(128, 53)
        PetPortrait:ClearAllPoints()
        PetPortrait:SetPoint("TOPLEFT", 7, -6)

        PetFrameTexture:SetSize(128, 64)
        PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame")
        PetFrameTexture:ClearAllPoints()
        PetFrameTexture:SetPoint("TOPLEFT", 1, -1)

        PetFrameFlash:SetSize(128, 67)
        PetFrameFlash:SetTexture("Interface\\TargetingFrame\\UI-PartyFrame-Flash")
        PetFrameFlash:SetPoint("TOPLEFT", -3, 12)
        PetFrameFlash:SetTexCoord(0, 1, 1, 0)
        PetFrameFlash:SetDrawLayer("BACKGROUND")

        PetFrameHealthBar:SetSize(69, 8)
        --PetFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        PetFrameHealthBar:ClearAllPoints()
        PetFrameHealthBar:SetPoint("TOPLEFT", 47, -22)
        PetFrameHealthBar:SetFrameLevel(1)
        PetFrameHealthBarMask:Hide()

        PetFrameManaBar:SetSize(71, 8)
        PetFrameManaBar:ClearAllPoints()
        PetFrameManaBar:SetPoint("TOPLEFT", 45, -29)
        PetFrameManaBar:SetFrameLevel(1)
        PetFrameManaBarMask:Hide()

        PetFrameHealthBarText:SetParent(PetFrame)
        PetFrameHealthBarTextLeft:SetParent(PetFrame)
        PetFrameHealthBarTextRight:SetParent(PetFrame)
        SetManaTextParent(PetFrameManaBarText, PetFrame)
        SetManaTextParent(PetFrameManaBarTextLeft, PetFrame)
        SetManaTextParent(PetFrameManaBarTextRight, PetFrame)

        PetFrameHealthBarText:ClearAllPoints()
        PetFrameHealthBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -26)
        PetFrameHealthBarTextLeft:ClearAllPoints()
        PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -26)
        PetFrameHealthBarTextRight:ClearAllPoints()
        PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -26)
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -35)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -35)

        PetFrameOverAbsorbGlow:SetParent(PetFrame)
        PetFrameOverAbsorbGlow:SetDrawLayer("ARTWORK", 7)

        PetAttackModeTexture:SetSize(76, 64)
        PetAttackModeTexture:SetTexture("Interface\\TargetingFrame\\UI-Player-AttackStatus")
        PetAttackModeTexture:SetTexCoord(0.703125, 1, 0, 1)
        PetAttackModeTexture:ClearAllPoints()
        PetAttackModeTexture:SetPoint("TOPLEFT", 6, -9)

        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint("CENTER", PetFrame, "TOPLEFT", 28, -27)

        if db.classicFramesDesaturated then
            PetFrameTexture:SetDesaturated(true)
        end
    end
end

local fancyManas = {
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    ["FURY"] = true,
    ["LUNAR_POWER"] = true,
    ["SOUL_FRAGMENTS"] = true,                 -- alt mana, powerName (as opposed to powerType)
}

local function AdjustAlternateBars()
    local altBarWidth = 105
    AlternatePowerBar:SetSize(altBarWidth, 12)
    AlternatePowerBar:ClearAllPoints()
    AlternatePowerBar:SetPoint("BOTTOMLEFT", 95, 16)

    AlternatePowerBarText:SetPoint("CENTER", 2, -1)
    AlternatePowerBar.LeftText:SetPoint("LEFT", 0, -1)
    AlternatePowerBar.RightText:SetPoint("RIGHT", 0, -1)

    AlternatePowerBar.Background = AlternatePowerBar:CreateTexture(nil, "BACKGROUND")
    AlternatePowerBar.Background:SetAllPoints()
    AlternatePowerBar.Background:SetColorTexture(0, 0, 0, 0.5)

    AlternatePowerBar.Border = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.Border:SetSize(0, 16)
    AlternatePowerBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
    AlternatePowerBar.Border:SetPoint("TOPLEFT", 4, 0)
    AlternatePowerBar.Border:SetPoint("TOPRIGHT", -4, 0)

    AlternatePowerBar.LeftBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.LeftBorder:SetSize(16, 16)
    AlternatePowerBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
    AlternatePowerBar.LeftBorder:SetPoint("RIGHT", AlternatePowerBar.Border, "LEFT")

    AlternatePowerBar.RightBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.RightBorder:SetSize(16, 16)
    AlternatePowerBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
    AlternatePowerBar.RightBorder:SetPoint("LEFT", AlternatePowerBar.Border, "RIGHT")

    if FCUIClassicDB.changeUnitFrameManabarTexture then
        FCUI.ApplyTextureChange("mana", AlternatePowerBar, nil, true, false, true)
        if AlternatePowerBar.PowerBarMask then
            AlternatePowerBar.PowerBarMask:Hide()
        end
    else
        --AdjustFramePoint(AlternatePowerBar.PowerBarMask, nil, -1)
        AlternatePowerBar.PowerBarMask:SetPoint("TOPLEFT", AlternatePowerBar, "TOPLEFT", -2, 3)
    end

    local classicFrameColorTargets = {
        AlternatePowerBar.Border,
        AlternatePowerBar.LeftBorder,
        AlternatePowerBar.RightBorder,
    }

    local function GetFrameColor()
        local r, g, b = PlayerFrame.PlayerFrameContainer.FrameTexture:GetVertexColor()
        for _, frame in pairs(classicFrameColorTargets) do
            if frame then
                frame:SetVertexColor(r, g, b)
            end
        end
    end
    GetFrameColor()
    hooksecurefunc(PlayerFrame.PlayerFrameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

    if FCUIClassicDB.hideUnitFramePlayerSecondResource then
        if AlternatePowerBar then
            AlternatePowerBar:SetAlpha(0)
        end
        FCUI.changedSecondResourceAlpha = true
    end
end

local function MakeClassicPartyFrame()
    if not PartyFrame or not PartyFrame.PartyMemberFramePool then
        return
    end
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        if frame.fcuiClassicParty or not frame.fcuiName then
        else
        frame.fcuiClassicParty = true
        local overlay = frame.PartyMemberOverlay
        local hpContainer = frame.HealthBarContainer
        local manaBar = frame.ManaBar

        frame.Texture:SetSize(136, 59)
        frame.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
        frame.Texture:SetTexCoord(1, 0.09375, 0, 0.78125)
        frame.Texture:ClearAllPoints()
        frame.Texture:SetPoint("TOPLEFT", -18, 2)
        frame.Texture:SetDrawLayer("ARTWORK", 7)
        frame.Texture:SetParent(hpContainer)

        frame.Flash:SetSize(143, 56)
        frame.Flash:SetTexture(flashTex)
        frame.Flash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
        frame.Flash:ClearAllPoints()
        frame.Flash:SetPoint("TOPLEFT", -10.5, 2.5)

        overlay.Status:SetSize(143, 56)
        overlay.Status:SetTexture(flashTex)
        overlay.Status:SetTexCoord(0.9453125, 0, 0, 0.181640625)
        overlay.Status:ClearAllPoints()
        overlay.Status:SetPoint("TOPLEFT", -10.5, 2.5)


        overlay.LeaderIcon:ClearAllPoints()
        overlay.LeaderIcon:SetSize(16, 16)
        if overlay.LeaderIcon.SetAtlas then
            overlay.LeaderIcon:SetAtlas(nil)
        end
        overlay.LeaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        overlay.LeaderIcon:SetTexCoord(0, 1, 0, 1)
        -- Forever default BOTTOM/TOP -10,-6; nudge left 5 and down 5.
        overlay.LeaderIcon:SetPoint("BOTTOM", overlay, "TOP", -15, -11)
        if overlay.GuideIcon then
            overlay.GuideIcon:ClearAllPoints()
            overlay.GuideIcon:SetSize(16, 16)
            overlay.GuideIcon:SetPoint("BOTTOM", overlay, "TOP", -15, -11)
        end
        overlay.RoleIcon:ClearAllPoints()
        overlay.RoleIcon:SetPoint("BOTTOMLEFT", 8, 10)
        overlay.PVPIcon:SetParent(FCUI.hiddenFrame)

        --AdjustFramePoint(hpContainer.HealthBarMask, nil, -3)
        hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -29, 0)

        -- Forever party mana is 7px; match health height so it fills the classic slot.
        local health = hpContainer.HealthBar
        local hw, hh = health:GetSize()
        if hw and hh and hw > 0 and hh > 0 then
            manaBar:SetSize(hw, hh)
        else
            manaBar:SetHeight(5)
        end
        manaBar:ClearAllPoints()
        manaBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 45, -25)
        if manaBar.ManaBarMask then
            manaBar.ManaBarMask:Hide()
        end

        frame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.Background:SetColorTexture(0,0,0,0.45)
        frame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 7)
        frame.Background:SetPoint("BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", 1, 3)

        frame.fcuiName:ClearAllPoints()
        frame.fcuiName:SetPoint("BOTTOM", hpContainer, "TOP", 0, -3)
        frame.fcuiName:SetWidth(69)
        frame.fcuiName:SetScale(0.85)
        frame.fcuiName:SetJustifyH("CENTER")

        hpContainer.LeftText:SetScale(0.72)
        hpContainer.RightText:SetScale(0.72)
        hpContainer.CenterText:SetScale(0.72)
        manaBar.TextString:SetScale(0.72)
        manaBar.LeftText:SetScale(0.72)
        manaBar.RightText:SetScale(0.72)

        hpContainer.CenterText:ClearAllPoints()
        hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2, -2)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 0, -2)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", 0, -2)
        manaBar.TextString:ClearAllPoints()
        manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6, 1)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", 0, 1)

        hooksecurefunc(frame, "ToPlayerArt", function(self)
            self.Texture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")

            --AdjustFramePoint(frame.HealthBarContainer.HealthBarMask, nil, -3)
            hpContainer.HealthBarMask:SetPoint("TOPLEFT", frame.HealthBarContainer.HealthBar, "TOPLEFT", -29, 0)

            local health = hpContainer.HealthBar
            local hw, hh = health:GetSize()
            if hw and hh and hw > 0 and hh > 0 then
                manaBar:SetSize(hw, hh)
            else
                manaBar:SetHeight(5)
            end
            manaBar:ClearAllPoints()
            manaBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 45, -25)
            if manaBar.ManaBarMask then
                manaBar.ManaBarMask:Hide()
            end

            hpContainer.CenterText:ClearAllPoints()
            hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2, -2)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 0, -2)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", 0, -2)
            manaBar.TextString:ClearAllPoints()
            manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6, 1)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", 0, 1)

            frame.Flash:SetSize(143, 56)
            frame.Flash:SetTexture(flashTex)
            frame.Flash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frame.Flash:ClearAllPoints()
            frame.Flash:SetPoint("TOPLEFT", -10.5, 2.5)

            overlay.Status:SetSize(143, 56)
            overlay.Status:SetTexture(flashTex)
            overlay.Status:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            overlay.Status:ClearAllPoints()
            overlay.Status:SetPoint("TOPLEFT", -10.5, 2.5)
        end)
        end
    end
end
FCUI.MakeClassicPartyFrame = MakeClassicPartyFrame

local function SortLocalizationChanges()
    hooksecurefunc("LocalizeFrames", function()
        for _, f in ipairs({TargetFrame, FocusFrame}) do
            local contentMain = f.TargetFrameContent.TargetFrameContentMain
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar
            local tex = f.ClassicFrame.Texture

            contentMain.LevelText:ClearAllPoints()
            contentMain.LevelText:SetPoint("CENTER", f, "BOTTOMRIGHT", -34, 25.5)

            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", tex, "LEFT", 66, 2.8)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", tex, "LEFT", 7, 2.8)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", tex, "RIGHT", -108, 2.8)
            hpContainer.DeadText:ClearAllPoints()
            hpContainer.DeadText:SetPoint("CENTER", tex, "LEFT", 66, 2.8)
            hpContainer.UnconsciousText:ClearAllPoints()
            hpContainer.UnconsciousText:SetPoint("CENTER", tex, "LEFT", 66, 2.8)

            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", tex, "LEFT", 66, -8.5)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", tex, "LEFT", 7, -8.5)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", tex, "RIGHT", -108, -8.5)
        end

        PetFrameHealthBarText:ClearAllPoints()
        PetFrameHealthBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -26)
        PetFrameHealthBarTextLeft:ClearAllPoints()
        PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -26)
        PetFrameHealthBarTextRight:ClearAllPoints()
        PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -26)
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -35)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -35)
    end)
end

function FCUI.ClassicFrames()
    if not FCUIClassicDB.classicFrames then
        FCUI.SetLevelRingsHidden(false)
        return
    end
    FCUI.SetLevelRingsHidden(true)
    MakeClassicFrame(TargetFrame)
    MakeClassicFrame(FocusFrame)
    MakeClassicFrame(PlayerFrame)
    MakeClassicFrame(PetFrame)

    MakeClassicPartyFrame()

    AdjustAlternateBars()
    SortLocalizationChanges()
    C_Timer.After(1, function()
        if C_AddOns.IsAddOnLoaded("ClassicFrames") then
            C_AddOns.DisableAddOn("ClassicFrames")
        end
    end)
end