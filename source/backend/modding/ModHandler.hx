package backend.modding;

import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.format.ParseRules;
import polymod.Polymod;

import sys.FileSystem;
import flixel.FlxG;

class ModHandler
{
	private static final MOD_DIR:String = 'mods';

	public static var loadedMods = []; // enabled mods

	public static function init():Void
	{
		loadedMods = FileSystem.readDirectory("mods/");
		trace("Initializing Polymod...");
		
		Polymod.init({
			// Root directory for all mods.
			modRoot: MOD_DIR,
			// Call this function any time an error occurs.
			errorCallback: onPolymodError,

			framework: OPENFL,
			// List of filenames to ignore in mods. Use the default list to ignore the metadata file, etc.
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		trace(loadedMods);
		Polymod.loadOnlyMods(loadedMods);
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			case MISSING_ICON:
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
					case WARNING:
						trace(error.message, null);
					case ERROR:
						trace(error.message, null);
				}
		}
	}
}