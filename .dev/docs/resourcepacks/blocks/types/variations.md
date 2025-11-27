# Resource Packs : Variation Blocks
[Back](../../Intro.md)

Allows a block to change its texture without switching to (or having to create) a new block

## JSON
- `type` : "variations"
- `variations` : List of variations
    - `id` : Name of the variation
    - `texture` (optional) : Path to your block relative to the image folder. (I.e `blocks/variation-blocks/block/blockstate_1` would redirect to `assets/images/blocks/variation-blocks/block/blockstate_1.png` in-game along with the resource pack versions)

## Example(s)

- [Wool block](/assets/base/images/blocks/wool.json)

## Notes

- For organization state it's recommended to have your block states in a seperate folder then all the other block textures, especally if you're not going to include a prefix.