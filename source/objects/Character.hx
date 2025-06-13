package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flxanimate.FlxAnimate;
import backend.utils.CharacterUtil;
import backend.utils.CharacterUtil.*;
import objects.note.Note;

using StringTools;

class Character extends FlxAnimate
{
	// dont mess with these unless you know what youre doing!
	// they are used in important stuff
	public var curChar:String = "bf";
	public var isPlayer:Bool = false;
	public var onEditor:Bool = false;
	public var specialAnim:Int = 0;
	public var curAnimFrame(get, never):Int;
	public var curAnimFinished(get, never):Bool;
	public var holdTimer:Float = Math.NEGATIVE_INFINITY;

	// time (in seconds) that takes to the character return to their idle anim
	public var holdLength:Float = 0.7;
	// when (in frames) should the character singing animation reset when pressing long notes
	public var holdLoop:Int = 4;

	// modify these for your liking (idle will cycle through every array value)
	public var idleAnims:Array<String> = ["idle"];
	public var altIdle:String = "";
	public var altSing:String = "";
	
	// true: dances every beat // false: dances every other beat
	public var quickDancer:Bool = false;

	// warning, only uses this
	// if the current character doesnt have game over anims
	public var deathChar:String = "bf-dead";

	// you can modify these manually but i reccomend using the offset editor instead
	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	// you're probably gonna use sparrow by default?
	var spriteType:SpriteType = SPARROW;

	public function new(curChar:String = "bf", isPlayer:Bool = false, onEditor:Bool = false)
	{
		super(0,0,false);
		this.onEditor = onEditor;
		this.isPlayer = isPlayer;
		this.curChar = curChar;
		
		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;
		
		var doidoChar = CharacterUtil.defaultChar();
		switch(curChar)
		{
			default:
				if (!Paths.fileExists('characters/$curChar.json'))
				{
					curChar = "bf";
					this.curChar = "bf";
				}

				var jsonData:CharacterJSON = Paths.json('characters/$curChar');

				doidoChar.spritesheet += jsonData.spritesheet;
				if (jsonData.extrasheets != null)
					doidoChar.extrasheets = jsonData.extrasheets;

				for (i in 0...jsonData.anims.length){
					var daAnim = jsonData.anims[i];
					if (daAnim.frames.length > 0)
						doidoChar.anims.push([daAnim.animation, daAnim.prefix, daAnim.fps, daAnim.loop, daAnim.frames]);
					else
						doidoChar.anims.push([daAnim.animation, daAnim.prefix, daAnim.fps, daAnim.loop]);

					addOffset(daAnim.animation, daAnim.offset[0], daAnim.offset[1]);
				}

				flipX = jsonData.flipX;
				
				antialiasing = jsonData.antialiasing;
				isPixelSprite = !jsonData.antialiasing;

				scale.set(jsonData.scale, jsonData.scale);

				if (jsonData.idleAnims != null){
					quickDancer = true;
					idleAnims = jsonData.idleAnims;
				}
				if (jsonData.deathChar != null)
					deathChar = jsonData.deathChar;

				if (jsonData.spriteType != null)
					switch(jsonData.spriteType.toUpperCase()){
						case "ATLAS":
							spriteType = ATLAS;
					}

				//Offset shiits
				globalOffset.set(jsonData.globalOffset[0], jsonData.globalOffset[1]);
				cameraOffset.set(jsonData.cameraOffset[0], jsonData.cameraOffset[1]);
				ratingsOffset.set(jsonData.ratingsOffset[0], jsonData.ratingsOffset[1]);
		}

		if(isPixelSprite) antialiasing = false;

		if(spriteType != ATLAS)
		{
			if(Paths.fileExists('images/${doidoChar.spritesheet}.txt')) {
				frames = Paths.getPackerAtlas(doidoChar.spritesheet);
				spriteType = PACKER;
			}
			else if(Paths.fileExists('images/${doidoChar.spritesheet}.json')) {
				frames = Paths.getAsepriteAtlas(doidoChar.spritesheet);
				spriteType = ASEPRITE;
			}
			else if(doidoChar.extrasheets != null) {
				frames = Paths.getMultiSparrowAtlas(doidoChar.spritesheet, doidoChar.extrasheets);
				spriteType = MULTISPARROW;
			}
			else
				frames = Paths.getSparrowAtlas(doidoChar.spritesheet);

			for(i in 0...doidoChar.anims.length)
			{
				var anim:Array<Dynamic> = doidoChar.anims[i];
				if(anim.length > 4)
					animation.addByIndices(anim[0],  anim[1], anim[4], "", anim[2], anim[3]);
				else
					animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
			}
		}
		else
		{
			// :shushing_face:
			isAnimateAtlas = true;

			loadAtlas(Paths.getPath('images/${doidoChar.spritesheet}'));
			showPivot = false;
			for(i in 0...doidoChar.anims.length)
			{
				var dAnim:Array<Dynamic> = doidoChar.anims[i];
				if(dAnim.length > 4)
					anim.addBySymbolIndices(dAnim[0], dAnim[1], dAnim[4], dAnim[2], dAnim[3]);
				else
					anim.addBySymbol(dAnim[0], dAnim[1], dAnim[2], dAnim[3]);
			}
		}

		// adding animations to array
		for(i in 0...doidoChar.anims.length) {
			var daAnim = doidoChar.anims[i][0];
			if(animExists(daAnim) && !animList.contains(daAnim))
				animList.push(daAnim);
		}

		// prevents crashing
		for(i in 0...idleAnims.length)
		{
			if(!animList.contains(idleAnims[i]))
				idleAnims[i] = animList[0];
		}
		
		playAnim(idleAnims[0]);

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		dance();
	}

