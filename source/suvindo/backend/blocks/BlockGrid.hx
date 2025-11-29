package suvindo.backend.blocks;

import haxe.crypto.Sha256;
import lime.app.Application;
import flixel.FlxG;
import suvindo.backend.blocks.BlockJSON.BlockWorldData;
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
			saveWorldInfo(world_file_path);

			if (world_info.blocks != null)
			{
				var overlap_count:Int = 0;

				var x:Float = 0;
				var y:Float = 0;
				var i:Int = 0;

				for (block in world_info.blocks)
				{
					var block_world_data:BlockWorldData = null;

					try
					{
						block_world_data = cast block;
					}
					catch (_) {}
					var block_string_data:String = null;
					try
					{
						block_string_data = cast block;
					}
					catch (_) {}
					var new_block:Block = null;

					if (block_world_data != null)
					{
						if (block_world_data?.block_id == null)
							continue;
						if (block_world_data?.x == null)
							continue;
						if (block_world_data?.y == null)
							continue;
						for (convert_block in RequestsManager.CONVERT.blocks)
							if (convert_block.from == block_world_data?.block_id)
							{
								block_world_data.block_id = convert_block.to;
								break;
							}
						if (RequestsManager.REMOVE?.blocks.contains(block_world_data?.block_id))
							continue;
						if (!BlockList.BLOCK_LIST.contains(block_world_data?.block_id))
							continue;

						new_block = new Block(block_world_data?.block_id, block_world_data?.x, block_world_data?.y);
						if (block_world_data?.variation_index != null)
						{
							new_block.variation_index = block_world_data.variation_index;
							new_block.changeVariationIndex(0);
						}
					}
					else if (block_string_data != null)
					{
						i++;
						x++;

						if (x > (FlxG.width / 16))
						{
							x = 0;
							y++;
						}

						if (block_string_data.startsWith('0'))
						{
							x += Std.parseInt(block_string_data.split('_')[1]);

							if (x > (FlxG.width / 16))
							{
								x = 0;
								y++;
							}
							continue;
						}

						var converted_block_id:String = BlockList.BLOCK_LIST[Std.parseInt(block_string_data.split('_')[0]) - 1];
						var amount = Std.parseInt(block_string_data.split('_')[1]);

						for (convert_block in RequestsManager.CONVERT.blocks)
							if (convert_block.from == converted_block_id)
							{
								converted_block_id = convert_block.to;
								break;
							}
						if (RequestsManager.REMOVE?.blocks.contains(converted_block_id))
							continue;
						if (!BlockList.BLOCK_LIST.contains(converted_block_id))
							continue;

						while (amount > 0)
						{
							new_block = new Block(converted_block_id, x * 16, y * 16);

							if (world_info.variation_indexes != null)
								for (variation in world_info.variation_indexes)
									if (variation.i == i)
										new_block.variation_index = variation.variation_index;
							new_block.changeVariationIndex(0);

							amount--;
							x++;
							if (x > (FlxG.width / 16))
							{
								x = 0;
								y++;
							}
						}
					}

					var can_be_added:Bool = true;

					if (new_block != null)
					{
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
				}

				trace('Removed ' + overlap_count + ' overlapping blocks');
			}
		}

		saveWorldInfo(world_file_path);
	}

	public function saveWorldInfo(path:String, ?save_file:Bool = true)
	{
		var x = 0;
		var y = 0;
		var i = 0;

		var amount = 0;

		while (y < (FlxG.height / 16))
		{
			while (x < (FlxG.width / 16))
			{
				amount = 0;
				i++;
				x++;

				var block_id = 0;

				if (this.members != null)
					for (block in this.members)
					{
						if (block.y == y * 16 && block.x >= x * 16)
						{
							amount++;

							if (block.block_json?.type == "variations")
								world_info.variation_indexes.push({i: i, variation_index: block.variation_index});

							block_id = BlockList.BLOCK_LIST.indexOf(block.block_id);

							if (block.graphic_path.contains("resources/"))
								if (!world_info.resource_packs.contains(block.graphic_path.split("/")[1]))
									world_info.resource_packs.push(block.graphic_path.split("/")[1]);
						}
					}
				world_info.blocks.push(block_id + '_' + amount);
			}

			y++;
			x = 0;
		}

		#if sys
		if (save_file)
			File.saveContent(path, Json.stringify(world_info, "\t"));
		#end
	}
}
