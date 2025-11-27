package suvindo;

import sphis.any.VersionConverts;

using StringTools;

typedef WorldInfo =
{
	?cursor_block:{x:Float, y:Float, block_id:String},
	?blocks:Array<Dynamic>,
	?has_animated_blocks:Bool,
	?animated_block_universal_frames:Dynamic,
	random_id:String,
	?world_name:String,
	game_version:String,
}

class WorldInfoClass
{
    public static var MIN_WORLD_VERSION:String = "0.2.0";
    public static var MAX_WORLD_VERSION:String = "0.3.0";

	public static function getGameVersionWarnings(game_version:String):String
	{
		var warning:String = '';

		var add_warning = function(warning:String)
		{
			warning += '- ' + warning + '\n';
		}

        var version_single_int = VersionConverts.convertToInt(game_version);

		if (version_single_int < VersionConverts.convertToInt(MIN_WORLD_VERSION))
			add_warning('Below the minimum supported world version');

		if (version_single_int > VersionConverts.convertToInt(MIN_WORLD_VERSION))
			add_warning('Above the maximum supported world version');

        if (game_version.toLowerCase().contains('[prototype]'))
			add_warning('Prototype version!');

		if (warning == '')
			warning = 'None';

		return warning;
	}
}