	private var curDance:Int = 0;

	public function dance(forced:Bool = false)
	{
		if(specialAnim > 0) return;

		switch(curChar)
		{
			default:
				var daIdle = idleAnims[curDance];
				if(animExists(daIdle + altIdle))
					daIdle += altIdle;
				playAnim(daIdle);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!onEditor)
		{
			if(animExists(curAnimName + '-loop') && curAnimFinished)
				playAnim(curAnimName + '-loop');
	
			if(specialAnim > 0 && specialAnim != 3 && curAnimFinished)
			{
				specialAnim = 0;
				dance();
			}
		}
	}

	public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public function playNote(note:Note, miss:Bool = false)
	{
		var daAnim:String = singAnims[note.noteData];
		if(animExists(daAnim + 'miss') && miss)
			daAnim += 'miss';

		if(animExists(daAnim + altSing))
			daAnim += altSing;

		holdTimer = 0;
		specialAnim = 0;
		playAnim(daAnim, true);
	}

	// animation handler
	public var curAnimName:String = '';
	public var animList:Array<String> = [];
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		if(!animExists(animName)) return;
		
		curAnimName = animName;
		if(spriteType != ATLAS)
			animation.play(animName, forced, reversed, frame);
		else
			anim.play(animName, forced, reversed, frame);
		
		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}

	public function invertDirections(axes:FlxAxes = NONE)
	{
		switch(axes) {
			case X:
				singAnims = ['singRIGHT', 'singDOWN', 'singUP', 'singLEFT'];
			case Y:
				singAnims = ['singLEFT', 'singUP', 'singDOWN', 'singRIGHT'];
			case XY:
				singAnims = ['singRIGHT', 'singUP', 'singDOWN', 'singLEFT'];
			default:
				singAnims = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		}
	}

	public function pauseAnim()
	{
		if(spriteType != ATLAS)
			animation.pause();
		else
			anim.pause();
	}

	public function animExists(animName:String):Bool
	{
		if(spriteType != ATLAS)
			return animation.getByName(animName) != null;
		else
			return anim.getByName(animName) != null;
	}

	public function get_curAnimFrame():Int
	{
		if(spriteType != ATLAS)
			return animation.curAnim.curFrame;
		else
			return anim.curSymbol.curFrame;
	}

	public function get_curAnimFinished():Bool
	{
		if(spriteType != ATLAS)
			return animation.curAnim.finished;
		else
			return anim.finished;
	}
}