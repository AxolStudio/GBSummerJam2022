package;

#if !html5
import lime.system.System;
#end
import djFlixel.D;
import djFlixel.gfx.RainbowStripes;
import djFlixel.gfx.SpriteEffects;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.Stripes;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.IListItem.ListItemEvent;
import djFlixel.ui.MPlug_Audio;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import haxe.ds.ArraySort;
import openfl.display.BitmapData;

class TitleState extends FlxState
{
	public var letters:Array<FlxSprite> = [];
	public var subtitle:FlxSprite;

	public var stars:StarfieldSimple;

	public var mask:FlxSprite;
	public var colors:BitmapData;
	public var colorSprite:FlxSprite;
	public var overlay:FlxSprite;
	public var copy:FlxSprite;

	public var mech:FlxSprite;
	public var ship:FlxSprite;

	public var doTransfer:Bool = false;

	override public function create():Void
	{
		bgColor = 0xff222034;

		add(stars = new StarfieldSimple(FlxG.width, FlxG.height, [0xff222034, 0xff5fcde4, 0xffffffff, 0xfffbf236]));
		stars.STAR_SPEED = 2;
		stars.STAR_ANGLE = -90;
		stars.WIDE_PIXEL = true;

		addLetter("S");
		addLetter("R2");

		addLetter("T");
		addLetter("E");

		addLetter("A1");
		addLetter("D");

		addLetter("R1");
		addLetter("N");

		addLetter("M");
		addLetter("A2");

		var c:Array<FlxColor> = [
			0xffac3232, 0xff76428a, 0xffd95763, 0xff5b6ee1, 0xff37946e, 0xffdf7126, 0xffd77bba, 0xff639bff, 0xffd9a066, 0xff6abe30, 0xff5fcde4, 0xff99e550,
			0xfffbf236
		];
		ArraySort.sort(c, (a, b) -> Std.int(a.hue - b.hue));
		c.push(c[0]);

		colors = FlxGradient.createGradientBitmapData(FlxG.width, 1, c, 1, 0, false);
		mask = new FlxSprite("assets/images/MASK.png");

		colorSprite = new FlxSprite();
		colorSprite.makeGraphic(Std.int(mask.width), Std.int(mask.height), FlxColor.TRANSPARENT);

		add(subtitle = new FlxSprite(0, 0, "assets/images/subtitle.png"));
		subtitle.x = letters[0].x;
		subtitle.y = letters[0].y;

		overlay = new FlxSprite("assets/images/OVERLAY.png");

		super.create();

		FlxG.camera.fade(FlxColor.BLACK, .2, true, startAnims);
	}

