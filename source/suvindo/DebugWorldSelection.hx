package suvindo;

import sys.FileSystem;
import flixel.text.FlxInputText;
import haxe.io.Path;
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

class DebugWorldSelection extends FlxState
{
	public var world_list:Array<String> = [];

	public var cur_selected:Int = 0;

	public var world_texts:FlxTypedGroup<FlxText>;

	public var camFollow:FlxObject;

	public var world_name:FlxInputText;

	override function create()
	{
		super.create();
		world_list = [null];

		for (save in ResourcePacks.readDirectory('saves/'))
		{
			var world_json:Dynamic = null;

			try
			{
				#if sys
				world_json = Json.parse(File.getContent(save));
				#end
			}
			catch (e) {}

			if (world_json != null)
			{
				world_list.push(Path.withoutDirectory(Path.withoutExtension(save)));
			}
		}

		trace("world_list: " + world_list);

		world_texts = new FlxTypedGroup<FlxText>();
		add(world_texts);

		var i = 0;
		for (world_id in world_list)
		{
			var world_txt:FlxText = new FlxText(2, 2, FlxG.width / 2, world_id ?? "New world", 32);
			world_texts.add(world_txt);
			world_txt.ID = i;

			i++;
		}

		camFollow = new FlxObject(FlxG.width / 2);
		add(camFollow);

		world_name = FlxInputTextUtil.createInputText(null, "World Name");
		world_name.scrollFactor.set();
		add(world_name);

		FlxG.camera.follow(camFollow, LOCKON, .1);
		FlxG.mouse.visible = true;

		ReloadPlugin.reload.add(() ->
		{
			FlxG.resetState();
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		ReloadPlugin.canReload = !world_name.hasFocus;

		for (world_text in world_texts)
		{
			world_text.y = 2 + ((world_text.size * 4) * world_text.ID);
			world_text.color = (world_text.ID == cur_selected) ? FlxColor.YELLOW : FlxColor.WHITE;

			if (world_text.ID == cur_selected)
				camFollow.y = world_text.y;
		}
		if (ReloadPlugin.canReload)
		{
			if (FlxG.keys.anyJustReleased([W, UP]))
			{
				cur_selected--;
				if (cur_selected < 0)
					cur_selected++;
			}
			if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				cur_selected++;
				if (cur_selected > world_texts.length - 1)
					cur_selected--;
			}

			if (FlxG.keys.justReleased.ENTER)
			{
				#if sys
				while (FileSystem.exists('assets/saves/' + world_name.text + '.json'))
					world_name.text += '๑_';
				#end
				FlxG.switchState(() -> new PlayState(world_list[cur_selected] ?? world_name.text));
			}
		}
	}
}
