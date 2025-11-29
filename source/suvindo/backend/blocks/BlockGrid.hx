package suvindo.backend.blocks;

import suvindo.backend.WorldInfo.WorldInfoClass;
import flixel.FlxG;
import haxe.crypto.Sha256;
import flixel.math.FlxPoint;
import sys.FileSystem;
import suvindo.backend.requests.Requests.RequestsManager;
import sys.io.File;
import lime.utils.Assets;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class BlockGrid extends FlxTypedGroup<Block>
{
	public var world_info:WorldInfo;

	public var x(default, set):Float;

	function set_x(x:Float):Float
	{
		applyBlockChanges(block ->
		{
			block.offset.x = x;
		});

		return x;
	}

	public var y(default, set):Float;

	function set_y(y:Float):Float
	{
		applyBlockChanges(block ->
		{
			block.offset.y = y;
		});

		return y;
	}

	public var alpha(default, set):Float;

	function set_alpha(alpha:Float):Float
	{
		applyBlockChanges(block ->
		{
			block.alpha = alpha;
		});

		return alpha;
	}

	public function applyBlockChanges(changes:Block->Void)
	{
		for (block in this.members)
			changes(block);
	}

	override public function new(world_file_path:String, ?x:Float = 0, ?y:Float = 0)
	{
		super();

		members = [];

		world_info = WorldInfoClass.getDefaultWorldInfo();

		if (world_file_path != null)
			loadWorld(world_file_path);

		this.x = x;
		this.y = y;
	}

	public function clearBlocks()
	{
		for (block in this.members)
		{
			this.members.remove(block);
			block.destroy();
		}
	}

	public function loadWorld(world_file_path:String)
	{
		#if sys
		this.world_info = Json.parse(File.getContent(world_file_path));
		#else
		this.world_info = Json.parse(Assets.getText(world_file_path));
		#end

		if (world_info != null)
		{
			clearBlocks();

			if (world_info.blocks != null)
			{
				var overlap_count:Int = 0;

				for (block in world_info.blocks)
				{
					if (block?.block_id == null)
						continue;
					if (block?.x == null)
						continue;
					if (block?.y == null)
						continue;
					for (convert_block in RequestsManager.CONVERT.blocks)
						if (convert_block.from == block?.block_id)
						{
							block.block_id = convert_block.to;
							break;
						}
					if (RequestsManager.REMOVE?.blocks.contains(block?.block_id))
						continue;
					if (!BlockList.BLOCK_LIST.contains(block?.block_id))
						continue;

					var new_block = new Block(block?.block_id, block?.x, block?.y);
					if (block?.variation_index != null)
					{
						new_block.variation_index = block.variation_index;
						new_block.changeVariationIndex(0);
					}

					var can_be_added:Bool = true;

					applyBlockChanges(block ->
					{
						if (block.overlaps(new_block) && can_be_added)
						{
							can_be_added = false;
							overlap_count++;
						}
					});

					if (can_be_added)
						add(new_block);
				}

				trace('Removed ' + overlap_count + ' overlapping blocks');
			}
		}

		saveWorldInfo(world_file_path);
	}

	public function saveWorldInfo(path:String, save_file:Bool = true)
	{
		if (world_info == null) world_info = WorldInfoClass.getDefaultWorldInfo();

		world_info.blocks = [];
		world_info.resource_packs = [];

		if (this.members != null)
			for (block in this.members)
			{
				var block_data:Dynamic = {
					block_id: block.block_id,
					x: block.x,
					y: block.y,
				};

				if (block.block_json?.type == "variations")
					block_data.variation_index = block.variation_index;

				world_info.blocks.push(block_data);

				if (block.graphic_path.contains("resources/"))
					if (!world_info.resource_packs.contains(block.graphic_path.split("/")[1]))
						world_info.resource_packs.push(block.graphic_path.split("/")[1]);
			}

		#if sys
		File.saveContent(path, Json.stringify(world_info, "\t"));
		#end
	}
}
