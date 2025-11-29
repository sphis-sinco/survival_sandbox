# 0.3.0 - 11/28/2025
## Resource Packs
Changes connected to the [new Request system changes](#requests-1)
- The resource `pack_version` is now `4`
    - Version `1`, `2`, and `3` are still supported

## Requests
- Fixed receiving request paths missing a "/"
- Added new "convert" request type

## Blocks
- If no blocks or less then 2 blocks are found in the block list the dirt and plank block is added
- Renamed "tree_trunk" to "log"
- Added "Cactus" block
    - Type: "regular"

## General
- New F3 Debug text entry: `tick`
- You can now hold directionals to move if you hold it for a bit and move every 4 ticks
- You now have to toggle between destroying and placing by pressing `SHIFT + ENTER`
    - Removed `touching_kids` variable
    - The Cursor block alpha will show if you're in placing or destorying mode via the opacity (lower = destroy)
- You can now hold ENTER to place or destroy blocks (ultimate destruction hehehe)
- Renamed "Below the minimum supported version number" to "Below the minimum supported pack number" in resource pack warnings
- Added "Above the maximum supported pack number" as an option to resource pack warnings
- **ADDED MAIN MENU**
- Changed size of pack info in the resource pack menu
- Changed size of world info text in the world select menu
- The Resource Pack Menu now uses a font and has a background
- The World Select Menu now uses a font and has a background
- Moved Game version watermark text to Main Menu
- PlayState watermark (now debug) text is now F3-only
- Loaded worlds are now auto-updated once loaded
- Code organization has been implemented
- Gameplay now calls for tracks to play
- Removed ability for the Resource Pack menu to play music
- Added `F1` Keybind : Hides **ALL** UI
- Fixed `MUSIC_RATE` compiler flags
    - Instead of `MUSIC_RATE=` it is now:
        - `MUSIC_RATE_OFF`
        - `MUSIC_RATE_CONSTANT`
        - `MUSIC_RATE_DEFAULT`
        - `MUSIC_RATE_FREQUENT`
        - `MUSIC_RATE_VARIABLE`

# 0.2.2 - 11/27/2025
## General
- Fixed Track timer not resetting when the music is destroyed
- Fixed "Above the maximum supported world version" showing up when it shouldnt've in the world notes
- General QOL fixes to the requests system
    - Fixed crashes with double-slashed paths (ex: `resources/myrp//myfile.extension`)
    - Requested tracks can play properly
        - (They're also loaded properly!)

# 0.2.1 - 11/27/2025
## General
- Fixed block variations not being saved in worlds

# 0.2.0 - 11/27/2025
## Requests
- [New system: Requests](/.dev/docs/resourcepacks/requests/overview.md) : A series of .JSON files that will give the game instructions

## Resource Packs
Changes connected to [the new Requests system](#requests) and the new tracks system
- The resource `pack_version` is now `3`
    - Version `2` is supported
    - Version `1` is still supported

## General
- Fixed becoming off-grid by going to the bottom of the worlds
- Added support for music tracks to play in the background randomly
- Changed Resource Pack Menu Pack Info text size from 32 to 16
- Fixed Resource Pack Menu warnings not displaying
- Several issues with the Resource Pack readDirectory function were fixed
    - Fixed resource pack paths not including the directory
    - Fixed crashes when trying to read non-existant resource pack directories
- You can now wrap around in the Resource Pack Menu
- Fixed mouse being visible when it shouldn't be
- Added worldautosaving (every minute)
- Added support for Loading worlds (World Selection State does this)
- Added support for Saving worlds (auto-done when reloading or leaving gameplay)
- `DEBUG` : Added Custom Debug Application icon
- Added World Selection State
- Added Current Block Variation to the watermark
- "Current Block (id)" is now "Current Block ID" on the watermark
- Changed company from "Sphis" to "SuvindoCrew"
- `DEBUG` : Added " [PROTOTYPE]" text to watermark
- Added extra linebreak inbetween the "Current Block (id)" and "Resource packs" text in watermarks
- Added Custom Application icon

## Blocks
- Added Debug "Block" - A texture used when a block's texture can't be found. Embeded texture
- Added Block JSON support with the following types:
    - [variations](/.dev/docs/resourcepacks/blocks/types/variations.md)
    - [animated](/.dev/docs/resourcepacks/blocks/types/animated.md)
    - [regular](/.dev/docs/resourcepacks/blocks/types/regular.md)
- Added Water Block
    - Type: "animated"
- Added Wool Block
    - Type: "variations"
    - Variations:
        - `red`
        - `orange`
        - `yellow`
        - `green`
        - `blue`
        - `purple`
        - `pink`
        - `brown`
        - `gray`
        - `white`
        - `black`

# 0.1.0 - 11/26/2025
Early prototype version of Suvindo.