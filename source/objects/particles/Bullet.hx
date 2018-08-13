package objects.particles;

class Bullet extends Particle
{

	public function new()
	{
		super();
		loadGraphic(Images.bullet__png, true, 12, 8);
		animation.add('play', [0, 1, 2], 30, false);
	}

	override public function fire(o)
	{
		super.fire(o);
		angle = velocity.vector_angle();
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (!isOnScreen()) kill();
	}

}