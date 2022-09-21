package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Thrust extends FlxSprite
{
	private var size:Float = 4;

	public var colors:Array<FlxColor> = [0xff5b6ee1, 0xff3f3f74];

	public function new():Void
	{
		super();
	}

	public function spawn(X:Float, Y:Float):Void
	{
		reset(X - 6, Y - 6);
		size = 4;
	}

	override function draw()
	{
		makeGraphic(12, 12, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCircle(this, -1, -1, Math.ceil(size), FlxColor.WHITE);
		color = colors[Std.int(Globals.gameTimer * 10) % 2];
		size -= 0.5;

		if (size <= 0)
			kill();
		else
			super.draw();
	}
}
