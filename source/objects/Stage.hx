package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import states.PlayState;

class Stage extends FlxGroup
{
	public var curStage:String = "";

	// things to help your stage get better
	public var bfPos:FlxPoint  = new FlxPoint();
	public var dadPos:FlxPoint = new FlxPoint();
	public var gfPos:FlxPoint  = new FlxPoint();

	public var foreground:FlxGroup;

	public function new() {
		super();
		foreground = new FlxGroup();
	}

	public function reloadStageFromSong(song:String = "test"):Void
	{
		var stageList:Array<String> = [];
		
		stageList = switch(song)
		{
			default: ["stage"];
			
			case "collision": ["mugen"];
			
			case "senpai"|"roses": 	["school"];
			case "thorns": 			["school-evil"];
			
			//case "template": ["preload1", "preload2", "starting-stage"];
		};
		
		/*
		*	makes changing stages easier by preloading
		*	a bunch of stages at the create function
		*	(remember to put the starting stage at the last spot of the array)
		*/
		for(i in stageList)
			reloadStage(i);
	}

	public function reloadStage(curStage:String = "")
	{
		this.clear();
		foreground.clear();

		var stageJSON:StageData = {
			zoom: 1,
			layers: [],
			positions: {
				gf: [650, 100],
				dad: [200, 150],
				boyfriend: [850, 0]
			}
		}

		if (Paths.fileExists('stages/$curStage.json'))
			stageJSON = Paths.json('stages/$curStage');

		this.curStage = curStage;
		PlayState.defaultCamZoom = stageJSON.zoom;
		
		gfPos.set(stageJSON.positions.gf[0], stageJSON.positions.gf[1]);
		/*dadPos.set(100,700);
		bfPos.set(850, 700);*/
		dadPos.set(stageJSON.positions.dad[0], stageJSON.positions.dad[1]);
		bfPos.set(stageJSON.positions.boyfriend[0], stageJSON.positions.boyfriend[1]);
		// setting gf to "" makes her invisible
		
		this.curStage = curStage;

		for (layer in stageJSON.layers)
		{
			var newLayer = new FlxSprite(layer.position[0], layer.position[1]).loadGraphic(Paths.image('stages/${layer.texture}'));
			newLayer.scrollFactor.set(layer.scroll, layer.scroll);
			newLayer.scale.set(layer.scale, layer.scale);
			add(newLayer);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function stepHit(curStep:Int = -1)
	{
		// put your song stuff here
		
		// beat hit
		if(curStep % 4 == 0)
		{
			
		}
	}
}

typedef StageData = {
	var zoom:Float;
	var layers:Array<StageLayer>;
	var positions:StagePositions;
}

typedef StagePositions = {
	var gf:Array<Float>;
	var dad:Array<Float>;
	var boyfriend:Array<Float>;
}

typedef StageLayer = {
	var ?id:String;
	var texture:String;
	var position:Array<Float>;
	var scroll:Float;
	var scale:Float;
}