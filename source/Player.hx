import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	public static var MAX_SHIP_SPEED:Float = 300;
	public static var SHIP_ACC:Float = 600;
	public static var SHIP_DRAG:Float = 1000;

	public static var MAX_MECH_SPEED:Float = 160;
	public static var MECH_ACC:Float = 3200;
	public static var MECH_DRAG:Float = 2000;
	public static var MECH_THRUST:Float = 60;

	public static var TRANS_COOLDOWN_TIME:Float = .5;
	public static var LASER_COOLDOWN_TIME:Float = .5;

	public static var MAX_HEALTH:Float = 100;

	public var thrustMax:Float = .5;

	public var thrust:Float = 0;

	public var mode(default, null):PlayerMode = SHIP;

	public var transCooldown:Float = -1;
	public var laserCooldown:Float = -1;

	public var shipHealth:Float;
	public var mechHealth:Float;

	public function new():Void
	{
		super();

		mechHealth = shipHealth = MAX_HEALTH;

		makeGraphic(12, 6, FlxColor.WHITE);

		maxVelocity.set(MAX_SHIP_SPEED, MAX_SHIP_SPEED);

		drag.set(SHIP_DRAG, SHIP_DRAG);

		facing = FlxObject.RIGHT;
	}

	override function hurt(Damage:Float)
	{
		if (mode == SHIP)
		{
			shipHealth -= Damage;
			if (shipHealth <= 0)
			{
				shipHealth = 0;
				switchMode();
			}
		}
		else
		{
			mechHealth -= Damage;
			if (mechHealth <= 0)
			{
				kill();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (transCooldown > 0)
			transCooldown -= elapsed;

		if (laserCooldown > 0)
			laserCooldown -= elapsed;

		if (mode == MECH)
		{
			if (shipHealth < MAX_HEALTH)
			{
				shipHealth += elapsed;
				if (shipHealth > MAX_HEALTH)
					shipHealth = MAX_HEALTH;
			}
		}

		if (velocity.x < 0)
			facing = FlxObject.LEFT;
		else if (velocity.x > 0)
			facing = FlxObject.RIGHT;
	}

	public function switchMode():Void
	{
		if (transCooldown > 0)
			return;

		transCooldown = TRANS_COOLDOWN_TIME;

		if (mode == SHIP)
		{
			mode = MECH;
			y -= 6;
			makeGraphic(6, 12, FlxColor.WHITE);
			width = 6;
			height = 12;
			maxVelocity.set(MAX_MECH_SPEED, MAX_MECH_SPEED);
			drag.set(MECH_DRAG, MECH_DRAG);
			acceleration.set();
			velocity.set();
			acceleration.y = PlayState.GRAVITY;
		}
		else if (mode == MECH)
		{
			mode = SHIP;
			x -= 6;
			makeGraphic(12, 6, FlxColor.WHITE);
			width = 12;
			height = 6;
			maxVelocity.set(MAX_SHIP_SPEED, MAX_SHIP_SPEED);
			drag.set(SHIP_DRAG, SHIP_DRAG);
			acceleration.set();
			velocity.set();
		}
	}
}

@:enum abstract PlayerMode(String)
{
	var SHIP = "ship";
	var MECH = "mech";
}
