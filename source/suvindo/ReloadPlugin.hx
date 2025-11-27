package suvindo;

import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxBasic;

class ReloadPlugin extends FlxBasic
{
	public static var reload:FlxSignal;
    public static var onReloadInit:()->Void = () -> {};

	override public function new()
	{
		super();

		reload = new FlxSignal();
        FlxG.signals.preStateSwitch.add(() ->
		{
			reload.removeAll();
            onReloadInit();
		});
        
        onReloadInit();
        reload.dispatch();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justReleased.R)
            reload.dispatch();
	}
}
