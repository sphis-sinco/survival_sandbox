package suvindo;

import haxe.io.Path;
#if sys
import sys.FileSystem;
#end

using StringTools;

class BlockList
{

    public static var BLOCK_LIST:Array<String> = [];

    public static function reload()
    {
        BLOCK_LIST = [];

        #if sys
        for (image in FileSystem.readDirectory('assets/images/blocks/'))
        {
            if (image.endsWith('.png') && !FileSystem.isDirectory('assets/images/blocks/'+image))
                BLOCK_LIST.push(Path.withoutExtension(image));
        }
        #else
        BLOCK_LIST = ['plank'];
        #end
    }
}