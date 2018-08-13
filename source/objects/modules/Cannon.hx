package objects.modules;



class Cannon extends Module
{

	public function new()
	{
		super({
			name: 'cannon',
			module_height: 1,
			constraints: [],
			components: []
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.frameIndex = 19;
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (Reg.c.just_pressed(FACE_B)) 
		{
			FlxG.sound.play(Audio.shoot__ogg, 0.25);
			PlayState.i.player_bullets.fire({
				velocity: (facing == LEFT ? 180 : 0).vector_from_angle(450).to_flx(),
				position: getPosition().add(facing == LEFT ? -12 : 16, 7),
				animation: 'play'
			});
			PlayState.i.small_explosions.fire({
				position: getPosition().add(facing == LEFT ? -4 : 20, 12),
				animation: 'play'
			});
		}
	}

}