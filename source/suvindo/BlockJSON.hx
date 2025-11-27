package suvindo;

typedef BlockJSON =
{
	> VariationsEntry,

	var ?type:String;
}

typedef VariationsEntry =
{
	var ?variations:Array<
		{
			id:String,
			texture:String
		}>;
}
