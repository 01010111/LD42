package objects;

class Spike extends Entity
{

	public function new(x:Int, y:Int, position:SpikePosition)
	{
		super({
			x: x * 16 + 4,
			y: y * 16
		});
		loadGraphic(Images.spikes__png, true, 16, 16);
		animation.add('0_FLOOR', [0, 1], 5);
		animation.add('0_CEILING', [2, 3], 5);
		animation.add('1_FLOOR', [1, 0], 5);
		animation.add('1_CEILING', [3, 2], 5);
		animation.play('${x % 2 == 0 ? 0 : 1}_$position');
		PlayState.i.hazards.add(this);
		offset.set(4);
	}

}

enum SpikePosition
{
	FLOOR;
	CEILING;
}