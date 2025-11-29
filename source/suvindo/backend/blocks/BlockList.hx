package suvindo.backend.blocks;

import suvindo.backend.resourcepacks.ResourcePacks;
import suvindo.backend.requests.Requests.RequestsManager;
import haxe.Json;
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
		trace('RELOADING');

		#if sys
		var blocksDir:Array<String> = ResourcePacks.readDirectory('images/blocks/');
		for (block in RequestsManager.ADD?.blocks)
		{
			var path:String = ResourcePacks.getPath('images/' + block + '.png');
			if (#if !sys Assets.exists #else FileSystem.exists #end (path))
				blocksDir.push(path);
		}
		for (image in blocksDir)
		{
			var list_entry:String = Path.withoutExtension(Path.withoutDirectory(image));
			var accept_entry = () ->
			{
				if (!BLOCK_LIST.contains(list_entry))
					BLOCK_LIST.push(list_entry);
			}

			if (RequestsManager.REMOVE?.blocks.contains(list_entry))
				continue;

			if (image.endsWith('.png') && !FileSystem.isDirectory(image) && !FileSystem.exists(image.replace('png', '.json')))
				accept_entry();

			if (image.endsWith('.json') && !FileSystem.isDirectory(image))
			{
				var block_json:BlockJSON = cast Json.parse(File.getContent(image));
				if (block_json != null)
					if (block_json.type != null)
					{
						switch (block_json.type.toLowerCase())
						{
							case 'variations':
								var all_variations_valid = true;
								if (block_json.variations != null)
								{
									for (variation in block_json.variations)
										if (variation.id == null || variation.texture == null)
											all_variations_valid = false;
								}
								else
									all_variations_valid = false;

								if (all_variations_valid)
									accept_entry();
							case 'animated':
								if (block_json.animated?.block_width != null)
									if (block_json.animated?.block_height != null)
										if (block_json.animated?.texture != null)
											accept_entry();

							default:
								accept_entry();
						}
					}
			}
		}
		#else
		BLOCK_LIST = Assets.getText(ResourcePacks.getPath('data/blocks-list.txt')).split('\n');
		#end

		if (BLOCK_LIST.length < 1)
		{
			BLOCK_LIST.push('dirt');
		}
		trace('block list: ' + BLOCK_LIST);
	}
}
