package ;
import openfl.display.Sprite;

class Platform extends Sprite
{

	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super();
		this.graphics.beginFill(Utils.PLATFORM_COLOR);
		this.graphics.drawRect(0, 0, width, height);
		this.graphics.endFill();
		this.x = x;
		this.y = y;
	}
}