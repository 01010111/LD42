package objects.modules;

class Robase extends Module
{

	public function new()
	{
		super({
			name: 'robase',
			module_height: 1,
			constraints: [],
			components: [new RobaseMovement()]
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.frameIndex = 0;
	}

}

class RobaseMovement extends Component
{

	var v:Float = 0;

	public function new()
	{
		super('h_move');
	}

	override public function update(dt:Float)
	{
		if (Reg.c.pressed(DPAD_LEFT) && Reg.c.pressed(DPAD_RIGHT)) v = 0;
		else if (Reg.c.pressed(DPAD_LEFT)) v = (v -= 5).max(-40).min(0);
		else if (Reg.c.pressed(DPAD_RIGHT)) v = (v += 5).min(40).max(0);
		else v *= 0.5;
		entity.velocity.x = v;
		if (v.abs() > 0.1)
		{
			entity.facing = v > 0 ? RIGHT : LEFT;
			if (entity.wasTouching & FLOOR > 0)
			{
				if (velocity.y >= 0) FlxG.sound.play(Audio.hop__ogg, 0.1);
				entity.velocity.y = -50;
			}
		}
	}

}