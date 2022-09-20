package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxSpriteUtil;

class PlayerPunch extends FlxSprite
{
	public var colors:Array<FlxColor> = [0xff5b6ee1, 0xff5fcde4];

	public static var MAX_LIFESPAN:Float = .2;

	public var lifespan:Float = 0;

	public function new()
	{
		super();
		makeGraphic(12, 12, FlxColor.TRANSPARENT);
	}

	public function fire():Void
	{
		super.reset(getX(), getY());

		lifespan = 0;
	}

	override public function update(elapsed:Float):Void
	{
		x = getX();
		y = getY();
		super.update(elapsed);

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
		FlxSpriteUtil.drawCircle(this, -1, -1, 6, colors[Std.int(Globals.gameTimer * 10) % 2]);
	}

	private function getX():Float
	{
		return Globals.State.player.x + (Globals.State.player.facing == FlxDirection.RIGHT ? Globals.State.player.width : -width);
	}

	private function getY():Float
	{
		return Globals.State.player.y + (Globals.State.player.height / 2) - (height / 2);
	}
}
