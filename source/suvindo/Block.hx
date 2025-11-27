package suvindo;

import suvindo.BlockJSON.BlockVariation;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.Json;
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
	public var variations:Array<BlockVariation> = [];

	public var hsv_shader:HSVShader;

	override public function new(block_id:String, ?X:Float, ?Y:Float)
	{
		super(X, Y);

		switchBlock(block_id);

		hsv_shader = new HSVShader();
		this.shader = hsv_shader;
	}

	public function defaultLoadGraphic(new_block:String)
	{
		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/blocks/' + new_block + '.png'))));
		#else
		loadGraphic(ResourcePacks.getPath('images/blocks/' + new_block + '.png'));
		#end
	}

	public function changeVariationIndex(amount:Int)
	{
		variation_index += amount;

		if (variation_index < 0)
			variation_index = variations.length - 1;
		if (variation_index > variations.length - 1)
			variation_index = 0;

		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/' + variations[variation_index].texture + '.png'))));
		#else
		loadGraphic(ResourcePacks.getPath('images/' + variations[variation_index].texture + '.png'));
		#end

		if (this.graphic == null)
			loadGraphic('assets/images/debug.png');
	}

	public function switchBlock(new_block:String)
	{
		variation_index = 0;
		variations = [];

		block_json = null;
		if (#if !sys Assets.exists #else FileSystem.exists #end (ResourcePacks.getPath('images/blocks/' + new_block + '.json')))
		{
			#if sys
			block_json = cast Json.parse(File.getContent(ResourcePacks.getPath('images/blocks/' + new_block + '.json')));
			#else
			block_json = cast Json.parse(Assets.getText(ResourcePacks.getPath('images/blocks/' + new_block + '.json')));
			#end
			if (block_json != null && block_json.type != null)
			{
				block_json.type = block_json.type.toLowerCase();
				switch (block_json.type)
				{
					case 'variations':
						for (variation in block_json.variations)
							variations.push(variation);

						changeVariationIndex(0);
					case 'animated':
						loadGraphic(#if sys FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/blocks/' + new_block +
							'.png'))) #else ResourcePacks.getPath('images/blocks/'
							+ new_block + '.png') #end,
							true, block_json.animated.block_width, block_json.animated.block_height);

						var getFrames = function():Array<Int>
						{
							var frames = [];
							var i = 0;
							while (i < this.animation.numFrames)
							{
								frames.push(i);
								i++;
							}

							return frames;
						};

						animation.add('animation', block_json.animated?.frames ?? getFrames(), block_json.animated?.fps ?? 24);
						animation.play('animation');

					case 'regular':
						defaultLoadGraphic(block_json?.regular?.texture ?? new_block);

					default:
						defaultLoadGraphic(new_block);
				}
			}
			else
				defaultLoadGraphic(new_block);
		}
		else
			defaultLoadGraphic(new_block);

		if (this.graphic == null)
			loadGraphic('assets/images/debug.png');

		this.scale.set(1, 1);
		if (this.graphic != null)
			if (block_json?.type == 'animated')
				this.scale.set(1 * (16 / this.block_json.animated.block_width), 1 * (16 / this.block_json.animated.block_height));
			else
				this.scale.set(1 * (16 / this.graphic.width), 1 * (16 / this.graphic.height));
		this.updateHitbox();

		this.block_id = new_block;
	}
}
