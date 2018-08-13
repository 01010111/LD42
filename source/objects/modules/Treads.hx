package objects.modules;

class Treads extends Module
{

	public function new()
	{
		super({
			name: 'treads',
			module_height: 1,
			constraints: [BOTTOM],
			components: [new TreadMovement()]
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.add('play', [1, 2]);
		animation.play('play');
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		animation.curAnim.frameRate = parent.velocity.x.half().floor();
	}

}

class TreadMovement extends Component
{

	var v:Float = 0;

	public function new()
	{
		super('h_move');
	}

	override public function update(dt:Float)
	{
		if (Reg.c.pressed(DPAD_LEFT) && Reg.c.pressed(DPAD_RIGHT)) v = 0;
		else if (Reg.c.pressed(DPAD_LEFT)) v = (v -= 5).max(-100).min(0);
		else if (Reg.c.pressed(DPAD_RIGHT)) v = (v += 5).min(100).max(0);
		else v *= 0.5;
		entity.velocity.x = v;
		if (v.abs() > 0) entity.facing = v > 0 ? RIGHT : LEFT;
	}

}