package;

import Enemy.EnemyType;
import djFlixel.D;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.Stripes;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;

class PlayState extends FlxState
{
	public static var WORLD_WIDTH:Int = 4256;
	public static var WORLD_HEIGHT:Int = 1120;

	public static var SCREEN_WIDTH:Int = 426;
	public static var SCREEN_HEIGHT:Int = 240;

	public static var GRAVITY:Float = 2200;

	public var isUnderground:Bool = false;

	public var player:Player;

	public var bg:FlxSprite;
	public var level:TiledLevel;

	public var mapA:FlxTilemap;
	public var mapB:FlxTilemap;

	public var playerAttacks:FlxTypedGroup<FlxSprite>;
	public var enemies:FlxTypedGroup<Enemy>;
	public var mapLayer:FlxTypedGroup<FlxTilemap>;
	public var enemyAttacks:FlxTypedGroup<EnemyBullet>;
	public var healthPickups:FlxTypedGroup<Health>;
	public var explosions:FlxTypedGroup<Explosion>;
	public var thrusts:FlxTypedGroup<Thrust>;
	public var bossAttacks:FlxTypedGroup<BossAttack>;

	public var ui:FlxGroup;

	public var shipHPBar:FlxSprite;
	public var shipHPBarBG:FlxSprite;

	public var mechHPBar:FlxSprite;
	public var mechHPBarBG:FlxSprite;

	public var thrustBar:FlxSprite;
	public var thrustBarBG:FlxSprite;

	public var stars:StarfieldSimple;

	public var bossCounter:Array<FlxSprite>;

	public var leaving:Bool = false;

	public var thrustSnd:FlxSound;

	public var punches:Array<Int> = [1, 2, 3];

	public var mechUI:FlxSprite;
	public var shipUI:FlxSprite;

	override public function create()
	{
		Globals.State = this;

		add(stars = new StarfieldSimple(SCREEN_WIDTH, SCREEN_HEIGHT, [0xff222034, 0xff5fcde4, 0xffffffff, 0xfffbf236]));
		stars.scrollFactor.x = 0;

		add(bg = new FlxSprite());
		bg.makeGraphic(SCREEN_WIDTH, WORLD_HEIGHT - SCREEN_HEIGHT, 0xff663931);
		bg.scrollFactor.x = 0;
		bg.y = SCREEN_HEIGHT;

		add(mapLayer = new FlxTypedGroup<FlxTilemap>());
		add(explosions = new FlxTypedGroup<Explosion>());
		add(playerAttacks = new FlxTypedGroup<FlxSprite>());
		add(enemies = new FlxTypedGroup<Enemy>());

		level = new TiledLevel("assets/data/world_01.tmx", this);

		FlxG.worldBounds.set(-SCREEN_WIDTH, 0, WORLD_WIDTH + (SCREEN_WIDTH * 2), WORLD_HEIGHT);

		mapA.y = mapB.y = 0;
		mapA.x = 0;
		mapB.x = mapA.x - mapB.width;

		add(thrusts = new FlxTypedGroup<Thrust>());
		add(player = new Player());

		player.x = 40;
		player.y = (FlxG.height / 2) - (player.height / 2);

		FlxG.camera.focusOn(player.getMidpoint());
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);
		FlxG.camera.setScrollBounds(-SCREEN_WIDTH, WORLD_WIDTH + (SCREEN_WIDTH * 2), 0, SCREEN_HEIGHT);

		add(enemyAttacks = new FlxTypedGroup<EnemyBullet>());
		add(bossAttacks = new FlxTypedGroup<BossAttack>());
		add(healthPickups = new FlxTypedGroup<Health>());

		add(ui = new FlxGroup());
		buildUI();

		transferObjects();

