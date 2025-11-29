package suvindo.backend.blocks;

typedef BlockWorldData =
{
	x:Float,
	y:Float,
	block_id:String,

	?frame_index:Int,
	?variation_index:Int,
}

typedef BlockWorldInfoV2VariationData = {
	i:Int,
	variation_index:Int,
}

typedef BlockJSON =
{
	var ?variations:Array<BlockVariation>;
	var ?animated:AnimatedEntry;
	var ?regular:RegularEntry;

	var ?type:String;
}

typedef RegularEntry =
{
	?texture:String
}

typedef BlockTexture =
{
	texture:String
}

typedef BlockVariation =
{
	> BlockTexture,

	id:String,
}

typedef AnimatedEntry =
{
	> BlockTexture,

	block_width:Int,
	block_height:Int,

	?frames:Array<Int>,
	?fps:Int
}
