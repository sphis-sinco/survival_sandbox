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
	public var variation_graphics:Array<BlockVariation> = [];

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
			variation_index = variation_graphics.length - 1;
		if (variation_index > variation_graphics.length - 1)
			variation_index = 0;

		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/' + variation_graphics[variation_index].texture + '.png'))));
		#else
		loadGraphic(ResourcePacks.getPath('images/' + variation_graphics[variation_index].texture + '.png'));
		#end
	}

	public function switchBlock(new_block:String)
	{
		variation_index = 0;
		variation_graphics = [];

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
						{
							#if sys
							var variation_graphic:FlxGraphicAsset = FlxGraphic.fromBitmapData(BitmapData.fromFile(ResourcePacks.getPath('images/'
								+ variation.texture + '.png')));
							#else
							var variation_graphic:FlxGraphicAsset = ResourcePacks.getPath('images/' + variation.texture + '.png');
							#end

							variation_graphics.push(variation);
						}

						changeVariationIndex(0);
					default:
						defaultLoadGraphic(new_block);
				}
			}
			else
				defaultLoadGraphic(new_block);
		}
		else
			defaultLoadGraphic(new_block);

		if (this.graphic != null)
			this.scale.set(1 * (16 / this.graphic.width), 1 * (16 / this.graphic.height));
		this.updateHitbox();

		this.block_id = new_block;
	}
}
