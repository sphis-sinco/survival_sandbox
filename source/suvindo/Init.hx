package suvindo;

import flixel.FlxG;
import flixel.FlxState;

class Init extends FlxState
{
	override function create()
	{
		super.create();

		FlxG.plugins.addPlugin(new ReloadPlugin());

		ReloadPlugin.reload_function();

        FlxG.switchState(() -> new PlayState());
	}
}
