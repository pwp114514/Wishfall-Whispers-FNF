package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flash.display.BlendMode;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import CustomWipeTransition;
import editors.MasterEditorMenu;
import WeekData;
import CharDescData;

#if sys
import sys.FileSystem;
#end

using StringTools;

var bg:FlxSprite;
var intendedColor:Int;
var colorTween:FlxTween;

class InfoState extends MusicBeatState
{
	
	var sprWeekGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	private var curCharInfo:Int = 1;
	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;

	
	public static var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['campaignA', 'campaignB'];
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var logoSpr:FlxSprite;
	var logoBl:FlxSprite;

	var caca:Int = 0;

	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var txtWeekTitle:FlxText;
	var txtWeekDesc:FlxText;

	var restaurantFilter:BGSprite;
	var banner:FlxSprite;

	override function create()
	{
		
		

		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		// var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		// bg.scrollFactor.set(0, 0);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
		// bg.screenCenter();
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		
		//add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		// magenta.scrollFactor.set(0, yScroll);
		// magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		// magenta.updateHitbox();
		// magenta.screenCenter();
		// magenta.visible = false;
		// magenta.antialiasing = ClientPrefs.globalAntialiasing;
		// magenta.color = 0xFFfd719b;
		// add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offsetY:Float = 100 - (Math.max(optionShit.length, 4) - 4);
			var offsetX:Float = 150 - (Math.max(optionShit.length, 4) - 4);
			var menuItem:FlxSprite = new FlxSprite((i * 500) + offsetX, offsetY);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.000;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.55));
			//menuItem.scrollFactor.set(0, yScroll);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
			menuItem.updateHitbox();
		}


			menuItems.forEach(function(menuItem:FlxSprite)
				{					
					
					FlxTween.angle(menuItem, menuItem.angle, -1, 2, {ease: FlxEase.sineInOut});
				});
			
		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				menuItems.forEach(function(menuItem:FlxSprite)
					{					
						if(menuItem.angle == -1) FlxTween.angle(menuItem, menuItem.angle, 1, 2, {ease: FlxEase.sineInOut});
						else FlxTween.angle(menuItem, menuItem.angle, -1, 2, {ease: FlxEase.sineInOut});
					});
	
			}, 0);


			
			// var frame:FlxSprite = new FlxSprite().loadGraphic(Paths.image('frame'));
			// frame.antialiasing = ClientPrefs.globalAntialiasing;
			// frame.x =- 150;
			// frame.y =- 30;
			// frame.setGraphicSize(Std.int(frame.width * 0.7));
			// frame.scrollFactor.set(0, 0);
			// // bg.setGraphicSize(Std.int(bg.width * 1.175));
			// // bg.updateHitbox();
			// frame.updateHitbox();




				//grpWeekCharacters.members.y += 100;
				// if(charNum == 0)
				// 	{
				// 		weekCharacterThing.x += 70;
				// 		weekCharacterThing.y += 10;
				// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * .9));
				// 		weekCharacterThing.scrollFactor.set(0, 0);
				// 		weekCharacterThing.updateHitbox();
				// 		weekCharacterThingShadow.x += 70;
				// 		weekCharacterThingShadow.y += 10;
				// 		weekCharacterThingShadow.setGraphicSize(Std.int(weekCharacterThingShadow.width * 0.9));
				// 		weekCharacterThingShadow.updateHitbox();
				// 		
				// 	}
				// else
				// 	{
				// 		
				// 		weekCharacterThing.y += 0;
				// 		weekCharacterThing.x += 0;
				// 	}
				// 	
			
			//grpWeekCharacters.add(weekCharacterThingShadow);

			

			//var charArray = CoolUtil.coolTextFile(Paths.txt('charList'));
			//poo = poo.toLowerCase();
			
			var charArray = CoolUtil.coolTextFile(Paths.txt('charList'));
			var charNum:Int = 0;
			grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
				var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charArray[charNum]);

			var charColorArray = CoolUtil.coolTextFile(Paths.txt('charColorList'));
			
			
			caca = charNum;
			trace(charArray);
			var funnyColor = charColorArray[charNum];
			
			if(!funnyColor.startsWith('0x')) funnyColor = '0xFF' + funnyColor;
			
			grpWeekCharacters.add(weekCharacterThing);
			var poo = grpWeekCharacters.members[0].character;
			
			var charData:CharDescFile = CharDescData.getCharDescFile(poo.toLowerCase());
			trace(charData);
			trace(poo);
			var shitshitshit:FlxColor = Std.parseInt(charData.color);
			
			var poop:FlxColor = 0xFFFFFFFF;
			trace(poop);
			

			
			trace(charData);
			var leName:String = charData.charName;
			trace(charData.charName);
			//txtWeekTitle.text = leName;
			
		


			


			//restaurantFilter.color = shitshitshittytytt;
			//trace(poop);
			
		camFollow.setPosition(500, 500);
		FlxG.camera.follow(camFollow, null, 1);
		
		// var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		// versionShit.scrollFactor.set(0,0);
		// versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set(0,0);
		versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var text:FlxText = new FlxText(0, FlxG.height - 670, 0, "Choose a campaign!", 40);
		text.scrollFactor.set(0,0);
		text.screenCenter(X);
		text.x += 70;
		text.setFormat("a Anti Corona", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);
		
		var scrLogo:Float = 0.000;
		
		changeItem();
		var wipe:CustomWipeTransition = new CustomWipeTransition();
		wipe.startVideoWipe('wipeIn');
		
		// #if ACHIEVEMENTS_ALLOWED
		// Achievements.loadAchievements();
		// var leDate = Date.now();
		// if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
		// 	var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
		// 	if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
		// 		Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
		// 		giveAchievement();
		// 		ClientPrefs.saveSettings();
		// 	}
		// }
		// #end
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gradient'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.scrollFactor.set(0, 0);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
		bg.updateHitbox();
		//bg.color = 0xFFFFFFFF;
		add(bg);

		
		var bgDiamonds:FlxSprite = new FlxSprite().loadGraphic(Paths.image('diamonds'));
		bgDiamonds.blend = BlendMode.MULTIPLY;
		bgDiamonds.alpha = 0.2;
		bgDiamonds.setGraphicSize(Std.int(bgDiamonds.width * 0.5));
		bgDiamonds.scrollFactor.set(0, 0);
		bgDiamonds.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
		bgDiamonds.updateHitbox();
		var scrollDiamonds:FlxBackdrop;
		scrollDiamonds = new FlxBackdrop(bgDiamonds.graphic, 60, 60);
		scrollDiamonds.scrollFactor.set(0, 0);
		scrollDiamonds.blend = BlendMode.MULTIPLY;
		scrollDiamonds.alpha = 0.1;
		add(scrollDiamonds);
		scrollDiamonds.velocity.set(30, 30);
		

		restaurantFilter = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		restaurantFilter.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
		restaurantFilter.alpha = 0;
		restaurantFilter.blend = MULTIPLY;
		add(restaurantFilter);

		//add(frame);

		 
		var banner0 = new FlxSprite().loadGraphic(Paths.image('charactersbanner'));
		banner0.antialiasing = ClientPrefs.globalAntialiasing;
		banner0.x =- 0;
		banner0.y =- 30;
		banner0.setGraphicSize(Std.int(banner0.width * 0.7));
		banner0.scrollFactor.set(0, 0);
			// bg.setGraphicSize(Std.int(bg.width * 1.175));
			// bg.updateHitbox();
			banner0.updateHitbox();

			add(banner0);

		banner = new FlxSprite().loadGraphic(Paths.image('charactersbanner'));
		banner.antialiasing = ClientPrefs.globalAntialiasing;
		banner.x =- 0;
		banner.y =- 30;
		banner.setGraphicSize(Std.int(banner.width * 0.7));
		banner.scrollFactor.set(0, 0);
			// bg.setGraphicSize(Std.int(bg.width * 1.175));
			// bg.updateHitbox();
			banner.updateHitbox();

			add(banner);

		

		// WeekData.setDirectoryFromWeek(WeekData.weeksBLoaded.get(WeekData.weeksBList[0]));
		// 	var charArray:Array<String> = WeekData.weeksBLoaded.get(WeekData.weeksBList[0]).weekCharacters;
		// 	for (char in 0...1)
		// 	{
		// 		var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5) * (1) - 150, 'lilac');
		// 		//var weekCharacterThing:Character = new Character((FlxG.width * 0.25) * (1) - 150, 0, 'lilac', true);
		// 		weekCharacterThing.x = 100;
		// 		weekCharacterThing.y += 80;
		// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1));
		// 		weekCharacterThing.updateHitbox();
		// 		grpWeekCharacters.add(weekCharacterThing);
		// 	}

		// var restaurantFilter:BGSprite;
		// 		restaurantFilter = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		// 		restaurantFilter.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), shitshitshitytytt);
		// 		restaurantFilter.alpha = 0.50;
		// 		restaurantFilter.blend = MULTIPLY;
		// 		add(restaurantFilter);


				// switch (charNum)
				// {
					
				// 	case 0:
				// 	poop = 0xFFDEDEFF;
				// 	FlxColor.BLUE;
				// 	case 1:
				// 	poop = 0xFFFFD5D5;
				// 	FlxColor.RED;
				// 	case 2:
				// 	poop = 0xFFFEDCFF;
				// 	//FlxColor.YELLOW;
				// }
				// //frame.color = poop;
		
				// var poop2:FlxColor = 0xFFFFFFFF;
				// trace(poop);
				// switch (charNum)
				// {
				// 	case 0:
				// 	poop2 = 0xFF3B3B81;
				// 	FlxColor.BLUE;
				// 	case 1:
				// 	poop2 = 0xFF7A2929;
				// 	FlxColor.RED;
				// 	case 2:
				// 	poop2 = 0xFF783E87;
				// 	//FlxColor.YELLOW;
				// }

				weekCharacterThing.scrollFactor.set(0, 0);
				weekCharacterThing.antialiasing = ClientPrefs.globalAntialiasing;
				weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1));
				//weekCharacterThing.scrollFactor.set(0, 0);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
				weekCharacterThing.updateHitbox();
				weekCharacterThing.animation.play("idle_anim");
				//weekCharacterThing.y += 50;
				weekCharacterThing.y = weekCharacterThing.y -250 + weekCharacterThing.height/2;
				if(MusicBeatState.glutoMode)
				weekCharacterThing.y += 100;
				weekCharacterThing.x += 150;
				var weekCharacterThingShadow:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charArray[charNum]);
				weekCharacterThingShadow.setPosition(weekCharacterThing.x + 10, weekCharacterThing.y + 10);
				//weekCharacterThingShadow.color = poop2;
				weekCharacterThingShadow.setGraphicSize(Std.int(weekCharacterThingShadow.width * 1.2));
				weekCharacterThingShadow.updateHitbox();
				
				grpWeekCharacters.add(weekCharacterThing);
				
				add(grpWeekCharacters);
				

			difficultySelectors = new FlxGroup();
			add(difficultySelectors);
			var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
			leftArrow = new FlxSprite(400 - 180, 600);
			leftArrow.frames = ui_tex;
			leftArrow.animation.addByPrefix('idle', "arrow left");
			leftArrow.animation.addByPrefix('press', "arrow push left");
			leftArrow.animation.play('idle');
			leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
			
			leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.7));
			//letfArrow.scrollFactor.set(0, 0);
			
			leftArrow.alpha = 0;
			leftArrow.updateHitbox();
			
			difficultySelectors.add(leftArrow);
			
			sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
			add(sprDifficultyGroup);
			for (i in 0...CoolUtil.difficultyStuff.length) {
				
				var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 35, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
				sprDifficulty.x += (308 - sprDifficulty.width * 0.7) / 2;
				sprDifficulty.ID = i;
				sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
				sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.7));
				sprDifficulty.scrollFactor.set(0, 0);
				sprDifficulty.updateHitbox();
				//sprDifficultyGroup.add(sprDifficulty);
				
			}
			
			changeDifficulty();
	
			difficultySelectors.add(sprDifficultyGroup);
	
			sprWeekGroup = new FlxTypedGroup<FlxSprite>();
			add(sprWeekGroup);
			

			txtWeekTitle = new FlxText(FlxG.width * 0.7, -100, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekTitle.alpha = 1;

		if(MusicBeatState.glutoMode)
			{
				txtWeekDesc = new FlxText(FlxG.width * 0.7 + 20, -70, 0, "", 22);
				txtWeekDesc.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, CENTER);
			}
	
		else
			{
				txtWeekDesc = new FlxText(FlxG.width * 0.7, -100, 0, "", 26);
				txtWeekDesc.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT);
			} 
		txtWeekDesc.alpha = 1;
		add(txtWeekTitle);
		add(txtWeekDesc);

		var charArray = CoolUtil.coolTextFile(Paths.txt('charList'));
		var charColorArray = CoolUtil.coolTextFile(Paths.txt('charColorList'));
		var charNum:Int = 0;
		trace(charArray);
		var funnyColor = charColorArray[charNum];
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
		//frame.color = poop;

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
		
		//bg.color = songs[curSelected].color;
		intendedColor = banner.color;
		//changeColor();
		updateText(0);
		super.create();
	}

	function updateText(change:Int):Void
		{
			
			//txtWeekDesc.scrollFactor(0,0);


		// 	var leWeek:WeekData = WeekData.weeksBLoaded.get(WeekData.weeksBList[curWeekB]);
		// var stringThing:Array<String> = [];
		// for (i in 0...leWeek.songs.length) {
		// 	stringThing.push(leWeek.songs[i][0]);
		// }

		// txtTracklist.text = '';
		// //for (i in 0...stringThing.length)
		// //{
		// 	txtTracklist.text = leName;
		// //}

		// txtTracklist.text = txtTracklist.text.toUpperCase();

		// txtTracklist.x = funnyTextOffset - txtTracklist.width/2;
		// txtTracklist.y = 400;
		
		//if(change != null)
			caca += change;
			
			//var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charArray[charNum]);
			var weekArray:Array<String> = ['lilac', 'primrose', 'bb', 'gina'];
			if(caca > weekArray.length - 1)
			{
				caca = 0;
			}
			if(caca < 0)
				{
					caca = weekArray.length - 1;
				}
				trace(caca);
				var poo:String = '';
			//WeekData.weeksBLoaded.get(WeekData.weeksBList[curWeekB]).weekCharacters;
			//new MenuCharacter((FlxG.width * 0.5), charArray[charNum]);
			for (i in 0...grpWeekCharacters.length) {
				//grpWeekCharacters.members[i].changeCharacter(weekArray[i]);

				if(MusicBeatState.glutoMode)
					grpWeekCharacters.members[i].changeCharacter('gluto');
				else
					grpWeekCharacters.members[i].changeCharacter(weekArray[caca]);

				grpWeekCharacters.members[i].scrollFactor.set(0, 0);
				grpWeekCharacters.members[i].antialiasing = ClientPrefs.globalAntialiasing;

				//var prevPos = grpWeekCharacters.members[i].y;
				if(grpWeekCharacters.members[i].character == 'lilac')
					{
						//grpWeekCharacters.members[0].y = -100;
						grpWeekCharacters.members[i].setGraphicSize(Std.int(grpWeekCharacters.members[i].width * 0.95));
					}
				else if (grpWeekCharacters.members[i].character == 'bb')
					grpWeekCharacters.members[i].setGraphicSize(Std.int(grpWeekCharacters.members[i].width * 0.92));
				else 
					{
						grpWeekCharacters.members[i].setGraphicSize(Std.int(grpWeekCharacters.members[i].width * 1));
						//grpWeekCharacters.members[i].y = prevPos;
					}


				grpWeekCharacters.members[i].updateHitbox();
				grpWeekCharacters.members[i].animation.play("idle_anim");
				
				//if(grpWeekCharacters.members[i].character == 'bb')
				//grpWeekCharacters.members[i].y -= 20;
				
				//grpWeekCharacters.members[i].x += 50;
				//var weekCharacterThingShadow:MenuCharacter = new MenuCharacter((FlxG.width * 0.5), charArray[charNum]);
				// weekCharacterThing.y += 0;
				// weekCharacterThing.x += 50;

				poo = grpWeekCharacters.members[i].character;
			}
			var charArray = CoolUtil.coolTextFile(Paths.txt('charList'));
			poo = poo.toLowerCase();
		var charData:CharDescFile = CharDescData.getCharDescFile(poo.toLowerCase());
		trace(charData);
		var leName:String = charData.charName;
		trace(charData.charName);
		txtWeekTitle.text = leName;
		//bg.color = charData.color;
		//txtWeekTitle.x = txtWeekTitle.width/2;
		
		txtWeekTitle.screenCenter();
		txtWeekTitle.x = txtWeekTitle.x -450;
		 txtWeekTitle.y = 220;
		if(MusicBeatState.glutoMode)
			{
		 		txtWeekTitle.y = 190;
			}
		trace(leName);
		//txtWeekTitle.scrollFactor(0,0);
		var leDesc:String = charData.desc;
		txtWeekDesc.text = leDesc;
		//txtWeekDesc.x = 900 - txtWeekDesc.width/2;
		//txtWeekDesc.y = 135;
		//txtWeekDesc.screenCenter();
		txtWeekDesc.x = -80;
		txtWeekDesc.y = 330;// + txtWeekDesc.width/2; 
		if(MusicBeatState.glutoMode)
			{
				txtWeekDesc.x = -80;
				txtWeekDesc.y = 310;
			}
		//txtWeekDesc.y += 50;
		changeColor(poo);
		}
	function changeColor(poo:String)	
		{
			var charData:CharDescFile = CharDescData.getCharDescFile(poo.toLowerCase());
			var newColor:Int = Std.parseInt(charData.color);
			if(newColor != intendedColor) {

				if(colorTween != null) {
					colorTween.cancel();
				}

				intendedColor = newColor;

				colorTween = FlxTween.color(banner, 1, banner.color, intendedColor, 
					{
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});

			}
		}

	function changeDifficulty(change:Int = 0):Void
		{
			curCharInfo += change;
			if (curCharInfo < 0)
				curCharInfo = CoolUtil.difficultyStuff.length-1;
			if (curCharInfo >= CoolUtil.difficultyStuff.length)
				curCharInfo = 0;
	
			sprDifficultyGroup.forEach(function(spr:FlxSprite) {
				spr.visible = false;
				if(curCharInfo == spr.ID) {
					spr.visible = true;
					spr.alpha = 0;
					spr.y = leftArrow.y - 15;
					//FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
				}
			});
	
			#if !switch
			//intendedScore = Highscore.getWeekScore(WeekData.weeksBList[curWeekB], curCharInfo);
			#end
			
		}

	//#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	// function giveAchievement() {
	// 	add(new AchievementObject('friday_night_play', camAchievement));
	// 	FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	// 	trace('Giving achievement "friday_night_play"');
		
	// }
