local _, ns = ...

ns.Defaults = {
  enabled = true,
  playerFrame = true,
  targetFrame = true,
  petFrame = true,
  partyFrames = true,
  castBars = true,
  minimap = true,
  hideModernChrome = true,
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
    label = "Player frame",
    help = "Restyle the player unit frame to Classic art and layout.",
  },
  {
    key = "targetFrame",
    label = "Target / focus frames",
    help = "Restyle target and focus frames, including target-of-target.",
  },
  {
    key = "petFrame",
    label = "Pet frame",
    help = "Restyle the pet unit frame.",
  },
  {
    key = "partyFrames",
    label = "Party frames",
    help = "Restyle party member frames.",
  },
  {
    key = "castBars",
    label = "Cast bars",
    help = "Restyle player, target, and focus cast bars.",
  },
  {
    key = "minimap",
    label = "Minimap",
    help = "Apply Classic minimap border and chrome.",
  },
  {
    key = "hideModernChrome",
    label = "Hide modern chrome",
    help = "Hide role icons, prestige badges, rest loops, and similar Forever/retail decorations.",
  },
  {
    key = "debug",
    label = "Debug chat",
    help = "Print extra diagnostics while skins apply.",
  },
}
