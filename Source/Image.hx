package ;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Image extends Sprite {

	public function new (bitmap :Bitmap) {
		super();
		this.addChild(bitmap);
	}
}
