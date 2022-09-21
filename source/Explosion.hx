package;

import djFlixel.D;
import djFlixel.other.FlxSequencer;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Explosion extends FlxSprite
{
	private var expSeq:FlxSequencer;

	public function new():Void
	{
		super();
		kill();
	}

	public function spawn(X:Float, Y:Float):Void
	{
		reset(X - 15, Y - 15);
		makeGraphic(30, 30, FlxColor.TRANSPARENT, true);

		D.snd.play("explosion");

		expSeq = (new FlxSequencer((s) ->
		{
			switch (s.step)
			{
				case 1:
					FlxSpriteUtil.drawCircle(this, -1, -1, 8, 0xfffbf236);
					s.next(0.1);
				case 2:
					FlxSpriteUtil.drawCircle(this, -1, -1, 10, 0xffdf7126);
					s.next(0.1);
				case 3:
					FlxSpriteUtil.drawCircle(this, -1, -1, 12, 0xffac3232);
					s.next(0.1);
				case 4:
					FlxSpriteUtil.drawCircle(this, -1, -1, 13, 0xff696a6a);
					s.next(0.1);
				case 5:
					FlxSpriteUtil.drawCircle(this, -1, -1, 14, 0xff595652);
					s.next(0.1);
				case 6:
					FlxSpriteUtil.drawCircle(this, -1, -1, 15, 0xff323c39);
					s.next(0.1);
				case 7:
					kill();
			}
		}, 0));
	}

	override function kill()
	{
		super.kill();
		expSeq = null;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive || !exists || expSeq == null)
			return;
		expSeq.update(elapsed);
	}
}
