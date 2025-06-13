package backend.utils;

typedef CharacterJSON = {
	var anims:Array<CharacterAnim>;
	var globalOffset:Array<Float>;
	var cameraOffset:Array<Float>;
	var spritesheet:String;
	var ?extrasheets:Array<String>;
	var ?spriteType:String;
	var flipX:Bool;
	var antialiasing:Bool;
	var scale:Float;
	var ?idleAnims: Array<String>;
	var ?deathChar:String;
}

typedef CharacterAnim = {
	var animation:String;
	var prefix:String;
	var fps:Float;
	var loop:Bool;
	var frames:Array<Int>;
	var offset:Array<Float>;
}

typedef DoidoCharacter = {
	var spritesheet:String;
	var anims:Array<Dynamic>;
	var ?extrasheets:Array<String>;
}

enum SpriteType {
	SPARROW;
	PACKER;
	ASEPRITE;
	ATLAS;
	MULTISPARROW;
}

class CharacterUtil
{
	inline public static function defaultJson():CharacterJSON
	{
		return {
			anims: [],
			globalOffset: [0,0],
			cameraOffset: [0,0],
			spritesheet: "",
			spriteType: "Sparrow",
			flipX: false,
			antialiasing: true,
			scale: 1
		};
	}

	inline public static function defaultChar():DoidoCharacter
	{
		return {
			spritesheet: 'characters/',
			anims: [],
		};
	}

	inline public static function formatChar(char:String):String
		return char.substring(0, char.lastIndexOf('-'));

	public static function charList():Array<String>
	{
		final readedDir = Paths.readDir('characters/', [".json"]);
		var returnShit:Array<String> = [];
		for (file in readedDir)
			if (file.endsWith(".json"))
				returnShit.push(file.split(".json")[0]);

		return returnShit;
	}
}