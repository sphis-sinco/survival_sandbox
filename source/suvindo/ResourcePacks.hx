package suvindo;

#if sys
import sys.FileSystem;
#end

class ResourcePacks
{
	public static var RESOURCE_PACKS:Array<String> = [];

	public static function reload()
	{
		RESOURCE_PACKS = [];

		#if sys
		for (pack in FileSystem.readDirectory('resources/'))
		{
			if (FileSystem.isDirectory('resources/' + pack))
				RESOURCE_PACKS.push(pack);
		}
		#end

        trace('Resource packs: ' + RESOURCE_PACKS);
	}
}
