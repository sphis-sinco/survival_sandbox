package;

import flixel.FlxG;
import suvindo.Block;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

class PlayState extends FlxState
{
	public var blocks:FlxTypedGroup<Block>;

	public var cursor_block:Block;

	override public function create()
	{
		super.create();

		blocks = new FlxTypedGroup<Block>();
		add(blocks);

		cursor_block = new Block('plank');
		add(cursor_block);
		cursor_block.hsv_shader.saturation = 2;
		cursor_block.x = 16 * ((FlxG.width / 16) / 2);
		cursor_block.y = 16 * ((FlxG.height / 16) / 2);
		cursor_block.alpha = .5;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustReleased([W, A, S, D, UP, LEFT, DOWN, RIGHT, ENTER, DELETE]))
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

			if (FlxG.keys.justReleased.ENTER && !touching_kids)
			{
				var new_block = new Block(cursor_block.block_id, cursor_block.x, cursor_block.y);
				blocks.add(new_block);
			}

			if (FlxG.keys.justReleased.DELETE && touching_kids)
			{
				for (minor in blocks.members)
					if (cursor_block.overlaps(minor))
					{
						blocks.members.remove(minor);
						minor.destroy();
					}
			}
		}
	}
}
