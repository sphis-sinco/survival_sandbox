package;

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

	public static var world_info:
		{
			?cursor_block:{x:Float, y:Float, block_id:String},
			?blocks:Array<Block>
		};

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
					blocks.add(new Block(block.block_id, block.x, block.y));
				}
			}

			if (world_info.cursor_block != null)
			{
				cursor_block.setPosition(world_info.cursor_block.x, world_info.cursor_block.y);
				cursor_block.switchBlock(world_info.cursor_block.block_id);
			}

			world_info = null;
		}

		ReloadPlugin.reload.add(onReload);
	}

	public function saveWorldInfo()
	{
		world_info = {
			cursor_block: null,
			blocks: []
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
			}
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

					if (new_block.block_json.type == 'variations')
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
				if (cursor_block.block_json?.types.contains('variations'))
					cursor_block.changeVariationIndex((FlxG.keys.pressed.SHIFT) ? -1 : 1);
			}
		}
	}
}
