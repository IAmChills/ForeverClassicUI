local _, ns = ...

ns.Defaults = {
  enabled = true,
  playerFrame = false,
  targetFrame = false,
  petFrame = false,
  partyFrames = false,
  castBars = false,
  minimap = false,
  hideLevelAlert = false,
  debug = false,
}

ns.OptionMeta = {
  {
    key = "enabled",
    label = "Enable Forever Classic UI",
    help = "Master toggle. Disable to leave Forever's default UI untouched.",
  },
  {
    key = "playerFrame",
    label = "Player Frame",
    help = "Restyle the player unit frame to Classic art and layout.",
    editMode = true,
  },
  {
    key = "targetFrame",
    label = "Target and Focus",
    help = "Restyle target and focus frames, including target-of-target.",
    editMode = true,
  },
  {
    key = "petFrame",
    label = "Pet Frame",
    help = "Restyle the pet unit frame.",
    editMode = true,
  },
  {
    key = "partyFrames",
    label = "Party Frames",
    help = "Restyle party member frames.",
    editMode = true,
  },
  {
    key = "castBars",
    label = "Cast Bar",
    help = "Restyle player, target, and focus cast bars.",
    editMode = true,
  },
  {
    key = "minimap",
    label = "Minimap",
    help = "Apply Classic minimap border and chrome.",
    editMode = true,
  },
  {
    key = "hideLevelAlert",
    label = "Level Alert",
    help = "Hide the center banner when you level up. Raid warnings and other alerts still show.",
    editMode = true,
    live = true,
  },
  {
    key = "debug",
    label = "Debug chat",
    help = "Print extra diagnostics while skins apply.",
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
