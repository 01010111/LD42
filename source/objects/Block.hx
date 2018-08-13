package objects;

class Block extends Entity
{

	public function new(x:Int, y:Int)
	{
		super({ x: x * 16, y: y * 16 });
		loadGraphic(Images.block__png);
		immovable = true;
		PlayState.i.collidables.add(this);
		PlayState.i.destructables.add(this);
	}

	override public function kill()
	{
		for (i in 0...5) new FlxTimer().start(0.2.get_random()).onComplete = (_) -> PlayState.i.big_explosions.fire({ position: getMidpoint().add(16.get_random(-16), 16.get_random(-16)), animation: 'play' });
		super.kill();
	}

}