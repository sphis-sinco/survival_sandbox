package;

import suvindo.BlockGrid;
import suvindo.TrackManager;
import suvindo.WorldInfo;
import suvindo.DebugWorldSelection;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.utils.Assets;
import haxe.Json;
import haxe.crypto.Sha256;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import suvindo.ResourcePackMenu;
import suvindo.ResourcePacks;
import suvindo.ReloadPlugin;
import flixel.text.FlxText;
import suvindo.BlockList;
import flixel.FlxG;
import suvindo.Block;
import flixel.FlxState;

using StringTools;

class PlayState extends FlxState
{
	public var blocks:BlockGrid;
	public var cursor_block:Block;
	public var watermark:FlxText;

	public static var world_info:WorldInfo;

	public var WORLD_NAME:String;

	public var autosave_timer:FlxTimer;

	override public function new(?world:String = null)
	{
		super();

		if (world == null && world_info != null)
			world = (world_info?.world_name ?? null) ?? ('world_' + world_info?.random_id ?? null) ?? null;

		if (world != null)
		{
			#if sys
			if (FileSystem.exists('assets/saves/' + world + '.json'))
			#else
			if (Assets.exists('assets/saves/' + world + '.json'))
			#end
			{
				blocks = new BlockGrid('assets/saves/' + world + '.json');
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
		cursor_block.alpha = .5;

		watermark = new FlxText(2, 2, 0, 'version', 8);
		add(watermark);

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
	}

	public function saveWorldInfo(save_file:Bool = true)
	{
		world_info = {
			cursor_block: null,
			blocks: [],
			has_animated_blocks: false,
			random_id: (world_info?.random_id ?? null) ?? Sha256.encode('' + FlxG.random.int(0, 255)),
			game_version: Application.current.meta.get('version') + #if debug ' [PROTOTYPE]' #else '' #end,
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

				if (block.block_json?.type == 'animated')
				{
					world_info.has_animated_blocks = true;
					block_data.frameIndex = block.animation.frameIndex;
				}
				if (block.block_json?.type == 'variations')
					block_data.variation_index = block.variation_index;

				world_info.blocks.push(block_data);

				if (block.graphic_path.contains('resources/'))
					if (!world_info.resource_packs.contains(block.graphic_path.split('/')[1]))
						world_info.resource_packs.push(block.graphic_path.split('/')[1]);
			}

		#if sys
		if (!FileSystem.exists('assets/saves'))
			FileSystem.createDirectory('assets/saves');

		if (save_file)
			File.saveContent('assets/saves/' + ((world_info?.world_name ?? null) ?? 'world_' + world_info.random_id) + '.json',
				Json.stringify(world_info, '\t'));
		#end
	}

	public function onReload()
	{
		saveWorldInfo();

		FlxTimer.wait(.5, () ->
		{
			trace('RELOAD!');
			FlxG.resetState();
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		watermark.text = 'Suvindo ' + lime.app.Application.current.meta.get('version') + #if debug ' [PROTOTYPE]' #else '' #end;
		watermark.text += '\n\nCurrent Block ID: ' + cursor_block.block_id;
		watermark.text += '\nCurrent Block Variation: '
			+ ((cursor_block.variations.length > 0) ? cursor_block.variations[cursor_block.variation_index]?.id : 'default');

		if (FlxG.keys.pressed.F3)
		{
			watermark.text += '\n\nResource packs:';
			if (ResourcePacks.RESOURCE_PACKS.length > 0)
				for (pack in ResourcePacks.RESOURCE_PACKS)
					watermark.text += '\n* ' + pack + ((ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack) ? ' (enabled)' : ' (disabled)'));
			else
				watermark.text += '\nNone';
			watermark.text += '\n\nTime until next autosave (seconds): ' + Std.int(autosave_timer.timeLeft);
		}

		cursor_block.visible = !FlxG.keys.pressed.F1;
		watermark.visible = !FlxG.keys.pressed.F1;

		if (FlxG.keys.justReleased.P && ResourcePacks.RESOURCE_PACKS.length > 0)
		{
			saveWorldInfo();
			FlxG.switchState(() -> new ResourcePackMenu(camera));
		}

		if (FlxG.keys.justReleased.ESCAPE)
		{
			saveWorldInfo();
			FlxTimer.wait(.1, () -> FlxG.switchState(() -> new DebugWorldSelection(camera)));
		}

		if (FlxG.keys.anyJustReleased([W, A, S, D, UP, LEFT, DOWN, RIGHT, ENTER, TAB, L]))
		{
			if (FlxG.keys.anyJustReleased([W, UP]))
				cursor_block.y -= cursor_block.height;
			if (FlxG.keys.anyJustReleased([A, LEFT]))
				cursor_block.x -= cursor_block.width;
			if (FlxG.keys.anyJustReleased([S, DOWN]))
				cursor_block.y += cursor_block.height;
			if (FlxG.keys.anyJustReleased([D, RIGHT]))
				cursor_block.x += cursor_block.width;

			if (cursor_block.x < 0)
				cursor_block.x = 0;
			if (cursor_block.x > FlxG.width - cursor_block.width)
				cursor_block.x = FlxG.width - cursor_block.width;

			if (cursor_block.y < 0)
				cursor_block.y = 0;
			if (cursor_block.y > FlxG.height - cursor_block.height / 2)
				cursor_block.y = FlxG.height - cursor_block.height / 2;

			var touching_kids:Bool = false; // thank god

			for (minor in blocks.members)
				if (cursor_block.overlaps(minor))
					touching_kids = true; // NOOOOOOOOOOOOOOOOOOO

			if (FlxG.keys.justReleased.ENTER)
			{
				if (!touching_kids)
				{
					var new_block = new Block(cursor_block.block_id, cursor_block.x, cursor_block.y);
					blocks.add(new_block);

					if (new_block?.block_json?.type == 'variations')
					{
						new_block.variation_index = cursor_block.variation_index;
						new_block.changeVariationIndex(0);
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
				if (cursor_block.block_json?.type == 'variations')
					cursor_block.changeVariationIndex((FlxG.keys.pressed.SHIFT) ? -1 : 1);
			}
		}
	}
}
