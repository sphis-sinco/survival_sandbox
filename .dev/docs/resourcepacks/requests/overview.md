# Resource Packs : Requests
[Back](../Intro.md)

A series of .JSON files that will give the game instructions

## JSON
Asset Path: `data/requests/`
    - You cannot do requests without this being where it's located

- `request` : The request type
    - `add` : will add the specified objects, most likely to be used when the block's in a different default directory
    - `remove` : will remove the specified objects
- `blocks` (optional)
    - `type: remove` : List of Block ID's
    - `type: add` : List of Block Paths relative to the images folder (I.e `myresourcepack/blocks/jujin` would redirect to `assets/images/myresourcepack/blocks/jujin.png` in-game along with the resource pack versions)
- `tracks` (optional)
    - `type: remove` : List of Track File names's
    - `type: add` : List of Track Paths relative to the music folder (I.e `c418/calm1.wav` would redirect to `assets/music/c418/calm1.wav` in-game along with the resource pack versions)

## Examples

- [Adding Blocks](/.dev/debug-resources/base/block_adding/data/requests/add-bluestone.json)
- [Removing Blocks](/.dev/debug-resources/base/block_removing/data/requests/remove-leaves.json)