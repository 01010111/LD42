package objects.modules;

class Copter extends Module
{

	public function new()
	{
		super({
			name: 'copter',
			module_height: 2,
			constraints: [TOP, NO_BOTTOM],
			components: [new CopterMovement()]
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.add('play', [29, 30, 31, 32, 33]);
		//animation.add('idle', [29]);
		animation.play('play');
		animation.callback = (s, f, i) -> if (f == 2) FlxG.sound.play(Audio.copter__ogg, 0.05);
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		//Reg.c.pressed(FACE_A) ? animation.play('play') : animation.play('idle');
		animation.curAnim.frameRate = Reg.c.pressed(FACE_A) ? (animation.curAnim.frameRate + 1).min(48).floor() : (animation.curAnim.frameRate - 1).max(0).floor();
	}

}

class CopterMovement extends Component
{

	var t_grav:Float;
	var v:Float = 0;

	public function new()
	{
		super('copter');
	}

	override function on_add()
	{
		super.on_add();
		t_grav = entity.acceleration.y;
	}

	override public function update(dt:Float)
	{
		acceleration.y = Reg.c.pressed(FACE_A) ? (acceleration.y - 40).max(-t_grav.half().half().half()) : (acceleration.y + 10).min(t_grav);
		if (Reg.c.pressed(DPAD_LEFT) && Reg.c.pressed(DPAD_RIGHT)) v = 0;
		else if (Reg.c.pressed(DPAD_LEFT)) v = (v -= 5).max(-40).min(0);
		else if (Reg.c.pressed(DPAD_RIGHT)) v = (v += 5).min(40).max(0);
		else v *= 0.5;
		entity.velocity.x = v;
		if (v.abs() > 0.1)
		{
			entity.facing = v > 0 ? RIGHT : LEFT;
			if (entity.wasTouching & FLOOR > 0) entity.velocity.y = -50;
		}
	}

}