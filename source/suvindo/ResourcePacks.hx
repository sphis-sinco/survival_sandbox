package suvindo;

import lime.utils.Assets;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ResourcePacks
{
	public static var RESOURCE_PACKS:Array<String> = [];
	public static var ENABLED_RESOURCE_PACKS:Array<String> = [];

	public static var PACK_VERSION:Int = 3;
	public static var MIN_PACK_VERSION:Int = 1;

	public static function reload()
	{
		RESOURCE_PACKS = [];
		ENABLED_RESOURCE_PACKS = [];
		var enabled_resource_list:String = '';
		trace('RELOADING');

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
				catch (e)
				{
					trace(e);
				}
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
		#end
		#if sys
		enabled_resource_list = File.getContent('resources/resource-list.txt');
		#else
		enabled_resource_list = Assets.getText('resources/resource-list.txt');
		#end

		for (enabled_pack in enabled_resource_list.split('\n'))
		{
			if (enabled_pack.length > 0 && enabled_pack != null && enabled_pack != '')
			{
				#if sys
				var pack_file:ResourcePack = Json.parse(File.getContent('resources/' + enabled_pack + '/pack.json'));
				#else
				var pack_file:ResourcePack = Json.parse(Assets.getText('resources/' + enabled_pack + '/pack.json'));
				#end
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

		enabled_resource_list = '';
		var i = 1;
		for (pack in ENABLED_RESOURCE_PACKS)
		{
			enabled_resource_list += pack;

			if (i < ENABLED_RESOURCE_PACKS.length)
				enabled_resource_list += '\n';
			i++;
		}
		#if sys
		File.saveContent('resources/resource-list.txt', enabled_resource_list);
		#else
		trace('Enabled resource list:\n' + enabled_resource_list);
		#end

		trace('Resource packs: ' + RESOURCE_PACKS);
		trace('Enabled resource packs: ' + ENABLED_RESOURCE_PACKS);
	}

	public static function getPath(path:String):String
	{
		for (pack in ENABLED_RESOURCE_PACKS)
		{
			#if sys
			if (FileSystem.exists('resources/' + pack + '/' + path))
			#else
			if (Assets.exists('resources/' + pack + '/' + path))
			#end
			{
				return 'resources/' + pack + '/' + path;
				break;
			}
		}

		return 'assets/' + path;
	}

	public static function readDirectory(directory:String):Array<String>
	{
		var read_directory:Array<String> = [];

		#if sys
		if (FileSystem.exists('assets/' + directory))
			try
			{
				for (path in FileSystem.readDirectory('assets/' + directory))
					read_directory.push('assets/' + directory + path);
			}
			catch (e)
			{
				trace(e);
			}
		for (pack in ENABLED_RESOURCE_PACKS)
		{
			if (FileSystem.exists('resources/' + pack + '/' + directory))
				try
				{
					for (path in FileSystem.readDirectory('resources/' + pack + '/' + directory))
						read_directory.push('resources/' + pack + '/' + directory + '/' + path);
				}
				catch (e)
				{
					trace(e);
				}
		}
		#end

		return read_directory;
	}

	public static function getPackVersionWarning(pack_version:Null<Int>):String
	{
		var warning:String = '';

		var add_warning = function(msg:String)
		{
			warning += '- ' + msg + '\n';
		}

		if (pack_version < MIN_PACK_VERSION)
			add_warning('Below the minimum supported version number');

		if (warning == '')
			warning = 'None';

		return warning;
	}
}

typedef ResourcePack =
{
	var name:String;
	var ?description:String;

	var pack_version:Null<Int>;
}
