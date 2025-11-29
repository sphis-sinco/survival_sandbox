package suvindo.frontend.states;

import flixel.input.keyboard.FlxKey;
import suvindo.backend.blocks.BlockGrid;
import suvindo.backend.TrackManager;
import suvindo.backend.WorldInfo;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.utils.Assets;
import haxe.Json;
import haxe.crypto.Sha256;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import suvindo.frontend.states.ResourcePackMenu;
import suvindo.backend.resourcepacks.ResourcePacks;
import suvindo.backend.ReloadPlugin;
import flixel.text.FlxText;
import suvindo.backend.blocks.BlockList;
import flixel.FlxG;
import suvindo.backend.blocks.Block;
import flixel.FlxState;

using StringTools;

class PlayState extends FlxState
{
	public var blocks:BlockGrid;
	public var cursor_block:Block;
	public var debug_text:FlxText;

	public static var world_info:WorldInfo;

	public var WORLD_NAME:String;

	public var autosave_timer:FlxTimer;

	override public function new(?world:String = null)
	{
		super();

		if (world == null && world_info != null)
			world = (world_info?.world_name ?? null) ?? ("world_" + world_info?.random_id ?? null) ?? null;

		if (world != null)
		{
			#if sys
			if (FileSystem.exists("assets/saves/" + world + ".json"))
			#else
			if (Assets.exists("assets/saves/" + world + ".json"))
			#end
			{
				blocks = new BlockGrid("assets/saves/" + world + ".json");
				world_info = blocks.world_info;

				WORLD_NAME = world_info.world_name;
			}
		else
		{
			WORLD_NAME = world;
			saveWorldInfo();
		}
		}
		else
		{
			blocks = new BlockGrid(null);
		}
		autosave_timer = new FlxTimer().start(60 * 1, t ->
		{
			saveWorldInfo(true);
		}, 0);
		trace("World name: " + WORLD_NAME);
	}

	override public function create()
	{
		super.create();

		add(blocks);

		cursor_block = new Block(BlockList.BLOCK_LIST[0]);
		add(cursor_block);
		cursor_block.hsv_shader.saturation = 2;
		cursor_block.x = 16 * ((FlxG.width / 16) / 2);
		cursor_block.y = 16 * ((FlxG.height / 16) / 2);

		debug_text = new FlxText(2, 2, 0, "version", 8);
		add(debug_text);

		if (world_info != null)
		{
			if (world_info.cursor_block != null)
			{
				cursor_block.setPosition(world_info.cursor_block.x ?? cursor_block.x, world_info.cursor_block.y ?? cursor_block.y);
				cursor_block.switchBlock(world_info.cursor_block.block_id ?? cursor_block.block_id);
			}

			world_info = null;
		}

		ReloadPlugin.reload.add(onReload);

		FlxG.mouse.visible = false;

		TrackManager.playTrack();

		directional_timer = new FlxTimer();
	}

	public function saveWorldInfo(save_file:Bool = true)
	{
		world_info = {
			cursor_block: null,
			blocks: [],
			random_id: (world_info?.random_id ?? null) ?? Sha256.encode("" + FlxG.random.int(0, 255)),
			game_version: Application.current.meta.get("version") + #if debug " [PROTOTYPE]" #else "" #end,
			world_name: WORLD_NAME ?? ((world_info?.world_name ?? null) ?? null),
			resource_packs: []
		};
		if (cursor_block != null)
			world_info.cursor_block = {
				x: cursor_block.x,
				y: cursor_block.y,
				block_id: cursor_block.block_id,
			}
		if (blocks?.members != null)
			for (block in blocks.members)
			{
				var block_data:Dynamic = {
					block_id: block.block_id,
					x: block.x,
					y: block.y,
				};

				if (block.block_json?.type == "variations")
					block_data.variation_index = block.variation_index;

				world_info.blocks.push(block_data);

				if (block.graphic_path.contains("resources/"))
					if (!world_info.resource_packs.contains(block.graphic_path.split("/")[1]))
						world_info.resource_packs.push(block.graphic_path.split("/")[1]);
			}

		#if sys
		if (!FileSystem.exists("assets/saves"))
			FileSystem.createDirectory("assets/saves");
		#end

		if (save_file)
			BlockGrid.saveWorldInfo(world_info, "assets/saves/" + ((world_info?.world_name ?? null) ?? "world_" + world_info.random_id) + ".json");
	}

	public function onReload()
	{
		saveWorldInfo();

		trace("RELOAD!");
		FlxG.resetState();
	}

	var place_mode:Bool = true;

	public var directional_timer:FlxTimer;
	public var can_hold_directionals:Bool = false;

	var controls:Array<FlxKey> = [W, A, S, D, UP, LEFT, DOWN, RIGHT, ENTER, TAB, L, SHIFT];

	var tick:Int = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		tick++;

		if (place_mode)
			cursor_block.alpha = .75;
		else
			cursor_block.alpha = .25;

