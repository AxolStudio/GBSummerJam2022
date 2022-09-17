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
	public static var MECH_DRAG:Float = 1000;

	public var mode(default, null):PlayerMode = SHIP;

	public var transCooldown:Float = -1;

	public function new():Void
	{
		super();

		makeGraphic(12, 6, FlxColor.WHITE);

		maxVelocity.set(MAX_SHIP_SPEED, MAX_SHIP_SPEED);

		drag.set(SHIP_DRAG, SHIP_DRAG);

		facing = FlxObject.RIGHT;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (transCooldown > 0)
			transCooldown -= elapsed;

		if (velocity.x < 0)
			facing = FlxObject.LEFT;
		else if (velocity.x > 0)
			facing = FlxObject.RIGHT;
	}

	public function switchMode():Void
	{
		if (transCooldown > 0)
			return;

		transCooldown = .5;

		if (mode == SHIP)
		{
			mode = MECH;
			makeGraphic(6, 12, FlxColor.WHITE);
			width = 6;
			height = 12;
			maxVelocity.set(MAX_MECH_SPEED, MAX_MECH_SPEED);
			drag.set(MECH_DRAG, MECH_DRAG);
			acceleration.set();
			velocity.set();
		}
		else if (mode == MECH)
		{
			mode = SHIP;
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
