package states;

import flixel.text.FlxText;
import zero.flxutil.states.sub.FadeIn;
import zero.flxutil.states.sub.FadeOut;
import objects.*;
import objects.particles.*;
import flixel.tile.FlxTilemap;
import zero.flxutil.editors.ZomeLoader;
import flixel.util.FlxSpriteUtil;

class PlayState extends BaseState
{

	public static var i:PlayState;
	public static var lvl:Int = 1;

	public var robot:Robot;
	public var level:FlxTilemap;
	public var goal:Goal;
	public var win_light:FlxSprite;

	public var poofs:ParticleEmitter;
	public var player_bullets:ParticleEmitter;
	public var player_missiles:ParticleEmitter;
	public var small_explosions:ParticleEmitter;
	public var big_explosions:ParticleEmitter;

	public var hazards:FlxGroup;
	public var destructables:FlxGroup;
	public var collidables:FlxGroup;
	public var shootables:FlxGroup;

	public var needs_chip:Bool = false;
	public var has_chip:Bool = false;

	override public function create():Void
	{
		i = this;

		bgColor = 0xFF1D2B53;

		init_groups();
		add_win_light();
		var level_data = Levels.LEVEL_ARRAY[lvl];
		add_level(level_data.json);
		add_objects(level_data.objects);
		add_particles();
		init_camera();

		super.create();
	}

	function init_groups()
	{
		hazards = new FlxGroup();
		destructables = new FlxGroup();
		collidables = new FlxGroup();
		shootables = new FlxGroup();
	}

	function add_win_light()
	{
		win_light = new FlxSprite();
		win_light.makeGraphic(2, 2);
		win_light.origin.set(1, 0);
		add(win_light);
	}

	function add_level(json:String)
	{
		var loader = new ZomeLoader(json);
		level = loader.get_tilemap();
		add(level);
	}

	function add_objects(objects:Array<ObjectData>)
	{
		for (object in objects) switch (object.name)
		{
			case 'SPIKE': add(new Spike(object.x, object.y, object.util_float == 0 ? FLOOR : CEILING));
			case 'BLOCK': add(new Block(object.x, object.y));
			case 'POUND': add(new Pounder(object.x, object.y));
			case 'CHIP': add(new Chip(object.x, object.y, object.util_float.floor()));
			case 'GOAL':
				goal = new Goal(object.x, object.y);
				add(goal);
			case 'ROBOT':
				robot = new Robot(object.x, object.y);
				add(robot);
			default: return;
		}
	}

	function init_camera()
	{
		var dolly = new PlatformerDolly(robot, {
			window_size: FlxPoint.get(FlxG.width * 0.5, FlxG.height * 0.8),
			lerp: FlxPoint.get(0.2, 0.4),
			edge_snapping: { tilemap: level },
			platform_snapping: {
				platform_offset: 32,
				max_delta: 2,
				lerp: 0.2
			},
			forward_focus: {
				offset: 12,
				trigger_offset: 32,
				lerp: 0.5,
				max_delta: 3
			}
		});
	}

	function add_particles()
	{
		poofs = new ParticleEmitter(() -> new Poof());
		player_bullets = new ParticleEmitter(() -> new Bullet());
		player_missiles = new ParticleEmitter(() -> new Missile());
		small_explosions = new ParticleEmitter(() -> new SmallExplosion());
		big_explosions = new ParticleEmitter(() -> new BigExplosion());

		add(poofs);
		add(player_bullets);
		add(player_missiles);
		add(small_explosions);
		add(big_explosions);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (robot.acceleration.y >= 580 && Reg.c.just_pressed(UTIL_START)) openSubState(new ModuleSub());
		FlxG.collide(robot, level);
		FlxG.collide(robot, collidables);
		FlxG.collide(level, collidables);
		FlxG.collide(level, player_bullets, kill_bullet);
		FlxG.collide(level, player_missiles, missile_explode);
		FlxG.collide(destructables, player_missiles, missile_explode_object);
		FlxG.overlap(shootables, player_bullets, bullet_hurt_object);
		FlxG.overlap(shootables, player_missiles, bullet_hurt_object);
		FlxG.overlap(collidables, player_bullets, kill_bullet);
		FlxG.collide(collidables, collidables);
		FlxG.overlap(robot, hazards, kill_robo);
		FlxG.overlap(robot, goal.winbox, win_level);
	}

