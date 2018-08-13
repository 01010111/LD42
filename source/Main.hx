package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(256, 224, MenuState));
		FlxG.sound.playMusic(Audio.tune2__ogg, 0.5);
	}
}
