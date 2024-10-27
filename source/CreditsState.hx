package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.addons.display.FlxBackdrop;
import flash.display.BlendMode;
#if sys
import sys.FileSystem;
#end

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		['Wishfall Whispers Creator'],
		['Silverift',		'silverift',		'I appreciate your support!!',					'https://www.youtube.com/channel/UCA9eeDJ1w1zcSvib4DdyxMQ/',	0xFFA4F7FF],
		[''],
		['Guest Composers'],
		['LimeSplatus',		'splatus',		'Composer of "Star Chasers" "Stargaze" and "Lakeside"',	'https://linktr.ee/flowlimesplatus',	0xFF8CFFB2],
		['Metriobarynx',		'metriobarynx',		'Composer of "Apple Cider"',					'https://www.youtube.com/channel/UCp0pZjgtH8YO5w2a-zd7SHw',	0xFFA7B3FF],
		['Ash McShan',		'ash',		'Composer of "Waves of Dusk"',					'https://www.youtube.com/channel/UCBxkbovJqhJZIdQrvD09xHQ',	0xFFEEFFA9],
		['YAMA HAKI',		'yama',		'Composer of "Carefree"',					'https://x.com/YamaTheHaki ',	0xFFCAA7FF],
		// [''],
		// [''],
		// [''],
		// [''],
		// [''],
		// [''],
		// [''],
		// [''],
		// [''],
		[''],
		['Special Thanks'],
		['Pysch Engine Team',		'shadowmario',		'Creators of Psych Engine',					'https://gamebanana.com/mods/309789',	0xFFFFDD33],
		["Funkin' Crew",			'ninjamuffin99',		"Creators of FNF'",				'https://ninja-muffin24.itch.io/funkin',		0xFFC30085]
		// [''],
		// ['Engine Contributors'],
		// ['shubs',				'shubs',			'New Input System Programmer',						'https://twitter.com/yoshubs',			0xFF4494E6],
		// ['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',	0xFFE01F32],
		// ['gedehari',			'gedehari',			'Chart Editor\'s Sound Waveform base',				'https://twitter.com/gedehari',			0xFFFF9300],
		// ['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			0xFFFFFFFF],
		// ['SandPlanet',			'sandplanet',		'Mascot\'s Owner\nMain Supporter of the Engine',		'https://twitter.com/SandPlanetNG',		0xFFD10616],
		// ['bubba',				'bubba',		'Guest Composer for "Hot Dilf"',	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw',	0xFF61536A],
		// [''],
		// ["Funkin' Crew"],
		// ['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
		// ['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
		// ['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
		// ['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3]
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
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

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet;
			if(MusicBeatState.glutoMode)
				optionText = new Alphabet(0, 70 * i, "Prince Gluto!", !isSelectable, false);
			else
				optionText = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite;
				if(MusicBeatState.glutoMode)
					icon = new AttachedSprite('menuicons/icon-gluto');
				else
					icon = new AttachedSprite('credits/' + creditsStuff[i][1]);
				
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		var wipe:CustomWipeTransition = new CustomWipeTransition();
		wipe.startVideoWipe('wipeIn');
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT && !controls.BACK && !upP && !downP) {
			if(MusicBeatState.glutoMode)
				{
					CoolUtil.browserLoad("https://youtu.be/AnyjH5mpyNA");
				}
			else
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));
		var newColor:Int = 0;
		if(MusicBeatState.glutoMode)
			newColor = 0xFFFFE988;
		else
			newColor = creditsStuff[curSelected][4];

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

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		if(MusicBeatState.glutoMode)
			descText.text = "gluto so faat"
		else
			descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
