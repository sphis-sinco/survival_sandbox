package suvindo;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
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

class ResourcePackMenu extends FlxSubState
{
	public var packList:Array<String> = [];
	public var literalPackList:Array<ResourcePack> = [];
	public var curSelected:Int = 0;
	public var packTexts:FlxTypedGroup<FlxText>;
	public var camFollow:FlxObject;
  
	override public function new(cam:FlxCamera) {
        super();
        camera = cam;
    }

	override function create()
	{
		super.create();
        var bg = new FlxSprite(0, -(FlxG.height / 2)).makeGraphic(FlxG.width, FlxG.height * 3, 0xAA000000);
        add(bg);
		packList = ResourcePacks.RESOURCE_PACKS.copy();
		literalPackList = [];

		packTexts = new FlxTypedGroup<FlxText>();
		add(packTexts);

		var i = 0;
		for (pack_id in packList)
		{
			var pack_txt:FlxText = new FlxText(2, 2, 0, pack_id, 32);
			packTexts.add(pack_txt);

			#if sys
			var pack_file:ResourcePack = Json.parse(File.getContent('resources/' + pack_id + '/pack.json'));
			literalPackList.push(pack_file);
			#end

			i++;
		}

		ReloadPlugin.reload.add(() ->
		{
			FlxG.resetState();
		});

		camFollow = new FlxObject(FlxG.width / 2);
		add(camFollow);

		packInfo = new FlxText(FlxG.width / 2, 2, FlxG.width / 2, '', 16);
		add(packInfo);
		packInfo.alignment = RIGHT;
		packInfo.scrollFactor.set();

		camera.follow(camFollow, LOCKON, .1);
		FlxG.mouse.visible = false;
	}

	public var packInfo:FlxText;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (pack_text in packTexts)
		{
			pack_text.ID = packList.indexOf(pack_text.text);
			pack_text.y = 2 + ((pack_text.size * 4) * pack_text.ID);
			pack_text.color = (pack_text.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			pack_text.alpha = (ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack_text.text)) ? 1 : 0.5;

			if (pack_text.ID == curSelected)
				camFollow.y = pack_text.y;
		}

		if (literalPackList.length > 0)
		{
			var cur_pack = literalPackList[curSelected];

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
				movePack(curSelected, -1);
			}
			if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				movePack(curSelected, 1);
			}
		}

		if (FlxG.keys.anyJustReleased([W, UP]))
		{
			curSelected--;
			if (curSelected < 0)
				curSelected = packTexts.length - 1;
		}
		if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			curSelected++;
			if (curSelected > packTexts.length - 1)
				curSelected = 0;
		}

		if (FlxG.keys.justReleased.ENTER)
		{
			if (ResourcePacks.ENABLED_RESOURCE_PACKS.contains(packList[curSelected]))
				ResourcePacks.ENABLED_RESOURCE_PACKS.remove(packList[curSelected]);
			else
				ResourcePacks.ENABLED_RESOURCE_PACKS.insert(curSelected, packList[curSelected]);
			saveEnabledRP();
		}

		if (FlxG.keys.justReleased.ESCAPE)
		{
			saveEnabledRP();
            ReloadPlugin.fullReload();
            close();
		}
	}

	public function movePack(pack_index:Int, amount:Int)
	{
		var pack_string:String = packList[pack_index];
		var pack_json:ResourcePack = literalPackList[pack_index];

		if (pack_index + amount < 0)
		{
			pack_index = 0;
			amount = 0;
		}

		packList.remove(pack_string);
		literalPackList.remove(pack_json);

		packList.insert(pack_index + amount, pack_string);
		literalPackList.insert(pack_index + amount, pack_json);

		saveEnabledRP();
	}

	public function saveEnabledRP()
	{
		ResourcePacks.ENABLED_RESOURCE_PACKS.sort((s1, s2) ->
		{
			if (packList.indexOf(s1) == packList.indexOf(s2))
				return 0;

			return (packList.indexOf(s1) < packList.indexOf(s2)) ? -1 : 1;
		});
		ResourcePacks.RESOURCE_PACKS.sort((s1, s2) ->
		{
			if (packList.indexOf(s1) == packList.indexOf(s2))
				return 0;

			return (packList.indexOf(s1) < packList.indexOf(s2)) ? -1 : 1;
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
