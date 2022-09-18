import axollib.AxolAPI;
import djFlixel.D;
import djFlixel.gfx.RainbowStripes;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.Stripes;
import djFlixel.gfx.TextBouncer;
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class SplashState extends FlxState
{
	var rb:RainbowStripes;
	var logo:SpriteEffects;
	var logoWidth:Int = 114;
	var logoHeight:Int = 81;
	var madeIn:SpriteEffects;
	var madeInWidth:Int = 108;
	var madeInHeight:Int = 39;

	var tmpLogo:FlxSprite;
	var tmpMadeIn:FlxSprite;

	var hfLogo:SpriteEffects;
	var tb:TextBouncer;
	var sound:FlxSound;

	var COLOR_BG = Globals.COLORS[1];

	override function create()
	{
		bgColor = Globals.COLORS[0];

		if (AxolAPI.init != null)
		{
			AxolAPI.init();
		}
		AxolAPI.sendEvent("GameStart");

		super.create();

		// #if debug
		// exitState();
		// return;
		// #end

		add(new FlxSequencer((s) ->
		{
			switch (s.step)
			{
				case 1:
					hfLogo = new SpriteEffects('assets/images/HAXELOGO.png');
					// hfLogo.addEffect("wave", {time: 1.75, width: 2, height: 0.6});
					hfLogo.addEffect("blink", {open: true, time: 1.5}, s.nextV);

					// DEV: There is a bug with the wave effect. Somehow for a frame it draws the whole thing
					//      This is why I am delaying the adding a bit
					new DelayCall(0.1, () ->
					{
						add(D.align.screen(hfLogo));
					});

					tb = new TextBouncer("HAXEFLIXEL", 0, 0, {
						startY: -32,
						time: 1.5,
						timeL: 0.4,
						ease: "elasticOut",
						snd0: "hihat"
					});
					add(D.align.screen(tb));
					tb.y += 40;
					tb.start();
				case 2:
					D.snd.play('flixel', 0.5);
					s.next(4);
				case 3:
					camera.flash(0x0, 0.2, () ->
					{
						bgColor = COLOR_BG;
					});

					remove(hfLogo);
					remove(tb);
					s.next(0.4);
				case 4:
					rb = new RainbowStripes(logoWidth, logoHeight);
					rb.COLORS = Globals.COLORS.copy();
					rb.COLORS.splice(0, 2);

					logo = new SpriteEffects('assets/images/axol_logo.png');
					new DelayCall(0.1, () ->
					{
						add(D.align.screen(rb));
						add(D.align.screen(logo));
					});

					logo.addEffect("blink", {time: 1, open: true}, s.nextV);
					logo.addEffect("wave", {
						id: "wave",
						time: 1,
						width: 3,
						height: 0.5
					});
					logo.addEffect("mask", {id: "mask", colorBG: COLOR_BG});

					rb.setMode(2);
					rb.setOn();
				case 5:
					rb.setMode(0);
					s.next(0.4);
				case 6:
					rb.setMode(3);
					logo.removeEffectID("wave");
					logo.addEffect("noiseline", {
						id: "line",
						h0: 2,
						w0: 20,
						time: 0
					});
					s.next(0.5);
				case 7:
					remove(rb);
					remove(logo);

					tmpLogo = new FlxSprite('assets/images/axol_logo.png');
					tmpMadeIn = new FlxSprite('assets/images/madeinstlouis.png');

					add(D.align.screen(tmpLogo));
					add(D.align.screen(tmpMadeIn, "c", "b", 20));

					camera.flash(0xFFFFFFFF, 0.2);

					D.snd.play('madeinstl');
					s.next(4);
				case 8:
					logo = new SpriteEffects('assets/images/axol_logo.png');
					logo.addEffect("dissolve", {time: 1, size: 3,}, s.nextV);
					madeIn = new SpriteEffects('assets/images/madeinstlouis.png');
					madeIn.addEffect("dissolve", {time: 1, size: 3,});
					new DelayCall(0.1, () ->
					{
						remove(tmpLogo);
						remove(tmpMadeIn);
						add(D.align.screen(logo));
						add(D.align.screen(madeIn, "c", "b", 20));
					});
				case 9:
					remove(logo);
					remove(madeIn);

					var r = new RainbowStripes();
					add(r);
					r.setMode(2);
					r.setOn();
					sound = D.snd.play('8bitload');
					s.next(0.2);
					new DelayCall(0.7, () ->
					{
						sound.stop();
					});

				case 10:
					exitState();
			}
		}, 0));
	}

	public function exitState():Void
	{
		Stripes.CREATE(() -> Globals.gotoState(AxolAPI.firstState), {
			mode: "on,right",
			color: Globals.COLORS[0],
			snd: "hihat"
		});
	}
}
