package objects;

import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import states.PlayState;

@:access(crowplexus.iris.Iris)

class Stage extends FlxGroup
{
	public var curStage:String = "";

	var stageScript:Iris = null;
	//cool map for scripting cuz haxe can't rename instances
	public var objects:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	// things to help your stage get better
	public var bfPos:FlxPoint  = new FlxPoint();
	public var dadPos:FlxPoint = new FlxPoint();
	public var gfPos:FlxPoint  = new FlxPoint();

	public var bfCam:FlxPoint  = new FlxPoint();
	public var dadCam:FlxPoint = new FlxPoint();
	public var gfCam:FlxPoint  = new FlxPoint();

	public var foreground:FlxGroup;

	public function new() {
		super();
		foreground = new FlxGroup();
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
		dadPos.set(stageJSON.positions.dad[0], stageJSON.positions.dad[1]);
		bfPos.set(stageJSON.positions.boyfriend[0], stageJSON.positions.boyfriend[1]);

		if (stageJSON.positions.gfCamera != null)
			gfCam.set(stageJSON.positions.gfCamera[0], stageJSON.positions.gfCamera[1]);
		if (stageJSON.positions.dadCamera != null)
			gfCam.set(stageJSON.positions.dadCamera[0], stageJSON.positions.dadCamera[1]);
		if (stageJSON.positions.boyfriendCamera != null)
			bfCam.set(stageJSON.positions.boyfriendCamera[0], stageJSON.positions.boyfriendCamera[1]);

		
		this.curStage = curStage;

		for (layer in stageJSON.layers)
		{
			var newLayer = new FlxSprite(layer.position[0], layer.position[1]);
			//2 many ifs????? i gonna cry babe
			if (layer.scroll != null)
				newLayer.scrollFactor.set(layer.scroll, layer.scroll);
			if (layer.scale != null)
				newLayer.scale.set(layer.scale, layer.scale);

			if (layer.animations != null)
			{
				newLayer.frames = Paths.getSparrowAtlas('stages/${layer.texture}');
				for (anim in layer.animations)
				{
					newLayer.animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
				}
				newLayer.animation.play(layer.animations[0].name);
			}
			else
				newLayer.loadGraphic(Paths.image('stages/${layer.texture}'));


			if (layer.foreground)
				foreground.add(newLayer);
			else
				add(newLayer);

			if (layer.id != null)
				objects.set(layer.id, newLayer);
		}
		//add scripts!!!!!
		if (Paths.fileExists('stages/$curStage.hx'))
		{
			stageScript = new Iris(Paths.script('stages/$curStage.hx'), {name: curStage, autoRun: false, autoPreset: true});
			stageScript.interp.parent = PlayState.instance;
			stageScript.set("objects", objects);
			stageScript.execute();
		}
		callScript("create");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		callScript("update", [elapsed]);
	}
	
	public function stepHit(curStep:Int = -1)
	{
		callScript("stepHit", [curStep]);
	}

	public function beatHit(curBeat:Int = -1)
	{
		callScript("beatHit", [curBeat]);
	}

	public function callScript(fun:String, ?args:Array<Dynamic>)
	{
		if (stageScript == null)
			return;
		
		var ny: Dynamic = stageScript.interp.variables.get(fun);
		try {
			if(ny != null && Reflect.isFunction(ny))
				stageScript.call(fun, args);
		} catch(e) {
			Logs.print('error parsing script: ' + e, ERROR);
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

	var ?gfCamera:Array<Float>;
	var ?dadCamera:Array<Float>;
	var ?boyfriendCamera:Array<Float>;
}

typedef StageLayer = {
	var ?id:String;
	var texture:String;
	var position:Array<Float>;
	var ?scroll:Float;
	var ?scale:Float;
	var ?foreground:Bool;
	var ?animations:Array<LayerAnimation>;
}

typedef LayerAnimation = {
	var name:String;
	var prefix:String;
	var fps:Float;
	var loop:Bool;
}