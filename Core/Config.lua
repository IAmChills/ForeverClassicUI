local _, ns = ...

ns.Defaults = {
  enabled = true,
  playerFrame = true,
  targetFrame = true,
  petFrame = true,
  partyFrames = true,
  castBars = true,
  minimap = true,
  classicTextures = true,
  classicComboPoints = true,
  hideLevelAlert = true,
}

ns.OptionMeta = {
  {
    key = "enabled",
    label = "Enable Forever Classic UI",
    help = "Master toggle. Disable to restore Forever's default UI on every Classic skin.",
  },
  {
    key = "playerFrame",
    label = "Classic Frames",
    help = "Classic player, target, focus, ToT, pet, and party frames with classic health/mana textures and combo points. Uncheck requires /reload.",
    editMode = true,
  },
  {
    key = "targetFrame",
    label = "Target and Focus",
    help = "Enables the full Classic Frames suite. Uncheck requires /reload.",
    editMode = true,
  },
  {
    key = "petFrame",
    label = "Pet Frame",
    help = "Enables the full Classic Frames suite. Uncheck requires /reload.",
    editMode = true,
  },
  {
    key = "partyFrames",
    label = "Party Frames",
    help = "Enables the full Classic Frames suite. Uncheck requires /reload.",
    editMode = true,
  },
  {
    key = "castBars",
    label = "Classic Cast Bars",
    help = "Classic cast bar art for player, target, and focus. Uncheck requires /reload.",
    editMode = true,
  },
  {
    key = "minimap",
    label = "Minimap",
    help = "Classic minimap border and zoom buttons. Uncheck restores Forever's look.",
    editMode = true,
  },
  {
    key = "hideLevelAlert",
    label = "Disable Level Alert",
    help = "Hide the center banner when you level up. Raid warnings and other alerts still show.",
    editMode = true,
    live = true,
  },
}

function ns.GetEditModeOptions()
  local options = {}
  for i = 1, #ns.OptionMeta do
    local option = ns.OptionMeta[i]
    if option.editMode then
      options[#options + 1] = option
    end
  end
  return options
end
