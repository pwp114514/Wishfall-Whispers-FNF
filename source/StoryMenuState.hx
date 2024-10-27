package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flash.display.BlendMode;
import WeekData;
import MenuCharacter;
import CustomWipeTransition;
import PlayState;
using StringTools;

class StoryMenuState extends MusicBeatState
{
	
	
	
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var txtWeekDesc:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;
	//private static var curWeekB:Int = 0;
	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var sprWeekGroup:FlxTypedGroup<FlxSprite>;
	var sprIconGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var lerpVal:Float;
	var newYPos:Float;
	var tween:FlxTween;
	var tweenTwo:FlxTween;
	var tweenThree:FlxTween;
	var colorTween:FlxTween;
	var canFadeOut:Bool = true;
	var assetNameOld:String;

	var funnyTextOffset:Float = 1050;

	var poop:Bool = true;
	var fadeOverride:Bool = true;

	var restaurantFilter:BGSprite;

	var bgDiamonds:FlxSprite;
	var scrollDiamonds:FlxBackdrop;
	var lucidFlash:FlxSprite;
	var willFlash:Bool = true;

	override function create()
	{
		curDifficulty = 1;

				PlayState.alternateMode = false;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		camFollow.y = -500;
		//camFollow.setPosition(camFollow.x, -500);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		
		add(camFollow);
		add(camFollowPos);
		
		//FlxG.camera.setPosition(0, -500);

		FlxG.camera.follow(null, null, 1);
		FlxTween.tween(camFollow, { y: 350}, 1, { ease: FlxEase.expoInOut });

		//tween = FlxTween.tween(camFollow, { y: -500}, 1, { ease: FlxEase.expoInOut });

		//camFollow.screenCenter(X);
		//camFollow.setPosition(camFollow.x, -500);
		
		//newYPos = FlxMath.lerp(camFollowPos.x, camFollow.y, 1);
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bgSprite = new FlxSprite(0, 0);
		bgSprite.setGraphicSize(Std.int(bgSprite.width * 0.667));
		bgSprite.updateHitbox();

		//bgSprite.color = 0xFFea71fd;
		//bgSprite.scrollFactor.set(0, 1);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgSprite);
		FlxTween.tween(bgSprite, {x: -170}, 5, {startDelay: 2.5, ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(bgSprite, {y: -80}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});

		bgDiamonds = new FlxSprite().loadGraphic(Paths.image('diamonds'));
		bgDiamonds.blend = BlendMode.ADD;
		bgDiamonds.alpha = 0.1;
		bgDiamonds.setGraphicSize(Std.int(bgDiamonds.width * 0.5));
		bgDiamonds.scrollFactor.set(0, 0);
		bgDiamonds.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
		bgDiamonds.updateHitbox();
		
		scrollDiamonds = new FlxBackdrop(bgDiamonds.graphic, 60, 60);
		scrollDiamonds.blend = BlendMode.ADD;
		scrollDiamonds.alpha = 0;
		scrollDiamonds.scrollFactor.set(1, 1);
		add(scrollDiamonds);
		scrollDiamonds.velocity.set(-50, -50);

		

		restaurantFilter = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		restaurantFilter.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
		restaurantFilter.alpha = 1;
		restaurantFilter.blend = ADD;
		add(restaurantFilter);
		FlxTween.color(restaurantFilter, 1, 0x00a9b0ff, 0x00a9b0ff);

	
		//FlxTween.color(restaurantFilter, 1, 0x00ffffff, 0x00f1a9ff);
		//{
			// onComplete: function(twn:FlxTween) {
			// 	colorTween = null;
			// 	trace('CAAA');
			// }
		//}); 



		//FlxTween.tween(bgSprite, {alpha: 1}, 1, {startDelay: 0}
			//  ,{ease: FlxEase.quadInOut,
			// // onComplete: function(twn:FlxTween) {
			// // 	blammedLightsBlackTween = null;							// // }
		//	);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;
		//for (char in 0...1)
		//{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5) * (1) - 150, 'bb', true);
			//var weekCharacterThing:Character = new Character((FlxG.width * 0.25) * (1) - 150, 0, 'lilac', true);
			weekCharacterThing.x = 100;
			weekCharacterThing.y += 15;
			weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1));
			weekCharacterThing.updateHitbox();
			grpWeekCharacters.add(weekCharacterThing);
			add(grpWeekCharacters);
		//}


		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr.ttf"), 23, FlxColor.WHITE, CENTER);
		txtWeekTitle.alpha = 1;

