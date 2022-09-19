package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class EnemyBullet extends FlxSprite
{
	public var colors:Array<FlxColor> = [0xffd95763, 0xffdf7126];

	public static var SPEED:Float = 200;

	public static var MAX_LIFESPAN:Float = 2;

	public var lifespan:Float = 0;

	public function new():Void
	{
		super();
		makeGraphic(6, 6, FlxColor.TRANSPARENT);
	}

	public function fire(X:Float, Y:Float, Angle:Float):Void
	{
		super.reset(X - 3, Y - 3);

		velocity.set(Std.int(SPEED * Math.cos(Angle)), Std.int(SPEED * Math.sin(Angle)));

		lifespan = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		lifespan += elapsed;

		if (lifespan > MAX_LIFESPAN)
		{
			super.kill();
		}
	}

	override function draw()
	{
		updateGraphic();
		super.draw();
	}

	public function updateGraphic():Void
	{
		FlxSpriteUtil.drawCircle(this, -1, -1, 3, colors[Std.int(Globals.gameTimer * 10) % 2]);
	}
}
