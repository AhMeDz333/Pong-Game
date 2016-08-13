package ;

import flash.ui.Mouse;
import flash.events.MouseEvent;
import com.roxstudio.haxe.gesture.RoxGestureEvent;
import com.roxstudio.haxe.gesture.RoxGestureAgent;
import openfl.ui.MultitouchInputMode;
import openfl.ui.Multitouch;
import Enums.GameState;
import Enums.Player;
import flash.media.SoundChannel;
import openfl.media.Sound;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class Main extends Sprite
{
	var inited :Bool;

	// key codes
	public static inline var CODE_SPACE :Int = 32;
	public static inline var CODE_UP :Int = 38;
	public static inline var CODE_DOWN :Int = 40;

	private var platform1 :Platform;
	private var platform2 :Platform;
	private var ball :Ball;
	private var scorePlayer :Int;
	private var scoreAI :Int;
	private var scoreField :TextField;
	private var messageField :TextField;
	private var currentGameState :GameState;
	private var arrowKeyUp :Bool;
	private var arrowKeyDown :Bool;
	private var platformSpeed :Float;
	private var messageVisibility :Int;
	private var ballMovement :Point;
	private var ballSpeed :Float;
	private var soundChannel :SoundChannel;
	private var soundFile :Sound;
	private var lastYScroll :Float;
	private var scrollTriggered :Bool;

	/* ENTRY POINT */

	function resize(e)
	{
		if (!inited) init();
		 else {
			// rescale all sprite objects to match the new screen size.
			rescale(ScaleManager.getScaleX(), ScaleManager.getScaleY());
			ScaleManager.resetScreenInitials(ScaleManager.getScaleX(), ScaleManager.getScaleY());
			platform2.x = ScaleManager.PLATFORM2_X;
		}
	}

	private function rescale(scaleX :Float, scaleY :Float) :Void {
		rescaleSprite(platform1, scaleX, scaleY);
		rescaleSprite(platform2, scaleX, scaleY);
		rescaleSprite(ball, scaleX, scaleY);
		rescaleTextField(scoreField, scaleX, scaleY);
		rescaleTextField(messageField, scaleX, scaleY);
	}

	private function rescaleSprite(sprite :Sprite, scaleX :Float, scaleY :Float) :Void {
//		sprite.scaleX = scaleX;
//		sprite.scaleY = scaleY;
//		trace("before", sprite.x+"", sprite.y+"");
		sprite.x *= scaleX;
		sprite.y *= scaleY;
//		trace("after", sprite.x+"", sprite.y+"");
	}

	private function rescaleTextField(textField :TextField, scaleX :Float, scaleY :Float) :Void {
		textField.width = Lib.current.stage.stageWidth;
		textField.y *= scaleY;
	}

	function init()
	{
		if (inited) return;
		inited = true;

		var bd :BitmapData = Assets.getBitmapData("backgroundImg");
		var b :Bitmap = new Bitmap(bd);
		this.addChild(b);

		soundFile = Assets.getSound("backgroundSound");
		soundChannel = soundFile.play(0 ,100);


		platform1 = new Platform(ScaleManager.PLATFORM1_X, ScaleManager.PLATFORM_Y, ScaleManager.PLATFORM_WIDTH, ScaleManager.PLATFORM_HEIGHT);
		this.addChild(platform1);

		platform2 = new Platform(ScaleManager.PLATFORM2_X, ScaleManager.PLATFORM_Y, ScaleManager.PLATFORM_WIDTH, ScaleManager.PLATFORM_HEIGHT);
		this.addChild(platform2);

		ball = new Ball(ScaleManager.screenWidth()/2, ScaleManager.screenHeight()/2);
		this.addChild(ball);

		var scoreFormat :TextFormat = new TextFormat("Verdana", 24, ScaleManager.SCORE_COLOR, true);
		scoreFormat.align = TextFormatAlign.CENTER;

		scoreField = new TextField();
		addChild(scoreField);
		scoreField.width = ScaleManager.screenWidth();
		scoreField.y = ScaleManager.MESSAGE_MARGIN_INITIAL;
		scoreField.defaultTextFormat = scoreFormat;
		scoreField.selectable = false;

		var messageFormat :TextFormat = new TextFormat("Verdana", 18, ScaleManager.SCORE_COLOR, true);
		messageFormat.align = TextFormatAlign.CENTER;

		messageField = new TextField();
		addChild(messageField);
		messageField.width = ScaleManager.screenWidth();
		messageField.y = ScaleManager.screenWidth() - ScaleManager.MESSAGE_MARGIN_INITIAL;
		messageField.defaultTextFormat = messageFormat;
		messageField.selectable = false;
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";

		initFieldVariables();
		setGameState(GameState.Paused);

		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
//		stage.addEventListener(TouchEvent.TOUCH_TAP, spaceClicked);
//		stage.addEventListener(TouchEvent.TOUCH);
		var roxAgent = new RoxGestureAgent(stage, RoxGestureAgent.GESTURE);

		stage.addEventListener(MouseEvent.MOUSE_UP, spaceClicked);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e :MouseEvent){
			if (lastYScroll == Math.NEGATIVE_INFINITY){
				lastYScroll = e.localY;

			} else if (e.buttonDown){
				if (lastYScroll > e.localY){
					arrowKeyDown = false;
					arrowKeyUp = true;
//					scrollTriggered = true;
//					haxe.Timer.delay(function(){
//						if (!scrollTriggered){
//							arrowKeyDown = arrowKeyUp = false;
//							trace("done scroll up!")
//						}
//					}, 100);
				} else {
					arrowKeyUp = false;
					arrowKeyDown = true;
				}
			}
		});
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}

	private function initFieldVariables() :Void {
		scorePlayer = 0;
		scoreAI = 0;
		messageVisibility = 0;
		lastYScroll = Math.NEGATIVE_INFINITY;
		scrollTriggered = false;
		arrowKeyUp = false;
		arrowKeyDown = false;
		platformSpeed = ScaleManager.PLATFORM_SPEED;
		ballSpeed = ScaleManager.BALL_SPEED;
		ballMovement = new Point(0,0);
	}

	private function setGameState(state :GameState) :Void {
		currentGameState = state;
		updateScore();
		if (state == GameState.Paused) {
			if (soundChannel != null)
				soundChannel.stop();

			messageField.alpha = 1;
		}else {
//			soundChannel = soundFile.play(0 ,100);
			messageField.alpha = 0;
			platform1.y = ScaleManager.PLATFORM_Y;
			platform2.y = ScaleManager.PLATFORM_Y;
			ball.x = ScaleManager.screenWidth() / 2;
			ball.y = ScaleManager.screenHeight() / 2;
			setBallMovementVector();
		}
	}

	private function setBallMovementVector() :Void {
		var direction :Int = (Math.random() > .5)?(1) :( -1);
		var randomAngle :Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = Math.sin(randomAngle) * ballSpeed;
	}

	private function spaceClicked(e:Dynamic) :Void {
//		trace("touch", messageVisibility++);
		lastYScroll = Math.NEGATIVE_INFINITY;
		arrowKeyDown = arrowKeyUp = false;
		if (currentGameState == GameState.Paused)
			setGameState(GameState.Playing);
	}

	private function keyDown(event :KeyboardEvent) :Void {
		if (event.keyCode == CODE_SPACE) { // Space
			spaceClicked(event);
		}else if (event.keyCode == CODE_UP) { // Up
			arrowKeyUp = true;
		}else if (event.keyCode == CODE_DOWN) { // Down
			arrowKeyDown = true;
		}
	}

	private function keyUp(event :KeyboardEvent) :Void {
		if (event.keyCode == CODE_UP) { // Up
			arrowKeyUp = false;
		}else if (event.keyCode == CODE_DOWN) { // Down
			arrowKeyDown = false;
		}
	}

	private function everyFrame(event :Event) :Void {
//		messageVisibility++;
		if(currentGameState == GameState.Playing){
			if (arrowKeyUp) {
				platform1.y -= platformSpeed;
			}
			if (arrowKeyDown) {
				platform1.y += platformSpeed;
			}
			// AI platform movement
			if (ball.x > ScaleManager.getAITriggerDistance() && ball.y > platform2.y + ScaleManager.PLATFORM_HEIGHT*0.7) {
				platform2.y += platformSpeed;
			}
			if (ball.x > ScaleManager.getAITriggerDistance() && ball.y < platform2.y + ScaleManager.PLATFORM_HEIGHT*0.3) {
				platform2.y -= platformSpeed;
			}
			// player platform limits
			platform1.y = Math.max(platform1.y, ScaleManager.PLATFORM_MARGIN);
			platform1.y = Math.min(platform1.y, ScaleManager.getPlatformYLimit());
			// AI platform limits
			platform2.y = Math.max(platform2.y, ScaleManager.PLATFORM_MARGIN);
			platform2.y = Math.min(platform2.y, ScaleManager.getPlatformYLimit());
			// ball movement
			ball.x += ballMovement.x;
			ball.y += ballMovement.y;
			// ball platform bounce
			if (ballMovement.x < 0 && ball.x < 30 && ball.y >= platform1.y && ball.y <= platform1.y + 100) {
				bounceBall();
				ball.x = 30;
			}
			if (ballMovement.x > 0 && ball.x > Lib.current.stage.stageWidth - 30 && ball.y >= platform2.y && ball.y <= platform2.y + 100) {
				bounceBall();
				ball.x = Lib.current.stage.stageWidth - 30;
			}
			// ball edge bounce
			if (ball.y < ScaleManager.PLATFORM_MARGIN || ball.y > ScaleManager.screenHeight() - ScaleManager.PLATFORM_MARGIN)
				ballMovement.y *= -1;
			// ball goal
			if (ball.x < ScaleManager.PLATFORM_MARGIN) winGame(Player.AI);
			if (ball.x > ScaleManager.screenWidth()-ScaleManager.PLATFORM_MARGIN) winGame(Player.Human);

		}/* else {
			if (messageVisibility % 101 == 0)
				messageField.alpha = 1;
			else if (messageVisibility % 203 == 0)
				messageField.alpha = 0;
		}*/
	}

	private function bounceBall() :Void {
		var direction :Int = (ballMovement.x > 0)?( -1) :(1);
		var randomAngle :Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = direction * Math.sin(randomAngle) * ballSpeed;
	}

	private function winGame(player :Player) :Void {
		if (player == Player.Human) {
			scorePlayer++;
		} else {
			scoreAI++;
		}
		setGameState(GameState.Paused);
	}

	private function updateScore() :Void {
		scoreField.text = scorePlayer + " : " + scoreAI;
	}

	/* SETUP */

	public function new()
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e)
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main()
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		//
	}
}