		txtWeekDesc = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekDesc.setFormat(Paths.font("vcr.ttf"), 23, FlxColor.WHITE, CENTER);
		txtWeekDesc.alpha = 1;
		//txtWeekDesc.setGraphicSize(Std.int(txtWeekDesc.width * 0.7));
		//txtWeekDesc.updateHitbox();

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		//var bgYellow:FlxSprite = new FlxSprite(-1000, 56).makeGraphic(-1000, 386, 0xFFF9CF51);
		// bgSprite = new FlxSprite(-400, 56);
		// bgSprite.color = 0x8ca2d1;
		// //bgSprite.scrollFactor.set(0, 1);
		// bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		// var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		// add(blackBarThingie);

		// var tempBlackBar:FlxSprite = new FlxSprite().makeGraphic(360, 440, FlxColor.WHITE);
		// tempBlackBar.x = 910;
		// add(tempBlackBar);

		//grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

// var blackbox2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu_block_left'));
		// blackbox2.scrollFactor.set(0, 0);
		// blackbox2.setGraphicSize(Std.int(blackbox2.width * 0.667));
		// blackbox2.updateHitbox();
		// blackbox2.screenCenter();
		// blackbox2.antialiasing = ClientPrefs.globalAntialiasing;
		// add(blackbox2);


		// var banners:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu_banners'));
		// banners.scrollFactor.set(0, 0);
		// banners.setGraphicSize(Std.int(banners.width * 0.667));
		// banners.updateHitbox();
		// banners.screenCenter();
		// banners.antialiasing = ClientPrefs.globalAntialiasing;
		// add(banners);

		// var borders:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu_borders'));
		// borders.scrollFactor.set(0, 0);
		// borders.setGraphicSize(Std.int(borders.width * 0.667));
		// borders.updateHitbox();
		// borders.screenCenter();
		// borders.antialiasing = ClientPrefs.globalAntialiasing;
		// add(borders);

		// WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		// var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;
		// //for (char in 0...1)
		// //{
		// 	var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5) * (1) - 150, 'bb');
		// 	//var weekCharacterThing:Character = new Character((FlxG.width * 0.25) * (1) - 150, 0, 'lilac', true);
		// 	weekCharacterThing.x = 100;
		// 	weekCharacterThing.y += 15;
		// 	weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1));
		// 	weekCharacterThing.updateHitbox();
		// 	grpWeekCharacters.add(weekCharacterThing);
		// //}


		var banner:FlxSprite = new FlxSprite(1, -9).loadGraphic(Paths.image('banner'));
		banner.antialiasing = ClientPrefs.globalAntialiasing;
		banner.alpha = 0.7;
		banner.setGraphicSize(Std.int(banner.width * 0.6661));
		banner.updateHitbox();
		add(banner);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(funnyTextOffset - 180, 600);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.7));
		leftArrow.updateHitbox();
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		//add(sprDifficultyGroup);

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 35, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width * 0.7) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.7));
			sprDifficulty.updateHitbox();
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		sprWeekGroup = new FlxTypedGroup<FlxSprite>();
		add(sprWeekGroup);
		
		for (i in 0...WeekData.weeksList.length) {
			var sprWeek:FlxSprite = new FlxSprite(leftArrow.x + 35, 55).loadGraphic(Paths.image('storymenu/' + WeekData.weeksList[i].toLowerCase()));
			sprWeek.x += (308 - sprWeek.width * 0.7) / 2;
			sprWeek.ID = i;
			sprWeek.antialiasing = ClientPrefs.globalAntialiasing;
			sprWeek.setGraphicSize(Std.int(sprWeek.width * 0.7));
			sprWeek.updateHitbox();
			sprWeekGroup.add(sprWeek);
		}

		sprIconGroup = new FlxTypedGroup<FlxSprite>();
		add(sprIconGroup);
		//var charArray:Array<String> = WeekData.weeksBLoaded.get(WeekData.weeksBList[0]).weekCharacters;
		for (i in 0...WeekData.weeksList.length) {
			var sprIcon:FlxSprite = new FlxSprite(leftArrow.x + 35, 200).loadGraphic(Paths.image('menuicons/' + 'icon-' + WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekCharacters[0]));
			sprIcon.x += (308 - sprIcon.width * 0.7) / 2;
			sprIcon.ID = i;
			sprIcon.antialiasing = ClientPrefs.globalAntialiasing;
			sprIcon.setGraphicSize(Std.int(sprIcon.width * 0.7));
			sprIcon.updateHitbox();
			sprIconGroup.add(sprIcon);
			
		}

