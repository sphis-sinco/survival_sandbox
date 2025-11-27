# Suvindo
A project originally intended to be a survival sandbox game similar to minecraft, now turned into a simple game where you build whatever you want with a limited palette of blocks. Unless you have some Resources Packs that add more, but that's for later.

## Credits

You do or did know there's a person making this or made this right? Not some robot prompted to do every single part of it. Especally the pixel art. (At the time of writing this.) They're not good at that.

### Sphis

Yo! I'm the one writing this actually so that's cool :D
I did just about all of the code for this project. And so-far all of the art, so yeah.

To quickly get over the social list just go to [my Carrd page](https://sphis-sinco.carrd.co). It's got all my socials. And some extra stuff.

### Friday Night Funkin'

More specifically [EliteMasterEric](https://x.com/EliteMasterEric), [Ninjamuffin99](https://x.com/ninja_muffin99), and [Lasercar](https://github.com/Lasercar).
I (Sphis) got the Hue Saturation and Value shader from the code. Specifically this version right [here](https://github.com/FunkinCrew/Funkin/blob/87a09cae2159ee14e014321be3ba0091885460ec/source/funkin/graphics/shaders/HSVShader.hx).


## Playing the Game

Surely you're not just here to check out the code right?

### Controls

Every game has controls! What're this game's controls?

#### Anywhere

R - Reload Resource Packs and the Block list

#### PlayState / The Main Game

WASD / Arrow Keys - Move the cursor block

TAB - Switch to the next block
TAB + SHIFT - Switch to the previous block

F3 - Display extra info on the watermark

ENTER - Place / Break blocks (depending on if you're touching a block)

#### Resource Pack Menu

W / Up Arrow Key - Move up
W / Up Arrow Key + Shift - Move up and move the resource pack up in priority

S / Down Arrow Key - Move down
S / Down Arrow Key + Shift - Move down and move the resource pack down in priority

ENTER - Disable / Enable the currently selected Resource Pack

ESCAPE - Leave to PlayState / The Main Game

### Resource Packs

Alright NOW we can talk about the Resource Packs.

So the resource packs in this game are a system where you can:
- Add / Replace blocks
( And that's about it for now but this game isn't in it's 1.0+ stage so gimme some time ight? (¬⤙¬ ) )

#### Little Note

I don't think this system really works on web / HTML5 unless you export / compile it with resource packs so uh, do what that what you will. (Mainly directed to the people going to the Source Code section so yeah.)

#### Adding (or replacing) new blocks

This is actually very easy to do!
Here are the steps:

1. Create an image (1 to 1 ratio to avoid stretching textures because it'll scale to 16x16, so 4x4, 8x8, 16x16, 32x32, all are good.)

2. Add it to the "images/blocks/" folder of the base game (why would you do that) or your resource pack as a .PNG

3. Go back to the game window and press "R" (or you can close and reopen the game but that's annoying to do each time.)

And you're done!

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
