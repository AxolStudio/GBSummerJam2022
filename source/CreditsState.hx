package;

import djFlixel.D;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.Stripes;
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

class CreditsState extends FlxState
{
	private var box:InfoBox;
	private var box2:InfoBox;
	private var box3:InfoBox;
	private var box4:InfoBox;
	private var box5:InfoBox;
	private var box6:InfoBox;
	private var logo:SpriteEffects;

	private var leaving:Bool = false;

	override function create()
	{
		super.create();

		var str:String = "This game was made in 1 week during the $Goodbye Summer Game Jam 2022$!";
		box = new InfoBox(str);
		add(D.align.screen(box, "c", "t", 5));

		box2 = new InfoBox("The theme was $Transition$");
		add(D.align.screen(box2, "c", "t", box.y + box.height));

		box3 = new InfoBox("The game was made by \n #Tim Hely# with music by #Elliot Hely#");
		add(D.align.screen(box3, "c", "t", box2.y + box2.height));

		logo = new SpriteEffects('assets/images/axol_logo.png');

		box5 = new InfoBox("$axolstudio.com$");
		add(D.align.screen(box5, "c", "t", box3.y + box3.height + 80));

		box6 = new InfoBox("Thanks for playing!\n$[ Press ANY KEY to Return ]$");
		add(D.align.screen(box6, "c", "b", 5));

		add(new FlxSequencer((s) ->
		{
			switch (s.step)
			{
				case 1:
					s.next(0.5);
				case 2:
					box.open();
					s.next(0.5);
				case 3:
					box2.open();
					s.next(0.5);
				case 4:
					box3.open();
					s.next(0.5);
				case 5:
					logo.addEffect("blink", {time: 1, open: true});
					new DelayCall(0.1, () ->
					{
						add(D.align.screen(logo, "c", "t", box3.y + box3.height + 5));
					});

					s.next(0.5);
				case 6:
					box5.open();
					s.next(0.5);
				case 7:
					box6.open();
			}
		}, 0));
	}

	override function update(elapsed:Float)
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
