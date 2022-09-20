package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirection;

class Enemy extends FlxSprite
{
	public var enemyType:EnemyType;

	public var actionTimer:Float = 0;

	public static var FIRE_RATE:Float = 2;

	public var hurtCooldown:Float = 0;

	private var coordD:FlxPoint = new FlxPoint();
	private var coordF:FlxPoint = new FlxPoint();

	public function new():Void
	{
		super();
	}

	public function spawn(X:Float, Y:Float, EnemyType:EnemyType):Void
	{
		reset(X, Y);
		enemyType = EnemyType;
		actionTimer = 0;
		facing = FlxDirection.LEFT;
		// loadGraphic(enemyType.image, true, true, 16, 16);
		makeGraphic(8, 8, switch (enemyType)
		{
			case FLYER: 0xffac3232;
			case WALKER: 0xff76428a;
			case SHOOTER: 0xffdf7126;
			case BOSS: 0xff5fcde4;
		}, false, enemyType);
		if (enemyType == BOSS)
		{
			health = 50;
			hurtCooldown = 0;
		}
		else
			health = 1;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (enemyType)
		{
			case FLYER:
				velocity.x = -60;
				velocity.y = Math.cos(x * .05) * 60;

			case WALKER:
				if (isOnScreen() || y < PlayState.SCREEN_HEIGHT)
				{
					checkAhead(elapsed);

					velocity.x = 20 * (facing == FlxDirection.LEFT ? -1 : 1);
				}
				else
					velocity.x = 0;

			case SHOOTER:
				if (isOnScreen() || y < PlayState.SCREEN_HEIGHT)
				{
					actionTimer += elapsed;
					if (actionTimer > FIRE_RATE)
					{
						actionTimer -= FIRE_RATE;

						var dx:Float = Globals.State.player.x - x;
						var dy:Float = Globals.State.player.y - y;

						var angle:Float = Math.atan2(dy, dx);

						Globals.State.fireEnemyBullet(x, y, angle);
					}
				}
			case BOSS:
				if (hurtCooldown > 0)
					hurtCooldown -= elapsed;
		}
	}

	public function checkAhead(elapsed:Float):Void
	{
		var posX:Float = x + (facing == FlxDirection.LEFT ? -(1 + (20 * elapsed / 2)) : width + (20 * elapsed / 2));
		var posY:Float = y;

		coordD.x = posX;
		coordD.y = posY + height + 4;
		coordF.x = posX;
		coordF.y = posY + (height / 2);

		var whichMap:FlxTilemap = x >= 0 && x <= PlayState.WORLD_WIDTH ? Globals.State.mapA : Globals.State.mapB;
		var below:Int = whichMap.getTileIndexByCoords(coordD);
		var ahead:Int = whichMap.getTileIndexByCoords(coordF);
		var tileBelow:Int = whichMap.getTileByIndex(below);
		var tileAhead:Int = whichMap.getTileByIndex(ahead);

		if (tileBelow != 2 || tileAhead == 2)
			facing = facing == FlxDirection.LEFT ? FlxDirection.RIGHT : FlxDirection.LEFT;
	}

	override function kill():Void
	{
		super.kill();
		if (FlxG.random.bool(20))
		{
			Globals.State.dropHealth(x, y);
		}
	}

	override function hurt(Damage:Float)
	{
		if (hurtCooldown > 0)
			return;

		hurtCooldown = 0.5;

		super.hurt(Damage);
	}
}

@:enum abstract EnemyType(String) from String to String
{
	var FLYER = "FLYER";
	var WALKER = "WALKER";
	var SHOOTER = "SHOOTER";
	var BOSS = "BOSS";
}
