# Resource Packs : Animated Blocks
[Back](../Intro.md)

A block with a looping animation

## JSON
- `type` : "animated"
- `animated` :
    - `block_width` : Width of your block
    - `block_height` : Height of your block
    - `texture` (optional) : Path to your block relative to the image folder. (I.e `blocks/liquids/lava` would redirect to `assets/images/blocks/liquids/lava.png` in-game)
    - `frames` (optional) : A list of integer values to control how your animation runs
        - Frames have to be specified like this: [0, 1, 2, 3, ...] : The first frame is 0.
        - Default: If you don't specify a frame order then the game will do it for you by just proceeding through the frames in order.
    - `fps` (optional, default: 24) : Controls how fast the animation will go, how many frames will play a second.

## Example(s)

- [Water block](/assets/base/images/blocks/water.json)

## Notes
If the .JSON file is unspecified then your texture will be squashed.