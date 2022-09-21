package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class EnemyBullet extends FlxSprite
{
	public var colors:Array<FlxColor> = [0xffd95763, 0xffdf7126];

	public static var SPEED:Float = 100;

	public static var MAX_LIFESPAN:Float = 1;

	public var lifespan:Float = 0;

	public function new():Void
	{
		super();
		loadGraphic("assets/images/enemy_bullet.png", false, 8, 8);
	}

	public function fire(X:Float, Y:Float, Angle:Float):Void
	{
		super.reset(X - 4, Y - 4);

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
		color = colors[Std.int(Globals.gameTimer * 10) % 2];
		super.draw();
	}
}
