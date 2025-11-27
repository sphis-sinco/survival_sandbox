# Suvindo
A project originally intended to be a survival sandbox game similar to minecraft, now turned into a simple game where you build whatever you want with a limited palette of blocks. Unless you have some Resources Packs that add more, but that's for later.

## Credits

You do or did know there's people making this or made this right? Not some robot prompted to do every single part of it. Especally the pixel art. (At the time of writing this.) They're not good at that.

### Suvindo Crew
The crew behind the game!

- [Sphis](https://sphis-sinco.carrd.co) : Director, Lead Programmer, and Artist
- [Xavier](https://www.instagram.com/thegreat_avirex?igsh=NTc4MTIwNjQ2YQ%3D%3D&utm_source=qr) : Musician and Sound designer
- [ZSolarDev](https://github.com/ZSolarDev) - Programmer

### Friday Night Funkin'

More specifically [EliteMasterEric](https://x.com/EliteMasterEric), [Ninjamuffin99](https://x.com/ninja_muffin99), and [Lasercar](https://github.com/Lasercar).
I (Sphis) got the Hue Saturation and Value shader from the code. Specifically this version right [here](https://github.com/FunkinCrew/Funkin/blob/87a09cae2159ee14e014321be3ba0091885460ec/source/funkin/graphics/shaders/HSVShader.hx).


## Playing the Game

Surely you're not just here to check out the code right?

### Controls

[ANYWHERE] R - Reload Resource Packs and the Block list

[GAMEPLAY] WASD / Arrow Keys - Move the cursor block

[GAMEPLAY] TAB - Switch to the next block

[GAMEPLAY] TAB + SHIFT - Switch to the previous block

[GAMEPLAY] L - Switch to the next variation

[GAMEPLAY] L + SHIFT - Switch to the previous variation

[GAMEPLAY] F3 - Display extra info on the watermark

[GAMEPLAY] ENTER - Place / Break blocks (depending on if you're touching a block)

[GAMEPLAY] ESCAPE - Leave to World Selection

[RESOURCE PACK MENU] W / Up Arrow Key - Move up

[RESOURCE PACK MENU] W / Up Arrow Key + Shift - Move up and move the resource pack up in priority

[RESOURCE PACK MENU] S / Down Arrow Key - Move down

[RESOURCE PACK MENU] S / Down Arrow Key + Shift - Move down and move the resource pack down in priority

[RESOURCE PACK MENU] ENTER - Disable / Enable the currently selected Resource Pack

[RESOURCE PACK MENU] ESCAPE - Leave to PlayState / The Main Game

[WORLD SELECTION MENU] W / Up Arrow Key - Move up

[WORLD SELECTION MENU] S / Down Arrow Key - Move down

[WORLD SELECTION MENU] ENTER - Select the current world (or make a new world)

### Resource Packs

Being reworked, not the system, the documentation.

## Source code

[Tell me why~](https://youtu.be/4fndeDfaWCg?t=54)

### P.S.

I'm not explaining a shit ton of things here because they can all change in one **minor** update, you get info on how to compile and when needed I'll add some stuff to help with errors n shit. But you get compiling.

### Compiling

Alright, let's talk about the steps compiling the game cause if you can't do that you're kinda screwed.

1. First thing you wanna do is install Haxe + Haxeflixel : https://haxeflixel.com/documentation/getting-started/
2. Make sure you install these libraries or make sure they are installed: 
```
flixel
flixel-addons
lime
openfl
hxcpp (windows compiling thing idk about mac or linux, maybe?)
```
3. Run "lime test <platform>". The platforms you can compile to are "windows", "mac", "linux", or "html5", there are more like "hl" which lets you compile VERY fast ( very nice ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧ ).
4. In theory you should be goo so have fun playing around with the code :D
