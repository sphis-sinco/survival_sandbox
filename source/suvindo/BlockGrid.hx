package suvindo;

import suvindo.Requests.RequestsManager;
import sys.io.File;
import lime.utils.Assets;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;

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
				for (block in world_info.blocks)
				{
					if (block?.block_id == null)
						continue;
					if (block?.x == null)
						continue;
					if (block?.y == null)
						continue;
					if (RequestsManager.REMOVE.blocks.contains(block?.block_id))
						continue;
					if (!BlockList.BLOCK_LIST.contains(block?.block_id))
						continue;

					var old_block = new Block(block?.block_id, block?.x, block?.y);
					if (world_info.has_animated_blocks)
					{
						if (block?.frameIndex != null)
						{
							old_block.animation.play(old_block.animation.name, false, false, block.frameIndex);
							old_block.animation.frameIndex = block.frameIndex;
						}
					}
					if (block?.variation_index != null)
					{
						old_block.variation_index = block.variation_index;
						old_block.changeVariationIndex(0);
					}
					add(old_block);
				}
			}
		}
	}
}
