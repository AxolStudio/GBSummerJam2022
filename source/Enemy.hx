import flixel.FlxSprite;
import flixel.util.FlxColor;

class Enemy extends FlxSprite
{
	public var enemyType:EnemyType;

	public function new():Void
	{
		super();
	}

	public function spawn(X:Float, Y:Float, EnemyType:EnemyType):Void
	{
		reset(X, Y);
		enemyType = EnemyType;
		// loadGraphic(enemyType.image, true, true, 16, 16);
		makeGraphic(16, 16, switch (enemyType)
		{
			case FLYER: 0xffac3232;
			case WALKER: 0xff76428a;
			case SHOOTER: 0xffdf7126;
		}, false, enemyType);
	}
}

@:enum abstract EnemyType(String) from String to String
{
	var FLYER = "FLYER";
	var WALKER = "WALKER";
	var SHOOTER = "SHOOTER";
}
