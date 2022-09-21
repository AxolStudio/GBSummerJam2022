package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;

class Enemy extends FlxSprite
{
	public var enemyType:EnemyType;

	public var actionTimer:Float = 0;

	public static var FIRE_RATE:Float = 2;
	public static var BOSS_FIRE_RATE:Float = 3;

	public static var BOSS_FLASH_COLORS:Array<FlxColor> = [0xff76428a, 0xffd77bba];

	public var hurtCooldown:Float = 0;

	private var coordD:FlxPoint = new FlxPoint();
	private var coordF:FlxPoint = new FlxPoint();

	public function new():Void
	{
		super();

		loadGraphic("assets/images/enemies.png", true, 8, 8);

		setFacingFlip(FlxDirection.LEFT, true, false);
		setFacingFlip(FlxDirection.RIGHT, false, false);

		animation.add("FLYER", [0, 1], 10, true);
		animation.add("WALKER", [2, 3], 10, true);
		animation.add("SHOOTER", [4, 5], 10, true);
		animation.add("BOSS", [6, 7], 10, true);
	}

	public function spawn(X:Float, Y:Float, EnemyType:EnemyType):Void
	{
		reset(X, Y);
		enemyType = EnemyType;
		actionTimer = 0;
		facing = FlxDirection.LEFT;

		animation.play(EnemyType, true);
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
				if (isOnScreen())
				{
					// can we see the player?
					var whichMap:FlxTilemap = x >= 0 && x <= PlayState.WORLD_WIDTH ? Globals.State.mapA : Globals.State.mapB;
					if (whichMap.ray(getMidpoint(), Globals.State.player.getMidpoint()))
					{
						// we can!
						actionTimer += elapsed;
						if (actionTimer > BOSS_FIRE_RATE)
						{
							actionTimer -= BOSS_FIRE_RATE;

							Globals.State.startBossAttack(x + 4, y + 4, x < Globals.State.player.x ? RIGHT : LEFT);
						}
					}
					else
					{
						actionTimer = 0;
					}
				}
				if (hurtCooldown > 0)
					hurtCooldown -= elapsed;
		}
	}

	override function draw()
	{
		if (enemyType == BOSS && actionTimer > FIRE_RATE)
		{
			color = BOSS_FLASH_COLORS[Std.int(Globals.gameTimer * 10) % 2];
		}
		else
			color = FlxColor.WHITE;
		
		super.draw();
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
