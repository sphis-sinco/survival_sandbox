# 0.2.0 - 11/??/2025
## Requests
- Added new system: Requests
    - A series of .JSON files that will give the game instructions
- Requests JSON
    - Asset Path: `data/requests/`
        - You cannot do requests without this being the path
    - `request` : The request type
        - `remove` : will remove the specified objects
    - `blocks` : List of Block ID's

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
- Added Block JSON support with the following fields and availible values:
    - Types:
        - "variations" - Allows the block to change its texture without switching to (or having to create) a new block
        - "animated" - Allows blocks to be animated
        - "regular" - Default block functions, just allows you to change the texture location
    - `TYPE: variations` : variations - An array of variations the block has with the following fields for each variation
        - "id" - Name of the variation, used in the watermark
        - "texture" - Path of the texture you'd like to use relative to the images folder, so if your texture is in `assets/images/mycoolblockstates/coolstate5.png`, then you'd put `mycoolblockstates/coolstate5`
    - `TYPE: animated` : animated - Data related to animated blocks
        - "block_width" - The width of your block image without the animation frames
        - "block_height" - The height of your block image without the animation frames
        - "texture" - Path of the texture you'd like to use relative to the images folder, so if your texture is in `assets/images/myanimatedblock/animatedblock.png`, then you'd put `myanimatedblock/animatedblock`
        - "frames" - The frame order your animation has, starting from 0 it can be [0,2,1,2,0], [0,1,2,1,0], and it will change the frame order so in the first one its a loop of frame 1, 3, 2, 3, then 1, and in the second 1,2,3,1,0.
        - "fps" - How many frames are played in a second
    - `TYPE: regular` regular - Data related to regular blocks
        - "texture" - Custom path of the texture you'd like to use relative to the images folder, so if your texture is in `assets/images/blocks/myblocks/block.png`, then you'd put `blocks/myblocks/block`
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