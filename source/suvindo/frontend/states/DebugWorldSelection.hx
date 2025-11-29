package suvindo.frontend.states;

import suvindo.backend.WorldInfo;
import suvindo.backend.FlxInputTextUtil;
import suvindo.backend.resourcepacks.ResourcePacks;
import flixel.FlxSprite;
import flixel.FlxCamera;
import suvindo.backend.ReloadPlugin;
import flixel.FlxSubState;
import suvindo.backend.WorldInfo.WorldInfoClass;
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

class DebugWorldSelection extends FlxSubState
{
	public var worldList:Array<String> = [];
	public var curSelected:Int = 0;

	public static var saved_selected:Int = 0;

	public var worldTexts:FlxTypedGroup<FlxText>;
	public var camFollow:FlxObject;
	public var worldName:FlxInputText;

	override public function new(cam:FlxCamera)
	{
		super();
		camera = cam;
	}

	override function create()
	{
		super.create();
		var bg = new FlxSprite(0, -(FlxG.height / 2)).makeGraphic(FlxG.width, FlxG.height * 3, 0xAA000000);
		add(bg);
		bg.scrollFactor.set();
		worldList = [null];

		curSelected = saved_selected;

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
					worldList.push(Path.withoutDirectory(Path.withoutExtension(save)));
			}
		}
		#end

		trace("worldList: ");
		for (world in worldList)
		{
			if (world != null)
				trace(' * ' + ((world.length > 32 + 3) ? world.substring(0, 32) + '...' : world));
		}

		if (curSelected > worldList.length)
			curSelected = 0;

		worldTexts = new FlxTypedGroup<FlxText>();
		add(worldTexts);

		camFollow = new FlxObject(FlxG.width / 2);
		add(camFollow);

		var i = 0;
		for (world_id in worldList)
		{
			var world_txt:FlxText = new FlxText(2, 2, FlxG.width / 2, world_id ?? "New world", 32);
			world_txt.font = ResourcePacks.getPath('fonts/ui_font.ttf');
			world_txt.antialiasing = true;
			worldTexts.add(world_txt);
			world_txt.ID = i;
			if (world_txt.ID == curSelected)
				camFollow.y = world_txt.y;

			i++;
		}

		camera.y = camFollow.y;

		worldName = FlxInputTextUtil.createInputText(null, "World Name");
		worldName.font = ResourcePacks.getPath('fonts/ui_font.ttf');
		worldName.scrollFactor.set();
		add(worldName);

		camera.follow(camFollow, LOCKON, .1);
		FlxG.mouse.visible = true;

		ReloadPlugin.reload.add(() ->
		{
			FlxG.resetState();
		});

		worldInfo = new FlxText(FlxG.width / 2, 2 + worldName.height + worldName.y, FlxG.width / 2, '', 16);
		add(worldInfo);
		worldInfo.alignment = RIGHT;
		worldInfo.scrollFactor.set();
	}

	public var worldInfo:FlxText;
	public var fCnt:Int = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (fCnt != 2)
		{
			fCnt++;
			return;
		}
		ReloadPlugin.canReload = !worldName.hasFocus;

		worldInfo.text = '';
		for (world_text in worldTexts)
		{
			world_text.y = 2 + ((world_text.size * 4) * world_text.ID);
			world_text.color = (world_text.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;

			if (world_text.ID == curSelected)
			{
				camFollow.y = world_text.y;
				if (worldList[curSelected] != null)
				{
					try
					{
						var cur_world:WorldInfo = Json.parse(File.getContent('assets/saves/' + worldList[curSelected] + '.json'));

						worldInfo.text = 'Name: ' + cur_world.world_name + '\nRID: ' + cur_world.random_id + '\n\nGame Version: ' + cur_world.game_version
							+ '\n\nWorld warning(s):\n' + WorldInfoClass.getWorldWarnings(cur_world);
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
				curSelected--;
				if (curSelected < 0)
					curSelected = worldTexts.length - 1;
			}
			if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				curSelected++;
				if (curSelected > worldTexts.length - 1)
					curSelected = 0;
			}

			if (FlxG.keys.justReleased.ENTER)
			{
				#if sys
				var count = 0;
				if (worldList[curSelected] == null)
					while (FileSystem.exists('assets/saves/' + worldName.text + '.json'))
					{
						worldName.text = worldName.text.split('๑-')[0] + "๑-" + (count + 1);
						count++;
					}
				#end
				saved_selected = 0;
				FlxG.switchState(() -> new PlayState((worldList[curSelected] == null) ? worldName.text : worldList[curSelected]));
			}

			if (FlxG.keys.justReleased.DELETE)
			{
				if (worldList[curSelected] != null)
				{
					saved_selected = curSelected;
					#if sys
					saved_selected -= 1;
					FileSystem.deleteFile('assets/saves/' + worldList[curSelected] + '.json');
					#end
					FlxG.resetState();
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
	}
}
