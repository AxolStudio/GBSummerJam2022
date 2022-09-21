package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Thrust extends FlxSprite
{
	public var colors:Array<FlxColor> = [0xff5b6ee1, 0xff3f3f74];

	public function new():Void
	{
		super();
		loadGraphic("assets/images/thrust.png", true, 8, 8);
		animation.add("thrust", [0, 1, 2, 3], 20, false);
		animation.finishCallback = (_) ->
		{
			kill();
		};
	}

	public function spawn(X:Float, Y:Float):Void
	{
		reset(X - 4, Y - 4);

		animation.play("thrust");
	}

	override function draw()
	{
		color = colors[Std.int(Globals.gameTimer * 10) % 2];

		super.draw();
	}
}
