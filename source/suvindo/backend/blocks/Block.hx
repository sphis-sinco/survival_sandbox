package suvindo.backend.blocks;

import suvindo.backend.resourcepacks.ResourcePacks;
import haxe.io.Path;
import suvindo.backend.requests.Requests.RequestsManager;
import suvindo.backend.blocks.BlockJSON.BlockVariation;
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

using StringTools;

class Block extends FlxSprite
{
	public var block_id:String;
	public var block_json:BlockJSON;

	public var graphic_path:String;

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

	public function getGraphicPath(block:String, blocks_folder:Bool = true, ext:String = "png"):String
	{
		var path:String = ResourcePacks.getPath("images/" + (blocks_folder ? "blocks/" : "") + block + "." + ext);

		for (block_path in RequestsManager.ADD?.blocks)
			if (Path.withoutDirectory(block_path) == block)
				path = ResourcePacks.getPath("images/" + block_path + "." + ext);

		graphic_path = path;
		return path;
	}

	public function defaultLoadGraphic(new_block:String)
	{
		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(getGraphicPath(new_block))));
		#else
		loadGraphic(getGraphicPath(new_block));
		#end

		if (this.graphic == null)
			loadGraphic("assets/images/debug.png");
	}

	public function changeVariationIndex(amount:Int)
	{
		variation_index += amount;

		if (variation_index < 0)
			variation_index = variations.length - 1;
		if (variation_index > variations.length - 1)
			variation_index = 0;

		#if sys
		loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile(getGraphicPath(variations[variation_index].texture, false))));
		#else
		loadGraphic(getGraphicPath(variations[variation_index].texture, false));
		#end

		if (this.graphic == null)
			trace(getGraphicPath(variations[variation_index].texture, false));

		if (this.graphic == null)
			loadGraphic("assets/images/debug.png");
	}

	public function switchBlock(new_block:String)
	{
		variation_index = 0;
		variations = [];

		block_json = null;
		if (#if !sys Assets.exists #else FileSystem.exists #end (getGraphicPath(new_block, true, "json")))
		{
			#if sys
			block_json = cast Json.parse(File.getContent(getGraphicPath(new_block, true, "json")));
			#else
			block_json = cast Json.parse(Assets.getText(getGraphicPath(new_block, true, "json", true, "json")));
			#end
			if (block_json != null && block_json.type != null)
			{
				block_json.type = block_json.type.toLowerCase();
				switch (block_json.type)
				{
					case "variations":
						for (variation in block_json.variations)
							variations.push(variation);

						changeVariationIndex(0);
					case "animated":
						loadGraphic(#if sys FlxGraphic.fromBitmapData(BitmapData.fromFile(getGraphicPath(new_block))) #else getGraphicPath(new_block) #end,
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

						animation.add("animation", block_json.animated?.frames ?? getFrames(), block_json.animated?.fps ?? 24);
						animation.play("animation");

					case "regular":
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

		if (this.graphic.bitmap == null)
			loadGraphic("assets/images/debug.png");

		this.scale.set(1, 1);
		if (this.graphic != null)
			if (block_json?.type == "animated")
				this.scale.set(1 * (16 / this.block_json.animated.block_width), 1 * (16 / this.block_json.animated.block_height));
			else
				this.scale.set(1 * (16 / this.graphic.width), 1 * (16 / this.graphic.height));
		this.updateHitbox();

		this.block_id = new_block;
	}
}
