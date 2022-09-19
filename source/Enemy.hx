package;

import flixel.FlxCamera;
import flixel.FlxSprite;

class Enemy extends FlxSprite
{
	public var enemyType:EnemyType;

	public var actionTimer:Float = 0;

	public static var FIRE_RATE:Float = 0.8;

	public function new():Void
	{
		super();
	}

	public function spawn(X:Float, Y:Float, EnemyType:EnemyType):Void
	{
		reset(X, Y);
		enemyType = EnemyType;
		actionTimer = 0;
		// loadGraphic(enemyType.image, true, true, 16, 16);
		makeGraphic(8, 8, switch (enemyType)
		{
			case FLYER: 0xffac3232;
			case WALKER: 0xff76428a;
			case SHOOTER: 0xffdf7126;
			case BOSS: 0xff5fcde4;
		}, false, enemyType);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (enemyType)
		{
			case FLYER:
				velocity.x = -100;
				velocity.y = Math.cos(x * .05) * 100;

			case WALKER:

			case SHOOTER:
				if (isOnScreen() || y < PlayState.SCREEN_HEIGHT)
				{
					actionTimer += elapsed;
					if (actionTimer > FIRE_RATE)
					{
						actionTimer -= FIRE_RATE;
						// on a timer, aim at the player and fire a bullet
						var dx:Float = Globals.State.player.x - x;
						var dy:Float = Globals.State.player.y - y;

						var angle:Float = Math.atan2(dy, dx);

						Globals.State.fireEnemyBullet(x, y, angle);
					}
				}
			case BOSS:
		}
	}
}

@:enum abstract EnemyType(String) from String to String
{
	var FLYER = "FLYER";
	var WALKER = "WALKER";
	var SHOOTER = "SHOOTER";
	var BOSS = "BOSS";
}
