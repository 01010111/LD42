package objects;

class Goal extends Entity
{

	public var winbox:FlxObject;

	public function new(x:Int, y:Int)
	{
		super({ x: x * 16, y: y * 16 });
		loadGraphic(Images.goal__png, true, 32, 16);
		animation.add('play', [0, 1, 2, 3]);
		animation.frameIndex = 3;
		winbox = new FlxObject(this.x + 15, this.y - 1, 2, 1);
		FlxG.state.add(winbox);
		PlayState.i.collidables.add(this);
		immovable = true;
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (PlayState.i.has_chip || !PlayState.i.needs_chip) animation.play('play');
	}

}