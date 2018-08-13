package objects.particles;

class Poof extends Particle
{

	public function new()
	{
		super();
		loadGraphic(Images.poof__png, true, 16, 16);
		offset.set(8, 8);
		animation.add('play', [0, 1, 2, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8], 30, false);
	}

	override public function fire(o)
	{
		super.fire(o);
		animation.play('play', true, false, o.util_amount.map(0, 1, 16, 0).floor());
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (animation.finished) kill();
	}

}