package objects.modules;



class Missiles extends Module
{

	public function new()
	{
		super({
			name: 'missiles',
			module_height: 2,
			constraints: [],
			components: []
		});
		loadGraphic(Images.modules__png, true, 32, 16);
		animation.frameIndex = 20;
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (Reg.c.just_pressed(FACE_B)) 
		{
			PlayState.i.player_missiles.fire({
				velocity: (facing == LEFT ? 180 : 0).vector_from_angle(200).to_flx(),
				position: getPosition().add(facing == LEFT ? -12 : 16, 8)
			});
			PlayState.i.small_explosions.fire({
				position: getPosition().add(facing == LEFT ? -4 : 20, 8),
				animation: 'play'
			});
		}
	}

}