package suvindo.backend;

import suvindo.backend.blocks.BlockJSON.BlockWorldInfoV2VariationData;
import flixel.util.typeLimit.OneOfTwo;
import suvindo.backend.blocks.BlockJSON.BlockWorldData;
import suvindo.backend.resourcepacks.ResourcePacks;
import sphis.any.VersionConverts;

using StringTools;

typedef WorldInfo =
{
	?cursor_block:BlockWorldData,
	
	?blocks:Array<OneOfTwo<BlockWorldData, Int>>,
	?variation_indexes:Array<BlockWorldInfoV2VariationData>,

	random_id:String,
	?world_name:String,
	game_version:String,
	?resource_packs:Array<String>,
}

class WorldInfoClass
{
	public static var MIN_WORLD_VERSION:String = "0.3.0";
	public static var MAX_WORLD_VERSION:String = "0.4.0";

	public static function getWorldWarnings(world_info:WorldInfo):String
	{
		var warning:String = "";

		var add_warning = function(msg:String)
		{
			warning += "- " + msg + "\n";
		}

		var version_single_int = VersionConverts.convertToInt(world_info.game_version);

		if (version_single_int < VersionConverts.convertToInt(MIN_WORLD_VERSION))
			add_warning("Using old world format // Playing will attempt to convert");

		if (version_single_int > VersionConverts.convertToInt(MAX_WORLD_VERSION))
			add_warning("Using a new world format // Playing can not convert");

		if (world_info.game_version.toLowerCase().contains("[prototype]"))
			add_warning("Prototype version!");

		var missing_resource_packs:Array<String> = [];
		for (pack in (world_info?.resource_packs ?? []))
		{
			if (!ResourcePacks.ENABLED_RESOURCE_PACKS.contains(pack))
				missing_resource_packs.push(pack);
		}

		if (missing_resource_packs.length > 0)
			add_warning("Missing resource packs: " + missing_resource_packs);

		if (warning == "")
			warning = "None";

		return warning;
	}
}
