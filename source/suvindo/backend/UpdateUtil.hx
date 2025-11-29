package suvindo.backend;

import sphis.any.VersionConverts;
import haxe.Http;
import lime.utils.Assets;

class UpdateUtil
{
	public static var VERSION_FILE_NAME:String = 'version.txt';
	public static var VERSION_FILE_PATH:String = 'assets/data/' + VERSION_FILE_NAME;
	public static var VERSION(get, never):String;

	static function get_VERSION():String
	{
		return Assets.getText(VERSION_FILE_PATH);
	}

	public static function isOutdated():Bool
	{
		var current_version = VERSION;
		#if !hl
		var git_version:String = Http.requestUrl('https://raw.githubusercontent.com/Synth-Studio-Official/suvindo/main/assets/embed/data/'
			+ VERSION_FILE_NAME);
		#else
		var git_version:String = #if FORCE_OUTDATED '0.0.0' #else VERSION #end;
		#end

		if (current_version != git_version)
		{
			var int_current_version = VersionConverts.convertToInt(current_version);
			var int_git_version = VersionConverts.convertToInt(git_version);

			if (int_current_version #if !NOT_EQUALS_OUTDATED_CHECK < #else != #end int_git_version)
				return true;
		}

		return false;
	}
}
