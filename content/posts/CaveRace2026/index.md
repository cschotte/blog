---
title: "Shipping CaveRace 1.5"
author: "Clemens Schotte"
date: 2026-08-05
lastmod: 2026-08-13

tags: ["Game Development", "Retro Computing", "Odin", "raylib", "macOS"]
categories: ["Retro"]

featuredImage: "featured-image.jpg"

draft: false

---

There is something strangely satisfying about opening source code that is almost three decades old.

Not because it is beautiful. It isn't. Not because you remember how everything works. You definitely don't. But because every line tells a story about a younger version of yourself who somehow thought "future me will understand this." Spoiler: future me did not.

![CaveRace miners facing an alien at the entrance to a cave](https://caverace.com/assets/images/caverace1/hero.jpg)

Back in 1997 I wrote CaveRace, a small DOS arcade game about collecting treasure, avoiding monsters, blowing up rocks, and trying not to blow yourself up in the process. Nothing revolutionary, just a fun little game made with the tools we had at the time. Over the years it lived on different computers, went through a DirectX rewrite, eventually made its way to Windows Phone, and then quietly disappeared. I never really forgot about it, though, and this year I sat down to answer a simple question: could I rebuild CaveRace today as if starting from scratch, while keeping the original gameplay completely intact? The answer became CaveRace 1.5.

## Reading my own code from 1997

![The CaveRace story screen showing the planet Eldora](https://caverace.com/assets/images/story-origin.jpg)

`CaveRace.c` opens with a header comment listing the four of us and a date — 17-03-97 — and then gets straight into raw MS-DOS graphics programming. The game runs in MCGA mode `0x13`: 320×200 pixels, 256 colors, and the framebuffer is a segment pointer, `VideoMem[0]` cast directly to address `0xA0000000`. Setting a pixel is a macro that writes a byte to that segment. Setting the palette is inline assembly that pokes the VGA DAC ports directly (`out dx,al` against port `0x3c8` and `0x3c9`) and screen fades are hand-rolled loops that scale every one of 254 palette entries by a fraction and push the whole table out through those same ports, 60 times a second, timed against the vertical retrace flag on port `0x3da`. There's no operating system graphics API in the loop at all; it's the metal.

The genuinely interesting artifact, though, is the level format. Each of the ten caves is a raw C struct dumped straight to disk: six 19×11 grids of byte: background, item, treasure, enemy, player, and a runtime-only bomb layer, and `LoadMap` reads it back with one call, `fread(&map, 1045, 1, pnf)`. No parser, no header, no version tag. 1,045 bytes because five of those six grids (19 × 11 × 5) get written to the file; the sixth is rebuilt at runtime. Movement was tile-based but animated a tile crossing as sixteen individual one-pixel steps inside `MoveSprites`, redrawing the full triple-buffered frame on every single step. And because it was 1997, there's a `-powerblast` command-line flag that unlocks five cheat keys (F1 through F5: skip level, max health, max bombs, more bomb power, double score) and a `-slow` flag for players whose PCs couldn't keep up.

## The DirectX years

Somewhere around 2002 the game got a facelift into DirectX 8.1. DirectDraw for textured sprite blitting instead of raw palette bitmaps, DirectMusic for audio, even for one-shot sound effects like the bomb fuse ticking. The window is a borderless, topmost Win32 popup sized to the full screen, and the game loop runs on its own worker thread, separate from the thread pumping Windows messages.

What I find genuinely charming, reading it back now, is that the 1.3 source still carries the comment `// Old game code !` directly above the level and player structs, because the level format didn't change. `LoadMap` in the DirectX version still does `fread(&map,1045,1,pnf)`, the exact same 1,045-byte layout from 1997, just renamed from `levels\01.bin` to `levels\caverace.s01`. The tile size doubled from 16 to 32 pixels (bit shifts moved from `<<4` to `<<5` throughout) and the sixteen-step tile crossing became thirty-two steps taken two pixels at a time, but the underlying grid, and the file that describes it, was untouched. By 2002 that binary format had already survived one full engine rewrite without anyone needing to touch it.

## Why Odin

For the current rebuild I deliberately avoided Unity, Unreal, Godot, and the other large engines, because CaveRace doesn't need an editor with a million features. That's what led me to Odin: a small, C-like systems language with explicit allocators instead of a garbage collector, multiple return values instead of exceptions, and a compiler that's genuinely fast to iterate against.

The clearest sign that Odin's discipline was worth it shows up in `level.odin`. The new `Map_Data` struct, the direct successor to the 1997 `map` struct, carries this line right after its declaration:

```odin
#assert(size_of(Map_Data) == 1045)
```

That's not a comment claiming compatibility; it's a compile-time assertion. If a future change to the struct's fields ever drifted from the original 1,045-byte layout, the build would fail before a single test ran. `load_level_from_path` reads the file with `os.read_full` straight into that struct's byte slice, checks the file size matches exactly, then walks every tile in every layer through `validate_level_data` (rejecting out-of-range background, item, treasure, enemy, or player indices) before the level is allowed to replace the active one. The same ten `.bin` files from 1997 (well, their 1.5 counterparts, converted once and never touched since) still load through that path today. `config.odin` does the same thing for the screen geometry: `#assert(MAP_OFFSET_X * 2 + MAP_WIDTH * MAP_TILE_SIZE == WINDOW_WIDTH)` ties the 19×11 grid, its 32-pixel tiles, and the 640×400 window together as a single checked equation, so nobody can quietly break the layout by editing one constant and forgetting the others.

## RayLib and a real fixed-timestep loop

Rendering, audio, input, and windowing all go through raylib. Where the original DOS and DirectX versions redrew the world once per animation step and coupled game speed directly to however fast that loop happened to run, version 1.5 separates simulation from presentation properly. `GAMEPLAY_TICK_HZ` is 60; every frame accumulates elapsed time and drains it in fixed 1/60th-second ticks (capped at fifteen per frame, so a stall can't spiral into a death march trying to catch up), while rendering targets its own 60 FPS independently. A tile crossing now takes exactly twelve of those fixed ticks (0.2 seconds) regardless of the display's refresh rate, replacing the old sixteen-step and thirty-two-step per-frame interpolation with something frame-rate independent.

That fixed tick also changed what a "hit" means. In 1997 and 2002, collision was checked against tile-aligned positions (you were hit when your coordinates matched an enemy's exactly). In 1.5, `player_touches_enemy` interpolates both the player and every enemy through their current move animation and checks for exact sub-tile overlap on every single tick, so a crossing near-miss actually reads as a near-miss instead of snapping to the nearest tile. Enemies also do something the originals never did: `enemy_pursuit_chance` gives each level a tuned probability that an enemy's next random step is replaced by one that shortens the Manhattan distance to the player, instead of the pure `random(4)` walk from 1997. It's deliberately subtle and capped at 35%, and it's driven by two independent seeded `xoshiro256` random streams: one for AI decisions, one for cosmetic/audio variation, so presentation randomness can never accidentally perturb a deterministic run.

![How to play CaveRace](https://caverace.com/assets/images/caverace-controls.jpg)

The Standard/Assisted difficulty split I mentioned isn't two code paths; it's one data table, `GAMEPLAY_TUNING`, indexed by difficulty. Standard keeps the original bite: two energy per enemy contact, a blast reduces you straight to zero. Assisted halves contact damage, gives blast hits a grace window, and (this is the one I like most) extends the bomb "danger preview" to cover the entire fuse instead of just its final third, so newer players can see a blast's exact footprint from the moment the bomb is placed rather than only in the last half-second. Both share the same 180-tick, three-second fuse; only the forgiveness around it changes. Layered on top of the original scoring (100 for treasure, 75 for an enemy, 50 for an item, 100 for clearing a level) are a few things that didn't exist in 1997: a partial-credit "salvage" score for items you can't carry, and clean-run bonuses for finishing a cave with no damage, under a time par, or with every piece of treasure collected.

## Pixel art, kept honest by validation

The original tiles and sprites were drawn in **Deluxe Paint** on an **Amiga**. I didn't want to redraw them, and I didn't want a bad conversion to silently corrupt the game either, so `assets.odin` validates every sprite sheet at load time: each is required to be exactly one tile wide (32 pixels) and a multiple of the tile height tall, checked by `vertical_sheet_dimensions_are_valid` before the game is allowed to start. Full-screen art like the menu, game-over, and victory screens is checked against the fixed 640×400 canvas the same way. If a texture doesn't match, startup fails immediately with a message naming exactly which asset was wrong, instead of the game quietly rendering garbage three menus later.

## Shipping is harder than coding

Like most side projects, I assumed writing the game would be the hard part. It wasn't. Publishing was the real adventure, and the build scripts in `packaging/` are its own small archive of what that took.

Odin doesn't produce universal macOS binaries directly, and the Mac App Store won't accept an arm64-only bundle unless your deployment target is 12.0 or later (CaveRace's is 10.15, to support older Intel Macs) so `build_macos_appstore.sh` cross-compiles the game twice, once for `darwin_arm64` and once for `darwin_amd64`, and glues the two executables into one with `lipo -create`. The provisioning profile, downloaded from Apple's portal through a browser, arrives tagged with macOS's quarantine attribute; App Store Connect rejects any uploaded package that still carries it (error ITMS-91109), so the script strips it recursively with `xattr -cr` before code-signing. The entitlements file sandboxes the app and grants exactly two device permissions (USB and Bluetooth) for controller support, nothing else. On the Windows Store side, `build_windows_store.ps1` refuses to even start the build if `AppxManifest.xml` still contains the placeholder string `TODO-PARTNER-CENTER`, forcing a stop and a trip to Partner Center to reserve the real package identity rather than shipping a submission doomed to fail certification. Between that and rediscovering that an old Windows Phone submission of CaveRace was still sitting in my account from years earlier, I spent more hours inside developer portals than inside the source tree.

Eventually it all came together, and [CaveRace 1.5 is live](https://caverace.com/1/) on both **macOS** and **Windows**.

## Things I learned

Small projects are worth more than their size suggests, they let you experiment without first building years of infrastructure just to find out if an idea still holds up. Good tools matter more than I usually give them credit for: choosing Odin and raylib made the actual development stretch genuinely enjoyable, and compile-time checks like the ones locking the level format and window geometry caught mistakes before they became bugs, not after. And finishing is its own skill, separate from writing code, the unglamorous back half (documentation, store assets, packaging, certification) is what turns a repository into something someone can actually buy. Also: never throw away old source code. Even the inline assembly for poking VGA registers turned out to be worth reading again, twenty-nine years later.

## What's next

CaveRace 1.5 was never meant to be a blockbuster. It was an experiment, a chance to revisit an old idea with tools that didn't exist when the idea was new, and proof that finishing a project still feels exactly as good today as it did in 1997.

What I didn't expect was how much rebuilding it would generate. While working on 1.5 I kept a running list of ideas that didn't belong in this game, better enemies, a richer world, deeper mechanics, a proper story, modern level design,  and that list has slowly turned into CaveRace 2. So maybe 1.5 isn't the end of this story. Maybe it's the bridge between a game written by a younger me, and one written almost three decades later.

![The original CaveRace story](https://caverace.com/assets/images/caverace-1997.png)

---

If you're curious, [CaveRace 1.5](https://caverace.com/1/) is available now for Windows and macOS. A focused, fully offline, single-player campaign across five worlds and ten handcrafted caves, with no ads and no in-app purchases.

Buying the game won't make me retire early. It will, however, help fund the next adventure, and give one very stubborn little mining game the audience it never had back in 1997.

And honestly, I think that's a pretty good ending. Or perhaps, a pretty good new beginning.
