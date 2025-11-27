# 0.2.0 - 11/??/2025
## Requests
- [New system: Requests](/.dev/docs/resourcepacks/requests/overview.md)

## Resource Packs
[Changes connected to the new Requests system](#requests)
- The resource `pack_version` is now `2`
    - Version `1` is still supported

## General
- You can now wrap around in the Resource Pack Menu
- Fixed mouse being visible when it shouldn't be
- Added autosaving (every minute)
- Added support for Loading worlds (World Selection State does this)
- Added support for Saving worlds (auto-done when reloading or leaving gameplay)
- `DEBUG` : Added Custom Debug Application icon
- Added World Selection State
- Fixed crashes when trying to read non-existant resource pack directories
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