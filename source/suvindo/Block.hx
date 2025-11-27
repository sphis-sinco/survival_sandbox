package suvindo;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import funkin.graphics.shaders.HSVShader;
import flixel.FlxSprite;

class Block extends FlxSprite
{
	public var block_id:String;
	public var block_json:BlockJSON;

	public var variation_index:Int = 0;

	public var hsv_shader:HSVShader;

	override public function new(block_id:String, ?X:Float, ?Y:Float)
	{
		super(X, Y);

		switchBlock(block_id);

		hsv_shader = new HSVShader();
		this.shader = hsv_shader;
	}

	public function switchBlock(new_block:String)
	{
		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/blocks/' + new_block + '.png'))));
		#else
		loadGraphic(ResourcePacks.getPath('images/blocks/' + new_block + '.png'));
		#end
		variation_index = 0;

		block_json = null;
		if (#if !sys Assets.exists #else FileSystem.exists #end (ResourcePacks.getPath('images/blocks/' + new_block + '.json')))
		{
			#if sys
			block_json = cast File.getContent(ResourcePacks.getPath('images/blocks/' + new_block + '.json'));
			#else
			block_json = cast Assets.getText(ResourcePacks.getPath('images/blocks/' + new_block + '.json'));
			#end
			if (block_json != null)
			{
				if (block_json.type != null) {}
			}
		}

		if (this.graphic != null)
			this.scale.set(1 * (16 / this.graphic.width), 1 * (16 / this.graphic.height));
		this.updateHitbox();

		this.block_id = new_block;
	}
}
