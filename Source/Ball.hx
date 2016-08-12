package ;
import openfl.display.Sprite;

class Ball extends Sprite
{

	public function new(x:Float, y:Float)
	{
		super();
		this.graphics.beginFill(Utils.BALL_COLOR);
		this.graphics.drawCircle(0, 0, Utils.BALL_RADIUS);
		this.graphics.endFill();
		this.x = x;
		this.y = y;
	}
}