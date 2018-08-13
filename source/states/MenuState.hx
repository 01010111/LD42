package states;

import flixel.text.FlxText;
import zero.flxutil.states.sub.FadeOut;

class MenuState extends BaseState
{

	override public function create()
	{
		bgColor = 0xFF1D2B53;
		super.create();
		var s = new FlxSprite(0, 0, Images.title__png);
		s.screenCenter();
		FlxTween.tween(s, { angle: 5, 'scale.x': 1.1, 'scale.y': 1.1 }, 1.5, { ease:FlxEase.sineInOut, type:FlxTweenType.PINGPONG });
		add(s);

		var t = new FlxText(0, FlxG.height - 32, FlxG.width, 'press X and C please');
		t.setFormat(null, 8, 0xFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		t.scale.set();
		add(t);

		FlxTween.tween(t.scale, { x: 1, y: 1 }, 0.4, { ease: FlxEase.backOut });
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (Reg.c.pressed(FACE_A) && Reg.c.pressed(FACE_B)) FlxG.switchState(new PlayState());
	}

}