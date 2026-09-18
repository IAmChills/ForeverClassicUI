local ADDON_NAME, ns = ...

FCUI = FCUI or {}
FCUIClassicDB = FCUIClassicDB or {}

ns.FCUI = FCUI
FCUI.hiddenFrame = FCUI.hiddenFrame or CreateFrame("Frame")
FCUI.hiddenFrame:Hide()

function FCUI.Print(...)
  if ns.Print then
    ns.Print(...)
  end
end

function FCUI.GetMaxPlayerLevel()
  if GetMaxLevelForPlayerExpansion then
    return GetMaxLevelForPlayerExpansion()
  end
  return MAX_PLAYER_LEVEL or UnitLevel("player") or 60
end

function FCUI.GetSpecialization()
  if GetSpecialization then
    return GetSpecialization()
  end
end

function FCUI.GetSpecializationInfo(index)
  if GetSpecializationInfo then
    return GetSpecializationInfo(index)
  end
end

local function EnsureDBDefaults()
  local db = FCUIClassicDB
  local defaults = {
    classicFrames = false,
    classicCastbars = false,
    classicCastbarsPlayer = false,
    classicCastbarsPlayerBorder = true,
    classicCastbarsModernSpark = false,
    changeUnitFrameHealthbarTexture = false,
    changeUnitFrameManabarTexture = false,
    changeUnitFrameManaBarTextureKeepFancy = false,
    changeUnitFrameHealthbarTextureRepColor = false,
    enableLegacyComboPoints = false,
    classicFramesDesaturated = false,
    classColorFrameTexture = false,
    darkModeUi = false,
    hideLevelText = false,
    hideLevelTextAlways = false,
    hideRareDragonTexture = false,
    hideCombatGlow = false,
    hidePvpTimerText = true,
    playerEliteFrame = false,
    playerEliteFrameMode = 1,
    bigPlayerHealthbar = false,
    hideUnitFramePlayerMana = false,
    hideUnitFramePlayerSecondResource = false,
    hideAllManabarText = false,
    hideTargetReputationColor = false,
    hideFocusReputationColor = false,
    hideTargetToTDebuffs = false,
    hideFocusToTDebuffs = false,
    moveResourceToTarget = false,
    moveResourceToTargetRogue = false,
    moveResourceToTargetDruid = false,
    moveResourceToTargetWarlock = false,
    moveResourceToTargetMage = false,
    moveResourceToTargetMonk = false,
    moveResourceToTargetEvoker = false,
    moveResourceToTargetPaladin = false,
    moveResourceToTargetDK = false,
    moveResourceToTargetShaman = false,
    moveResourceToTargetHunter = false,
    playerCastBarWidth = 205,
    playerCastBarHeight = 12.5,
    targetCastBarWidth = 143,
    targetCastBarHeight = 10,
    focusCastBarWidth = 143,
    focusCastBarHeight = 10,
    partyCastBarWidth = 100,
    partyCastBarHeight = 10,
    playerCastbarIconXPos = 0,
    playerCastbarIconYPos = 0,
    targetCastbarIconXPos = 0,
    targetCastbarIconYPos = 0,
    focusCastbarIconXPos = 0,
    focusCastbarIconYPos = 0,
    partyCastbarIconXPos = 0,
    partyCastbarIconYPos = 0,
    legacyComboXPos = -44,
    legacyComboYPos = -8,
    legacyComboScale = 0.85,
    classColorFrames = false,
    targetToTAnchor = "BOTTOMRIGHT",
    focusToTAnchor = "BOTTOMRIGHT",
    targetToTXPos = 0,
    targetToTYPos = 0,
    focusToTXPos = 0,
    focusToTYPos = 0,
    targetToTScale = 1,
    focusToTScale = 1,
  }
  for k, v in pairs(defaults) do
    if db[k] == nil then
      db[k] = v
    end
  end
end

EnsureDBDefaults()

function ns.SyncClassicDBFromProfile()
  EnsureDBDefaults()
  local profile = ns.db or {}
  local enabled = profile.enabled and true or false
  local framesOn = enabled and (profile.playerFrame or profile.targetFrame or profile.petFrame or profile.partyFrames)
  local castOn = enabled and profile.castBars
  local texturesOn = framesOn and profile.classicTextures ~= false
  local comboOn = framesOn and profile.classicComboPoints ~= false

  FCUIClassicDB.classicFrames = framesOn and true or false
  FCUIClassicDB.classicCastbars = castOn and true or false
  FCUIClassicDB.classicCastbarsPlayer = castOn and true or false
  FCUIClassicDB.classicCastbarsPlayerBorder = true
  FCUIClassicDB.changeUnitFrameHealthbarTexture = texturesOn and true or false
  FCUIClassicDB.changeUnitFrameManabarTexture = texturesOn and true or false
  FCUIClassicDB.enableLegacyComboPoints = comboOn and true or false

  if framesOn then
    FCUIClassicDB.targetToTAnchor = "BOTTOMRIGHT"
    FCUIClassicDB.focusToTAnchor = "BOTTOMRIGHT"
    FCUIClassicDB.targetToTXPos = -1
    FCUIClassicDB.targetToTYPos = 17
    FCUIClassicDB.focusToTXPos = -1
    FCUIClassicDB.focusToTYPos = 17
    FCUIClassicDB.targetToTScale = 0.97
    FCUIClassicDB.focusToTScale = 0.97
  end
end

function FCUI.UpdateLegacyComboPosition() end
function FCUI.ApplyTextureChange() end
function FCUI.SetLevelRingsHidden() end
