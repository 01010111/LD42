package objects.particles;

class BigExplosion extends Particle
{

	public function new()
	{
		super();
		loadGraphic(Images.big_explosion__png, true, 32, 32);
		offset.set(16, 16);
		animation.add('play', [0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8], 30, false);
	}

	override public function fire(o)
	{
		super.fire(o);
		angle = 90 * 4.get_random().floor();
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (animation.finished) kill();
	}

}