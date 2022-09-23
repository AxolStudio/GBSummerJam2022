package;

import djFlixel.D;
import djFlixel.other.DelayCall;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PauseSubState extends FlxSubState
{
	override public function create():Void
	{
		bgColor = 0x66222034;
		super.create();

		var txt:FlxText = new FlxText("PAUSED");
		txt.scrollFactor.set();
		txt.font = "assets/fonts/skullboy.ttf";
		txt.color = FlxColor.WHITE;
		txt.borderColor = FlxColor.BLACK;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.borderSize = 2;
		txt.size = 16;
		txt.alignment = FlxTextAlign.CENTER;
		add(D.align.screen(txt));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (Actions.pause.check())
		{
			close();
		}
	}
}
