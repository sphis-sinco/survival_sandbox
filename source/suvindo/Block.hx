package suvindo;

import flixel.FlxSprite;

class Block extends FlxSprite
{
	public var block_id:String;

	override public function new(block_id:String, ?X:Float, ?Y:Float)
	{
		super(X, Y);

		switchBlock(block_id);
	}

	public function switchBlock(new_block:String)
	{
		loadGraphic('assets/images/blocks/' + new_block + '.png');

		this.block_id = new_block;
	}
}
