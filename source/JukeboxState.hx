package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flash.display.BlendMode;
import lime.utils.Assets;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import FreeplayState;

#if sys
import sys.FileSystem;
#end

using StringTools;

class JukeboxState extends MusicBeatState
{
	var songs:Array<SongMetadataTemp> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	// var scoreBG:FlxSprite;
	// var scoreText:FlxText;
	// var diffText:FlxText;
	// var lerpScore:Int = 0;
	// var lerpRating:Float = 0;
	// var intendedScore:Int = 0;
	// var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var beatbud:FlxSprite;
	var isPlaying:Bool;

	var jukeboxed:Bool;

	var record:FlxSprite;

	var composerText:FlxText;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		WeekData.reloadWeekBFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FreeplayState.destroyFreeplayVocals();
		JukeboxState.destroyFreeplayVocals();

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}



			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				trace(leWeek.songs);
				trace(leWeek.hasLucid);
				
				//if(!song[1].contains("primrose"))
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), false, false, song[3] /*link*/, song[4] /*composer*/);
				if(leWeek.hasLucid)
					{
						if(song[5] != null)
						//if(song[0] != "Primrose1")
						addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), false, true, song[5] /*lucid link*/, song[6] /*composer lucid*/);
					}
			}
		}

		for (i in 0...WeekData.weeksBList.length) {
			var leWeek:WeekData = WeekData.weeksBLoaded.get(WeekData.weeksBList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}



			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				trace(leWeek.songs);
				trace(leWeek.hasLucid);
				
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), false, false, song[3] /*link*/, song[4] /*composer*/);
				if(leWeek.hasLucid)
					{
						if(song[5] != null)
						addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), false, true, song[5] /*lucid link*/, song[6] /*composer lucid*/);
					}
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('jukeboxSonglist'));
		for (i in 0...initSonglist.length)
		{
			
			if(i % 3 == 0 && initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addMenuMusic(songArray[0], 0, "nobody", FlxColor.fromRGB(157, 175, 209), true, false, initSonglist[i+1], initSonglist[i+2]);
				trace(initSonglist[i+2]);
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat2'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
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
		scrollDiamonds = new FlxBackdrop(bgDiamonds.graphic, 60, 60, true, true);
		scrollDiamonds.scrollFactor.set(0, 0);
		scrollDiamonds.blend = BlendMode.MULTIPLY;
		scrollDiamonds.alpha = 0.1;
		add(scrollDiamonds);
		scrollDiamonds.velocity.set(30, 30);

		var banner:FlxSprite;
		banner = new FlxSprite().loadGraphic(Paths.image('jukeboxbanner'));
		banner.antialiasing = ClientPrefs.globalAntialiasing;
		add(banner);

		record = new FlxSprite(-685, -260).loadGraphic(Paths.image('disc'));
		record.antialiasing = ClientPrefs.globalAntialiasing;
		record.setGraphicSize(Std.int(record.width * 2.6));
		record.updateHitbox();
		add(record);

		beatbud = new FlxSprite(770, 100);
		beatbud.frames = Paths.getSparrowAtlas('beatbud');
		beatbud.animation.addByPrefix('idle', "idle", 24);
		beatbud.animation.addByPrefix('vibin', "vibin", 24);
		beatbud.animation.addByPrefix('toVibin', "toVibin", 24, false);
		beatbud.animation.addByPrefix('toIdle', "toIdle", 24, false);
		beatbud.animation.play('idle');
		beatbud.setGraphicSize(Std.int(beatbud.width * 1.8));
		beatbud.updateHitbox();
		add(beatbud);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songDisplayName, true, false, 0.05, 0.81, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			//songText.setGraphicSize(Std.int(songText.width * 1));
			//songText.updateHitbox();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		// scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		// scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		// scoreBG.alpha = 0.6;
		// add(scoreBG);

		// diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		// diffText.font = scoreText.font;
		// add(diffText);

		// add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		changeSelection();
		changeDiff();
		
		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		composerText = new FlxText(textBG.x - 20, 23, FlxG.width, "poop", 30);
		composerText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT);
		composerText.scrollFactor.set();
		add(composerText);

		#if PRELOAD_ALL
		var leText:String = "Press ENTER to listen to this Song / Press SPACE to to listen to its instrumental / Press SHIFT to visit song artist's page.";
		#else
		var leText:String = "Press ENTER to listen to this Song / Press SPACE to to listen to its instrumental / Press SHIFT to visit song artist's page.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		

		// diffText = new FlxText(10, 5 + 36, 0, "", 24);
		// diffText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		// add(diffText);

		var wipe:CustomWipeTransition = new CustomWipeTransition();
		wipe.startVideoWipe('wipeIn');
		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, isMenuMusic:Bool, lucid:Bool, songLink:String, songComposer:String)
	{
		var lucidText:String = "";
		if(lucid)
			{
				lucidText = " Lucid";
			}
			songName = '${songName.toLowerCase().replace('-', ' ')}';

		songs.push(new SongMetadataTemp(songName, weekNum, songCharacter, color, isMenuMusic, lucid, songName + lucidText, songLink, songComposer));
	}

	public function addMenuMusic(songName:String, weekNum:Int, songCharacter:String, color:Int, isMenuMusic:Bool, ?lucid:Bool, songLink:String, songComposer:String)
	{
		trace(songComposer);
		songs.push(new SongMetadataTemp(songName, 0, songCharacter, color, isMenuMusic, false, songName, songLink, songComposer));
	}
	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 1)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if(beatbud.animation.curAnim.finished && beatbud.animation.curAnim.name == "toVibin")
			{
				beatbud.animation.play('vibin');
			}

		//lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		//lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		// if (Math.abs(lerpScore - intendedScore) <= 10)
		// 	lerpScore = intendedScore;
		// if (Math.abs(lerpRating - intendedRating) <= 0.01)
		// 	lerpRating = intendedRating;

		//scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		//positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.justPressed.SHIFT && !space && !accepted && !controls.BACK && !upP && !downP && !controls.UI_LEFT_P && !controls.UI_RIGHT_P) 
		{
			//if(FlxG.sound.music == null)
			//shiftMult = 3;
			if(songs[curSelected].songLink != "null" || songs[curSelected].songLink != null || songs[curSelected].songLink != '') CoolUtil.browserLoad(songs[curSelected].songLink);
		}
			
	
		if (upP)
		{
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			changeSelection(shiftMult);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			if(FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.menuMusic('Wayward'), 1);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new ExtrasState());
		}

	//#if PRELOAD_ALL
		if(space && instPlaying != curSelected)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			destroyFreeplayVocals();
				FlxG.sound.play(Paths.sound('jukebox'));
			jukeboxed = true;

			isPlaying = true;
			beatbud.animation.play('toVibin');
			
			if(songs[curSelected].isMenuMusic)
				{
					destroyFreeplayVocals();
					//Paths.currentModDirectory = songs[curSelected].folder;
					//var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					// PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					// if (PlayState.SONG.needsVoices)
					// 	vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					// else
					// 	vocals = new FlxSound();
		
					//FlxG.sound.list.add(vocals);
					//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
					FlxG.sound.playMusic(Paths.music(songs[curSelected].songName), 1, true);
					trace(songs[curSelected].songName);
					//vocals.play();
					//vocals.persist = true;
					//vocals.looped = true;
					//vocals.volume = 0.7;
					instPlaying = curSelected;
				}
			else
				{
					destroyFreeplayVocals();
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					//if (PlayState.SONG.needsVoices)
					//	vocals = new FlxSound().loadEmbedded(Paths.voicesJukebox(PlayState.SONG.song, songs[curSelected].lucid));
					//else
					vocals = null;
						vocals = new FlxSound();
		
					//FlxG.sound.list.add(vocals);

					FlxG.sound.playMusic(Paths.instJukebox(PlayState.SONG.song, songs[curSelected].lucid), 1);
					
					trace(PlayState.SONG.song + " shitty");
					trace(songs[curSelected].songName);
					//vocals.play();fsfsf
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 0;
					instPlaying = curSelected;
				}
		}
		else if(accepted)
			///&& instPlaying != curSelected)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			
			destroyFreeplayVocals();
			//if(!jukeboxed) 
				FlxG.sound.play(Paths.sound('jukebox'));
			jukeboxed = true;

			isPlaying = true;
			beatbud.animation.play('toVibin');
			
			if(songs[curSelected].isMenuMusic)
				{
					destroyFreeplayVocals();
					//Paths.currentModDirectory = songs[curSelected].folder;
					//var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					// PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					// if (PlayState.SONG.needsVoices)
					// 	vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					// else
					// 	vocals = new FlxSound();
		
					//FlxG.sound.list.add(vocals);
					//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);

					//if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music(songs[curSelected].songName));
					//vocals.play();
					//vocals.persist = true;
					//vocals.looped = true;
					//vocals.volume = 0.7;
					instPlaying = curSelected;
				}
			else
				{
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					
			destroyFreeplayVocals();
					//if(!jukeboxed) 
				FlxG.sound.play(Paths.sound('jukebox'));
			jukeboxed = true;
					
					destroyFreeplayVocals();
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
						vocals = new FlxSound().loadEmbedded(Paths.voicesJukebox(PlayState.SONG.song, songs[curSelected].lucid));
					else
						vocals = new FlxSound();
		
					FlxG.sound.list.add(vocals);
					//if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.instJukebox(PlayState.SONG.song, songs[curSelected].lucid), 1);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 1;
					instPlaying = curSelected;
				}
		}
		 
		//if (accepted)
		// {
		// 	if (FlxG.sound.music != null)
		// 		FlxG.sound.music.stop();
			
		// 	destroyFreeplayVocals();
		// 	//if(!jukeboxed) 
		// 	FlxG.sound.play(Paths.sound('jukebox'));
		// 	jukeboxed = true;

		// 	trace("i love poop");
		// 	return;
		// 	var wipe:CustomWipeTransition = new CustomWipeTransition();
		// 	wipe.startVideoWipe('wipeOut');
		// 	var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		// 	var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
		// 	#if MODS_ALLOWED
		// 	if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
		// 	#else
		// 	if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
		// 	#end
		// 		poop = songLowercase;
		// 		curDifficulty = 1;
		// 		trace('Couldnt find file');
		// 	}
		// 	trace(poop);

		// 	PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		// 	PlayState.isStoryMode = false;
		// 	PlayState.storyDifficulty = curDifficulty;

		// 	PlayState.storyWeek = songs[curSelected].week;
		// 	trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		// 	if(colorTween != null) {
		// 		colorTween.cancel();
		// 	}
		// 	LoadingState.loadAndSwitchState(new PlayState());

		// 	FlxG.sound.music.volume = 0;
					
		// 	destroyFreeplayVocals();
		// }
		else if(accepted)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			//if(!jukeboxed) 
			
			destroyFreeplayVocals();
				FlxG.sound.play(Paths.sound('jukebox'));
			jukeboxed = true;

			isPlaying = true;
			beatbud.animation.play('toVibin');
			
			if(songs[curSelected].isMenuMusic)
				{
					destroyFreeplayVocals();
					//Paths.currentModDirectory = songs[curSelected].folder;
					//var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					// PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					// if (PlayState.SONG.needsVoices)
					// 	vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					// else
					// 	vocals = new FlxSound();
		
					//FlxG.sound.list.add(vocals);
					//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				//	if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
						FlxG.sound.music = null;
					FlxG.sound.playMusic(Paths.music(songs[curSelected].songName));
					//vocals.play();
					//vocals.persist = true;
					//vocals.looped = true;
					//vocals.volume = 0.7;
					instPlaying = curSelected;
				}
			else
				{
					destroyFreeplayVocals();
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
						vocals = new FlxSound().loadEmbedded(Paths.voicesJukebox(PlayState.SONG.song, songs[curSelected].lucid));
					else
						vocals = new FlxSound();
		
					FlxG.sound.list.add(vocals);
					//if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
					FlxG.sound.music = null;
					FlxG.sound.playMusic(Paths.instJukebox(PlayState.SONG.song, songs[curSelected].lucid),  1);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 1;
					instPlaying = curSelected;
				}
		}
		//#end 
		// else if(controls.RESET)
		// {
		// 	openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
		// 	FlxG.sound.play(Paths.sound('scrollMenu'));
		// }
		
		if(songs[curSelected].songComposer != null && songs[curSelected].songComposer != 'null')
		composerText.text = "by " + songs[curSelected].songComposer;
		else composerText.text = "";
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		//#if !switch
		// intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		//#end
		PlayState.storyDifficulty = curDifficulty;
		//diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		//positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{

		curSelected += change;

		if (curSelected < 0) 
			{
				curSelected -= change;
				return;
			}
			
			//curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			{
				curSelected -= change;
				return;
			}

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			//curSelected = 0;

		FlxTween.angle(record, record.angle, curSelected * -10, 0.33, {ease: FlxEase.sineOut});

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		// #if !switch
		// #end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	// private function positionHighscore() {
	// 	scoreText.x = FlxG.width - scoreText.width - 6;

	// 	scoreBG.scale.x = FlxG.width - scoreText.x + 6;
	// 	scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	// 	diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
	// 	diffText.x -= diffText.width / 2;
	// }
}  

class SongMetadataTemp
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var isMenuMusic:Bool = false;
	public var lucid:Bool = false;
	public var songDisplayName:String = "";
	public var songLink:String = "";
	public var songComposer:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, isMenuMusic:Bool, lucid:Bool, songDisplayName:String, songLink:String, songComposer:String)
	{
		if(isMenuMusic)
			{
				this.songName = song;
				this.week = week;
				this.songCharacter = songCharacter;
				this.color = color;
				this.folder = Paths.currentModDirectory;
				if(this.folder == null) this.folder = '';
				this.isMenuMusic = true;
				this.lucid = lucid;
				this.songDisplayName = songDisplayName;
				this.songLink = songLink;
				this.songComposer = songComposer;
			}
		else
			{
				this.songName = song;
				this.week = week;
				this.songCharacter = songCharacter;
				this.color = color;
				this.folder = Paths.currentModDirectory;
				if(this.folder == null) this.folder = '';
				this.isMenuMusic = false;
				this.lucid = lucid;
				this.songDisplayName = songDisplayName;
				this.songLink = songLink;
				this.songComposer = songComposer;
			}
		
		
	}
}
