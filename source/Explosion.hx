package;

import djFlixel.D;
import djFlixel.other.FlxSequencer;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Explosion extends FlxSprite
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/explosion.png", true, 30, 30);
		animation.add("explosion", [0, 1, 2, 3, 4, 5], 10, false);
		animation.finishCallback = (_) ->
		{
			kill();
		};
	}

	public function spawn(X:Float, Y:Float):Void
	{
		reset(X - 15, Y - 15);

		D.snd.play("explosion");

		animation.play("explosion");
	}
}
