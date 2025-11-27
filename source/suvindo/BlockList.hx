package suvindo;

import sys.io.File;
import lime.utils.Assets;
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
		for (image in ResourcePacks.readDirectory('images/blocks/'))
		{
			if (image.endsWith('.png') && !FileSystem.isDirectory(image))
				if (!BLOCK_LIST.contains(Path.withoutExtension(Path.withoutDirectory(image))))
					BLOCK_LIST.push(Path.withoutExtension(Path.withoutDirectory(image)));

			if (image.endsWith('.json') && !FileSystem.isDirectory(image))
			{
				var block_json:BlockJSON = cast File.getContent(image);
				if (block_json != null)
					if (block_json.type != null)
						if (!BLOCK_LIST.contains(Path.withoutExtension(Path.withoutDirectory(image))))
							BLOCK_LIST.push(Path.withoutExtension(Path.withoutDirectory(image)));
			}
		}
		#else
		BLOCK_LIST = Assets.getText(ResourcePacks.getPath('data/blocks-list.txt')).split('\n');
		#end

		trace('block list: ' + BLOCK_LIST);
	}
}