	function kill_bullet(o:FlxObject, m:FlxObject)
	{
		FlxG.sound.play(Audio.plif__ogg, 0.15);
		small_explosions.fire({ position: m.getMidpoint(), animation: 'play' });
		m.kill();
	}

	function bullet_hurt_object(o:FlxObject, b:FlxObject)
	{
		kill_bullet(o, b);
		o.hurt(1);
	}

	function missile_explode(o:FlxObject, m:FlxObject)
	{
		FlxG.sound.play(Audio.explode__ogg, 0.5);
		FlxG.camera.shake(0.01, 0.025);
		big_explosions.fire({ position: m.getMidpoint(), animation: 'play' });
		m.kill();
	}

	function missile_explode_object(o:FlxObject, m:FlxObject)
	{
		missile_explode(o, m);
		o.kill();
	}

	function kill_robo(r:Robot, h:FlxObject)
	{
		FlxG.camera.flash(0xFFFFFFFF, 0.1);
		r.kill();

		new FlxTimer().start(1).onComplete = (_) -> openSubState(new FadeOut(() -> FlxG.resetState()));
	}

	function win_level(r:Robot, g:FlxObject)
	{
		if (needs_chip && !has_chip) return;
		FlxG.sound.play(Audio.teleport__ogg, 0.25);
		FlxG.camera.flash(0xFFFFFFFF, 0.1);
		r.deady = false;
		for (i in 0...8) poofs.fire({ position: r.getMidpoint().add(16.get_random(-16), 0.get_random(-64)), util_amount: 1.get_random() });
		r.kill();
		show_light();
		lvl++;
		if (lvl == 7)
		{
			show_end();
			return;
		}
		new FlxTimer().start(2).onComplete = (_) -> openSubState(new FadeOut(() -> FlxG.resetState()));
	}

	function show_light()
	{
		win_light.x = goal.winbox.x;
		win_light.scale.set(12, FlxG.height);
		FlxTween.tween(win_light.scale, { x: 1 }, 0.5).onComplete = (_) -> {
			FlxSpriteUtil.flicker(win_light, 0.5, 0.025, false);
		}
	}

	function show_end()
	{
		var s = new FlxSprite();
		s.makeGraphic(FlxG.width, FlxG.height, 0x80000000);
		s.alpha = 0;
		s.scrollFactor.set();
		add(s);
		FlxTween.tween(s, { alpha: 1 }, 1);

		var t = new FlxText(0, FlxG.height.half(), FlxG.width, 'thank you :)');
		t.setFormat(null, 8, 0xFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		t.scale.set();
		t.scrollFactor.set();
		add(t);

		FlxTween.tween(t.scale, { x: 1, y: 1 }, 0.4, { ease: FlxEase.backOut });
	}

}

typedef LevelData =
{
	json:String,
	objects:Array<ObjectData>
}

typedef ObjectData =
{
	name:String,
	x:Int,
	y:Int,
	?util_float:Float
}

class Levels
{

