package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Health extends FlxSprite
{
	private var colors:Array<FlxColor> = [0xff6abe30, 0xff99e550];

	public function new():Void
	{
		super();
		makeGraphic(4, 6, 0xff99e550);
	}

	public function spawn(X:Float, Y:Float):Void
	{
		super.reset(X, Y - 1);
		FlxTween.tween(this, {y: y + 2}, 0.2, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
	}

	override function kill()
	{
		super.kill();
		FlxTween.cancelTweensOf(this);
	}

	override public function draw():Void
	{
		updateGraphic();
		super.draw();
	}

	public function updateGraphic():Void
	{
		makeGraphic(4, 6, colors[Std.int(Globals.gameTimer * 10) % 2]);
	}
}
