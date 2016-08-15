package ;

import ScaleManager;
import ScaleManager;
import openfl.events.MouseEvent;
import com.roxstudio.haxe.gesture.RoxGestureAgent;
import openfl.ui.MultitouchInputMode;
import openfl.ui.Multitouch;
import Enums.GameState;
import Enums.Player;
import openfl.media.SoundChannel;
import openfl.media.Sound;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
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
	private var messageVisibility :Int;
	private var ballMovement :Point;
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
			rescale();
		}
	}

	private function rescale() :Void {
		ScaleManager.rescaleSprite(platform1);
		ScaleManager.rescaleSprite(platform2);
		platform1.x = ScaleManager.PLATFORM_MARGIN;
		platform2.x = Lib.current.stage.stageWidth - ScaleManager.PLATFORM_WIDTH - ScaleManager.PLATFORM_MARGIN;
		platform1.scaleY = platform2.scaleY = ScaleManager.getPureScaleY();
		ScaleManager.rescaleSprite(ball);
		ScaleManager.rescaleTextField(scoreField);
		ScaleManager.rescaleTextField(messageField);
		ScaleManager.resetScreenInitials();
	}

	function init()
	{   trace("init");
		if (inited) return;
		inited = true;

//		var bd :BitmapData = Assets.getBitmapData("backgroundImg");
//		var b :Bitmap = new Bitmap(bd);
//		this.addChild(b);
//
//		soundFile = Assets.getSound("backgroundSound");
//		soundChannel = soundFile.play(0 ,100);


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
		#if (mobile)
		messageField.text = "Touch anywhere to start\nSwipe to move your platform";
		#else
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";
		#end
		initFieldVariables();
		setGameState(GameState.Paused);

		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
//		stage.addEventListener(TouchEvent.TOUCH_TAP, spaceClicked);
//		stage.addEventListener(TouchEvent.TOUCH);
		var roxAgent = new RoxGestureAgent(stage, RoxGestureAgent.GESTURE);

		stage.addEventListener(MouseEvent.MOUSE_DOWN, spaceClicked);
		stage.addEventListener(MouseEvent.MOUSE_UP, function(e :MouseEvent){
			lastYScroll = Math.NEGATIVE_INFINITY;
			arrowKeyDown = arrowKeyUp = false;
		});
		stage.addEventListener(MouseEvent.MOUSE_OUT, function(e :MouseEvent){
			lastYScroll = Math.NEGATIVE_INFINITY;
			arrowKeyDown = arrowKeyUp = false;
		});
		stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e :MouseEvent){
			if (e.buttonDown){
				trace(e, messageVisibility++);
				if (lastYScroll != Math.NEGATIVE_INFINITY){
					if (lastYScroll > e.localY){
						arrowKeyDown = false;
						arrowKeyUp = true;
						lastYScroll = e.localY;

					} else if (lastYScroll < e.localY){
						arrowKeyUp = false;
						arrowKeyDown = true;
						lastYScroll = e.localY;
					}
				} else {
//				trace("equal", messageVisibility++);
					arrowKeyDown = arrowKeyUp = false;
					lastYScroll = e.localY;
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
		ballMovement = new Point(0,0);
		#if (mobile)
		ScaleManager.PLATFORM_SPEED = 10;
		#end
	}

	private function setGameState(state :GameState) :Void {
		currentGameState = state;
		updateScore();
		if (state == GameState.Paused) {
			if (soundChannel != null)
				soundChannel.stop();

			messageField.alpha = 1;
		}else {
			if (soundFile != null)
				soundChannel = soundFile.play(0 ,100);
			lastYScroll = Math.NEGATIVE_INFINITY;
			arrowKeyDown = arrowKeyUp = false;
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
		ballMovement.x = direction * Math.cos(randomAngle) * ScaleManager.BALL_SPEED;
		ballMovement.y = Math.sin(randomAngle) * ScaleManager.BALL_SPEED;
	}

	private function spaceClicked(e:Dynamic) :Void {
		lastYScroll = Math.NEGATIVE_INFINITY;
		arrowKeyDown = arrowKeyUp = false;
//		trace("touch", messageVisibility++);
		if (currentGameState == GameState.Paused)
			setGameState(GameState.Playing);
		else{
//			if (Std.instance(e, MouseEvent) != null){
//				var me :MouseEvent = cast(e, MouseEvent);
//				if (me.localY == lastYScroll){
//					arrowKeyUp = arrowKeyDown = false;
//					lastYScroll = Math.NEGATIVE_INFINITY;
//				}
//			}
		}
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
				platform1.y -= ScaleManager.PLATFORM_SPEED;
			}
			if (arrowKeyDown) {
				platform1.y += ScaleManager.PLATFORM_SPEED;
			}
			// AI platform movement
			if (ball.x > ScaleManager.getAITriggerDistance() && ball.y > platform2.y + ScaleManager.PLATFORM_HEIGHT*0.7) {
				platform2.y += ScaleManager.PLATFORM_SPEED;
			}
			if (ball.x > ScaleManager.getAITriggerDistance() && ball.y < platform2.y + ScaleManager.PLATFORM_HEIGHT*0.3) {
				platform2.y -= ScaleManager.PLATFORM_SPEED;
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
			if (ballMovement.x < 0 && ball.x < 30 && ball.y >= platform1.y && ball.y <= platform1.y + ScaleManager.PLATFORM_HEIGHT) {
				bounceBall();
				ball.x = 30;
			}
			if (ballMovement.x > 0 && ball.x > Lib.current.stage.stageWidth - 30 && ball.y >= platform2.y && ball.y <= platform2.y + ScaleManager.PLATFORM_HEIGHT) {
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
		ballMovement.x = direction * Math.cos(randomAngle) * ScaleManager.BALL_SPEED;
		ballMovement.y = direction * Math.sin(randomAngle) * ScaleManager.BALL_SPEED;
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
		Lib.current.stage.align = openfl.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		//
	}
}