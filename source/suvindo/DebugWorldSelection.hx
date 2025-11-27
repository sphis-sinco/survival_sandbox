package suvindo;

import suvindo.WorldInfo.WorldInfoClass;
import flixel.text.FlxInputText;
import haxe.io.Path;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

class DebugWorldSelection extends FlxState
{
	public var world_list:Array<String> = [];

	public var cur_selected:Int = 0;

	public static var saved_selected:Int = 0;

	public var world_texts:FlxTypedGroup<FlxText>;

	public var camFollow:FlxObject;

	public var world_name:FlxInputText;

	override function create()
	{
		super.create();
		world_list = [null];

		cur_selected = saved_selected;

		#if sys
		if (FileSystem.exists('assets/saves'))
		{
			// trace(FileSystem.readDirectory('assets/saves'));
			for (save in FileSystem.readDirectory('assets/saves'))
			{
				var world_json:Dynamic = null;

				try
				{
					#if sys
					world_json = Json.parse(File.getContent('assets/saves/' + save));
					#end
				}
				catch (e)
				{
					trace(e);
				}

				if (world_json != null)
					world_list.push(Path.withoutDirectory(Path.withoutExtension(save)));
			}
		}
		#end

		trace("world_list: ");
		for (world in world_list)
		{
			if (world != null)
				trace(' * ' + ((world.length > 32 + 3) ? world.substring(0, 32) + '...' : world));
		}

		if (cur_selected > world_list.length)
			cur_selected = 0;

		world_texts = new FlxTypedGroup<FlxText>();
		add(world_texts);

		camFollow = new FlxObject(FlxG.width / 2);
		add(camFollow);

		var i = 0;
		for (world_id in world_list)
		{
			var world_txt:FlxText = new FlxText(2, 2, FlxG.width / 2, world_id ?? "New world", 32);
			world_texts.add(world_txt);
			world_txt.ID = i;
			if (world_txt.ID == cur_selected)
				camFollow.y = world_txt.y;

			i++;
		}

		FlxG.camera.y = camFollow.y;

		world_name = FlxInputTextUtil.createInputText(null, "World Name");
		world_name.scrollFactor.set();
		add(world_name);

		FlxG.camera.follow(camFollow, LOCKON, .1);
		FlxG.mouse.visible = true;

		ReloadPlugin.reload.add(() ->
		{
			FlxG.resetState();
		});

		worldInfo = new FlxText(FlxG.width / 2, 2 + world_name.height + world_name.y, FlxG.width / 2, '', 32);
		add(worldInfo);
		worldInfo.alignment = RIGHT;
		worldInfo.scrollFactor.set();
	}

	public var worldInfo:FlxText;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		ReloadPlugin.canReload = !world_name.hasFocus;

		worldInfo.text = '';
		for (world_text in world_texts)
		{
			world_text.y = 2 + ((world_text.size * 4) * world_text.ID);
			world_text.color = (world_text.ID == cur_selected) ? FlxColor.YELLOW : FlxColor.WHITE;

			if (world_text.ID == cur_selected)
			{
				camFollow.y = world_text.y;
				if (world_list[cur_selected] != null)
				{
					try
					{
						var cur_world:WorldInfo = Json.parse(File.getContent('assets/saves/' + world_list[cur_selected] + '.json'));

						worldInfo.text = 'Name: '
							+ cur_world.world_name
							+ '\nRID: '
							+ cur_world.random_id
							+ '\n\nGame Version: '
							+ cur_world.game_version
							+ '\n\nGame Version Warning(s):\n'
							+ WorldInfoClass.getGameVersionWarnings(cur_world.game_version);
					}
					catch (e)
					{
						trace(e);
					}
				}
			}
		}

		if (ReloadPlugin.canReload)
		{
			if (FlxG.keys.anyJustReleased([W, UP]))
			{
				cur_selected--;
				if (cur_selected < 0)
					cur_selected = world_texts.length - 1;
			}
			if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				cur_selected++;
				if (cur_selected > world_texts.length - 1)
					cur_selected = 0;
			}

			if (FlxG.keys.justReleased.ENTER)
			{
				#if sys
				var count = 0;
				if (world_list[cur_selected] == null)
					while (FileSystem.exists('assets/saves/' + world_name.text + '.json'))
					{
						world_name.text = world_name.text.split('๑-')[0] + "๑-" + (count + 1);
						count++;
					}
				#end
				saved_selected = 0;
				FlxG.switchState(() -> new PlayState((world_list[cur_selected] == null) ? world_name.text : world_list[cur_selected]));
			}

			if (FlxG.keys.justReleased.DELETE)
			{
				if (world_list[cur_selected] != null)
				{
					saved_selected = cur_selected;
					#if sys
					saved_selected -= 1;
					FileSystem.deleteFile('assets/saves/' + world_list[cur_selected] + '.json');
					#end
					FlxG.resetState();
				}
			}
		}
	}
}
