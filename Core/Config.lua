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
    help = "Master toggle. Disable to restore Forever's default UI on every Classic skin.",
  },
  {
    key = "playerFrame",
    label = "Player Frame",
    help = "Restyle the player unit frame to Classic art and layout. Uncheck restores Forever's look. Changes wait if you are in combat.",
    editMode = true,
  },
  {
    key = "targetFrame",
    label = "Target and Focus",
    help = "Restyle target and focus frames, including target-of-target. Uncheck restores Forever's look.",
    editMode = true,
  },
  {
    key = "petFrame",
    label = "Pet Frame",
    help = "Restyle the pet unit frame. Uncheck restores Forever's look.",
    editMode = true,
  },
  {
    key = "partyFrames",
    label = "Party Frames",
    help = "Restyle party member frames. Uncheck restores Forever's look. Vehicle party art is left alone.",
    editMode = true,
  },
  {
    key = "castBars",
    label = "Cast Bar",
    help = "Restyle player, target, and focus cast bars. Uncheck restores Forever's look.",
    editMode = true,
  },
  {
    key = "minimap",
    label = "Minimap",
    help = "Apply Classic minimap border and zoom buttons. Uncheck restores Forever's look.",
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
