package;

import djA.DataT;
import djFlixel.D;
import djFlixel.gfx.PanelPop;
import djFlixel.gfx.pal.Pal_DB32 as DB32;
import djFlixel.ui.UIIndicator;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

/**
	A Quick PANELPOL + FLXTEXT with MARKUP
**/
class InfoBox extends FlxSpriteGroup
{
	// Initial Parameters
	var P = {
		text: { // DTextStyle
			f: "assets/fonts/skullboy.ttf",
			s: 16,
			c: FlxColor.WHITE,
			bc: FlxColor.BLACK,
			a: "center"
		},
		colBG: 0xff222034,
		colF1: 0xfffbf236,
		colF2: 0xffd77bba,
		width: 260,
		height: 0, // 0 for AUTO
		padIn: 4 // Inner padding of text
	};

	var p:PanelPop; // Background
	var t:FlxText; // Text

	//--
	var boxWidth:Int;
	var boxHeight:Int;

	var m:UIIndicator; // Used as a Blinking Sprite

	/**
	 * Create and add to the state a text string at the bottom of the screen
	 * --> You need to call open() after
	 * @param TEXT The text to be displayed, supports formatting tags "$","#"
	 * @param PARAMS Override P fields
	 */
	public function new(TEXT:String = "", ?PARAMS:Dynamic)
	{
		super();

		P = DataT.copyFields(PARAMS, P);

		D.text.markupClear();

		#if html5
		D.text.HTML_FORCE_LEADING.set("assets/fonts/skullboy.ttf", [16, 4]);
		#end

		D.text.markupAdd("$", P.colF1, P.text.bc);
		D.text.markupAdd("#", P.colF2, P.text.bc);

		// --
		boxWidth = P.width;

		// -- Setup the Text
		t = D.text.get("", P.padIn, P.padIn, P.text);
		t.fieldWidth = boxWidth - P.padIn * 2;
		D.text.applyMarkup(t, TEXT);
		t.visible = false;

		// --
		boxHeight = P.height;
		if (boxHeight < 1)
		{
			boxHeight = Std.int(t.height + P.padIn * 2);
		}

		// -- BG Panel
		p = new PanelPop(boxWidth, boxHeight, {
			bm: new BitmapData(32, 32, false, P.colBG) // Flat box, because the default has a border
		});

		add(p);
		add(t);
	} //---------------------------------------------------;

	//-- Force set the text
	public function setText(TEXT:String)
	{
		D.text.applyMarkup(t, TEXT);

		if (t.height > boxHeight)
			FlxG.log.error('Warning: New text longer than bg');

		D.align.YAxis(t, p);
	} //---------------------------------------------------;

	/**
	 * @param	T text to show, optional
	 * @param	M Show MORE arrow, optional
	 */
	public function open(?T:String, M:Bool = false)
	{
		visible = true;
		t.visible = false;
		p.visible = true;
		p.clear(); // Just in case
		p.start(() ->
		{
			if (T != null)
				setText(T);
			t.visible = true;
			if (M)
				more();
		});
	} //---------------------------------------------------;

	// --
	// Shows the `more` sprite until new text has been set
	// You need to call this manually
	public function more()
	{
		if (m == null)
		{
			m = new UIIndicator(p.width, p.height);
			m.loadGraphic(D.gfx.colorizeBitmapWithTextStyle(D.ui.getIcon(8, "minus"), P.text));
			m.setAnim(3, {time: 0.2});
			add(m);
		}

		m.setEnabled();
	} //---------------------------------------------------;
} // --
