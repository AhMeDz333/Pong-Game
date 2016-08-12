package ;
import openfl.Lib;

class ScaleManager {
	// dimensions
	public static inline var BALL_RADIUS :Float = 10;
	public static inline var PLATFORM_WIDTH :Float = 15;
	public static inline var PLATFORM_HEIGHT :Float = 100;
	public static inline var PLATFORM_Y :Float = 200;
	public static inline var PLATFORM1_X :Float = 5;
	public static inline var PLATFORM2_X :Float = 480;
	public static inline var SCREEN_CENTER :Float = 250;
	public static var LAST_SCREEN_WIDTH :Float = 500;
	public static var LAST_SCREEN_HEIGHT :Float = 500;

	// dynamicality constants
	public static inline var PLATFORM_SPEED :Int = 7;
	public static inline var BALL_SPEED :Int = 7;

	// colors
	public static inline var BALL_COLOR :Int = 0x8662A3;
	public static inline var PLATFORM_COLOR :Int = 0x81C7DE;
	public static inline var SCORE_COLOR :Int = 0xbbbbbb;


	// key codes
	public static inline var CODE_SPACE :Int = 32;
	public static inline var CODE_UP :Int = 38;
	public static inline var CODE_DOWN :Int = 40;


	// layout parameters
	public static inline var MESSAGE_MARGIN :Int = 50;


	// helper methods
	public static function screenHeight() :Float{
		return Lib.current.stage.stageHeight;
//		return 500;
	}

	public static function screenWidth() :Float{
		return Lib.current.stage.stageWidth;
//		return 500;
	}

	public static function resetScreenInitials() :Void{
		LAST_SCREEN_HEIGHT = screenHeight();
		LAST_SCREEN_WIDTH = screenWidth();
	}

	public static function getScaleX() :Float{
		trace("width", screenWidth());
		return screenWidth() / LAST_SCREEN_WIDTH;
	}

	public static function getScaleY() :Float{
		trace("height", screenHeight());
		return screenHeight() / LAST_SCREEN_HEIGHT;
	}

	public static function getAITriggerDistance() :Float{
		return screenWidth() * 3 / 5;
	}

	public function new() {
	}
}
