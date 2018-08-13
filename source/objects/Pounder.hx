package objects;

import flixel.system.FlxAssets;

class Pounder extends Entity
{

	var sensitivity:Int = 6;
	var hurt_timer:Float = 0;
	var hurt_mix:Float = 0;
	var mad_timer:Float = 0;
	var d_shader:DamageShader = new DamageShader();

	public function new(x:Int, y:Int)
	{
		super({ x: x * 16, y: y * 16 });
		loadGraphic(Images.pounder__png, true, 32, 48);
		PlayState.i.hazards.add(this);
		PlayState.i.collidables.add(this);
		PlayState.i.shootables.add(this);
		health = 10;
		drag.x = 100000;
		//shader = d_shader;
	}

	override public function update(dt:Float)
	{
		d_shader.uMix.value = [hurt_mix];
		if (justTouched(FLOOR))
		{
			FlxG.sound.play(Audio.explode__ogg, 0.4);
			FlxG.camera.shake(0.01, 0.2);
			for (i in 0...4) PlayState.i.poofs.fire({ position: this.get_anchor().add(16.get_random(-16)), util_amount: 1.get_random(0.7) });
		}
		super.update(dt);
		var mad = ((PlayState.i.robot.getMidpoint().x - getMidpoint().x).abs() < width + sensitivity * 2);
		if (mad) mad_timer = 180;
		acceleration.y = mad_timer > 0 ? 400 : -100;
		animation.frameIndex = hurt_timer > 0 ? 2 : acceleration.y > 0 ? 1 : 0;
		if (hurt_timer > 0) hurt_timer--;
		if (mad_timer > 0) mad_timer--;
		hurt_mix += (0 - hurt_mix) * 0.1;
	}

	override public function hurt(_)
	{
		super.hurt(_);
		if (!alive) return;
		hurt_mix = 1;
		hurt_timer = 60;
	}

	override public function kill()
	{
		FlxG.sound.play(Audio.explode__ogg, 0.4);
		for (i in 0...8) new FlxTimer().start(0.3.get_random()).onComplete = (_) -> PlayState.i.big_explosions.fire({ position: getMidpoint().add(16.get_random(-16), 24.get_random(-24)), animation: 'play' });
		super.kill();
	}

}

class DamageShader extends FlxShader
{

	@:glFragmentSource('
		#pragma header

		uniform float uMix;

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = mix(color, vec4(1, 0.25, 0 color.a), uMix);
		}
	')

	public function new()
	{
		super();
	}
}