///	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		trace("gup");
		// if (controls.UI_RIGHT_P)
		// 	{
		// 		FlxG.sound.play(Paths.sound('scrollMenu'));
		// 		updateText(1);
		// 	}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		//camFollowPos.setPosition(200, -300);
		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				updateText(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				updateText(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new ExtrasState());
			}

			if (controls.ACCEPT)
			{
				return;
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						// FlxTween.tween(spr, {x: 1500}, 2, {ease: FlxEase.quadOut});
						// FlxTween.tween(spr, {alpha: 0}, 0.4, {
						// 	ease: FlxEase.quadOut,
						// 	onComplete: function(twn:FlxTween)
						// 	{
						// 		logoBl.kill();
						// 	}
						// });
						var poop:Int = 0;
						if(spr.x > 400)	poop = 1000; else poop = -400;
						
						if (curSelected != spr.ID)
						{
							//trace(spr.x);
							FlxTween.tween(spr, {x: poop}, 1, {ease: FlxEase.sineInOut});
							// FlxTween.tween(spr, {alpha: 0}, 0.4, {
							// 	ease: FlxEase.quadOut,
							// 	onComplete: function(twn:FlxTween)
							// 	{
							// 		spr.kill();
							// 	}
							// });
						}
						else
						{
							var wipe:CustomWipeTransition = new CustomWipeTransition();
							new FlxTimer().start(0.35, function(tmr:FlxTimer)
								{
									wipe.startVideoWipe('wipeOut');
									// var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(1000, 1000, FlxColor.BLACK);
									// add(black);
								});
							FlxTween.tween(spr, {x: 400}, 1, {ease: FlxEase.sineInOut});
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'campaignA':
										MusicBeatState.switchState(new FreeplayState());
									case 'campaignB':
										MusicBeatState.switchState(new FreeplayState());
									//case 'awards':
									//	MusicBeatState.switchState(new AchievementsMenuState());
									// case 'credits':
									// 	MusicBeatState.switchState(new CreditsState());
									// case 'options':
									// 	MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				//selectedSomethin = true;
				//MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			//spr.updateHitbox();
			spr.scrollFactor.set(0, 0);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		 spr.updateHitbox();
			

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				camFollow.setPosition(500, 500);
				//spr.offset.x = (0.15 * (spr.frameWidth / 2 + 180)) + 92;
				//spr.offset.y = (0.15 * spr.frameHeight) + 25;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