		debug_text.text = "";
		if (FlxG.keys.pressed.F3)
		{
			debug_text.text += "Current Block ID: " + cursor_block.block_id;
			debug_text.text += "\nCurrent Block Variation: "
				+ ((cursor_block.variations.length > 0) ? cursor_block.variations[cursor_block.variation_index]?.id : "default");

			debug_text.text += "\n\nResource packs:";
			if (ResourcePacks.RESOURCE_PACKS.length > 0)
				for (pack in ResourcePacks.RESOURCE_PACKS)
					debug_text.text += "\n* " + pack + ((ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack) ? " (enabled)" : " (disabled)"));
			else
				debug_text.text += "\nNone";
			debug_text.text += "\n\nTime until next autosave (seconds): " + Std.int(autosave_timer.timeLeft);
			debug_text.text += "\n\nTick: " + tick;
		}

		cursor_block.visible = !FlxG.keys.pressed.F1;
		debug_text.visible = !FlxG.keys.pressed.F1;

		if (FlxG.keys.justReleased.ESCAPE)
		{
			saveWorldInfo();

			FlxG.switchState(() -> new MainMenu());
		}

		if (FlxG.keys.anyPressed(controls) || FlxG.keys.anyJustReleased(controls))
		{
			if (!can_hold_directionals)
			{
				if (FlxG.keys.anyJustReleased([W, UP]))
					cursor_block.y -= cursor_block.height;
				if (FlxG.keys.anyJustReleased([A, LEFT]))
					cursor_block.x -= cursor_block.width;
				if (FlxG.keys.anyJustReleased([S, DOWN]))
					cursor_block.y += cursor_block.height;
				if (FlxG.keys.anyJustReleased([D, RIGHT]))
					cursor_block.x += cursor_block.width;
				if (FlxG.keys.anyJustPressed([W, A, S, D, UP, LEFT, DOWN, RIGHT]))
				{
					directional_timer.start(.2, t ->
					{
						if (FlxG.keys.anyPressed([W, A, S, D, UP, LEFT, DOWN, RIGHT]))
							can_hold_directionals = true;
					});
				}
			}
			else
			{
				if (FlxG.keys.anyPressed([W, A, S, D, UP, LEFT, DOWN, RIGHT]))
					directional_timer.start(.5, t ->
					{
						can_hold_directionals = false;
					});

				if (tick % 4 == 0)
				{
					if (FlxG.keys.anyPressed([W, UP]))
						cursor_block.y -= cursor_block.height;
					if (FlxG.keys.anyPressed([A, LEFT]))
						cursor_block.x -= cursor_block.width;
					if (FlxG.keys.anyPressed([S, DOWN]))
						cursor_block.y += cursor_block.height;
					if (FlxG.keys.anyPressed([D, RIGHT]))
						cursor_block.x += cursor_block.width;
				}
			}

			if (cursor_block.x < 0)
				cursor_block.x = 0;
			if (cursor_block.x > FlxG.width - cursor_block.width)
				cursor_block.x = FlxG.width - cursor_block.width;

			if (cursor_block.y < 0)
				cursor_block.y = 0;
			if (cursor_block.y > FlxG.height - cursor_block.height)
				cursor_block.y = FlxG.height - cursor_block.height;

			if (FlxG.keys.pressed.ENTER && !FlxG.keys.pressed.SHIFT)
			{
				if (place_mode)
				{
					var can_place = true;
					for (minor in blocks.members)
						if (cursor_block.overlaps(minor))
							can_place = false;

					if (can_place)
					{
						var new_block = new Block(cursor_block.block_id, cursor_block.x, cursor_block.y);
						blocks.add(new_block);

						if (new_block?.block_json?.type == "variations")
						{
							new_block.variation_index = cursor_block.variation_index;
							new_block.changeVariationIndex(0);
						}
					}
				}
				else
				{
					for (minor in blocks.members)
						if (cursor_block.overlaps(minor))
						{
							blocks.members.remove(minor);
							minor.destroy();
						}
				}
			}
			else if (FlxG.keys.justReleased.ENTER && FlxG.keys.pressed.SHIFT)
			{
				place_mode = !place_mode;
			}

			if (FlxG.keys.justReleased.TAB)
			{
				var index:Int = BlockList.BLOCK_LIST.indexOf(cursor_block.block_id);

				if (FlxG.keys.pressed.SHIFT)
					index--;
				else
					index++;

				if (index < 0)
					index = BlockList.BLOCK_LIST.length - 1;
				if (index > BlockList.BLOCK_LIST.length - 1)
					index = 0;

				cursor_block.switchBlock(BlockList.BLOCK_LIST[index]);
			}

			if (FlxG.keys.justReleased.L)
			{
				if (cursor_block.block_json?.type == "variations")
					cursor_block.changeVariationIndex((FlxG.keys.pressed.SHIFT) ? -1 : 1);
			}
		}
	}
}
