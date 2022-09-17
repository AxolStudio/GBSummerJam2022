package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	public static var GRAVITY:Float = 2200;

	public var player:Player;
	public var bg:FlxSprite;
	public var map:FlxTilemap;

	override public function create()
	{
		add(bg = FlxGridOverlay.create(16, 16, FlxG.width * 5, -1, true, Globals.COLORS[0], Globals.COLORS[1]));

		map = new FlxTilemap();
		map.loadMapFromCSV('assets/data/world_01.csv', 'assets/images/tiles.png', 8, 8, FlxTilemapAutoTiling.OFF, 0, 1, 1);
		add(map);

		add(player = new Player());

		player.x = 40;
		player.y = (FlxG.height / 2) - (player.height / 2);

		camera.setScrollBoundsRect(0, 0, map.width, FlxG.height, true);
		camera.follow(player, FlxCameraFollowStyle.LOCKON);

		super.create();

		FlxG.watch.add(player, "acceleration", "acceleration");
		FlxG.watch.add(player, "velocity", "velocity");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		updateMovement();
		checkBounds();

		FlxG.collide(player, map);
	}

	public function checkBounds():Void
	{
		if (player.x < 2)
		{
			player.x = 2;
		}
		else if (player.x > FlxG.worldBounds.width - player.width - 2)
		{
			player.x = FlxG.worldBounds.width - player.width - 2;
		}

		if (player.y < 2)
		{
			player.y = 2;
		}
		else if (player.y > FlxG.worldBounds.height - player.height - 2)
		{
			player.y = FlxG.worldBounds.height - player.height - 2;
		}
	}

	public function transform():Void
	{
		player.switchMode();
	}

	public function updateMovement():Void
	{
		var up:Bool = Actions.up.check();
		var down:Bool = Actions.down.check();
		var left:Bool = Actions.left.check();
		var right:Bool = Actions.right.check();

		if (Actions.transform.check())
		{
			transform();
		}

		if (player.mode == SHIP)
		{
			if (up && !down)
				player.acceleration.y = -Player.SHIP_ACC / 2;
			else if (down && !up)
				player.acceleration.y = Player.SHIP_ACC / 2;
			else if (!up && !down)
			{
				player.acceleration.y /= 20;
				if (Math.abs(player.acceleration.y) < 1)
					player.acceleration.y = 0;
			}
		}
		else
		{
			player.acceleration.y = GRAVITY;
		}

		if (left && !right)
			player.acceleration.x = -(player.mode == SHIP ? Player.SHIP_ACC : Player.MECH_ACC) / 2;
		else if (right && !left)
			player.acceleration.x = (player.mode == SHIP ? Player.SHIP_ACC : Player.MECH_ACC);
		else if (!right && !left)
		{
			player.acceleration.x /= 20;
			if (Math.abs(player.acceleration.x) < 1)
				player.acceleration.x = 0;
		}
	}
}
