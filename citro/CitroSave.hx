package citro;

import haxe.Json;
import haxe3ds.Env;
import haxe3ds.services.FS;
import sys.FileSystem;
import sys.io.File;

/**
 * An enum for checking its status to know if it succeeded or not.
 */
enum CitroSaveStatus {
	/**
	 * Save Operation is Successful, It's opened and ready to read and save.
	 */
	SUCCESSFUL;

	/**
	 * Status for calling any FS functions received an error and its not gonna continue.
	 */
	FS_ERROR;

	/**
	 * Status says that Application is using a 3DSX instead of CIA, which doesn't support saves.
	 */
	USES_3DSX;
}

/**
 * A class utility for Save Data, this can be used to access, modify, delete, or do some stuff in there.
 *
 * This only works if the Save Status is Successful.
 */
class CitroSave {
	/**
	 * The current status for this save, this can be used to determine if something went wrong, or some other miscellaneous enums.
	 */
	public var status(default, null):CitroSaveStatus;

	/**
	 * Variable for all of the data that's stored, this can be used to set some properties to load everytime the user launches this application.
	 * 
	 * It's useful to track whether a property that you want for the game to be used, such as having to know how many cumulative points the user has.
	 * 
	 * Example Usage:
	 * ```
	 * if (CitroG.save.data.score == null) {
	 * 	CitroG.save.data.score = 0; // this gets stored in the data variable, it will not be flushed, only if the game exits.
	 * }
	 * 
	 * // incrementing the score:
	 * override function update(delta:Int) {
	 * 	if (HID.keyPressed(Key.A)) {
	 * 		CitroG.save.data.score++; // increment the variable
	 * 		CitroG.save.flush(); // you can use it to flush right away, this is not recommended since it's generally slower the more values it has in that data.
	 * 	}
	 * }
	 */
	public var data:Dynamic = {};

	/**
	 * Constructor for creating a new Save Data, this can only be used once and it's in the class `CitroG`.
	 * @param files How many files that should be stored in the save data?
	 * @param dirs How many directories that should be stored? Leave at 1 if you just want the root only.
	 */
	public function new(files:Int = 16, dirs:Int = 1) {
		#if IS_3DSX
		status = USES_3DSX;
		#else
		if (FS.mountSaveData("ext", files, dirs).isFail()) {
			status = FS_ERROR;
			return;
		}

		if (FileSystem.exists('ext:/save.json')) {
			try {
				data = Json.parse(File.getContent('ext:/save.json'));
			} catch(error) {
				trace('save.json is corrupt and will be deleted, reason: ${error.message}');
				FileSystem.deleteFile('ext:/save.json');
			}
		}

		status = SUCCESSFUL;
		#end
	}

	/**
	 * Converts the save to a Compatible JSON Format and saves it to the Save Extension.
	 * @return Bool to indicate that it succeeded or not.
	 */
	public function flush():Bool {
		if (status != SUCCESSFUL) {
			return false;
		}

		try {
			#if IS_CIA
			File.saveContent("ext:/save.json", Json.stringify(data));
			FS.flushAndCommit();
			#end
			return true;
		} catch(e) {
			return false;
		}
	}

	/**
	 * Function to delete the save data (and maybe reset the Data Variable too).
	 * @param alsoResetData Whether or not it should reset its own data or not, this is a RISKY move.
	 * @return Bool to determine if save is actually deleted or not.
	 */
	public function delete(alsoResetData:Bool = true):Bool {
		if (status != SUCCESSFUL) {
			return false;
		}

		if (alsoResetData) {
			data = {};
		}

		try {
			FileSystem.deleteFile("ext:/save.json");
			return true;
		} catch(_) {
			return false;
		}
	}
}