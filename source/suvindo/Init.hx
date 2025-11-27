package suvindo;

import suvindo.Requests.RequestsManager;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;

class Init extends FlxState
{
	override function create()
	{
		super.create();

		FlxG.mouse.visible = false;
		ReloadPlugin.onReloadInit = () ->
		{
			ReloadPlugin.reload.add(ResourcePacks.reload);
			ReloadPlugin.reload.add(RequestsManager.reload);
			ReloadPlugin.reload.add(BlockList.reload);
			ReloadPlugin.reload.add(TrackManager.reload);
		}
		FlxG.plugins.addPlugin(new ReloadPlugin());

		#if (MUSIC_RATE == OFF)
		TrackManager.MUSIC_RATE = OFF;
		#elseif (MUSIC_RATE == CONSTANT)
		TrackManager.MUSIC_RATE = CONSTANT;
		#elseif (MUSIC_RATE == DEFAULT)
		TrackManager.MUSIC_RATE = DEFAULT;
		#elseif (MUSIC_RATE == FREQUENT)
		TrackManager.MUSIC_RATE = FREQUENT;
		#elseif (MUSIC_RATE == VARIABLE)
		TrackManager.MUSIC_RATE = VARIABLE;
		#end

		#if RESOURCE_PACK_MENU
		FlxG.switchState(() -> new ResourcePackMenu());
		#else
		FlxG.switchState(() -> new DebugWorldSelection());
		#end
	}
}
