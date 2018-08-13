package states;

import objects.modules.Robase;
import objects.modules.Copter;
import objects.modules.Cap;
import objects.modules.Missiles;
import objects.modules.Cannon;
import objects.modules.Pogo;
import objects.modules.Treads;
import flixel.FlxSubState;


class ModuleSub extends FlxSubState
{

	var module_sprite:FlxSprite;
	public static var frames = [26];
	public static var frames_to_get = [1, 18, 19, 20, 26, 29];
	var cur_mod:Int = 0;
	var wait = false;

	public function new()
	{
		super(0xD0000000);

		if (frames.length == 0) close();

		module_sprite = new FlxSprite(FlxG.width.half(), FlxG.height.half());
		module_sprite.loadGraphic(Images.modules__png, true, 32, 16);
		module_sprite.animation.frameIndex = frames[0];
		module_sprite.offset.set(16, 8);
		module_sprite.scale.set(4, 4);
		module_sprite.scrollFactor.set();
		add(module_sprite);
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		Reg.c.update(dt);

		controls();
	}

	function controls()
	{
		if (wait) return;
		if (Reg.c.just_pressed(DPAD_LEFT)) select_module(-1);
		if (Reg.c.just_pressed(DPAD_RIGHT)) select_module(1);
		if (Reg.c.just_pressed(FACE_A)) choose_module();
		if (Reg.c.just_pressed(FACE_B)) remove_modules();
	}

	function select_module(i:Int)
	{
		if (i == 0) return;
		FlxG.sound.play(Audio.click__ogg, 0.02);
		cur_mod = (cur_mod + i == -1 ? frames.length - 1 : cur_mod + i) % frames.length;
		wait = true;
		FlxTween.tween(module_sprite, { x: FlxG.width.half() + i * -64, alpha: 0 }, 0.05).onComplete = (_) -> {
			module_sprite.x = FlxG.width.half() + i * 64;
			module_sprite.animation.frameIndex = frames[cur_mod];
			FlxTween.tween(module_sprite, { x: FlxG.width.half(), alpha: 1 }, 0.05).onComplete = (_) -> wait = false;
		};
	}

	function choose_module()
	{
		var module = switch (frames[cur_mod])
		{
			case 1:	new Treads();
			case 18: new Pogo();
			case 19: new Cannon();
			case 20: new Missiles();
			case 26: new Cap();
			case 29: new Copter();
			default: null;
		}
		PlayState.i.robot.add_module(module);
		close();
	}

	function remove_modules()
	{
		while (PlayState.i.robot.modules.length > 0) PlayState.i.robot.remove_module(0);
		PlayState.i.robot.add_module(new Robase());
		close();
	}

	override public function close()
	{
		FlxG.sound.play(Audio.mod__ogg, 0.2);
		super.close();
	}

}

enum Modules
{
	TREADS;
	POGO;
	CANNON;
	MISSILES;
	CAP;
	COPTER;
}