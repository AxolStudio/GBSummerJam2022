import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class PlayerLaser extends FlxSprite
{
	public var colors:Array<FlxColor> = [0xff5b6ee1, 0xff5fcde4];

	public static var SPEED:Float = 400;
	public static var MAX_WIDTH:Float = 32;
	public static var MAX_LIFESPAN:Float = 3;

	public var lifespan:Float = 0;

	public function new()
	{
		super();
	}

	public function fire(X:Float, Y:Float, Facing:FlxDirectionFlags):Void
	{
		super.reset(X, Y);
		width = 1;
		facing = Facing;
		velocity.x = SPEED * (facing == FlxDirectionFlags.RIGHT ? 1 : -1);
		lifespan = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (facing == FlxDirectionFlags.LEFT && width < MAX_WIDTH)
		{
			x -= (SPEED * .5) * elapsed;
		}
		width = Math.min(width + (SPEED * .5) * elapsed, MAX_WIDTH);

		lifespan += elapsed;
		if (lifespan >= MAX_LIFESPAN)
			kill();
	}

	override public function draw():Void
	{
		updateGraphic();
		super.draw();
	}

	public function updateGraphic():Void
	{
		makeGraphic(Std.int(width), 2, colors[Std.int(Globals.gameTimer * 10) % 2]);
	}
}
