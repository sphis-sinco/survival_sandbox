package survival_sandbox;

import flixel.FlxSprite;

class Block extends FlxSprite
{
	public var block_id:String;

	override public function new(block_id:String, ?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadGraphic('assets/images/blocks/' + block_id + '.png');

        this.block_id = block_id;
	}
}
