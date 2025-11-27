# Resource Packs : Regular Blocks
[Back](../Intro.md)

A regular block, no animation, no variations. A simple image.

## JSON (optional)
- `type` : "regular"
- `regular` :
    - `texture` (optional) : Path to your block relative to the image folder. (I.e `blocks/stone` would redirect to `assets/images/blocks/stone.png` in-game)

## Notes
The .JSON file is only optional if you're not using a custom texture location, it WILL look in `assets/images/blocks/yourblock.png` unless specified through the .JSON