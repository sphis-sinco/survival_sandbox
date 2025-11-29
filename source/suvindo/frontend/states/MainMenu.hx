package suvindo.frontend.states;

import suvindo.backend.TrackManager;
import suvindo.frontend.states.ResourcePackMenu;
import suvindo.backend.resourcepacks.ResourcePacks;
import suvindo.backend.blocks.BlockGrid;
import flixel.FlxCamera;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;

class MainMenu extends FlxState
{
	public var menuCam:FlxCamera;
	public var logo:FlxSprite = new FlxSprite(0, 0, ResourcePacks.getPath('images/ui/logo.png'));
	public var selections:Array<{name:String, onPress:Void->Void}> = [];
	public var texts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	public var curSel:Int = 0;
	public var curSelText(get, never):FlxText;

	function get_curSelText():FlxText
		return selections[curSel].name == '__LOGO__' ? null : texts.members[curSel - 1];

	public var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 3, [0xFF5E90EC, 0xFF3DBEFA]);
	public var blocks:BlockGrid;

	override public function create()
	{
		super.create();
		TrackManager.playTrack();
		selections = [
			{name: '__LOGO__', onPress: () -> {}},
			{name: 'Play', onPress: () ->
			{
				openSubState(new DebugWorldSelection(menuCam));
			}},
			{name: 'Resource Packs', onPress: () ->
			{
				openSubState(new ResourcePackMenu(menuCam));
			}}
		];

		menuCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		menuCam.bgColor.alpha = 0;
		FlxG.cameras.add(menuCam, true);
		add(bg);
		bg.y -= FlxG.height / 2;
		bg.camera = menuCam;
		bg.scrollFactor.set();

		logo.scale.set(0.15, 0.15);
		logo.updateHitbox();
		logo.screenCenter();
		logo.y -= 100;
		logo.antialiasing = true;
		logo.camera = menuCam;
		add(logo);

		var lSelY:Float = 400;
		var processed = selections.copy();
		processed.remove(selections[0]);
		for (selection in processed)
		{
			var txt = new FlxText(0, lSelY + 40, 0, selection.name, 80);
			txt.font = ResourcePacks.getPath('fonts/ui_font.ttf');
			txt.color = FlxColor.WHITE;
			txt.borderStyle = OUTLINE;
			txt.borderColor = 0x66000000;
			txt.borderSize = 2;
			txt.screenCenter(X);
			txt.antialiasing = true;
			txt.scale.set(0.5, 0.5);
			txt.camera = menuCam;
			texts.add(txt);
			lSelY += 100;
		}

		blocks = new BlockGrid(ResourcePacks.getPath('data/menuWorld.json'));
		blocks.camera = menuCam;
		blocks.y -= texts.members[texts.members.length - 1].y - (FlxG.height / 2.5);
		var highestY:Float = Math.POSITIVE_INFINITY;
		var lowestY:Float = Math.NEGATIVE_INFINITY;

		blocks.applyBlockChanges((block) ->
		{
			if (block.y < highestY)
				highestY = block.y;
			else if (block.y > lowestY)
				lowestY = block.y;
		});
		blocks.applyBlockChanges((block) ->
		{
			block.alpha = (block.y - lowestY) / (highestY - lowestY) * 0.9;
		});
		add(blocks);
		add(texts);

		
		var version_text = new FlxText(2, 2, 0, 'version', 8);
		version_text.text = lime.app.Application.current.meta.get('version') + #if debug ' [PROTOTYPE]' #else '' #end;
		add(version_text);
		version_text.camera = menuCam;
		version_text.scrollFactor.set();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.UP)
			curSel = (curSel - 1 + selections.length) % selections.length;
		if (FlxG.keys.justPressed.DOWN)
			curSel = (curSel + 1) % selections.length;

		if (FlxG.keys.justPressed.ENTER)
			selections[curSel].onPress();
		if (curSelText != null)
		{
			curSelText.color = FlxColor.interpolate(curSelText.color, FlxColor.YELLOW, 0.5);
			menuCam.follow(curSelText, LOCKON, 0.1);
		}
		if (selections[curSel].name == '__LOGO__')
			menuCam.follow(logo, LOCKON, 0.1);
		for (text in texts.members)
			if (text != curSelText)
				text.color = FlxColor.interpolate(text.color, FlxColor.WHITE, 0.5);
	}

	override public function destroy()
	{
		super.destroy();
		FlxG.cameras.remove(menuCam);
	}
}
