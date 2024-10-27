package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flash.display.BlendMode;
//import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import MenuCharacter;

using StringTools;

class TitleState extends MusicBeatState
{
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.G, FlxKey.L, FlxKey.U, FlxKey.T, FlxKey.O]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	override public function create():Void
	{

		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end
		
		#if CHECK_FOR_UPDATES
		// if(!closedState) {
		// 	trace('checking for update');
		// 	var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
		// 	http.onData = function (data:String)
		// 	{
		// 		updateVersion = data.split('\n')[0].trim();
		// 		var curVersion:String = MainMenuState.psychEngineVersion.trim();
		// 		trace('version online: ' + updateVersion + ', your version: ' + curVersion);
		// 		if(updateVersion != curVersion) {
		// 			trace('versions arent matching!');
		// 			mustUpdate = true;
		// 		}
		// 	}
			
		// 	http.onError = function (error) {
		// 		trace('error: $error');
		// 	}
			
		// 	http.request();
		// }
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else 
		{
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('Wayward'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.menuMusic('Wayward'), 0);

				FlxG.sound.music.fadeIn(4, 0, 1);
			}
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		// var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 2));
		// bg.updateHitbox();
		// add(bg);

		var bgcove:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGevening'));
		if (MusicBeatState.worldTimeName == "morning")
			{
				bgcove = new FlxSprite(-80).loadGraphic(Paths.image('menuBGmorning'));
				FlxG.save.data.playedMorning = true;
			}
		else if (MusicBeatState.worldTimeName == "day")
			{	
				bgcove = new FlxSprite(-80).loadGraphic(Paths.image('menuBGday'));
				FlxG.save.data.playedDay = true;
			}
		else if (MusicBeatState.worldTimeName == "evening")
			{
				bgcove = new FlxSprite(-80).loadGraphic(Paths.image('menuBGevening'));
				FlxG.save.data.playedEvening = true;
			}
		else if (MusicBeatState.worldTimeName == "night")
			{
				FlxG.save.data.playedNight = true;
				bgcove = new FlxSprite(-80).loadGraphic(Paths.image('menuBGnight'));
			}
				



			//bgcove.scrollFactor.set(camFollow.x, yScroll * 0.7);
		bgcove.setGraphicSize(Std.int(bgcove.width * 0.8));
		bgcove.updateHitbox();
		bgcove.screenCenter();
		bgcove.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(bgcove);
		bgcove.x = bgcove.x - 14;


		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gradient'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(Std.int(bg.width * 2));
		bg.updateHitbox();
		add(bg);


		var bgDiamonds:FlxSprite = new FlxSprite().loadGraphic(Paths.image('diamonds'));
		bgDiamonds.blend = BlendMode.MULTIPLY;
		bgDiamonds.alpha = 0.2;
		bgDiamonds.setGraphicSize(Std.int(bgDiamonds.width * 0.5));
		bgDiamonds.antialiasing = true;
		bgDiamonds.updateHitbox();
		var scrollDiamonds:FlxBackdrop;
		scrollDiamonds = new FlxBackdrop(bgDiamonds.graphic, 60, 60);
		scrollDiamonds.blend = BlendMode.MULTIPLY;
		scrollDiamonds.alpha = 0.1;
		add(scrollDiamonds);
		scrollDiamonds.velocity.set(30, 30);

		var slice:FlxSprite = new FlxSprite().loadGraphic(Paths.image('titleSlice'));
		slice.antialiasing = ClientPrefs.globalAntialiasing;
		slice.setGraphicSize(Std.int(slice.width * 0.7));
		slice.updateHitbox();
		add(slice);


		var charArray = CoolUtil.coolTextFile(Paths.txt('charList'));
		var charColorArray = CoolUtil.coolTextFile(Paths.txt('charColorList'));
		var charNum:Int = FlxG.random.int(0,2);
		trace(charArray);
		var funnyColor = "0xFF49B0B9";
		if(MusicBeatState.glutoMode)
			funnyColor = "0xFFDBAF00";
		else 
			funnyColor = charColorArray[charNum];
			

		if(!funnyColor.startsWith('0x')) funnyColor = '0xFF' + funnyColor;
		var shitshitshit:FlxColor = Std.parseInt(funnyColor);
		var poop:FlxColor = 0xFFFFFFFF;
		trace(poop);
		switch (charNum)
		{
			case 0:
			poop = 0xFFDEDEFF;
			FlxColor.BLUE;
			case 1:
			poop = 0xFFFFD5D5;
			FlxColor.RED;
			case 2:
			poop = 0xFFFEDCFF;
			//FlxColor.YELLOW;
		}
		slice.color = poop;

		var poop2:FlxColor = 0xFFFFFFFF;
		trace(poop);
		switch (charNum)
		{
			case 0:
			poop2 = 0xFF3B3B81;
			FlxColor.BLUE;
			case 1:
			poop2 = 0xFF7A2929;
			FlxColor.RED;
			case 2:
			poop2 = 0xFF783E87;
			//FlxColor.YELLOW;
		}
		//restaurantFilter.color = shitshitshit;
		//trace(poop);
		

		var restaurantFilter:BGSprite;
				restaurantFilter = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				restaurantFilter.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), shitshitshit);
				restaurantFilter.alpha = 0.50;
				restaurantFilter.blend = MULTIPLY;
				add(restaurantFilter);





		logoBl = new FlxSprite(60, 250);
		if(MusicBeatState.glutoMode)
			logoBl.frames = Paths.getSparrowAtlas('logoGluto');
		else
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.4));
		logoBl.updateHitbox();
		logoBl.alpha = 1;
		var logoScale = logoBl.scale.x;

		if(MusicBeatState.glutoMode)
			logoBl.color = 0xFFEAE4C7
		else 
			logoBl.color = poop;
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		add(logoBl);

		bop(logoScale);
		
		

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		//WeekData.setDirectoryFromWeek(WeekData.weeksBLoaded.get(WeekData.weeksBList[0]));
		
		
		// for (i in 0...charArray.length)
		// {
		// 	if(charArray[i] != null && charArray[i].length > 0) {
		// 		var chars:Array<String> = chars[i].split(":");
		// 	}
		// }

		// for (char in 0...1)
		// {
		// 	var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5) * (1) - 150, 'lilac');
		// 	//var weekCharacterThing:Character = new Character((FlxG.width * 0.25) * (1) - 150, 0, 'lilac', true);
		// 	weekCharacterThing.x = 100;
		// 	weekCharacterThing.y += 80;
		// 	weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1));
		// 	weekCharacterThing.updateHitbox();
		// 	grpWeekCharacters.add(weekCharacterThing);
		// }
		
			var charName:String = "";
			trace(MusicBeatState.glutoMode);
			if(MusicBeatState.glutoMode)
				{
					charName = "gluto";
					trace("check");
				}
			else 
				{
					charName = charArray[charNum];
					trace("check");
				}

			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charName);
			weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1.2));
			weekCharacterThing.updateHitbox();
			weekCharacterThing.animation.play("idle_anim");
			weekCharacterThing.y += 0;
			weekCharacterThing.x += 50;
			var weekCharacterThingShadow:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charName);
			weekCharacterThingShadow.setPosition(weekCharacterThing.x + 10, weekCharacterThing.y + 10);
			
			if(MusicBeatState.glutoMode)
				weekCharacterThingShadow.color = 0xFF53350D
			else
				weekCharacterThingShadow.color = poop2;

			weekCharacterThingShadow.setGraphicSize(Std.int(weekCharacterThingShadow.width * 1.2));
			weekCharacterThingShadow.updateHitbox();
			
			

			if(charNum == 0 && !MusicBeatState.glutoMode)
				{
					weekCharacterThing.x += 70;
					weekCharacterThing.y += 10;
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * .9));
					weekCharacterThing.updateHitbox();
					weekCharacterThingShadow.x += 70;
					weekCharacterThingShadow.y += 10;
					weekCharacterThingShadow.setGraphicSize(Std.int(weekCharacterThingShadow.width * 0.9));
					weekCharacterThingShadow.updateHitbox();
				}
			else
				{
					weekCharacterThing.y += 0;
					weekCharacterThing.x += 0;
				}
			if(MusicBeatState.glutoMode)
				{
					// weekCharacterThing.x += 70;
					// weekCharacterThing.y += 10;
					// weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * .9));
					// weekCharacterThing.updateHitbox();
					// weekCharacterThingShadow.x += 70;
					// weekCharacterThingShadow.y += 10;
					// weekCharacterThingShadow.setGraphicSize(Std.int(weekCharacterThingShadow.width * 0.9));
					// weekCharacterThingShadow.updateHitbox();
				}
		
		
		grpWeekCharacters.add(weekCharacterThingShadow);
		grpWeekCharacters.add(weekCharacterThing);

		add(grpWeekCharacters);
			

		swagShader = new ColorSwap();
		if(!FlxG.save.data.psykaEasterEgg || !easterEggEnabled) {
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		else //Psyka easter egg
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.04);
			gfDance.frames = Paths.getSparrowAtlas('psykaDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'psykaDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'psykaDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		//add(gfDance);
		gfDance.shader = swagShader.shader;
	
		//logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		//add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true, false, 0.05, 0.5);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('silverift'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	private function bop(logoScale:Float)
		{
			new FlxTimer().start(0.9, function (tmr:FlxTimer) {
				FlxTween.tween(logoBl, {'scale.x': 0.45, 'scale.y': 0.45, x:logoBl.x -20, y:logoBl.y + 12}, 0.03, {ease: FlxEase.quadInOut, 
					onStart: function (twn:FlxTween){}, onComplete: function (twn:FlxTween){
		
								FlxTween.tween(logoBl, {'scale.x': 0.4, 'scale.y': 0.4, x: logoBl.x + 20, y: logoBl.y - 12}, 0.3, {ease: FlxEase.quadIn, type: ONESHOT, onStart: function (twn:FlxTween){}, onComplete: function (twn:FlxTween)
								{
									bop(logoScale);
								}});
	
								
						
						}});
			});
			
		}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				
				
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if(easterEggEnabled)
			{
				var finalKey:FlxKey = FlxG.keys.firstJustPressed();
				if(finalKey != FlxKey.NONE) {
					lastKeysPressed.push(finalKey); //Convert int to FlxKey
					if(lastKeysPressed.length > easterEggKeyCombination.length)
					{
						lastKeysPressed.shift();
					}
					
					if(lastKeysPressed.length == easterEggKeyCombination.length)
					{
						var isDifferent:Bool = false;
						for (i in 0...lastKeysPressed.length) {
							if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
								isDifferent = true;
								break;
							}
						}

						if(!isDifferent) {
							trace('Easter egg triggered!');
							MusicBeatState.glutoMode = !MusicBeatState.glutoMode;
							FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
							FlxG.sound.play(Paths.sound('secretSound'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							lastKeysPressed = [];
							closedState = true;
							transitioning = true;
						}
					}
				}
			}
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false, 0.05, 0.5);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false, 0.05, 0.5);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			//coolText.setGraphicSize(Std.int(coolText.width * 0.5));
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) 
			logoBl.animation.play('bump');

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				//case 1:
				//	createCoolText(['Psych Engine by'], 45);
				// credTextShit.visible = true;
				//case 3:
				//	addMoreText('Shadow Mario', 45);
				//	addMoreText('RiverOaken', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				//case 4:
				//	deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 1:
					createCoolText(['Created by'], -60);
				case 3:
					//addMoreText('This game right below lol', -60);
					logoSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 6:
					deleteCoolText();
					logoSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				//case 9:
				//	createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				//case 11:
				//	addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				//case 12:
				//	deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				//case 13:
				//	addMoreText('Wishfall');
				// credTextShit.visible = true;
				//case 14:
				//	addMoreText('Whispers');
				// credTextShit.text += '\nNight';
				//case 15:
				//	addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 8:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);

			FlxG.camera.flash(FlxColor.BLACK, 2);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
