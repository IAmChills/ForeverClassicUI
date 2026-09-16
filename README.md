# Forever Classic UI

World of Warcraft: Forever AddOn that restyles the default HUD to look like Classic. Player and target frames, cast bars, pet/party frames, and the minimap are skinned in place instead of replaced.

Forever is expected to use retail-style UI code and Midnight-like addon restrictions. That means health, power, and combat data may be secret during encounters, so this AddOn **does not build its own unit frames**. It only changes the art, size, and chrome of Blizzard's existing frames.

## Status

**0.1.0 scaffold.** Forever is not out yet. Frame names, Interface version, and which Classic textures the client still ships are guessed from current retail (10.x/12.x) layout plus Classic FrameXML. The skins are a working example to retune the moment beta is installed.

## Install

Battle.net will put Forever in its own flavor folder next to `_retail_` and `_anniversary_`. This repo is already laid out as an AddOn:

```
World of Warcraft\_forever_\Interface\AddOns\ForeverClassicUI\
```

If the live client uses a different folder (`_forever_beta_`, `_classic_forever_`, etc.), copy `ForeverClassicUI` into that flavor's `Interface\AddOns` directory. The folder name must stay `ForeverClassicUI`.

1. Enable **Forever Classic UI** on the character select AddOns list.
2. If it shows as out of date, check **Load out of date AddOns** until the TOC Interface number is updated from in-game.
3. In game, run `/fcui probe`.

## Commands

| Command | What it does |
| --- | --- |
| `/fcui` | Help |
| `/fcui options` | Settings panel |
| `/fcui probe` | Dump build info, frame trees, and Classic texture availability |
| `/fcui status` | Show detected layout and which skins applied |
| `/fcui debug` | Toggle extra chat diagnostics |
| `/fcui reset` | Restore default settings |

Probe output is also stored on `ForeverClassicUIDB.lastProbe` after a `/reload`, so you can copy it from SavedVariables.

## First session on beta

1. Log in and note whether the AddOn loads or is marked out of date.
2. Run `/dump (select(4, GetBuildInfo()))` and put that number in `ForeverClassicUI.toc` as `## Interface:`.
3. Run `/fcui probe`. That tells us:
   - Whether `PlayerFrame.PlayerFrameContainer` (retail 10+ style) exists
   - Whether classic globals like `PlayerFrameTexture` / `CastingBarFrame` exist
   - Which `Interface\TargetingFrame\...` textures Forever still has
4. If textures are `MISS`, extract the Classic versions into `Media/` (see `Media/README.md`).
5. Tune `Core/Util.lua` `ns.Layout` offsets against screenshots. Do not rewrite the skin files from scratch unless the probe shows a totally different frame tree.

## How skins work

Each file under `Skins/` registers with `ns.RegisterSkin`. On login the core detects a layout:

- `retail10` — `PlayerFrame.PlayerFrameContainer` (Dragonflight / Midnight style, likely Forever)
- `classic` — `PlayerFrameTexture` already present
- `unknown-playerframe` / `missing` — probe and patch the path tables

Skins then hide modern chrome (role icons, prestige, rest loops, cast sparkles) and apply Classic `UI-TargetingFrame` / `UI-CastingBar-*` art. Layout numbers live in `ns.Layout` so beta tuning is data, not a rewrite.

## Reference

[Classic Frames](https://github.com/G1t-Happens/ClassicFrames) is the retail AddOn that already does this job for Midnight: it skins Blizzard frames instead of replacing them. Forever Classic UI follows that approach, with a probe/compat layer because Forever's actual frame names are not public yet.

## License

MIT. See `LICENSE`.
