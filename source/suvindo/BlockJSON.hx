package suvindo;

typedef BlockJSON =
{
	> VariationsEntry,

	var ?types:Array<String>;
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