	public function createMenu():Void
	{
		var m:FlxMenu = new FlxMenu(56, 156);
		m.PAR.start_button_fire = true;

		add(m);

		m.createPage('main')
			.add('
            -|New Game  |link|id_newGame
            -|Credits   |link|id_credits' #if !html5
				+ '-|Quit      |link|id_quit | ?pop=Really?:Yes:No' #end);

		m.STP.item_pad = 2;

		m.STP.item.text = {
			f: "assets/fonts/skullboy.ttf",
			s: 16,
			bt: 2,
			bc: 0xff45283c
		};
		m.STP.item.col_t = {
			idle: FlxColor.WHITE,
			focus: 0xfffbf236,
			accent: FlxColor.WHITE,
			dis: 0xff696a6a,
			dis_f: 0xff9badb7
		};

		m.plug(new MPlug_Audio({
			pageCall: 'cursor_high',
			back: 'cursor_low',
			it_fire: 'cursor_high',
			it_focus: 'cursor_tick',
			it_invalid: 'cursor_error'
		}));

		m.onItemEvent = (a, item) ->
		{
			if (a == ListItemEvent.fire)
			{
				D.snd.play("title_select");
				switch (item.ID)
				{
					case "id_newGame":
						Stripes.CREATE(() -> Globals.gotoState(PlayState), {
							mode: "on,in",
							color: Globals.COLORS[0],
							snd: "hihat"
						});

					case "id_credits":
						Stripes.CREATE(() -> Globals.gotoState(CreditsState), {
							mode: "on,in",
							color: Globals.COLORS[0],
							snd: "hihat"
						});
					#if !html5
					case "id_quit":
						Stripes.CREATE(() -> System.exit(0), {
							mode: "on,in",
							color: Globals.COLORS[0],
							snd: "hihat"
						});
					#end

					default:
				}
			}
		};

		m.goto("main");
	}

	public function addLetter(Letter:String):Void
	{
		var letter:FlxSprite = new FlxSprite(0, 0, "assets/images/" + Letter + ".png");
		letter.x = FlxG.width / 2 - letter.width / 2;
		letter.y = -letter.height;

		add(letter);
		letters.push(letter);
	}

	public function startAnims():Void
	{
		add(new FlxSequencer((s) ->
		{
			switch (s.step)
			{
				case 1:
					FlxTween.tween(letters[letters.length - 1], {y: 10}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
					FlxTween.tween(letters[letters.length - 2], {y: 10}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut});
				case 2:
					D.snd.play("title_drop");
					FlxTween.tween(letters[letters.length - 3], {y: 10}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
					FlxTween.tween(letters[letters.length - 4], {y: 10}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut});
				case 3:
					D.snd.play("title_drop");
					FlxTween.tween(letters[letters.length - 5], {y: 10}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
					FlxTween.tween(letters[letters.length - 6], {y: 10}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut});
				case 4:
					D.snd.play("title_drop");

					FlxTween.tween(letters[letters.length - 7], {y: 10}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
					FlxTween.tween(letters[letters.length - 8], {y: 10}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut});
				case 5:
					D.snd.play("title_drop");

					FlxTween.tween(letters[letters.length - 9], {y: 10}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
					FlxTween.tween(letters[letters.length - 10], {y: 10}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut});
				case 6:
					add(colorSprite);
					colorSprite.x = letters[0].x;
					colorSprite.y = letters[0].y;
					transferColors();
					doTransfer = true;
					add(overlay);
					overlay.x = letters[0].x;
					overlay.y = letters[0].y;
					D.snd.play("title_drop");
					D.snd.play("title_crash");
					camera.flash(FlxColor.WHITE, 0.2, () ->
					{
						s.next();
					});
				case 7:
					FlxTween.tween(subtitle, {y: letters[0].y + letters[0].height + 8}, .2,
						{type: FlxTweenType.ONESHOT, ease: FlxEase.elasticOut, onComplete: (_) -> s.next()});
				case 8:
					D.snd.play("title_drop");
					add(copy = new FlxSprite("assets/images/copyright.png"));
					copy.x = 8;
					copy.y = FlxG.height - copy.height - 8;

					add(mech = new FlxSprite("assets/images/mech.png"));
					mech.x = FlxG.width;
					mech.y = FlxG.height - mech.height;

					FlxTween.tween(mech, {x: copy.x + copy.width + 8}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.quartIn});

					add(ship = new FlxSprite("assets/images/ship.png"));
					ship.x = FlxG.width;
					ship.y = FlxG.height - ship.height;

					FlxTween.tween(ship, {x: FlxG.width - ship.width - 10}, .2, {
						type: FlxTweenType.ONESHOT,
						ease: FlxEase.quartIn,
						startDelay: .1,
						onComplete: (_) -> s.next()
					});

				case 9:
					createMenu();
			}
		}, 0));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (doTransfer)
		{
			transferColors();
		}
	}

	public function transferColors():Void
	{
		var start:Int = Std.int(FlxG.game.ticks / 10) % colors.width;
		for (y in 0...Std.int(colorSprite.height))
		{
			for (x in 0...Std.int(colorSprite.width))
			{
				var color:FlxColor = colors.getPixel32((start + x + y) % colors.width, 0);
				var maskColor:FlxColor = mask.pixels.getPixel32(x, y);
				if (maskColor.alpha > 0)
				{
					colorSprite.pixels.setPixel32(x, y, color);
				}
			}
		}
		colorSprite.dirty = true;
	}
}
