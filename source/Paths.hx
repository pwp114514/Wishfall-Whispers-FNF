package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Graphics;
#end
import haxe.Json;

import flash.media.Sound;
import MusicBeatState;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if MODS_ALLOWED
	#if (haxe >= "4.0.0")
	public static var ignoreModFolders:Map<String, Bool> = new Map();
	public static var customImagesLoaded:Map<String, Bool> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var ignoreModFolders:Map<String, Bool> = new Map<String, Bool>();
	public static var customImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end
	#end

	public static function destroyLoadedImages(ignoreCheck:Bool = false) {
		#if MODS_ALLOWED
		if(!ignoreCheck && ClientPrefs.imagesPersist) return; //If there's 20+ images loaded, do a cleanup just for preventing a crash

		for (key in customImagesLoaded.keys()) {
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if(graphic != null) {
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}
		Paths.customImagesLoaded.clear();
		#end
	}

	static public var currentModDirectory:String = null;
	static var currentLevel:String;
	static public function getModFolders()
	{
		#if MODS_ALLOWED
		ignoreModFolders.set('characters', true);
		ignoreModFolders.set('custom_events', true);
		ignoreModFolders.set('custom_notetypes', true);
		ignoreModFolders.set('data', true);
		ignoreModFolders.set('songs', true);
		ignoreModFolders.set('music', true);
		ignoreModFolders.set('sounds', true);
		ignoreModFolders.set('videos', true);
		ignoreModFolders.set('images', true);
		ignoreModFolders.set('stages', true);
		ignoreModFolders.set('weeks', true);
		ignoreModFolders.set('scripts', true);
		#end
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var file:String = modsSounds(key);
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		#end
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var file:String = modsMusic(key);
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		#end
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function menuMusic(key:String, ?library:String):Dynamic
		{
			// #if MODS_ALLOWED
			// var file:String = modsMusic(key);
			// if(FileSystem.exists(file)) {
			// 	if(!customSoundsLoaded.exists(file)) {
			// 		customSoundsLoaded.set(file, Sound.fromFile(file));
			// 	}
			// 	return customSoundsLoaded.get(file);
			// }
			// #end
			
			var time = Date.now();
			trace("Hour is " + time.getHours() + ".");

			var worldTimeName;
			var menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListDay'));

			if(time.getHours() >=6 && time.getHours() < 20)
				{
					if(time.getHours() >= 11)
					{
						if(time.getHours() < 17) 
							{
								worldTimeName = "day";
								var menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListDay'));
								trace("Hour is " + time.getHours() + ".");

							}
						else {
								trace("Hour is " + time.getHours() + ".");
								worldTimeName = "evening";
								if(FlxG.random.int(0,1) == 0)
									menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListDay'));
								else
									menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListNight'));
							}
					}
					else 
						{
							trace("Hour is " + time.getHours() + ".");
							worldTimeName = "morning";
							if(FlxG.random.int(0,1) == 0)
								menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListDay'));
							else
								menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListNight'));
						}
				}
			else 
					{
						worldTimeName = "night";
						trace("Hour is " + time.getHours() + ".");
						menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicListNight'));
					}

				trace("Menu music list is " + menuMusicList + ".");
				var menuMusic:Int = FlxG.random.int(0, menuMusicList.length - 1);
				trace("Menu music int is " + menuMusic + ".");
				key = menuMusicList[menuMusic];
				trace("Menu music is " + key + ".");
				return getPath('music/$key.$SOUND_EXT', MUSIC, library);

			

					

				// var menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicList'));
				// trace("Menu music list is " + menuMusicList + ".");
				// var menuMusic:Int = FlxG.random.int(0, menuMusicList.length - 1);
				// trace("Menu music int is " + menuMusic + ".");
				// key = menuMusicList[menuMusic];
				// trace("Menu music is " + key + ".");
				// return getPath('music/menuMusic/night/$key.$SOUND_EXT', MUSIC, library);

			// var menuMusicList = CoolUtil.coolTextFile(Paths.txt('menuMusicList'));
			// trace("Menu music list is " + menuMusicList + ".");
			// var menuMusic:Int = FlxG.random.int(0, menuMusicList.length - 1);
			// trace("Menu music int is " + menuMusic + ".");
			// key = menuMusicList[menuMusic];
			// trace("Menu music is " + key + ".");
			// return getPath('music/$key.$SOUND_EXT', MUSIC, library);

		}

	inline static public function voices(song:String, ?isLucid:Bool):Any
	{
			var lucidText:String = '';
			if(isLucid) lucidText = '-lucid';
			if(MusicBeatState.glutoMode) lucidText = '-gluto';
			#if MODS_ALLOWED
			var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Voices' + lucidText));
			if(file != null) {
				return file;
			}
			//return 'songs:assets/music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT';
			return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Voices' + lucidText + '.$SOUND_EXT', MUSIC);
			#else { 
				

				if(isLucid)
				//return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT',  MUSIC, library);
				return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Voices' + lucidText + '.$SOUND_EXT', MUSIC);
				else 
					//return 'songs:assets/music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT';
					return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Voices' + lucidText + '.$SOUND_EXT', MUSIC);
				
			}

			#end
	}

	inline static public function voicesJukebox(song:String, ?isLucid:Bool, ?library:String):Dynamic
		{
			var lucidText:String = '';
			if(isLucid) lucidText = '-lucid';
			if(MusicBeatState.glutoMode) lucidText = '-gluto';
	
			#if MODS_ALLOWED
			var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Voices' + lucidText));
			if(file != null) {
				return file;
			}
			#end
			trace(getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Voices' + lucidText + '.$SOUND_EXT', MUSIC, library));
			return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Voices' + lucidText + '.$SOUND_EXT', MUSIC, library);
		}

	inline static public function inst(song:String, ?isLucid:Bool, ?library:String):Any
		{
			var lucidText:String = '';
			if(isLucid) lucidText = '-lucid';
			if(MusicBeatState.glutoMode) lucidText = '';
			#if MODS_ALLOWED
			var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Inst' + lucidText));
			if(file != null) {
				return file;
			}

			trace('songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT');
			//return 'songs:assets/music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT';
			return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT', MUSIC);
			#else { 
				

				if(isLucid)
				//return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT',  MUSIC, library);
				return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT',  MUSIC, library);
				else 
					//return 'songs:assets/music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT';
					return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT', MUSIC);
				
			}

			#end
			
		}

		inline static public function musics(key:String, ?library:String):Dynamic
			{
				#if MODS_ALLOWED
				var file:String = modsMusic(key);
				if(FileSystem.exists(file)) {
					if(!customSoundsLoaded.exists(file)) {
						customSoundsLoaded.set(file, Sound.fromFile(file));
					}
					return customSoundsLoaded.get(file);
				}
				#end
				return getPath('music/$key.$SOUND_EXT', MUSIC, library);
			}

		inline static public function instJukebox(song:String, ?isLucid:Bool, ?library:String):Dynamic
			{
				var lucidText:String = '';
				if(isLucid) lucidText = '-lucid';
				if(MusicBeatState.glutoMode) lucidText = '';
				#if MODS_ALLOWED
				var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Inst' + lucidText));
				if(file != null) {
					return file;
				}
				#end
				trace('songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT');
				return getPath('music/songs/${song.toLowerCase().replace(' ', '-')}/Inst' + lucidText + '.$SOUND_EXT',  MUSIC, library);
			}

	#if MODS_ALLOWED
	inline static private function returnSongFile(file:String):Sound
	{
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		return null;
	}
	#end

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if(imageToReturn != null) return imageToReturn;
		#end
		return getPath('images/$key.png', IMAGE, library);
	}
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if MODE_ALLOWED
		if (!ignoreMods && FileSystem.exists(mods(key)))
			return File.getContent(mods(key));

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		#if MODS_ALLOWED
		var modsFolder:String = Paths.mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		#end
		return list;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end
		
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String) {		
		trace(path);
		trace(path.toLowerCase().replace(' ', '-'));
		if(path == 'events-lucid')
			{
				trace(path);
				return path;
			}
			trace(path);
		return path.toLowerCase().replace(' ', '-');
	}
	
	#if MODS_ALLOWED
	static public function addCustomGraphic(key:String):FlxGraphic {
		if(FileSystem.exists(modsImages(key))) {
			if(!customImagesLoaded.exists(key)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modsImages(key));
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}
		return null;
	}

	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsMusic(key:String) {
		return modFolders('music/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsSounds(key:String) {
		return modFolders('sounds/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsSongs(key:String) {
		return modFolders('songs/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}
		for(mod in getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return 'mods/' + key;
	}

		public static var globalMods:Array<String> = [];

	static public function getGlobalMods()
		return globalMods;

	static public function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = Paths.mods(folder + '/pack.json');
					if(FileSystem.exists(path)) {
						try{
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global)globalMods.push(dat[0]);
							}
						} catch(e:Dynamic){
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}

	#end
}
