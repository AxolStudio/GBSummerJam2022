package;

import axollib.AxolAPI;
import djFlixel.D;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		AxolAPI.firstState = PlayState;
		AxolAPI.init = Globals.initGame;

		D.init({
			name: "GBSummerJam2022 " + D.DJFLX_VER,
			smoothing: false
		});

		Lib.application.window.onClose.add(() ->
		{
			AxolAPI.sendEvent("GameExited");
		});

		addChild(new FlxGame(320, 240, SplashState, 6, 60, 60, true));
	}
}
