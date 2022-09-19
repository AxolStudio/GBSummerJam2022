package;

import axollib.AxolAPI;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.utils.ByteArray;

@:file("keys/axolapi") class AxolKey extends ByteArrayData {}

class Globals
{
	public static var gameTimer:Float = 0;

	static private var axolBytes = new AxolKey();

	static private var AXOL_KEY:String = StringTools.replace(axolBytes.readUTFBytes(axolBytes.length), "\n", "");

	public static var gameInitialized:Bool = false;

	public static var State:PlayState;

	// DB32 COLOR PALETTE
	public static var COLORS:Array<FlxColor> = [
		0xff000000, 0xff222034, 0xff45283c, 0xff323c39, 0xff663931, 0xff3f3f74, 0xff524b24, 0xffac3232, 0xff76428a, 0xff595652, 0xff306082, 0xff8f563b,
		0xff4b692f, 0xff696a6a, 0xff8a6f30, 0xffd95763, 0xff5b6ee1, 0xff847e87, 0xff37946e, 0xffdf7126, 0xff8f974a, 0xffd77bba, 0xff639bff, 0xffd9a066,
		0xff6abe30, 0xff9badb7, 0xff5fcde4, 0xffeec39a, 0xff99e550, 0xffcbdbfc, 0xfffbf236, 0xffffffff
	];

	public inline static function initGame():Void
	{
		if (gameInitialized)
			return;

		AxolAPI.initialize(AXOL_KEY);

		FlxG.autoPause = false;

		Actions.init();

		FlxG.camera.pixelPerfectRender = true;

		gameInitialized = true;
	}

	public static function gotoState(S:Class<FlxState>, ?Effect:String):Void
	{
		switch (Effect)
		{
			default:
				FlxG.switchState(Type.createInstance(S, []));
		}
	}
}
