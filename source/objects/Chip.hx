package objects;

import states.ModuleSub;

class Chip extends Entity
{

	var data:Int;

	public function new(x:Int, y:Int, data:Int)
	{
		PlayState.i.needs_chip = true;
		super({ x: x * 16, y: y * 16 });
		loadGraphic(Images.disk__png, true, 16, 16);
		animation.add('play', [0, 0, 1, 2, 3, 4, 4, 5, 6, 7], 12);
		animation.play('play');
		FlxTween.tween(this, { y: this.y - 4 }, 1, { ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG });
		this.data = data;
		if (ModuleSub.frames.indexOf(ModuleSub.frames_to_get[data]) >= 0) kill();
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (FlxG.overlap(this, PlayState.i.robot))
		{
			FlxG.sound.play(Audio.module_get__ogg, 0.15);
			ModuleSub.frames.push(ModuleSub.frames_to_get[data]);
			for (i in 0...4) PlayState.i.poofs.fire({ position: getMidpoint().add(8.get_random(-8), 8.get_random(-8)), util_amount: 1.get_random(0.5) });
			kill();
		}
	}

	override public function kill()
	{
		super.kill();
		PlayState.i.has_chip = true;
	}

}