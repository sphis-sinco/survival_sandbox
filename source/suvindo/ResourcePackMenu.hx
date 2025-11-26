package suvindo;

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
			var pack_txt:FlxText = new FlxText(2, 2, 0, pack_id, 16);
			pack_txt.y += 20 * i;
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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (pack_text in pack_texts)
		{
			pack_text.ID = pack_list.indexOf(pack_text.text);
			pack_text.color = (pack_text.ID == cur_selected) ? FlxColor.YELLOW : FlxColor.WHITE;
			pack_text.alpha = (ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack_text.text)) ? 1 : 0.5;
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
		}

		if (FlxG.keys.justReleased.ESCAPE)
		{
			FlxG.switchState(() -> new PlayState());
		}
	}
}
