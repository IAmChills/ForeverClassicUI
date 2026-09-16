# Media

Drop Classic art here once the Forever beta is available and you can confirm which textures the client still ships.

Forever is expected to use a retail-style UI, so Classic TargetingFrame / CastingBar / Minimap files may be missing. If `GetFileIDFromPath` reports a texture as missing, extract the Classic version and place it here using the same relative path.

Example:

```
Media/TargetingFrame/UI-TargetingFrame.blp
Media/CastingBar/UI-CastingBar-Border.blp
Media/Minimap/UI-Minimap-Border.blp
```

Then add a fallback in `Core/Util.lua` `ns.Art` so the skins resolve:

```lua
ns.Art.PlayerFrame = ns.Media("TargetingFrame/UI-TargetingFrame")
  or "Interface\\TargetingFrame\\UI-TargetingFrame"
```

Do not commit Blizzard `.blp` files unless you have a redistribution plan you are comfortable with. They are ignored by `.gitignore`.
