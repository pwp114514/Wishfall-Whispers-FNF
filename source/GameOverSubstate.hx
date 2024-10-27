package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var loseBG:FlxSprite;
	var character:FlxSprite;
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	var rotateTimer:FlxTimer;
	var charTween:FlxTween;
	var charRotate:FlxTween;
	var charTween2:FlxTween;
	var retryTween:FlxTween;	
	var retry:FlxSprite;
	var alphaTween:FlxTween;
	var alphaTween2:FlxTween;
	var flashTween:FlxTween;
	var blackScreenTween:FlxTween;


	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	var tween:FlxTween;
	//var video = new PlayMedia();
	var flash:FlxSprite;
	var blackScreen:FlxSprite;
	//public static var videoPlayed = false;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
		{
			instance = this;
			PlayState.instance.callOnLuas('onGameOverStart', []);
	
			super.create();
		}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{		
		//curCharacter.startsWith('gf');
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		  bf = new Boyfriend(x, y, characterName);
		  add(bf);
		  bf.alpha = 0;

		  
		loseBG = new FlxSprite().loadGraphic(Paths.image('loseBG'));
		// loseBG.setGraphicSize(Std.int(loseBG.width * 1));
		// loseBG.updateHitbox();
		loseBG.screenCenter();
		loseBG.setGraphicSize(Std.int(loseBG.width * 1.1));
		 add(loseBG);

		 if(state.boyfriend.curCharacter.startsWith("bb"))
			{
				loseBG.alpha = 0;
				character = new FlxSprite(120, -25);
				character.frames = Paths.getSparrowAtlas('bbLose');
				character.animation.addByPrefix('idle', "idle", 12);
				character.animation.addByPrefix('confirm', "confirm", 12, false);
				//if(PlayState.isLucid)
				  // character.animation.play('glitch');
			   //else
					character.animation.play('idle');
				character.setGraphicSize(Std.int(character.width * 0.75));
				character.alpha = 0;
				character.antialiasing = ClientPrefs.globalAntialiasing;
				character.updateHitbox();
				add(character);
			}
		else
			{
				loseBG.alpha = 1;
				character = new FlxSprite(350, -50);
				character.frames = Paths.getSparrowAtlas('lilacLose');
				character.animation.addByPrefix('idle', "idle", 12);
				character.animation.addByPrefix('glitch', "glitch", 12);
				character.animation.addByPrefix('confirm', "confirm", 12, false);
				if(PlayState.isLucid)
				   character.animation.play('glitch');
			   else
					character.animation.play('idle');
				character.setGraphicSize(Std.int(character.width * 0.75));
				character.alpha = 0;
				character.antialiasing = ClientPrefs.globalAntialiasing;
				character.updateHitbox();
				add(character);
			}
		 


		 retry = new FlxSprite().loadGraphic(Paths.image('retry'));

		 retry.setGraphicSize(Std.int(retry.width * 0.7));
		 retry.alpha = 0;
		 retry.updateHitbox();
		 retry.x -= 80;
		 retry.y -= 70;
		 retry.antialiasing = ClientPrefs.globalAntialiasing;
		 add(retry);
		 retryTween = FlxTween.tween(retry, {'scale.x': 0.85, 'scale.y': 0.85}, 2.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		 
		 alphaTween = FlxTween.tween(retry, {alpha:1}, 3, {ease: FlxEase.quadOut, type: ONESHOT});
		 alphaTween2 = FlxTween.tween(character, {alpha:1}, 3, {ease: FlxEase.quadOut, type: ONESHOT});

		 if(state.boyfriend.curCharacter.startsWith("bb"))
			{
				charTween = FlxTween.tween(character, {y: character.y}, 3.27, {ease: FlxEase.sineInOut, type: PINGPONG});
				charTween2 =  FlxTween.angle(character, character.angle, 0, 5, {ease: FlxEase.sineInOut});
				rotateTimer =  new FlxTimer().start(5, function(tmr:FlxTimer)
				   {			
							if(charTween != null && charTween2 != null)
								{
									if(character.angle == -2)
										FlxTween.angle(character, character.angle, 0, 4.9, {ease: FlxEase.sineInOut});
									else 
										FlxTween.angle(character, character.angle, 0, 4.9, {ease: FlxEase.sineInOut});
								}
							  
				   }, 0);
			}
		else 
			{
				charTween = FlxTween.tween(character, {y: character.y + 17}, 3.27, {ease: FlxEase.sineInOut, type: PINGPONG});
				charTween2 =  FlxTween.angle(character, character.angle, -2, 5, {ease: FlxEase.sineInOut});
				rotateTimer =  new FlxTimer().start(5, function(tmr:FlxTimer)
				   {			
							if(charTween != null && charTween2 != null)
								{
									if(charRotate != null && character.angle == -2)
										charRotate = FlxTween.angle(character, character.angle, 7, 4.9, {ease: FlxEase.sineInOut});
									else if(charRotate != null)
										charRotate = FlxTween.angle(character, character.angle, -2, 4.9, {ease: FlxEase.sineInOut});
								}
							   
				   }, 0);
			}
		
		
		

		camFollow = new FlxPoint(character.getGraphicMidpoint().x, character.getGraphicMidpoint().y);
		

		FlxG.sound.play(Paths.sound(deathSoundName));

		blackScreen = new FlxSprite(0, 0).makeGraphic(3000, 3000, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 1;
		add(blackScreen);

		flash = new FlxSprite(0, 0).makeGraphic(3000, 3000, FlxColor.WHITE);
		flash.screenCenter();
		flash.blend = ADD;
		flash.alpha = 0;
		add(flash);
		
		
		// #if MODS_ALLOWED
		// if(!videoPlayed)
		// {
		// 	if(PlayState.isLucid)
		// 		video.startVideo('lilacGameOverLucid');
		// 	else 
		// 		video.startVideo('lilacGameOver');
		// }
		// #end
		//videoPlayed = true;

		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		trace(FlxG.camera.zoom);

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

				//updateCamera = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.camera.zoom = 0.8;

		FlxG.camera.follow(camFollowPos, LOCKON, 0);
		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			//camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			//if(video != null)
			//video.update(1);
			rotateTimer.active = false;
			if(flashTween != null)
				flashTween.cancel();
				if(blackScreenTween != null)
				blackScreenTween.cancel();
				if(charTween != null)
				charTween.cancel();
				if(charTween2 != null)
				charTween2.cancel();
				if(retryTween != null)
				retryTween.cancel();
				if(alphaTween != null)
				alphaTween.cancel();
				if(alphaTween2 != null)
				alphaTween2.cancel();
				if(charRotate != null)
				charRotate.cancel();
				
			endBullshit();
		}

		if (controls.BACK)
		{
			rotateTimer.active = false;
			//if(video != null)
			//video.update(1);
			if(flashTween != null)
			flashTween.cancel();
			if(blackScreenTween != null)
			blackScreenTween.cancel();
			if(charTween != null)
			charTween.cancel();
			if(charTween2 != null)
			charTween2.cancel();
			if(retryTween != null)
			retryTween.cancel();
			if(alphaTween != null)
			alphaTween.cancel();
			if(alphaTween2 != null)
			alphaTween2.cancel();
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				{
					if(!PlayState.isCampaignB)MusicBeatState.switchState(new StoryMenuState());
					else if(PlayState.isCampaignB)MusicBeatState.switchState(new StoryMenuBState());
				}
				
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.menuMusic('Wayward'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		 if (bf.animation.curAnim.name == 'firstDeath')
		 {
			if(bf.animation.curAnim.curFrame == 1)
			{
			
			}

			// if (bf.animation.curAnim.finished)
			if (bf.animation.curAnim.curFrame == 30)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		blackScreenTween = FlxTween.tween(blackScreen, {alpha: 0}, 1.5);
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{

			if(blackScreenTween != null)
			blackScreenTween.cancel();
			blackScreen.alpha = 0;
			flash.color = 0xff786f7d;
	
			flash.alpha = 1;
			flashTween = FlxTween.tween(flash, {alpha: 0}, 1.2);

			isEnding = true;
			character.animation.play('confirm');
			bf.playAnim('deathConfirm', false);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxTween.tween(camFollow, {y: -4000}, 1, { ease: FlxEase.quadInOut});
			FlxTween.tween(retry, { alpha: 0}, 1, { ease: FlxEase.quadInOut});
			tween;
			rotateTimer.active = false;
			
			if(charTween != null)
			charTween.cancel();
			if(charTween2 != null)
			charTween2.cancel();
			if(retryTween != null)
			retryTween.cancel();
			if(alphaTween != null)
			alphaTween.cancel();
			if(alphaTween2 != null)
			alphaTween2.cancel();

				if(blackScreenTween != null)
				blackScreenTween.cancel();
				if(charTween != null)
				charTween.cancel();
				if(charTween2 != null)
				charTween2.cancel();
				if(retryTween != null)
				retryTween.cancel();
				if(alphaTween != null)
				alphaTween.cancel();
				if(alphaTween2 != null)
				alphaTween2.cancel();

			retry.alpha = 1;
			character.alpha = 1;
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
