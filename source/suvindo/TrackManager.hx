package suvindo;

import flixel.util.FlxTimer;
import flixel.FlxG;
import haxe.io.Path;
#if sys
import sys.FileSystem;
#end
import suvindo.Requests.RequestsManager;

using StringTools;

class TrackManager
{
	public static var TRACKS_LIST:Array<String> = [];

	public static function reload()
	{
		TRACKS_LIST = [];
		#if sys
		var tracksDir:Array<String> = ResourcePacks.readDirectory('music/');
		for (track in RequestsManager.ADD.tracks)
		{
			var path:String = ResourcePacks.getPath('music/' + track + '.png');
			if (#if !sys Assets.exists #else FileSystem.exists #end (path))
				tracksDir.push(path);
		}
		for (track in tracksDir)
		{
			var list_entry:String = Path.withoutExtension(Path.withoutDirectory(track));
			var accept_entry = () ->
			{
				if (!TRACKS_LIST.contains(list_entry))
					TRACKS_LIST.push(list_entry);
			}

			if (RequestsManager.REMOVE.tracks.contains(list_entry))
				continue;

			if (track.endsWith('.wav') && !FileSystem.isDirectory(track))
				accept_entry();
		}
		#else
		TRACKS_LIST = Assets.getText(ResourcePacks.getPath('data/tracks-list.txt')).split('\n');
		#end

		trace('tracks list: ' + TRACKS_LIST);
	}

	public static var MUSIC_RATE:MusicRate = DEFAULT;

	public static function playTrack()
	{
		if (FlxG.sound.music.playing)
			return;

		if (MUSIC_RATE == OFF)
			return;

		FlxG.sound.music.loadStream(ResourcePacks.getPath(TRACKS_LIST[FlxG.random.int(0, TRACKS_LIST.length - 1)]), false, false, () ->
		{
			FlxTimer.wait(FlxG.random.float(60, 60 * switch (MUSIC_RATE)
			{
				case OFF: Math.POSITIVE_INFINITY;
				case CONSTANT: 0.5;
				case FREQUENT: 5;
				case DEFAULT: FlxG.random.int(10, 20);
				case VARIABLE: ((FlxG.state is DebugWorldSelection) ? FlxG.random.int(0.5, 15) : FlxG.random.int(0.5, 120));
			}), playTrack);
		});
	}
}

enum MusicRate
{
	OFF;
	CONSTANT;
	DEFAULT;
	FREQUENT;
	VARIABLE;
}
