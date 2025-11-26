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
		cursor_block.alpha = .5;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		cursor_block.setPosition((FlxG.mouse.x / 16), (FlxG.mouse.y / 16));
	}
}
