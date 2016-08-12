package ;

import flash.media.SoundChannel;
import openfl.media.Sound;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.BitmapData;
import Main.Player;
import Main.GameState;
import openfl.geom.Point;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

enum GameState {
	Paused;
	Playing;
}

enum Player {
	Human;
	AI;
}

class Main extends Sprite
{
	var inited:Bool;
	
	private var platform1:Platform;
	private var platform2:Platform;
	private var ball:Ball;
	private var scorePlayer:Int;
	private var scoreAI:Int;
	private var scoreField:TextField;
	private var messageField:TextField;
	private var currentGameState:GameState;
	private var arrowKeyUp:Bool;
	private var arrowKeyDown:Bool;
	private var platformSpeed:Int;
	private var messageVisibility:Int;
	private var ballMovement:Point;
	private var ballSpeed:Int;
	private var soundChannel:SoundChannel;
	private var soundFile:Sound;

	/* ENTRY POINT */

	function resize(e)
	{
		if (!inited) init();
		 else {
			trace("resize");
			// (resize or orientation change)
		}
	}

	function init()
	{
		trace("init");
		if (inited) return;
		inited = true;

		var bd:BitmapData = Assets.getBitmapData("backgroundImg");
		var b:Bitmap = new Bitmap(bd);
		this.addChild(b);

		soundFile = Assets.getSound("backgroundSound");
		soundChannel = soundFile.play(0 ,100);

		platform1 = new Platform(Utils.PLATFORM1_X, Utils.PLATFORM_Y, Utils.PLATFORM_WIDTH, Utils.PLATFORM_HEIGHT);
		this.addChild(platform1);

		platform2 = new Platform(Utils.PLATFORM2_X, Utils.PLATFORM_Y, Utils.PLATFORM_WIDTH, Utils.PLATFORM_HEIGHT);
		this.addChild(platform2);

		ball = new Ball(Utils.screenWidth()/2, Utils.screenHeight()/2);
		this.addChild(ball);

		var scoreFormat:TextFormat = new TextFormat("Verdana", 24, Utils.SCORE_COLOR, true);
		scoreFormat.align = TextFormatAlign.CENTER;

		scoreField = new TextField();
		addChild(scoreField);
		scoreField.width = Utils.screenWidth();
		scoreField.y = Utils.MESSAGE_MARGIN;
		scoreField.defaultTextFormat = scoreFormat;
		scoreField.selectable = false;

		var messageFormat:TextFormat = new TextFormat("Verdana", 18, Utils.SCORE_COLOR, true);
		messageFormat.align = TextFormatAlign.CENTER;

		messageField = new TextField();
		addChild(messageField);
		messageField.width = Utils.screenWidth();
		messageField.y = Utils.screenWidth() - Utils.MESSAGE_MARGIN;
		messageField.defaultTextFormat = messageFormat;
		messageField.selectable = false;
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";

		initFieldVariables();
		setGameState(GameState.Paused);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
//		stage.addEventListener(KeyboardEvent.);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}

	private function initFieldVariables():Void{
		scorePlayer = 0;
		scoreAI = 0;
//		messageVisibility = 0;
		arrowKeyUp = false;
		arrowKeyDown = false;
		platformSpeed = Utils.PLATFORM_SPEED;
		ballSpeed = Utils.BALL_SPEED;
		ballMovement = new Point(0,0);
	}

	private function setGameState(state:GameState):Void {
		currentGameState = state;
		updateScore();
		if (state == GameState.Paused) {
			if (soundChannel != null)
				soundChannel.stop();

			messageField.alpha = 1;
		}else {
			soundChannel = soundFile.play(0 ,100);
			messageField.alpha = 0;
			platform1.y = Utils.PLATFORM_Y;
			platform2.y = Utils.PLATFORM_Y;
			ball.x = Utils.screenWidth() / 2;
			ball.y = Utils.screenHeight() / 2;
			setBallMovementVector();
		}
	}

	private function setBallMovementVector():Void{
		var direction:Int = (Math.random() > .5)?(1):( -1);
		var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = Math.sin(randomAngle) * ballSpeed;
	}

	private function keyDown(event:KeyboardEvent):Void {
		if (currentGameState == GameState.Paused && event.keyCode == Utils.CODE_SPACE) { // Space
			setGameState(GameState.Playing);
		}else if (event.keyCode == Utils.CODE_UP) { // Up
			arrowKeyUp = true;
		}else if (event.keyCode == Utils.CODE_DOWN) { // Down
			arrowKeyDown = true;
		}
	}

	private function keyUp(event:KeyboardEvent):Void {
		if (event.keyCode == Utils.CODE_UP) { // Up
			arrowKeyUp = false;
		}else if (event.keyCode == Utils.CODE_DOWN) { // Down
			arrowKeyDown = false;
		}
	}

	private function everyFrame(event:Event):Void {
//		messageVisibility++;
		if(currentGameState == GameState.Playing){
			if (arrowKeyUp) {
				platform1.y -= platformSpeed;
			}
			if (arrowKeyDown) {
				platform1.y += platformSpeed;
			}
			// AI platform movement
			if (ball.x > Utils.getAITriggerDistance() && ball.y > platform2.y + 70) {
				platform2.y += platformSpeed;
			}
			if (ball.x > Utils.getAITriggerDistance() && ball.y < platform2.y + 30) {
				platform2.y -= platformSpeed;
			}
			// player platform limits
			if (platform1.y < 5) platform1.y = 5;
			if (platform1.y > 395) platform1.y = 395;
			// AI platform limits
			if (platform2.y < 5) platform2.y = 5;
			if (platform2.y > 395) platform2.y = 395;
			// ball movement
			ball.x += ballMovement.x;
			ball.y += ballMovement.y;
			// ball platform bounce
			if (ballMovement.x < 0 && ball.x < 30 && ball.y >= platform1.y && ball.y <= platform1.y + 100) {
				bounceBall();
				ball.x = 30;
			}
			if (ballMovement.x > 0 && ball.x > 470 && ball.y >= platform2.y && ball.y <= platform2.y + 100) {
				bounceBall();
				ball.x = 470;
			}
			// ball edge bounce
			if (ball.y < 5 || ball.y > 495)
				ballMovement.y *= -1;
			// ball goal
			if (ball.x < 5) winGame(Player.AI);
			if (ball.x > 495) winGame(Player.Human);

		}/* else {
			if (messageVisibility % 101 == 0)
				messageField.alpha = 1;
			else if (messageVisibility % 203 == 0)
				messageField.alpha = 0;
		}*/
	}

	private function bounceBall():Void {
		var direction:Int = (ballMovement.x > 0)?( -1):(1);
		var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = direction * Math.sin(randomAngle) * ballSpeed;
	}

	private function winGame(player:Player):Void {
		if (player == Player.Human) {
			scorePlayer++;
		} else {
			scoreAI++;
		}
		setGameState(GameState.Paused);
	}

	private function updateScore():Void {
		scoreField.text = scorePlayer + " : " + scoreAI;
		scoreField.textColor = Utils.SCORE_COLOR;
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