package suvindo;

import suvindo.backend.TrackManager;
import suvindo.backend.ReloadPlugin;
import suvindo.backend.resourcepacks.ResourcePacks;
import suvindo.backend.blocks.BlockList;
import suvindo.frontend.states.MainMenu;
import suvindo.backend.Requests.RequestsManager;
import flixel.FlxG;
import flixel.FlxState;

class Init extends FlxState
{
	public static var reloadPluginReload:Void->Void = function()
	{
		ReloadPlugin.reload.add(ResourcePacks.reload);
		ReloadPlugin.reload.add(RequestsManager.reload);
		ReloadPlugin.reload.add(BlockList.reload);
		ReloadPlugin.reload.add(TrackManager.reload);
		ReloadPlugin.reload.add(TrackManager.playTrack);
	};

	override function create()
	{
		super.create();

		FlxG.mouse.visible = false;
		
		#if !VOLUME_KEYS
		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.muteKeys = [];
		#end

		ReloadPlugin.baseReloadInit = () -> reloadPluginReload();
		ReloadPlugin.onReloadInit = () -> reloadPluginReload();
		FlxG.plugins.addPlugin(new ReloadPlugin());

		#if (MUSIC_RATE_OFF)
		TrackManager.MUSIC_RATE = OFF;
		#elseif (MUSIC_RATE_CONSTANT)
		TrackManager.MUSIC_RATE = CONSTANT;
		#elseif (MUSIC_RATE_DEFAULT)
		TrackManager.MUSIC_RATE = DEFAULT;
		#elseif (MUSIC_RATE_FREQUENT)
		TrackManager.MUSIC_RATE = FREQUENT;
		#elseif (MUSIC_RATE_VARIABLE)
		TrackManager.MUSIC_RATE = VARIABLE;
		#end

		FlxG.switchState(MainMenu.new);
	}
}
