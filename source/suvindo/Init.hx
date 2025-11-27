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

		TrackManager.playTrack();

		#if RESOURCE_PACK_MENU
		FlxG.switchState(() -> new ResourcePackMenu());
		#else
		FlxG.switchState(() -> new DebugWorldSelection());
		#end
	}
}
