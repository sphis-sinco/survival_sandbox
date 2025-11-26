package;

import suvindo.Block;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

class PlayState extends FlxState
{
	public var blocks:FlxTypedGroup<Block>;

	override public function create()
	{
		super.create();

		blocks = new FlxTypedGroup<Block>();
		add(blocks);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
