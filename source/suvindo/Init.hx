package suvindo;

import flixel.FlxG;
import flixel.FlxState;

class Init extends FlxState
{
	override function create()
	{
		super.create();

        FlxG.mouse.visible = false;
        ReloadPlugin.onReloadInit = () -> {
            ReloadPlugin.reload.add(ResourcePacks.reload);
            ReloadPlugin.reload.add(BlockList.reload);
        }
		FlxG.plugins.addPlugin(new ReloadPlugin());
		

		#if RESOURCE_PACK_MENU
		FlxG.switchState(() -> new ResourcePackMenu());
		#else
		#if sys
		FlxG.switchState(() -> new DebugWorldSelection());
		#else
		FlxG.switchState(() -> new PlayState());
		#end
		#end
	}
}