sprIconGroup.forEach(function(sprIcon:FlxSprite)
			{					
				FlxTween.angle(sprIcon, sprIcon.angle, -10, 2, {ease: FlxEase.sineInOut});
			});

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				sprIconGroup.forEach(function(sprIcon:FlxSprite)
					{					
						if(sprIcon.angle == -10) FlxTween.angle(sprIcon, sprIcon.angle, 10, 2, {ease: FlxEase.sineInOut});
						else FlxTween.angle(sprIcon, sprIcon.angle, -10, 2, {ease: FlxEase.sineInOut});
					});
	
			}, 0);




		rightArrow = new FlxSprite(leftArrow.x + 310, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.7));
		rightArrow.updateHitbox();
		difficultySelectors.add(rightArrow);

		//add(bgYellow);
		
		//add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(0, bgSprite.y + 350).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		tracksSprite.setGraphicSize(Std.int(tracksSprite.width * 0.8));
		tracksSprite.updateHitbox();
		tracksSprite.x = funnyTextOffset - tracksSprite.width/2;
		add(tracksSprite);

		txtTracklist = new FlxText(800, 400, 0, "", 32);
		txtTracklist.x = funnyTextOffset - txtTracklist.width/2;
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		//txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(txtWeekDesc);

		for (i in 0...WeekData.weeksList.length)
			{
				WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
				var weekThing:MenuItem = new MenuItem(20, bgSprite.y, WeekData.weeksList[i]);
				//weekThing.y += ((weekThing.height - 500) * i);
				weekThing.targetY = i;
				weekThing.setGraphicSize(Std.int(weekThing.width * 0.6));
				weekThing.updateHitbox();
				weekThing.alpha = 0; //TEMPORARY
				grpWeekText.add(weekThing);
	
				//weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();
	
				// Needs an offset thingie
				if (weekIsLocked(i))
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
			}

		changeWeek();

		// sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		// add(sprDifficultyGroup);
		
		// for (i in 0...CoolUtil.difficultyStuff.length) {
		// 	var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 35, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
		// 	sprDifficulty.x += (308 - sprDifficulty.width * 0.7) / 2;
		// 	sprDifficulty.ID = i;
		// 	sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		// 	sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.7));
		// 	sprDifficulty.updateHitbox();
		// 	sprDifficultyGroup.add(sprDifficulty);
		// }

		lucidFlash = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		lucidFlash.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
		lucidFlash.alpha = 0;
		//lucidFlash.blend = ADD;
		add(lucidFlash);
		FlxTween.color(lucidFlash, 0, 0x00000000, 0x00f1a9ff);

		//changeDifficulty();

		//difficultySelectors.add(sprDifficultyGroup);

		//sprWeekGroup = new FlxTypedGroup<FlxSprite>();
		//add(sprWeekGroup);

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		FlxG.camera.follow(camFollow, null, 1);
		
		
		//lerpVal = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		
		
		//camFollow.setPosition(camFollow.x, newYPos);

		//FlxTween.tween(camFollow, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
		//FlxTween.tween(camFollow, { y: -1000}, 0.15, { ease: FlxEase.expoIn });
		//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
		//if (controls.UI_RIGHT)
		//	{
		//		if (tween != null)
		//			{tween.cancel();}

		//		tween = FlxTween.tween(camFollow, { y: -500}, 1, { ease: FlxEase.expoInOut });
		//		tween;
				//newYPos = -500;				
		//	}
		if (controls.BACK)
			{
				if (tween != null){tween.cancel();}
				
				tween = FlxTween.tween(camFollow, { y: 1200}, 0.5, { ease: FlxEase.expoInOut });
				tween;
				//newYPos = 350;				
			}

			
		// scoreText.setFormat('Coolvetica Rg', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;
		scoreText.setPosition(funnyTextOffset - scoreText.width/2, 550);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = !weekIsLocked(curWeek);

		if (!movedBack && !selectedWeek)
		{
			#if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
				// PlayState.alternateMode = !PlayState.alternateMode;
				
				// trace("Alternate Mode is at:" + PlayState.alternateMode);
				// if(PlayState.alternateMode) FlxG.sound.play(Paths.sound('scrollMenu'));
				// else FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			#end

			if (controls.UI_UP_P && WeekData.weeksList.length > 1)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P && WeekData.weeksList.length > 1)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDifficulty(1);
				}
			if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDifficulty(-1);
				}

			if (controls.ACCEPT)
			{
				selectWeek();
				trace("Alternate Mode is at:" + PlayState.alternateMode);
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			PlayState.alternateMode = false;
			MusicBeatState.switchState(new CampaignState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				//if(grpWeekCharacters.members[0].character != '') grpWeekCharacters.members[0].animation.play('confirm');
				tween = FlxTween.tween(camFollow, { y: 1200}, 2, { ease: FlxEase.expoInOut });
				tween;
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			PlayState.isCampaignB = false;
			selectedWeek = true;

			var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			var alternate:String = "";
			if(PlayState.alternateMode) alternate = '-alternate';
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic + alternate, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			trace(curWeek + " is the number of the week that is now playing");
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{				
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			{
				curDifficulty = CoolUtil.difficultyStuff.length-2;
				//FlxTween.color(restaurantFilter, 1, restaurantFilter.color, 0xff222f56);
				//FlxTween.tween(scrollDiamonds, {alpha: 0.1}, 1);
			}
		if (curDifficulty >= CoolUtil.difficultyStuff.length -1)
			{
				curDifficulty = 0;
				//FlxTween.color(restaurantFilter, 1, restaurantFilter.color, 0x00a9b0ff);
				FlxTween.tween(scrollDiamonds, {alpha: 0}, 1);
			}
		if (curDifficulty == CoolUtil.difficultyStuff.length - 2)
			{
				//curDifficulty = CoolUtil.difficultyStuff.length-1;
				//FlxTween.color(restaurantFilter, 1, restaurantFilter.color, 0x00a9b0ff);
				FlxTween.tween(scrollDiamonds, {alpha: 0}, 1);
			}	

		// if (curDifficulty == CoolUtil.difficultyStuff.length - 1)
		// {
		// 	if(willFlash) 
		// 		{
		// 			FlxG.sound.play(Paths.sound('lucid'));
		// 			willFlash = false;
		// 			FlxTween.color(lucidFlash, 1, 0x98d9dcff, 0x00a9b0ff);
		// 		}
		// 	FlxTween.color(restaurantFilter, 1, restaurantFilter.color, 0xff222f56);
		// 	FlxTween.tween(scrollDiamonds, {alpha: 0.1}, 1);
		// }

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 15;
				FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function bgFadeOut(SHITTER:String):Void
		{
			assetNameOld = SHITTER;
			//bgFadeIn(assetName, assetNameOld);
			if(tweenTwo != null && canFadeOut == true){tweenTwo.cancel();}
			// if(tweenTwo != null){tweenTwo.cancel();}
			// bgFadeIn(assetName);
			if(canFadeOut == true)
			{
				tweenTwo = FlxTween.tween(bgSprite, {alpha: 0}, 1,{ease: FlxEase.quadInOut,
				 onComplete: function(twn:FlxTween) {
						// trace(bgSprite);
						// bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
						// bgSprite.x = -200;
						// bgSprite.y = -100;
						// bgSprite.setGraphicSize(Std.int(bgSprite.width * 0.8));
						// bgSprite.alpha = 0;
						// bgSprite.updateHitbox();;
						tweenTwo = null;
						bgFadeIn(SHITTER);
							//  ,{ease: FlxEase.quadInOut,
							// // onComplete: function(twn:FlxTween) {
							// // 	blammedLightsBlackTween = null;							// // }
							
					}		
				
					
				}
			);
			}

			
		//poop = false;
		
			if(false == true)
				{
					trace(bgSprite);
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + SHITTER));
			bgSprite.x = -200;
			bgSprite.y = -100;
			bgSprite.setGraphicSize(Std.int(bgSprite.width * 0.8));
			bgSprite.alpha = 0;
			bgSprite.updateHitbox();
			FlxTween.tween(bgSprite, {alpha: 1}, 1, {startDelay: 0}
				//  ,{ease: FlxEase.quadInOut,
				// // onComplete: function(twn:FlxTween) {
				// // 	blammedLightsBlackTween = null;							// // }
				);}
		}

	function bgFadeIn(SHITTERBUG:String):Void
		{
			var poopysprite:FlxSprite = bgSprite;

			canFadeOut = false;
			poopysprite.loadGraphic(Paths.image('menubackgrounds/menu_' + SHITTERBUG));
			poopysprite.x = -200;
			poopysprite.y = -100;
			poopysprite.setGraphicSize(Std.int(poopysprite.width * 0.8));
			poopysprite.alpha = 0;
			poopysprite.updateHitbox();
			tweenThree = FlxTween.tween(poopysprite, {alpha: 1}, 1,{ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween) 
					{		
						canFadeOut = true;
						tweenThree = null;
						if(SHITTERBUG != assetNameOld && SHITTERBUG != null)

							{bgFadeOut(assetNameOld);}
					}});
		}



	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		//var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksBList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		trace(WeekData.weeksList[curWeek].toLowerCase());
		sprWeekGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curWeek == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = 55;
				FlxTween.tween(spr, {y: 65, alpha: 1}, 0.07);
			}
		});

		trace(WeekData.weeksList[curWeek].toLowerCase());
		sprIconGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			trace(curWeek + "= curWeekB");
			trace(spr.ID + "= spr.ID");
			if(curWeek == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = 200;
				FlxTween.tween(spr, {y: 210, alpha: 1}, 0.07);
			}
		});

		var funnyInt:Int;
		var colors:Array<Int> = leWeek.weekColor;
			if(colors == null || colors.length < 3) {
				colors = [146, 113, 253];
			}
			funnyInt = FlxColor.fromRGB(colors[0], colors[1], colors[2]);
		//}
		var intendedColor:Int;
		intendedColor = bgSprite.color;
		var newColor:Int = funnyInt;
		
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bgSprite, 1, bgSprite.color, intendedColor, 
				{
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName;
		txtWeekTitle.x = funnyTextOffset - txtWeekTitle.width/2;
		txtWeekTitle.y = 135;
		//txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		
		//txtWeekTitle.setPosition(10, 10);

		// txtWeekDesc.text = leWeek.weekDesc;
		// txtWeekDesc.x = 900 - txtWeekDesc.width/2;
		// txtWeekDesc.y = 135;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				{
					item.alpha = 1;
					item.alpha = 0; //TEMPORARY
				}
			else
				{
					item.alpha = 0.6;
					item.alpha = 0; //TEMPORARY
				}
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			

			if(fadeOverride)
				{
					var poopysprite:FlxSprite = bgSprite;
					poopysprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
					poopysprite.x = -200;
					poopysprite.y = -100;
					poopysprite.setGraphicSize(Std.int(poopysprite.width * 0.8));
					poopysprite.alpha = 1;
					poopysprite.updateHitbox();
					!fadeOverride;
				}
			else if(bgSprite != null)
				{
			bgFadeOut(assetName);		
				}
		
		}
		updateText();
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		//var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksBList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			//grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.x = funnyTextOffset - txtTracklist.width/2;
		txtTracklist.y = 400;
		//txtTracklist.x = 100;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
