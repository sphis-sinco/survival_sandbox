package suvindo;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
#end
import haxe.Json;
import suvindo.ResourcePacks.ResourcePack;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

class ResourcePackMenu extends FlxState
{
	public var pack_list:Array<String> = [];
	public var literal_pack_list:Array<ResourcePack> = [];

	public var cur_selected:Int = 0;

	public var pack_texts:FlxTypedGroup<FlxText>;

	public var camFollow:FlxObject;

	override function create()
	{
		super.create();
		pack_list = ResourcePacks.RESOURCE_PACKS.copy();
		literal_pack_list = [];

		pack_texts = new FlxTypedGroup<FlxText>();
		add(pack_texts);

		var i = 0;
		for (pack_id in pack_list)
		{
			var pack_txt:FlxText = new FlxText(2, 2, 0, pack_id, 32);
			pack_texts.add(pack_txt);

			#if sys
			var pack_file:ResourcePack = Json.parse(File.getContent('resources/' + pack_id + '/pack.json'));
			literal_pack_list.push(pack_file);
			#end

			i++;
		}

		ReloadPlugin.reload.add(() ->
		{
			FlxG.resetState();
		});

		camFollow = new FlxObject(FlxG.width / 2);
		add(camFollow);

		packInfo = new FlxText(FlxG.width / 2, 2, FlxG.width / 2, '', 32);
		add(packInfo);
		packInfo.alignment = RIGHT;
		packInfo.scrollFactor.set();

		FlxG.camera.follow(camFollow, LOCKON, .1);
		FlxG.mouse.visible = false;
	}

	public var packInfo:FlxText;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (pack_text in pack_texts)
		{
			pack_text.ID = pack_list.indexOf(pack_text.text);
			pack_text.y = 2 + ((pack_text.size * 4) * pack_text.ID);
			pack_text.color = (pack_text.ID == cur_selected) ? FlxColor.YELLOW : FlxColor.WHITE;
			pack_text.alpha = (ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack_text.text)) ? 1 : 0.5;

			if (pack_text.ID == cur_selected)
				camFollow.y = pack_text.y;
		}

		if (literal_pack_list.length > 0)
		{
			var cur_pack = literal_pack_list[cur_selected];

			packInfo.text = 'Name: ' + cur_pack.name + '\nDescription: ' + cur_pack.description + '\n\nPack Version: ' + cur_pack.pack_version
				+ '\n\nPack Version Warning(s):\n' + ResourcePacks.getPackVersionWarning(cur_pack.pack_version);
		}
		else
		{
			packInfo.text = 'N/A';
		}

		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.anyJustReleased([W, UP]))
			{
				movePack(cur_selected, -1);
			}
			if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				movePack(cur_selected, 1);
			}
		}

		if (FlxG.keys.anyJustReleased([W, UP]))
		{
			cur_selected--;
			if (cur_selected < 0)
				cur_selected++;
		}
		if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			cur_selected++;
			if (cur_selected > pack_texts.length - 1)
				cur_selected--;
		}

		if (FlxG.keys.justReleased.ENTER)
		{
			if (ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack_list[cur_selected]))
				ResourcePacks.ENABLED_RESOURCE_PACKS.remove(pack_list[cur_selected]);
			else
				ResourcePacks.ENABLED_RESOURCE_PACKS.insert(cur_selected, pack_list[cur_selected]);
			saveEnabledRP();
		}

		if (FlxG.keys.justReleased.ESCAPE)
		{
			saveEnabledRP();

			trace('Left resource pack menu');
			trace('Resource packs: ' + ResourcePacks.RESOURCE_PACKS);
			trace('Enabled resource packs: ' + ResourcePacks.ENABLED_RESOURCE_PACKS);

			FlxG.switchState(() -> new PlayState());
		}
	}

	public function movePack(pack_index:Int, amount:Int)
	{
		var pack_string:String = pack_list[pack_index];
		var pack_json:ResourcePack = literal_pack_list[pack_index];

		if (pack_index + amount < 0)
		{
			pack_index = 0;
			amount = 0;
		}

		pack_list.remove(pack_string);
		literal_pack_list.remove(pack_json);

		pack_list.insert(pack_index + amount, pack_string);
		literal_pack_list.insert(pack_index + amount, pack_json);

		saveEnabledRP();
	}

	public function saveEnabledRP()
	{
		ResourcePacks.ENABLED_RESOURCE_PACKS.sort((s1, s2) ->
		{
			if (pack_list.indexOf(s1) == pack_list.indexOf(s2))
				return 0;

			return (pack_list.indexOf(s1) < pack_list.indexOf(s2)) ? -1 : 1;
		});
		ResourcePacks.RESOURCE_PACKS.sort((s1, s2) ->
		{
			if (pack_list.indexOf(s1) == pack_list.indexOf(s2))
				return 0;

			return (pack_list.indexOf(s1) < pack_list.indexOf(s2)) ? -1 : 1;
		});

		var enabled_resource_list = '';
		var i = 1;
		for (pack in ResourcePacks.ENABLED_RESOURCE_PACKS)
		{
			enabled_resource_list += pack;

			if (i < ResourcePacks.ENABLED_RESOURCE_PACKS.length)
				enabled_resource_list += '\n';
			i++;
		}
		#if sys
		File.saveContent('resources/resource-list.txt', enabled_resource_list);
		#end
	}
}
