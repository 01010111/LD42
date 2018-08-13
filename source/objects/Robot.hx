package objects;

import objects.modules.Robase;
import objects.modules.Module;


class Robot extends Entity
{

	public var modules:Array<Module> = [];
	public var module_group:FlxGroup;
	public var deady:Bool = true;

	public function new(x:Float, y:Float)
	{
		super({
			y: y * 16 + 8,
			x: x * 16,
			name: 'Robot',
			components: []
		});
		makeGraphic(16, 8, 0x00FF0000);
		module_group = new FlxGroup();
		FlxG.state.add(module_group);
		acceleration.y = 600;
		maxVelocity.set(120, 300);
		add_module(new Robase());
		FlxG.sound.play(Audio.shoot__ogg, 0.2);
	}

	public function add_module(module:Module, ?position:Int = 0)
	{
		if (module.constraints.indexOf(BOTTOM) >= 0) for (i in 0...modules.length) if (modules[i].constraints.indexOf(NO_BOTTOM) >= 0) remove_module(i);
		if (module.constraints.indexOf(BOTTOM) >= 0 && modules[0].constraints.indexOf(BOTTOM) >= 0) remove_module(0);
		if (module.constraints.indexOf(NO_BOTTOM) >= 0 && modules[0].constraints.indexOf(BOTTOM) >= 0) remove_module(0);
		if (module.constraints.indexOf(TOP) >= 0 && modules[modules.length - 1].constraints.indexOf(TOP) >= 0) remove_module(modules.length - 1);
		modules.insert(position, module);
		module.parent = this;
		module_group.add(module);
		for (component in module.module_components) add_component(component);
		recalculate_robot();
	}

	public function remove_module(index:Int)
	{
		var module = modules[index];
		modules.remove(module);
		//for (component in module.module_components) remove_component(component.get_name());
		module.kill();
		recalculate_robot();
	}

	function recalculate_robot()
	{
		for (component in components) remove_component(component.get_name());
		for (module in modules) for (component in module.module_components) add_component(component);
		var l = height;
		for (module in modules) 
		{
			if (module.constraints.indexOf(BOTTOM) >= 0)
			{
				modules.remove(module);
				modules.unshift(module);
			}
			if (module.constraints.indexOf(TOP) >= 0)
			{
				modules.remove(module);
				modules.push(module);
			}
		}
		var h = 0;
		for (module in modules) h += module.module_height * 8;
		setSize(16, h);
		y += l - h;

		set_modules();
		for (module in modules) for (i in 0...4) new FlxTimer().start(0.2.get_random()).onComplete = (_) -> PlayState.i.small_explosions.fire({ position: module.getMidpoint().add(8.get_random(-8) - 8, 8.get_random(-8)), animation: 'play' });
	}

	override public function add_component(component:Component)
	{
		if (components.exists(component.get_name())) return;
		components.set(component.get_name(), component);
		component.add_to(this);
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		set_modules();
	}

	function set_modules()
	{
		var m_y = y + height - 16;
		for (module in modules)
		{
			module.setPosition(x, m_y);
			module.facing = this.facing;
			m_y -= module.module_height * 8;
		}
	}

	override public function kill()
	{
		FlxG.sound.play(Audio.explode__ogg, 0.4);
		for (module in modules)
		{
			if (deady) for (i in 0...3) new FlxTimer().start(0.3.get_random()).onComplete = (_) -> PlayState.i.big_explosions.fire({ position: module.getMidpoint().add(16.get_random(-16), 16.get_random(-16)), animation: 'play' });
			module.kill();
		}
		super.kill();
	}

}