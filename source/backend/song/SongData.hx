package backend.song;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gf:String;

	var stage:String;
	//var assetModifier:String;
}
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	//var typeOfSection:Int;
	//var altAnim:Bool;
	
	// psych suport
	var ?sectionBeats:Float;
}
typedef EventSong = {
	// [0] = section // [1] = strumTime // [2] events
	var songEvents:Array<Dynamic>;
}
typedef SongMeta = {
	var icon:String;
	var displayName:String;
	var difficulties:Array<String>;
}
typedef FunkyWeek = {
	var songs:Array<String>;
	var ?name:String;
	var ?characters:Array<String>;
	var ?onlyFreeplay:Bool;
	var ?onlyStory:Bool;
}

class SongData
{
	public static var defaultDiffs:Array<String> = ['easy', 'normal', 'hard'];

	// use these to whatever
	inline public static function defaultSong():SwagSong
	{
		return
		{
			song: "-debug",
			notes: [],
			bpm: 100,
			needsVoices: true,
			speed: 1.0,

			player1: "bf",
			player2: "dad",
			gf: "gf",
			stage: "stage"
		};
	}
	inline public static function defaultSection():SwagSection
	{
		return
		{
			sectionNotes: [],
			lengthInSteps: 16,
			mustHitSection: true,
			bpm: 100,
			changeBPM: false,
		};
	}
	inline public static function defaultSongEvents():EventSong
		return {songEvents: []};
	// [0] = section // [1] = strumTime // [2] events
	inline public static function defaultEventNote():Array<Dynamic>
		return [0, 0, []];
	inline public static function defaultEvent():Array<Dynamic>
		return ["name", "value1", "value2", "value3"];

	// stuff from fnf
	inline public static function loadFromJson(jsonInput:String, ?diff:String = "normal"):SwagSong
	{		
		Logs.print('Chart Loaded: ' + '$jsonInput/$diff');

		if(!Paths.fileExists('songs/$jsonInput/chart/$diff.json'))
			diff = "normal";
		
		var daSong:SwagSong = cast Paths.json('songs/$jsonInput/chart/$diff').song;
		
		// no need for SONG.song.toLowerCase() every time
		// the game auto-lowercases it now
		daSong.song = daSong.song.toLowerCase();
		if(daSong.song.contains(' '))
			daSong.song = daSong.song.replace(' ', '-');
		
		// formatting it
		daSong = formatSong(daSong);
		
		return daSong;
	}
	
	// 
	inline public static function formatSong(SONG:SwagSong):SwagSong
	{
		// cleaning multiple notes at the same place
		var removed:Int = 0;
		for(section in SONG.notes)
		{
			if(!Std.isOfType(section.lengthInSteps, Int))
			{
				var steps:Int = 16;
				if(section.sectionBeats != null)
					steps = Math.floor(section.sectionBeats * 4);
				
				section.lengthInSteps = steps;
			}
			
			for(songNotes in section.sectionNotes)
			{
				for(doubleNotes in section.sectionNotes)
				{
					if(songNotes 	!= doubleNotes
					&& songNotes[0] == doubleNotes[0]
					&& songNotes[1] == doubleNotes[1])
					{
						section.sectionNotes.remove(doubleNotes);
						removed++;
					}
				}
			}
		}
		if(removed > 0)
			Logs.print('removed $removed duplicated notes');
		
		return SONG;
	}

	inline public static function loadEventsJson(jsonInput:String, diff:String = "normal"):EventSong
	{
		var formatPath = 'events-$diff';

		function checkFile():Bool {
			return Paths.fileExists('songs/$jsonInput/chart/$formatPath.json');
		}
		if(!checkFile())
			formatPath = 'events';
		if(!checkFile()) {
			Logs.print('No Events Loaded');
			return {songEvents: []};
		}

		Logs.print('Events Loaded: ' + '$jsonInput/chart/$formatPath');

		var daEvents:EventSong = cast Paths.json('songs/$jsonInput/chart/$formatPath');
		return daEvents;
	}
}