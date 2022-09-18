package;

import Enemy.EnemyType;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;

class PlayState extends FlxState
{
	public static var GRAVITY:Float = 2200;

	public var player:Player;
	public var bg:FlxSprite;
	public var level:TiledLevel;

	public var playerAttacks:FlxTypedGroup<PlayerLaser>;
	public var enemies:FlxTypedGroup<Enemy>;
	public var mapLayer:FlxTypedGroup<FlxTilemap>;

	override public function create()
	{
		add(bg = FlxGridOverlay.create(16, 16, FlxG.width * 5, -1, true, Globals.COLORS[0], Globals.COLORS[1]));

		// map = new FlxTilemap();
		// map.loadMapFromCSV('assets/data/world_01.csv', 'assets/images/tiles.png', 8, 8, FlxTilemapAutoTiling.OFF, 0, 1, 1);
		// add(map);
		add(mapLayer = new FlxTypedGroup<FlxTilemap>());
		add(playerAttacks = new FlxTypedGroup<PlayerLaser>());
		add(enemies = new FlxTypedGroup<Enemy>());

		level = new TiledLevel("assets/data/world_01.tmx", this);

		add(player = new Player());

		player.x = 40;
		player.y = (FlxG.height / 2) - (player.height / 2);

		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);

		super.create();

		FlxG.watch.add(player, "acceleration", "acceleration");
		FlxG.watch.add(player, "velocity", "velocity");
		FlxG.watch.add(player, "thrust", "thrust");
	}

	public function fireLaser()
	{
		if (player.laserCooldown > 0)
			return;
		player.laserCooldown = Player.LASER_COOLDOWN_TIME;

		var laser:PlayerLaser = playerAttacks.getFirstAvailable(PlayerLaser);
		if (laser == null)
		{
			laser = new PlayerLaser();
			playerAttacks.add(laser);
		}

		laser.fire(player.x + (player.facing == FlxDirectionFlags.RIGHT ? player.width + 1 : -1), Std.int(player.y + (player.height / 2)) - 1, player.facing);
	}

	public function addEnemy(X:Float, Y:Float, EnemyType:EnemyType):Void
	{
		var enemy:Enemy = enemies.getFirstAvailable(Enemy);
		if (enemy == null)
		{
			enemy = new Enemy();
			enemies.add(enemy);
		}

		enemy.spawn(X, Y, EnemyType);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		Globals.gameTimer += elapsed;

		// FlxG.collide(player, map);

		updateMovement(elapsed);

		checkBounds();
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

	public function updateMovement(elapsed:Float):Void
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
				player.acceleration.y = -Player.SHIP_ACC / 5;
			else if (down && !up)
				player.acceleration.y = Player.SHIP_ACC / 5;
			else if (!up && !down)
			{
				player.acceleration.y /= 50;
				if (Math.abs(player.acceleration.y) < 1)
					player.acceleration.y = 0;
			}

			if (Actions.attack.check())
			{
				fireLaser();
			}
		}
		else
		{
			if (Actions.thrust.check())
			{
				if (player.thrust < player.thrustMax)
				{
					player.velocity.y = -Player.MECH_THRUST;
					player.thrust += elapsed;
				}
			}
			else if (player.thrust > 0)
			{
				player.thrust -= elapsed * 2;
				player.thrust = Math.max(0, player.thrust);
			}
		}

		if (left && !right)
			player.acceleration.x = -(player.mode == SHIP ? Player.SHIP_ACC : Player.MECH_ACC) / 2;
		else if (right && !left)
			player.acceleration.x = (player.mode == SHIP ? Player.SHIP_ACC : Player.MECH_ACC);
		else if (!right && !left)
		{
			player.acceleration.x /= (player.mode == SHIP ? 20 : 50);
			if (Math.abs(player.acceleration.x) < 1)
				player.acceleration.x = 0;
		}
	}
}
