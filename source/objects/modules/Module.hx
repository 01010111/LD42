package objects.modules;

class Module extends Entity
{

	public var parent:Robot;
	public var module_height:Int;
	public var constraints:Array<ModuleConstraint>;
	public var module_components:Array<Component>;

	public function new(options:ModuleOptions)
	{
		super({
			y: 0,
			x: 0,
			name: options.name
		});
		module_height = options.module_height;
		constraints = options.constraints;
		module_components = options.components;
		offset.set(8);
		this.set_facing_flip_horizontal();
	}

}

typedef ModuleOptions = {
	name:String,
	components:Array<Component>,
	module_height:Int,
	constraints:Array<ModuleConstraint>
}

enum ModuleConstraint
{
	TOP;
	BOTTOM;
	NO_BOTTOM;
}