	public static var LEVEL_ARRAY:Array<LevelData> = [
		{
			json: Data.level0__json,
			objects: [
				{ name: 'ROBOT', x: 7, y: 11 },
				{ name: 'GOAL', x: 26, y: 16 },
			]
		},
		{
			json: Data.level1__json,
			objects: [
				{ name: 'ROBOT', x: 4, y: 10 },
				{ name: 'GOAL', x: 23, y: 16 },
			]
		},
		{
			json: Data.level2__json,
			objects: [
				{ name: 'ROBOT', x: 7, y: 7 },
				{ name: 'GOAL', x: 25, y: 16 },
				{ name: 'CHIP', x: 8, y: 21, util_float: ModRef.POGO }
			]
		},
		{
			json: Data.level3__json,
			objects: [
				{ name: 'ROBOT', x: 8, y: 14 },
				{ name: 'GOAL', x: 32, y: 15 },
				{ name: 'CHIP', x: 4, y: 11, util_float: ModRef.TREADS },
				{ name: 'POUND', x: 15, y: 6 },
				{ name: 'POUND', x: 19, y: 6 },
				{ name: 'POUND', x: 23, y: 6 }
			]
		},
		{
			json: Data.level4__json,
			objects: [
				{ name: 'ROBOT', x: 6, y: 21 },
				{ name: 'GOAL', x: 18, y: 21 },
				{ name: 'CHIP', x: 8, y: 5, util_float: ModRef.CANNON },
				{ name: 'POUND', x: 14, y: 13 }
			]
		},
		{
			json: Data.level5__json,
			objects: [
				{ name: 'ROBOT', x: 3, y: 8 },
				{ name: 'GOAL', x: 15, y: 9 },
				{ name: 'CHIP', x: 10, y: 9, util_float: ModRef.MISSILES },
				{ name: 'POUND', x: 7, y: 7 },
				{ name: 'POUND', x: 13, y: 5 },
				{ name: 'BLOCK', x: 7, y: 5 },
				{ name: 'BLOCK', x: 9, y: 4 },
				{ name: 'BLOCK', x: 9, y: 6 },
				{ name: 'BLOCK', x: 11, y: 4 },
				{ name: 'BLOCK', x: 11, y: 6 },
				{ name: 'BLOCK', x: 11, y: 8 },
				{ name: 'BLOCK', x: 13, y: 8 },
			]
		},
		{
			json: Data.level6__json,
			objects: [
				{ name: 'ROBOT', x: 4, y: 10 },
				{ name: 'GOAL', x: 4, y: 42 },
				{ name: 'CHIP', x: 15, y: 10, util_float: ModRef.COPTER },
				{ name: 'SPIKE', x: 7, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 8, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 9, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 11, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 12, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 13, y: 11, util_float: 0 },
				{ name: 'SPIKE', x: 7, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 8, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 9, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 10, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 11, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 12, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 13, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 14, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 15, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 16, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 17, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 18, y: 21, util_float: 0 },
				{ name: 'SPIKE', x: 7, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 8, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 9, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 10, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 11, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 12, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 13, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 14, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 15, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 16, y: 31, util_float: 0 },
				{ name: 'SPIKE', x: 7, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 8, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 9, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 10, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 11, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 12, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 13, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 14, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 15, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 16, y: 25, util_float: 1 },
				{ name: 'SPIKE', x: 7, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 8, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 9, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 10, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 11, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 12, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 13, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 14, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 15, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 16, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 17, y: 39, util_float: 0 },
				{ name: 'SPIKE', x: 7, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 8, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 9, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 10, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 11, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 12, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 13, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 14, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 15, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 16, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 17, y: 34, util_float: 1 },
				{ name: 'SPIKE', x: 18, y: 41, util_float: 0 },
				{ name: 'SPIKE', x: 19, y: 41, util_float: 0 },
				{ name: 'SPIKE', x: 20, y: 41, util_float: 0 },
				{ name: 'SPIKE', x: 21, y: 41, util_float: 0 },
				{ name: 'SPIKE', x: 22, y: 41, util_float: 0 },
			]
		},
	];

}

class ModRef
{

	public static var TREADS:Int = 0;
	public static var POGO:Int = 1;
	public static var CANNON:Int = 2;
	public static var MISSILES:Int = 3;
	public static var CAP:Int = 4;
	public static var COPTER:Int = 5;

}