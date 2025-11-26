package suvindo;

import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ResourcePacks
{
	public static var RESOURCE_PACKS:Array<String> = [];
	public static var ENABLED_RESOURCE_PACKS:Array<String> = [];

	public static var PACK_VERSION:Int = 1;
	public static var MIN_PACK_VERSION:Int = 1;

	public static function reload()
	{
		RESOURCE_PACKS = [];
		ENABLED_RESOURCE_PACKS = [];
		var enabled_resource_list:String = '';

		#if sys
		for (pack in FileSystem.readDirectory('resources/'))
		{
			if (FileSystem.isDirectory('resources/' + pack))
			{
				try
				{
					var pack_file:ResourcePack = Json.parse(File.getContent('resources/' + pack + '/pack.json'));
					if (pack_file.name == null)
						continue;
					if (pack_file.pack_version == null)
						continue;
					if (pack_file.pack_version < MIN_PACK_VERSION)
					{
						trace('"' + pack_file.name + '" is below the minimum supported version number (' + MIN_PACK_VERSION + ' > ' + pack_file.pack_version
							+ ')');
						continue;
					}
					if (pack_file.pack_version > PACK_VERSION)
					{
						trace('"'
							+ pack_file.name
							+ '" is above the max supported version number ('
							+ PACK_VERSION
							+ ' < '
							+ pack_file.pack_version
							+ ')');
						continue;
					}

					RESOURCE_PACKS.push(pack);
				}
				catch (e) {}
			}
		}

		if (!FileSystem.exists('resources/resource-list.txt'))
		{
			var i = 1;
			for (pack in RESOURCE_PACKS)
			{
				enabled_resource_list += pack;

				if (i < RESOURCE_PACKS.length)
					enabled_resource_list += '\n';
				i++;
			}

			File.saveContent('resources/resource-list.txt', enabled_resource_list);
		}
		else
			enabled_resource_list = File.getContent('resources/resource-list.txt');
		#end

		for (enabled_pack in enabled_resource_list.split('\n'))
		{
			if (enabled_pack.length > 0 && enabled_pack != null && enabled_pack != '')
			{
				var pack_file:ResourcePack = Json.parse(File.getContent('resources/' + enabled_pack + '/pack.json'));
				if (pack_file.name == null)
					continue;
				if (pack_file.pack_version == null)
					continue;
				if (pack_file.pack_version < MIN_PACK_VERSION)
					continue;
				if (pack_file.pack_version > PACK_VERSION)
					continue;
				ENABLED_RESOURCE_PACKS.push(enabled_pack);
			}
		}

		#if sys
		enabled_resource_list = '';
		var i = 1;
		for (pack in ENABLED_RESOURCE_PACKS)
		{
			enabled_resource_list += pack;

			if (i < ENABLED_RESOURCE_PACKS.length)
				enabled_resource_list += '\n';
			i++;
			File.saveContent('resources/resource-list.txt', enabled_resource_list);
		}
		#end

		trace('Resource packs: ' + RESOURCE_PACKS);
		trace('Enabled resource packs: ' + ENABLED_RESOURCE_PACKS);
	}

	public static function getPath(path:String):String
	{
		#if sys
		for (pack in ENABLED_RESOURCE_PACKS)
		{
			if (FileSystem.exists('resources/' + pack + '/' + path))
				return 'resources/' + pack + '/' + path;
		}
		#end

		return 'assets/' + path;
	}

	public static function readDirectory(directory:String):Array<String>
	{
		var read_directory:Array<String> = [];

		#if sys
		for (path in FileSystem.readDirectory('assets/' + directory))
			read_directory.push('assets/' + path);
		for (pack in ENABLED_RESOURCE_PACKS)
			for (path in FileSystem.readDirectory('resources/' + pack + '/' + directory))
				read_directory.push('resources/' + pack + '/' + path);
		#end

		return read_directory;
	}
}

typedef ResourcePack =
{
	var name:String;
	var ?description:String;

	var pack_version:Null<Int>;
}
