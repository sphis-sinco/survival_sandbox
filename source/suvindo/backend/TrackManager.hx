package suvindo.backend;

import suvindo.frontend.states.DebugWorldSelection;
import suvindo.backend.resourcepacks.ResourcePacks;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxG;
import haxe.io.Path;
#if sys
import sys.FileSystem;
#end
import suvindo.backend.requests.Requests.RequestsManager;

using StringTools;

class TrackManager
{
	public static var TRACKS_LIST:Array<String> = [];

	public static function reload()
	{
		TRACKS_LIST = [];
		if (MUSIC != null)
		{
			MUSIC.destroy();
			MUSIC_TIMER = null;
		}
		trace("RELOADING");
		#if sys
		var tracksDir:Array<String> = ResourcePacks.readDirectory("music/");
		var requestedTracks:Map<String, String> = [];
		for (track in RequestsManager.ADD?.tracks)
		{
			var path:String = ResourcePacks.getPath("music/" + track + ".wav");
			trace(path);
			if (#if !sys Assets.exists #else FileSystem.exists #end (path))
			{
				tracksDir.push(path);
				requestedTracks.set(Path.withoutExtension(Path.withoutDirectory(path)), track);
			}
		}
		for (track in tracksDir)
		{
			var list_entry:String = Path.withoutExtension(Path.withoutDirectory(track));

			if (requestedTracks.exists(list_entry))
				list_entry = requestedTracks.get(list_entry);

			var accept_entry = () ->
			{
				if (!TRACKS_LIST.contains(list_entry))
					TRACKS_LIST.push(list_entry);
			}

			if (RequestsManager.REMOVE?.tracks.contains(list_entry))
				continue;

			if (track.endsWith(".wav") && !FileSystem.isDirectory(track))
				accept_entry();
		}
		#else
		TRACKS_LIST = Assets.getText(ResourcePacks.getPath("data/tracks-list.txt")).split("\n");
		#end

		trace("tracks list: " + TRACKS_LIST);
	}

	public static var MUSIC_RATE:MusicRate = DEFAULT;

	public static var MUSIC_TIMER:FlxTimer;

	public static var MUSIC:FlxSound;

	public static function playTrack()
	{
		if (MUSIC?.playing)
			return;

		if (MUSIC_TIMER?.active)
		{
			trace(FlxMath.roundDecimal(MUSIC_TIMER.timeLeft / 60, 2) + " minutes left");
			return;
		}

		if (MUSIC_RATE == OFF)
			return;

		if (TRACKS_LIST.length == 0)
			return;

		var track = ResourcePacks.getPath("music/" + TRACKS_LIST[FlxG.random.int(0, TRACKS_LIST.length - 1)] + ".wav");

		#if sys
		if (!FileSystem.exists(track))
		#else
		if (!Assets.exists(track))
		#end
		return;

		if (MUSIC == null)
			MUSIC = new FlxSound();

		final max_wait_secs:Float = 60 * switch (MUSIC_RATE)
		{
			case OFF: Math.POSITIVE_INFINITY;
			case CONSTANT: FlxG.random.float(0.25, 1);
			case FREQUENT: FlxG.random.float(4, 6);
			case DEFAULT: FlxG.random.float(10, 20);
			case VARIABLE: ((FlxG.state is DebugWorldSelection) ? FlxG.random.float(0.5, 15) : FlxG.random.float(0.5, 120));
		};
		trace("MUSIC RATE : " + MUSIC_RATE);

		final time_to_wait = FlxG.random.float(60, max_wait_secs);

		if (MUSIC_TIMER == null)
			MUSIC_TIMER = new FlxTimer();

		trace("Going to wait " + FlxMath.roundDecimal(time_to_wait / 60, 2) + " minutes to play next track");

		MUSIC.loadStream(track, false, false, () ->
		{
			trace("Waiting " + FlxMath.roundDecimal(time_to_wait / 60, 2) + " minutes to play next track");
			MUSIC_TIMER.start(time_to_wait, t -> playTrack);
		}, () ->
			{
				trace("playing " + track);
			});
		MUSIC.play();
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
