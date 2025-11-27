package suvindo;

typedef BlockJSON =
{
	> VariationsEntry,

	var ?type:String;
}

typedef VariationsEntry =
{
	var ?variations:Array<BlockVariation>;
}

typedef BlockVariation =
{
	id:String,
	texture:String
}
