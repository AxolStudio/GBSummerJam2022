package;

import djFlixel.D;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class Player extends FlxSprite
{
	public static var MAX_SHIP_SPEED:Float = 200;
	public static var SHIP_ACC:Float = 600;
	public static var SHIP_DRAG:Float = 1000;

	public static var MAX_MECH_SPEED:Float = 80;
	public static var MECH_ACC:Float = 3200;
	public static var MECH_DRAG:Float = 2000;
	public static var MECH_THRUST:Float = 80;

	public static var TRANS_COOLDOWN_TIME:Float = .25;
	public static var LASER_COOLDOWN_TIME:Float = .8;
	public static var PUNCH_COOLDOWN_TIME:Float = .25;
	public static var JUSTPUNCHED_COOLDOWN_TIME:Float = .2;

	public static var SHIP_HEAL_DELAY:Float = 1;

	public static var MAX_HEALTH:Float = 100;

	public var thrustMax:Float = .5;

	public var thrust:Float = 0;

	public var mode(default, null):PlayerMode = SHIP;

	public var transCooldown:Float = -1;
	public var laserCooldown:Float = -1;
	public var punchCooldown:Float = -1;
	public var justPunchedCooldown:Float = -1;

	public var shipHealth:Float;
	public var mechHealth:Float;
	public var shipHealTime:Float = -1;

	public var justHurt:Float = -1;

	public static var JUST_HURT_TIME:Float = 0.2;

	public var animFrames:Map<String, Int> = [];

	public function new():Void
	{
		super();

		mechHealth = shipHealth = MAX_HEALTH;

		// makeGraphic(12, 6, FlxColor.WHITE);
		loadGraphic("assets/images/player.png", true, 12, 12);

		animFrames.set("ship", 0);
		animFrames.set("step-1", 1);
		animFrames.set("step-2", 2);
		animFrames.set("punch-1", 3);
		animFrames.set("punch-2", 4);
		animFrames.set("transform", 5);

		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);

		animation.frameIndex = animFrames.get("ship");
		width = 12;
		height = 6;
		offset.x = 0;
		offset.y = 3;
		centerOrigin();

		maxVelocity.set(MAX_SHIP_SPEED, MAX_SHIP_SPEED);

		drag.set(SHIP_DRAG, SHIP_DRAG);

		facing = RIGHT;
	}

	override function hurt(Damage:Float)
	{
		if (justHurt > 0)
			return;
		if (mode == SHIP)
		{
			shipHealth -= Damage;
			if (shipHealth <= 0)
			{
				shipHealth = 0;
				shipHealTime = SHIP_HEAL_DELAY;
				switchMode();
			}
		}
		else
		{
			mechHealth -= Damage;
			if (mechHealth <= 0)
			{
				kill();
			}
		}
		if (alive)
		{
			D.snd.play('player_hit');
			justHurt = JUST_HURT_TIME;
		}
		else
			D.snd.play('title_crash');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (justHurt > 0)
			justHurt -= elapsed;

		if (transCooldown > 0)
			transCooldown -= elapsed;

		if (laserCooldown > 0)
			laserCooldown -= elapsed;

		if (justPunchedCooldown > 0)
			justPunchedCooldown -= elapsed;

		if (punchCooldown > 0)
			punchCooldown -= elapsed;

		if (mode == MECH)
		{
			if (shipHealth < MAX_HEALTH)
			{
				if (shipHealTime > 0)
					shipHealTime -= elapsed;
				else
				{
					shipHealth += elapsed;
					if (shipHealth > MAX_HEALTH)
						shipHealth = MAX_HEALTH;
				}
			}
			if (justPunchedCooldown > 0)
			{
				velocity.set();
			}
		}

		if (velocity.x < 0)
			facing = FlxObject.LEFT;
		else if (velocity.x > 0)
			facing = FlxObject.RIGHT;
	}

	public function switchMode():Void
	{
		if (transCooldown > 0 || (mode == MECH && shipHealth < 10))
			return;

		transCooldown = TRANS_COOLDOWN_TIME;

		D.snd.play('transform');

		animation.frameIndex = animFrames.get("transform");

		trace(animation.frameIndex, animFrames.get("transform"));

		if (mode == SHIP)
		{
			mode = MECH;
			width = 6;
			height = 12;
			offset.y = 0;
			if (facing == LEFT)
			{
				offset.x = 5;
			}
			else if (facing == RIGHT)
			{
				offset.x = 1;
			}
			centerOrigin();
			FlxG.camera.follow(this, FlxCameraFollowStyle.LOCKON);

			maxVelocity.set(MAX_MECH_SPEED, MAX_MECH_SPEED);
			drag.set(MECH_DRAG, MECH_DRAG);
			acceleration.set();
			velocity.set();
			acceleration.y = PlayState.GRAVITY;
		}
		else if (mode == MECH)
		{
			mode = SHIP;
			y -= 3;

			width = 12;
			height = 6;
			offset.x = 0;
			offset.y = 3;
			centerOrigin();
			FlxG.camera.follow(this, FlxCameraFollowStyle.LOCKON);

			maxVelocity.set(MAX_SHIP_SPEED, MAX_SHIP_SPEED);
			drag.set(SHIP_DRAG, SHIP_DRAG);
			acceleration.set();
			velocity.set();
		}
	}

	override private function set_facing(Direction:FlxDirectionFlags):FlxDirectionFlags
	{
		super.set_facing(Direction);
		if (mode == MECH)
		{
			if (facing == LEFT)
			{
				offset.x = 5;
			}
			else if (facing == RIGHT)
			{
				offset.x = 1;
			}
			centerOrigin();
			FlxG.camera.follow(this, FlxCameraFollowStyle.LOCKON);
		}
		return facing;
	}

	override function draw()
	{
		// trace(player.isTouching(FLOOR), player.velocity.x != 0, player.animation.frameIndex, player.animFrames.get("step-1"));
		if (Std.int(Globals.gameTimer * 10) % 2 == 0)
		{
			if (animation.frameIndex == animFrames.get("transform"))
			{
				if (transCooldown <= 0)
					animation.frameIndex = animFrames.get(mode == SHIP ? "ship" : "step-1");
			}
			else if (mode == MECH && punchCooldown <= 0)
			{
				if ((isTouching(FLOOR) && velocity.x != 0) || (animation.frameIndex != animFrames.get("step-1")))
				{
					trace(animation.frameIndex);
					if (animation.frameIndex == animFrames.get("step-1"))
					{
						animation.frameIndex = animFrames.get("step-2");
						trace(2);
					}
					else
					{
						animation.frameIndex = animFrames.get("step-1");
						trace(1);
					}
				}
			}
		}

		super.draw();
	}
}

@:enum abstract PlayerMode(String)
{
	var SHIP = "ship";
	var MECH = "mech";
}
