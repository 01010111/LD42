package objects.particles;



import flixel.system.frontEnds.SoundFrontEnd;

class Missile extends Particle
{

	var timer:Float = 0;

	public function new()
	{
		super();
		loadGraphic(Images.missile__png);
		this.make_and_center_hitbox(2, 2);
	}

	override public function fire(o)
	{
		FlxG.sound.play(Audio.plif__ogg, 0.1);
		super.fire(o);
		angle = velocity.vector_angle();
		timer = Math.random();
	}

	override public function update(dt:Float)
	{
		timer += dt;
		super.update(dt);
		if (!isOnScreen()) kill();
		angle += Math.sin(timer * 10) * 5;
		velocity = (angle).vector_from_angle(velocity.vector_length()).to_flx();
		if (Math.random() > 0.85) PlayState.i.poofs.fire({
			position: getPosition(),
			util_amount: 1.get_random(0.75)
		});
	}

}