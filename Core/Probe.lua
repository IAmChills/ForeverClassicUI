local ADDON_NAME, ns = ...

local MAX_CHILDREN = 40
local MAX_DEPTH = 3

local function FrameName(frame)
  if not frame then
    return "nil"
  end
  if frame.GetName then
    local name = frame:GetName()
    if name and name ~= "" then
      return name
    end
  end
  if frame.GetDebugName then
    return frame:GetDebugName()
  end
  return tostring(frame)
end

local function DumpNode(frame, depth, lines, prefix)
  if not frame or depth > MAX_DEPTH then
    return
  end
  lines[#lines + 1] = string.rep("  ", depth) .. prefix .. FrameName(frame)

  if frame.GetChildren and depth < MAX_DEPTH then
    local children = { frame:GetChildren() }
    local count = math.min(#children, MAX_CHILDREN)
    for i = 1, count do
      DumpNode(children[i], depth + 1, lines, "")
    end
    if #children > MAX_CHILDREN then
      lines[#lines + 1] = string.rep("  ", depth + 1) .. "... " .. (#children - MAX_CHILDREN) .. " more children"
    end
  end

  if frame.GetRegions and depth < MAX_DEPTH then
    local regions = { frame:GetRegions() }
    local shown = 0
    for i = 1, #regions do
      local region = regions[i]
      local rtype = region.GetObjectType and region:GetObjectType() or "Region"
      if rtype == "Texture" or rtype == "FontString" then
        shown = shown + 1
        if shown <= 12 then
          local extra = ""
          if region.GetTexture then
            extra = tostring(region:GetTexture() or "")
          elseif region.GetText then
            extra = tostring(region:GetText() or "")
          end
          lines[#lines + 1] = string.rep("  ", depth + 1) .. rtype .. " " .. extra
        end
      end
    end
  end
end

local function ReportTexture(key)
  local path = ns.Art[key]
  local exists = ns.TextureExists(path)
  return string.format("%s  %s  %s", exists and "OK " or "MISS", key, path)
end

function ns.RunProbe(printToChat)
  local lines = {}
  local function add(text)
    lines[#lines + 1] = text
  end

  local version, build, date, interface = GetBuildInfo()
  add("Forever Classic UI probe")
  add("Build: " .. tostring(version) .. "." .. tostring(build) .. "  interface " .. tostring(interface) .. "  date " .. tostring(date))
  add("Project: " .. tostring(WOW_PROJECT_ID))
  add("Detected layout: " .. tostring(ns.DetectLayout()))
  add("")
  add("Known globals:")

  local globals = {
    "PlayerFrame",
    "PlayerFrameTexture",
    "PlayerName",
    "PlayerLevelText",
    "TargetFrame",
    "FocusFrame",
    "PetFrame",
    "PartyFrame",
    "PartyMemberFrame1",
    "PlayerCastingBarFrame",
    "CastingBarFrame",
    "Minimap",
    "MinimapCluster",
    "MinimapBorder",
    "MinimapBorderTop",
    "BuffFrame",
    "CompactRaidFrameContainer",
    "MainMenuBar",
    "StatusTrackingBarManager",
  }
  for i = 1, #globals do
    local name = globals[i]
    add(string.format("  %-28s %s", name, _G[name] and "yes" or "no"))
  end

  add("")
  add("PlayerFrame children:")
  DumpNode(PlayerFrame, 0, lines, "")

  add("")
  add("TargetFrame children:")
  DumpNode(TargetFrame, 0, lines, "")

  add("")
  add("Cast bar:")
  DumpNode(PlayerCastingBarFrame or CastingBarFrame, 0, lines, "")

  add("")
  add("Minimap:")
  DumpNode(MinimapCluster or Minimap, 0, lines, "")

  add("")
  add("Classic textures:")
  local keys = {}
  for key in pairs(ns.Art) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for i = 1, #keys do
    add("  " .. ReportTexture(keys[i]))
  end

  ForeverClassicUIDB = ForeverClassicUIDB or {}
  ForeverClassicUIDB.lastProbe = {
    time = time and time() or 0,
    interface = interface,
    version = version,
    build = build,
    layout = ns.DetectLayout(),
    report = table.concat(lines, "\n"),
  }

  if printToChat then
    ns.Print("Probe written. Last lines also saved to ForeverClassicUIDB.lastProbe.")
    for i = 1, math.min(#lines, 40) do
      print(lines[i])
    end
    if #lines > 40 then
      print("... " .. (#lines - 40) .. " more lines saved to SavedVariables. /reload then check WTF.")
    end
  end

  return lines
end
