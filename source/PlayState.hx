package;

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

		watermark = new FlxText(2, 2, 0, "Suvindo " + lime.app.Application.current.meta.get('version'), 8);
		add(watermark);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if sys
		if (FlxG.keys.justReleased.R)
		{
			BlockList.reload();
			cursor_block.switchBlock(BlockList.BLOCK_LIST[0]);
		}
		#end

		if (FlxG.keys.anyJustReleased([W, A, S, D, UP, LEFT, DOWN, RIGHT, ENTER, TAB]))
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
		}
	}
}