		super.create();
	}

	public function startBossAttack(X:Float, Y:Float, Facing:FlxDirection):Void
	{
		var attack:BossAttack = bossAttacks.getFirstAvailable();
		if (attack == null)
		{
			attack = new BossAttack();
			bossAttacks.add(attack);
		}
		attack.spawn(X, Y, Facing);
	}

	public function spawnThrust(X:Float, Y:Float):Void
	{
		var thrust:Thrust = thrusts.getFirstAvailable();
		if (thrust == null)
		{
			thrust = new Thrust();
			thrusts.add(thrust);
		}

		thrust.spawn(X, Y);
	}

	public function spawnExplosion(X:Float, Y:Float):Void
	{
		var explosion:Explosion = explosions.getFirstAvailable();
		if (explosion == null)
		{
			explosion = new Explosion();
			explosions.add(explosion);
		}
		explosion.spawn(X, Y);
	}

	public function buildUI():Void
	{
		ui.add(shipHPBarBG = new FlxSprite());
		shipHPBarBG.makeGraphic(102, 6, 0xffac3232);
		shipHPBarBG.x = 6;
		shipHPBarBG.y = 2;
		shipHPBarBG.scrollFactor.set();

		ui.add(shipHPBar = new FlxSprite());
		shipHPBar.makeGraphic(100, 4, 0xffd95763);
		shipHPBar.x = 7;
		shipHPBar.y = 3;
		shipHPBar.scrollFactor.set();
		shipHPBar.origin.x = 0;

		add(shipUI = new FlxSprite(2, 2));
		shipUI.loadGraphic("assets/images/ship_hud.png", true, 6, 6);
		shipUI.scrollFactor.set();

		ui.add(mechHPBarBG = new FlxSprite());
		mechHPBarBG.makeGraphic(102, 6, 0xffac3232);
		mechHPBarBG.x = 6;
		mechHPBarBG.y = 9;
		mechHPBarBG.scrollFactor.set();

		ui.add(mechHPBar = new FlxSprite());
		mechHPBar.makeGraphic(100, 4, 0xffd95763);
		mechHPBar.x = 7;
		mechHPBar.y = 10;
		mechHPBar.scrollFactor.set();
		mechHPBar.origin.x = 0;

		add(mechUI = new FlxSprite(2, 9, "assets/images/mech_hud.png"));
		mechUI.scrollFactor.set();

		ui.add(thrustBarBG = new FlxSprite());
		thrustBarBG.makeGraphic(4, 12, 0xff3f3f74);
		thrustBarBG.visible = false;
		// thrustBarBG.x = 2;
		// thrustBarBG.y = 16;
		// thrustBarBG.scrollFactor.set();

		ui.add(thrustBar = new FlxSprite());
		thrustBar.makeGraphic(2, 10, 0xff639bff);
		thrustBar.origin.y = 10;
		thrustBar.visible = false;

		var bossCount:Int = enemies.members.filter((e) -> e.enemyType == BOSS && e.alive).length;
		bossCounter = [];
		var icon:FlxSprite;
		for (i in 0...bossCount)
		{
			icon = new FlxSprite(FlxG.width - 10 - (i * 8), 2);
			icon.makeGraphic(6, 6, 0xff5fcde4);
			icon.scrollFactor.set();
			bossCounter.push(icon);
			ui.add(icon);
		}
	}

	public function dropHealth(X:Float, Y:Float):Void
	{
		var health:Health = healthPickups.getFirstAvailable(Health);
		if (health == null)
		{
			health = new Health();
			healthPickups.add(health);
		}
		health.spawn(X + 2, Y + 1);
	}

	public function fireEnemyBullet(X:Float, Y:Float, Angle:Float):Void
	{
		var bullet:EnemyBullet = enemyAttacks.getFirstAvailable(EnemyBullet);
		if (bullet == null)
		{
			bullet = new EnemyBullet();
			enemyAttacks.add(bullet);
		}
		bullet.fire(X, Y, Angle);
		if (bullet.isOnScreen())
			D.snd.play("enemy_shoot", 0.01);
	}

	public function fireLaser():Void
	{
		if (player.laserCooldown > 0)
			return;

		D.snd.play('laser');

		player.laserCooldown = Player.LASER_COOLDOWN_TIME;

		var laser:PlayerLaser = cast playerAttacks.getFirstAvailable(PlayerLaser);
		if (laser == null)
		{
			laser = new PlayerLaser();
			playerAttacks.add(laser);
		}

		laser.fire(player.x + (player.facing == FlxDirectionFlags.RIGHT ? player.width + 1 : -1), Std.int(player.y + (player.height / 2)) - 1, player.facing);
	}

	public function playerPunch():Void
	{
		if (player.punchCooldown > 0)
			return;

		var n:Int = punches.shift();
		D.snd.play('punch_$n');
		punches.push(n);
		if (n == 1)
			player.animation.frameIndex = player.animFrames.get("punch-2");
		else
			player.animation.frameIndex = player.animFrames.get("punch-1");

		player.punchCooldown = Player.PUNCH_COOLDOWN_TIME;
		player.justPunchedCooldown = Player.JUSTPUNCHED_COOLDOWN_TIME;

		var punch:PlayerPunch = cast playerAttacks.getFirstAvailable(PlayerPunch);
		if (punch == null)
		{
			punch = new PlayerPunch();
			playerAttacks.add(punch);
		}

		punch.fire();
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

		if (leaving)
			return;

		Globals.gameTimer += elapsed;

		FlxG.collide(mapLayer, enemyAttacks, onEnemyAttackHitWall);
		FlxG.collide(mapLayer, player, onPlayerHitWall);
		FlxG.collide(mapLayer, playerAttacks, onPlayerAttackHitMap);

		FlxG.overlap(enemies, player, enemyHitPlayer, didEnemyHitPlayer);
		FlxG.overlap(playerAttacks, enemies, playerAttackHitEnemy, didPlayerAttackHitEnemy);
		FlxG.overlap(enemyAttacks, player, enemyAttackHitPlayer, didEnemyAttackHitPlayer);
		FlxG.overlap(bossAttacks, player, bossAttackHitPlayer, didBossAttackHitPlayer);

		FlxG.overlap(player, healthPickups, playerHitHealth, didPlayerHitHealth);

		updateMovement(elapsed);

		checkBounds();

		updateUI();

		updatePlayerPos();

		stars.STAR_SPEED = (player.velocity.x / Player.MAX_SHIP_SPEED);

		if (!player.alive)
		{
			leaving = true;
			Stripes.CREATE(() -> Globals.gotoState(LoseState), {
				mode: "on,out",
				color: 0xffac3232,
				snd: "hihat"
			});
		}
	}

	private function didBossAttackHitPlayer(BA:BossAttack, P:Player):Bool
	{
		if (BA.alive && P.alive && P.justHurt <= 0)
		{
			return FlxG.pixelPerfectOverlap(BA, P);
		}
		return false;
	}

	private function bossAttackHitPlayer(BA:BossAttack, P:Player):Void
	{
		P.hurt(10);
	}

	private function didPlayerHitHealth(Player:Player, Health:Health):Bool
	{
		return Player.alive && Health.alive;
	}

	private function playerHitHealth(P:Player, H:Health):Void
	{
		H.kill();

		D.snd.play('get_health');

		if (P.mechHealth < Player.MAX_HEALTH)
		{
			P.mechHealth += 20;
			if (P.mechHealth > Player.MAX_HEALTH)
				P.mechHealth = Player.MAX_HEALTH;
		}
		else if (P.shipHealth < Player.MAX_HEALTH)
		{
			P.shipHealth += 20;
			if (P.shipHealth > Player.MAX_HEALTH)
				P.shipHealth = Player.MAX_HEALTH;
		}
	}

	public function updatePlayerPos():Void
	{
		if (player.x > WORLD_WIDTH)
		{
			player.x -= WORLD_WIDTH;
			FlxG.camera.focusOn(player.getMidpoint());
		}
		else if (player.x < 0)
		{
			player.x += WORLD_WIDTH;
			FlxG.camera.focusOn(player.getMidpoint());
		}

		if (player.x > WORLD_WIDTH / 2)
		{
			mapB.x = mapA.x + mapA.width;
			transferObjects();
		}
		else if (player.y < WORLD_WIDTH / 2)
		{
			mapB.x = mapA.x - mapB.width;
			transferObjects();
		}
	}

	public function transferObjects():Void
	{
		if (player.x < SCREEN_WIDTH)
		{
			for (e in enemies.members.filter((e) ->
			{
				return e.alive && e.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				e.x -= WORLD_WIDTH;

			for (l in playerAttacks.members.filter((l) ->
			{
				return l.alive && l.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				l.x -= WORLD_WIDTH;

			for (l in enemyAttacks.members.filter((l) ->
			{
				return l.alive && l.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				l.x -= WORLD_WIDTH;

			for (h in healthPickups.members.filter((h) ->
			{
				return h.alive && h.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				h.x -= WORLD_WIDTH;

			for (e in explosions.members.filter((e) ->
			{
				return e.alive && e.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				e.x -= WORLD_WIDTH;

			for (t in thrusts.members.filter((t) ->
			{
				return t.alive && t.x > WORLD_WIDTH - SCREEN_WIDTH;
			}))
				t.x -= WORLD_WIDTH;
		}
		else if (player.x > WORLD_WIDTH - SCREEN_WIDTH)
		{
			for (e in enemies.members.filter((e) ->
			{
				return e.alive && e.x < SCREEN_WIDTH;
			}))
				e.x += WORLD_WIDTH;

			for (l in playerAttacks.members.filter((l) ->
			{
				return l.alive && l.x < SCREEN_WIDTH;
			}))
				l.x += WORLD_WIDTH;

			for (l in enemyAttacks.members.filter((l) ->
			{
				return l.alive && l.x < SCREEN_WIDTH;
			}))
				l.x += WORLD_WIDTH;

			for (h in healthPickups.members.filter((h) ->
			{
				return h.alive && h.x < SCREEN_WIDTH;
			}))
				h.x += WORLD_WIDTH;

			for (e in explosions.members.filter((e) ->
			{
				return e.alive && e.x < SCREEN_WIDTH;
			}))
				e.x += WORLD_WIDTH;

			for (t in thrusts.members.filter((t) ->
			{
				return t.alive && t.x < SCREEN_WIDTH;
			}))
				t.x += WORLD_WIDTH;
		}
	}

	public function updateUI()
	{
		shipHPBar.scale.x = FlxMath.bound(player.shipHealth / Player.MAX_HEALTH, 0, 1);
		mechHPBar.scale.x = FlxMath.bound(player.mechHealth / Player.MAX_HEALTH, 0, 1);
		thrustBar.scale.y = FlxMath.bound(1 - (player.thrust / player.thrustMax), 0, 1);
		if (player.thrust > 0)
		{
			thrustBarBG.x = player.x + (player.facing == RIGHT ? -6 : player.width + 2);
			thrustBarBG.y = player.y;
			thrustBar.x = thrustBarBG.x + 1;
			thrustBar.y = thrustBarBG.y + 1;
			thrustBarBG.visible = thrustBar.visible = true;
		}
		else
		{
			thrustBarBG.visible = thrustBar.visible = false;
		}

		shipUI.animation.frameIndex = player.shipHealth < 10 ? 1 : 0;
	}

	private function onPlayerHitWall(T:FlxTilemap, P:Player):Void
	{
		if (P.mode == SHIP)
			P.hurt(100);
	}

	private function onEnemyAttackHitWall(Map:FlxTilemap, Attack:EnemyBullet):Void
	{
		Attack.kill();
		D.snd.play("wall");
	}

	private function onPlayerAttackHitMap(Map:FlxTilemap, Attack:PlayerLaser):Void
	{
		Attack.kill();
		D.snd.play("wall");
	}

	private function enemyHitPlayer(E:Enemy, P:Player):Void
	{
		if (E.enemyType != BOSS)
		{
			P.hurt(10);
			E.kill();
			spawnExplosion(E.x + 4, E.y + 4);
		}
		else
			P.hurt(100);
	}

	private function didEnemyHitPlayer(E:Enemy, P:Player):Bool
	{
		return E.alive && P.alive;
	}

	private function playerAttackHitEnemy(L:FlxSprite, E:Enemy):Void
	{
		if (E.enemyType != BOSS)
		{
			E.kill();
			spawnExplosion(E.x + 4, E.y + 4);
		}
		else
		{
			E.hurt(10);

			if (!E.alive)
			{
				spawnExplosion(E.x + 4, E.y + 4);

				var e:FlxSprite = bossCounter.pop();
				e.kill();

				if (bossCounter.length == 0)
				{
					// game win!
					leaving = true;
					Stripes.CREATE(() -> Globals.gotoState(WinState), {
						mode: "on,in",
						color: 0xff639bff,
						snd: "hihat"
					});
				}
			}
			else
			{
				D.snd.play("enemy_hit");
			}
		}
		if (Std.is(L, PlayerLaser))
			L.kill();
	}

	private function didPlayerAttackHitEnemy(L:FlxSprite, E:Enemy):Bool
	{
		return L.alive && E.alive;
	}

	private function enemyAttackHitPlayer(B:EnemyBullet, P:Player):Void
	{
		P.hurt(10);
		B.kill();
	}

	private function didEnemyAttackHitPlayer(B:EnemyBullet, P:Player):Bool
	{
		return B.alive && P.alive;
	}

	public function checkBounds():Void
	{
		// if (player.x < 2)
		// {
		// 	player.x = 2;
		// }
		// else if (player.x > FlxG.worldBounds.width - player.width - 2)
		// {
		// 	player.x = FlxG.worldBounds.width - player.width - 2;
		// }

		if (player.y < 8)
		{
			player.y = 8;
		}
		else if (!isUnderground && player.y > SCREEN_HEIGHT - player.height - 2)
		{
			// FlxG.camera.setScrollBounds(-SCREEN_WIDTH, WORLD_WIDTH + (SCREEN_WIDTH * 2), 0, WORLD_HEIGHT);
			FlxG.camera.maxScrollY = WORLD_HEIGHT;

			isUnderground = true;
			FlxG.camera.followLerp = 0.2;
		}
		else if (isUnderground && player.y < SCREEN_HEIGHT - player.height - 2)
		{
			// FlxG.camera.setScrollBounds(-SCREEN_WIDTH, WORLD_WIDTH + (SCREEN_WIDTH * 2), 0, SCREEN_HEIGHT);
			FlxG.camera.maxScrollY = SCREEN_HEIGHT;

			isUnderground = false;
			FlxG.camera.followLerp = 0;
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);

			// trace(FlxG.camera.minScrollX, FlxG.camera.maxScrollX, FlxG.camera.minScrollY, FlxG.camera.maxScrollY);
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

			if (player.thrust > 0)
			{
				player.thrust -= elapsed * 2;
				player.thrust = Math.max(0, player.thrust);
			}
			if (thrustSnd != null)
			{
				if (thrustSnd.playing)
					thrustSnd.stop();
			}

			spawnThrust(player.x + (player.facing == LEFT ? player.width : 0), player.y + 3);
		}
		else
		{
			if (player.transCooldown <= 0)
			{
				if (Actions.attack.check())
				{
					playerPunch();
				}

				if (Actions.thrust.check())
				{
					if (player.thrust < player.thrustMax)
					{
						player.velocity.y = -Player.MECH_THRUST;
						player.thrust += elapsed;
						thrustSnd = D.snd.play('thrust', 0.1, false, false);
						spawnThrust(player.x + 3, player.y + player.height);
						player.animation.frameIndex = player.animFrames.get("step-1");
					}
					else if (thrustSnd != null)
					{
						if (thrustSnd.playing)
							thrustSnd.stop();
					}
				}
				else if (player.thrust > 0)
				{
					player.thrust -= elapsed * 2;
					player.thrust = Math.max(0, player.thrust);
					if (thrustSnd != null)
					{
						if (thrustSnd.playing)
							thrustSnd.stop();
					}
				}
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

		if (player.velocity.x != 0)
		{
			player.facing = player.velocity.x > 0 ? RIGHT : LEFT;
		}
	}
}
