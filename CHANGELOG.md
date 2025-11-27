# 0.2.0
## General
- Changed company from "Sphis" to "SuvindoCrew"
- [DEBUG] Added " [PROTOTYPE]" text to watermark
- Added extra linebreak inbetween the "Current Block (id)" and "Resource packs" text in watermarks
- Added Custom Application icon

## Blocks
- Added Block JSON support with the following fields and availible values:
    - Types:
        - "Variations" - Allows the block to change its texture without switching to (or having to create) a new block
    - [TYPE: "Variations"] Variations - An array of variations the block has with the following fields for each variation
        - "id" - Name of the variation
        - "texture" - path of the texture you'd like to use relative to the images folder, so if your texture is in `assets/images/mycoolblock/coolstate5.png`, then you'd put `mycoolblock/coolstate5`
- Added Wool Block
    - Type: "Variations"
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

# 0.1.0
Early prototype version of Suvindo.