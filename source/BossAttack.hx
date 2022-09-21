package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxSpriteUtil;

class BossAttack extends FlxSprite
{
	private var shootAngle:Float = 0;
	private var anchor:FlxPoint;
	private var endPoint:FlxPoint;
	private var wallHit:FlxPoint;
	private var dir:Int = 1;

	private var colors:Array<FlxColor> = [0xffac3232, 0xffdf7126, 0xfffbf236, 0xff6abe30, 0xff5fcde4, 0xff76428a];

	public function new():Void
	{
		super();
		wallHit = FlxPoint.get();
		endPoint = FlxPoint.get();
	}

	public function spawn(X:Float, Y:Float, Facing:FlxDirection):Void
	{
		reset(X + (Facing == LEFT ? -PlayState.SCREEN_WIDTH + 2 : -2), Y - (PlayState.SCREEN_HEIGHT / 2));

		dir = Facing == LEFT ? 1 : -1;

		anchor = FlxPoint.get(X, Y);

		makeGraphic(PlayState.SCREEN_WIDTH, PlayState.SCREEN_HEIGHT, FlxColor.TRANSPARENT, true);
		shootAngle = 90;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		makeGraphic(Std.int(PlayState.SCREEN_WIDTH / 2), PlayState.SCREEN_HEIGHT, FlxColor.TRANSPARENT, true);

		(endPoint : FlxVector).setPolarDegrees(PlayState.SCREEN_WIDTH, shootAngle);
		endPoint.x += anchor.x;
		endPoint.y += anchor.y;

		var whichMap:FlxTilemap = x >= 0 && x <= PlayState.WORLD_WIDTH ? Globals.State.mapA : Globals.State.mapB;
		var madeIt:Bool = whichMap.ray(anchor, endPoint, wallHit);
		if (!madeIt)
		{
			// we hit the wall
			FlxSpriteUtil.drawLine(this, anchor.x - x, anchor.y - y, wallHit.x - x, wallHit.y - y,
				{thickness: 3, color: colors[Std.int(Globals.gameTimer * 10) % colors.length]});

			// sparks at the wall?
		}
		else
		{
			FlxSpriteUtil.drawLine(this, anchor.x - x, anchor.y - y, endPoint.x - x, endPoint.y - y,
				{thickness: 3, color: colors[Std.int(Globals.gameTimer * 10) % colors.length]});
		}

		shootAngle += 5 * dir;

		if ((dir == 1 && shootAngle > 270) || (dir == -1 && shootAngle < -90))
		{
			kill();
		}
	}
}
