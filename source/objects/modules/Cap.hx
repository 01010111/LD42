package objects.modules;

class Cap extends Module
{

	public function new()
	{
		super({
			name: 'cap',
			module_height: 1,
			constraints: [TOP],
			components: []
		});
		loadGraphic(Images.modules__png, true, 32, 16);
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		if (parent.velocity.y.abs() < 100) animation.frameIndex = 26;
		if (parent.velocity.y < 0) animation.frameIndex = 27;
		if (parent.velocity.y > 0) animation.frameIndex = 28;
	}

}