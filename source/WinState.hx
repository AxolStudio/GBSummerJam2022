package;

import djFlixel.D;
import djFlixel.gfx.Stripes;
import djFlixel.other.DelayCall;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;

class WinState extends FlxState
{
	public var box:InfoBox;

	private var leaving:Bool = false;

	override public function create():Void
	{
		bgColor = 0xff639bff;
		super.create();

		box = new InfoBox("Mission Successful!\n\n$[ Press Any Key to Continue ]$");
		add(D.align.screen(box));
		new DelayCall(0.2, () ->
		{
			box.open();
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([ANY]) && !leaving)
		{
			leaving = true;
			Stripes.CREATE(() -> Globals.gotoState(TitleState), {
				mode: "on,out",
				color: Globals.COLORS[0],
				snd: "hihat"
			});
		}
	}
}
