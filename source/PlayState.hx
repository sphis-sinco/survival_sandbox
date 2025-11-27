package;

import lime.utils.Assets;
import haxe.Json;
import haxe.crypto.Sha256;
import sys.io.File;
#if sys
import sys.FileSystem;
#end
import suvindo.ResourcePackMenu;
import suvindo.ResourcePacks;
import suvindo.ReloadPlugin;
import flixel.text.FlxText;
import suvindo.BlockList;
import flixel.FlxG;
import suvindo.Block;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

class PlayState extends FlxState
{
	public var blocks:FlxTypedGroup<Block>;
	public var cursor_block:Block;
	public var watermark:FlxText;

	public #if !sys static #end var world_info:
		{
			?cursor_block:{x:Float, y:Float, block_id:String},
			?blocks:Array<Block>,
			?has_animated_blocks:Bool,
			?animated_block_universal_frames:Dynamic,
			random_id:String,
			// world_name:String,
		};

	override public function new(?world:String = null)
	{
		super();

		if (world != null)
		{
			#if sys
			world_info = Json.parse(File.getContent('assets/saves/' + world + '.json'));
			#else
			world_info = Json.parse(Assets.getText('assets/saves/' + world + '.json'));
			#end
		}
	}

	override public function create()
	{
		super.create();

		blocks = new FlxTypedGroup<Block>();
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
			if (world_info.blocks != null)
			{
				for (block in world_info.blocks)
				{
					var old_block = new Block(block.block_id, block.x, block.y);
					if (world_info.has_animated_blocks)
					{
						if (Reflect.fields(world_info.animated_block_universal_frames).contains(old_block.block_id))
							old_block.animation.frameIndex = Reflect.field(world_info.animated_block_universal_frames, old_block.block_id);
					}
					blocks.add(old_block);
				}
			}

			if (world_info.cursor_block != null)
			{
				cursor_block.setPosition(world_info.cursor_block.x ?? cursor_block.x, world_info.cursor_block.y ?? cursor_block.y);
				cursor_block.switchBlock(world_info.cursor_block.block_id ?? cursor_block.block_id);
			}

			world_info = null;
		}

		ReloadPlugin.reload.add(onReload);
	}

	public function saveWorldInfo()
	{
		world_info = {
			cursor_block: null,
			blocks: [],
			has_animated_blocks: false,
			animated_block_universal_frames: {},
			random_id: world_info.random_id ?? Sha256.encode('' + FlxG.random.int(0, 255)),
			// world_name: world_info.world_name ?? null
		};
		world_info.cursor_block = {
			x: cursor_block.x,
			y: cursor_block.y,
			block_id: cursor_block.block_id,
		}
		if (blocks.members != null)
			for (block in blocks.members)
			{
				world_info.blocks.push(block);

				if (block.block_json?.type == "animated" && !Reflect.hasField(world_info.animated_block_universal_frames, block.block_id))
				{
					world_info.has_animated_blocks = true;
					Reflect.setField(world_info.animated_block_universal_frames, block.block_id,
						block.animation.frameIndex +
						((FlxG.random.bool((block.animation.frameIndex / block.animation.numFrames) * 100)) ? ((block.animation.frameIndex / block.animation.numFrames == 1) ? block.animation.curAnim.frames[0]
							- block.animation.frameIndex : 1) : 0));
				}
			}

		#if sys
		if (!FileSystem.exists('assets/saves'))
			FileSystem.createDirectory('assets/saves');

		File.saveContent('assets/saves/world_' + world_info.random_id + '.json', Json.stringify(world_info, "\t"));
		#end
	}

	public function onReload()
	{
		saveWorldInfo();

		trace('RELOAD!');
		FlxG.resetState();
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
		}

		if (FlxG.keys.justReleased.P && ResourcePacks.RESOURCE_PACKS.length > 0)
		{
			saveWorldInfo();
			FlxG.switchState(() -> new ResourcePackMenu());
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
			if (cursor_block.y > FlxG.height - cursor_block.height)
				cursor_block.y = FlxG.height - cursor_block.height;

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

					if (new_block?.block_json?.type == "variations")
					{
						new_block.variation_index = cursor_block.variation_index;
						new_block.changeVariationIndex(0);
					}

					if (new_block?.block_json?.type == "animated")
					{
						onReload();
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
				if (cursor_block.block_json?.type == "variations")
					cursor_block.changeVariationIndex((FlxG.keys.pressed.SHIFT) ? -1 : 1);
			}
		}
	}
}
