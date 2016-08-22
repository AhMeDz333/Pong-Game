package ;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.Lib;

class ScaleManager {
	// dimensions
	public static var BALL_RADIUS :Float = 10;
	public static var PLATFORM_WIDTH :Float = 15;
	public static var PLATFORM_HEIGHT :Float = 100;
	public static var LAST_SCREEN_WIDTH :Float = 500;
	public static var LAST_SCREEN_HEIGHT :Float = 500;
	public static var PLATFORM_MARGIN :Float = 5;
	public static var ARROW_MARGIN :Float = 50;
	public static var PLATFORM_Y :Float = 200;
	public static var PLATFORM1_X :Float = 5;
	public static var PLATFORM2_X_INITIAL :Float = 495;
	public static var PLATFORM2_X :Float = 480;
	public static var BOUNCE_X_LIMIT :Float = 30;

	// dynamicality variables
	public static var PLATFORM_SPEED :Float = 7;
	public static var BALL_SPEED :Float = 7;

	// colors
	public static inline var BALL_COLOR :Int = 0x8662A3;
	public static inline var PLATFORM_COLOR :Int = 0x81C7DE;
	public static inline var SCORE_COLOR :Int = 0xbbbbbb;

	// layout parameters
	public static inline var MESSAGE_MARGIN_INITIAL :Int = 50;


	// helper methods
	public static function screenHeight() :Float {
		return LAST_SCREEN_HEIGHT;
//		return 500;
	}

	public static function screenWidth() :Float {
		return LAST_SCREEN_WIDTH;
//		return 500;
	}


	public static function rescaleSprite(displayObj :DisplayObject) :Void {
		var scaleX :Float = getScaleX();
		var scaleY :Float = getScaleY();
//		displayObj.scaleX = scaleX;
//		displayObj.scaleY = scaleY;
//		trace("before", displayObj.x+"", displayObj.y+"");
		displayObj.x *= scaleX;
		displayObj.y *= scaleY;
//		trace("after", displayObj.x+"", displayObj.y+"");
	}

	public static function rescaleTextField(textField :TextField) :Void {
		var scaleX :Float = getScaleX();
		var scaleY :Float = getScaleY();
		textField.width = Lib.current.stage.stageWidth;
		textField.y *= scaleY;
	}

	public static function resetScreenInitials() :Void {
		var scaleX :Float = getScaleX();
		var scaleY :Float = getScaleY();
		LAST_SCREEN_HEIGHT = Lib.current.stage.stageHeight;
		LAST_SCREEN_WIDTH = Lib.current.stage.stageWidth;
		PLATFORM_Y *= scaleY;
//		PLATFORM1_X *= scaleX;
//		PLATFORM2_X = Lib.current.stage.stageWidth - PLATFORM_WIDTH - PLATFORM_MARGIN;
		BOUNCE_X_LIMIT *= scaleX;
		BALL_SPEED *= scaleX;
		PLATFORM_SPEED *= scaleY;
		PLATFORM_HEIGHT *= scaleY;
	}

	public static function getPlatformYLimit() :Float {
		return screenHeight() - PLATFORM_HEIGHT - 5;
	}

	public static function getScaleX() :Float {
		return Lib.current.stage.stageWidth / LAST_SCREEN_WIDTH;
	}

	public static function getScaleY() :Float {
		return Lib.current.stage.stageHeight / LAST_SCREEN_HEIGHT;
	}

	public static function getPureScaleX() :Float {
		return Lib.current.stage.stageWidth / 500;
	}

	public static function getPureScaleY() :Float {
		return Lib.current.stage.stageHeight / 500;
	}



	public static function getAITriggerDistance() :Float {
		return screenWidth() * 3 / 5;
	}

	public function new() {
	}
}
