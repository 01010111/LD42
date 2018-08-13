package objects.modules;

class Pogo extends Module
{

	public function new()
	{
		super({
			name: 'pogo',
			module_height: 2,
			constraints: [BOTTOM],
			components: [new PogoMovement()]
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.add('play', [15, 16, 17, 18], 30, false);
		animation.frameIndex = 18;
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (parent.wasTouching & FLOOR > 0) animation.play('play');
	}

}

class PogoMovement extends Component
{

	var v:Float = 0;

	public function new()
	{
		super('h_move');
	}

	override public function update(dt:Float)
	{
		if (entity.wasTouching & FLOOR > 0) Reg.c.pressed(FACE_A) ? bounce(true) : bounce(false);
		if (Reg.c.pressed(DPAD_LEFT) && Reg.c.pressed(DPAD_RIGHT)) v = 0;
		else if (Reg.c.pressed(DPAD_LEFT)) v = (v -= 5).max(-100).min(0);
		else if (Reg.c.pressed(DPAD_RIGHT)) v = (v += 5).min(100).max(0);
		else v *= 0.5;
		entity.velocity.x = v;
		if (v.abs() > 0) entity.facing = v > 0 ? RIGHT : LEFT;
	}

	function bounce(big:Bool)
	{
		velocity.y = big ? -300 : -150;
		big ? FlxG.sound.play(Audio.big_pogo__ogg, 0.1) : FlxG.sound.play(Audio.lil_pogo__ogg, 0.1);
	}

}