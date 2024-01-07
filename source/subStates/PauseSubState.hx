package subStates;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import states.*;

class PauseSubState extends MusicBeatSubState
{
	var optionShit:Array<String> = [
		"resume",
		"restart song",
		"botplay",
		"options",
		"exit to menu",
	];
	
	var curSelected:Int = 0;
	
	var optionsGrp:FlxTypedGroup<AlphabetMenu>;
	var textsGrp:FlxTypedGroup<FlxText>;
	var bottomTxt:FlxText;

	var pauseSong:FlxSound;

	public function new()
	{
		super();
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;
		FlxTween.tween(banana, {alpha: 0.4}, 0.1);

		if(!PlayState.startedSong)
		{
			optionShit.remove("options");
		}

		optionsGrp = new FlxTypedGroup<AlphabetMenu>();
		add(optionsGrp);

		for(i in 0...optionShit.length)
		{
			var newItem = new AlphabetMenu(0, 0, optionShit[i], true);
			newItem.ID = i;
			newItem.focusY = i - curSelected;
			// isn't as accurate to base game
			newItem.spaceX = 25;
			newItem.spaceY = 150; // 200
			// but it looks better
			newItem.updatePos();
			optionsGrp.add(newItem);

			newItem.x = 0;
		}
		
		textsGrp = new FlxTypedGroup<FlxText>();
		add(textsGrp);
		
		var textArray:Array<String> = [
			PlayState.SONG.song,
			PlayState.songDiff,
			'BLUEBALLED: ' + PlayState.blueballed,
		];
		for(i in 0...textArray.length)
		{
			if(textArray[i] == "") continue;
		
			var text = new FlxText(0,0,0,textArray[i].toUpperCase());
			text.setFormat(Main.gFont, 36, 0xFFFFFFFF, RIGHT);
			text.setPosition(FlxG.width - text.width - 10, 10 + 40 * i);
			textsGrp.add(text);
			
			text.alpha = 0.00001;
			text.y -= 20;
			FlxTween.tween(text, {y: text.y + 20, alpha: 1}, 0.4, {ease: FlxEase.quadOut, startDelay: 0.2 + 0.18 * i});
		}
		
		bottomTxt = new FlxText(0,0,0,"");
		bottomTxt.setFormat(Main.gFont, 36, 0xFFFFFFFF, RIGHT);
		add(bottomTxt);

		pauseSong = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song.toLowerCase()), true, false);
		if(Conductor.songPos > 0)
		{
			pauseSong.play(Conductor.songPos);
			pauseSong.pitch = 0.9;
			pauseSong.volume = 0;
			FlxTween.tween(pauseSong, {volume: 0.6}, 3, {startDelay: 1});
		}
		FlxG.sound.list.add(pauseSong);

		changeSelection();
	}

	override function close()
	{
		pauseSong.stop();
		PlayState.instance.updateOption('Song Offset');
		super.close();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		DiscordClient.changePresence("Paused - Restin' a bit", null);
		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		if(!pauseSong.playing && Conductor.songPos >= 0)
			pauseSong.play(false, pauseSong.time);

		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(Controls.justPressed("ACCEPT"))
		{
			switch(optionShit[curSelected])
			{
				default:
					FlxG.sound.play(Paths.sound("menu/cancelMenu"));
				
				case "resume":
					PlayState.paused = false;
					close();

				case "restart song":
					Main.skipStuff();
					Main.resetState();
				
				case "botplay":
					FlxG.sound.play(Paths.sound("menu/cancelMenu"));
					PlayState.botplay = !PlayState.botplay;

				case "options":
					//Main.switchState(new states.menu.OptionsState(new LoadSongState()));
					persistentDraw = false;
					pauseSong.pause();
					this.openSubState(new OptionsSubState(PlayState.instance));

				case "exit to menu":
					//Main.switchState(new MenuState());
					persistentDraw = true;
					PlayState.sendToMenu();
			}
		}
		
		bottomTxt.text = "";
		if(PlayState.botplay)
			bottomTxt.text += "BOTPLAY";
		
		bottomTxt.x = FlxG.width - bottomTxt.width - 10;
		bottomTxt.y = FlxG.height- bottomTxt.height- 10;

		// works the same as resume
		if(Controls.justPressed("BACK"))
		{
			PlayState.paused = false;
			close();
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionsGrp)
		{
			item.focusY = item.ID - curSelected;

			item.alpha = 0.4;
			if(item.ID == curSelected)
				item.alpha = 1;
		}

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scrollMenu"));
	}
}