package citro;

import citro.backend.CitroCache;
import citro.backend.CitroTimer;
import citro.backend.CitroTween;
import citro.math.CitroRandom;
import citro.object.CitroObject;
import citro.state.CitroState;
import citro.state.CitroSubState;

import cpp.Star;

import haxe3ds.applet.WebBrowser;
import haxe3ds.services.FS;
import haxe3ds.services.HID;
import haxe3ds.types.Result;

extern abstract VoidPtr(Star<Void>) {}

/**
 * The main class for all of your Game Utility Needs and Handlings.
 * 
 * This class is Main Used for stuff, Such as:
 * - Getting the current Width, Height, and the Bottom Width of your 3DS (all in fixed variables)
 * - A random number generator to generate random numbers, using Haxe's Built-In functions with Math.
 * - State and Substate Management, To view the current active and running state, or Switch States.
 * - Save Management, To Edit, Save, Import, and even has Error Handling!
 * - Basic Utility Functions such as `CitroG.overlaps` & `CitroG.isTouching`
 */
class CitroG {
	/**
	 * Current width for the Top 3DS Screen, This is an inline variable so it's read only.
	 */
	public static inline var WIDTH:Int = 400;

	/**
	 * Current height for the Top and Bottom 3DS Screen, This is an inline variable so it's read only.
	 */
	public static inline var HEIGHT:Int = 240;

	/**
	 * Current width for the Bottom 3DS Screen, This is an inline variable so it's read only.
	 */
	public static inline var BOTTOM_WIDTH:Int = 320;

	/**
	 * Variable for generating a pseudorandom number, array, color, and more!
	 * 
	 * This uses Std functions with Math instead of our own because it was always that bloated and i just didn't feel like it.
	 */
	public static var random:CitroRandom = new CitroRandom();

	/**
	 * The state that's currently running, do NOT use it for switching a new state, instead use `CitroG.switchState`.
	 */
	public static var state:CitroState;

	/**
	 * Citro's Sub State, The same thing as CitroG's `state` variable but for the other state for creating Pauses and such.
	 * 
	 * If this substate is not `null` and is a valid substate, This will update and render if the current `state` finished updating & rendering.
	 */
	public static var substate:CitroSubState;

	/**
	 * Variable for Save Data Management, This can be used to access Data in a Dynamic variable.
	 * 
	 * It's saved as a `.json` format instead of `.sol` as it would've been a little bit complicated, but it isn't bloated and really usable.
	 */
	public static var save:CitroSave = new CitroSave();

	/**
	 * Variable for the current Delta Time that currently got passed in Milliseconds.
	 * 
	 * This is mutated every frame, it's still Read Only.
	 */
	public static var deltaTime:Int = 16;

	/**
	 * Variable for caching certain data using a Map, This can be used to load memory data that hasn't been freed to avoid double loading.
	 * 
	 * Again, the 3DS memory has a total of 128MB so This will sometimes free if it's not used.
	 * 
	 * TODO: Maybe free them if it hasn't been used in a certain period of time?
	 */
	public static var caches:CitroCache = new CitroCache();

	/**
	 * Function to check if both of the objects are overlapping or not.
	 * 
	 * This handles size, visibility, and if one of the objects is null.
	 * 
	 * ***WARNING:*** Any of the argument object that has it added into a camera will behave weirdly and shouldn't be using it.
	 * 
	 * @param obj1 The first object to compare if it's overlapping to the second object.
	 * @param obj2 The second object to compare if it's overlapping to the first object.
	 * @returns `true` if it's overlapping, `false` if it's not, or any of the object is invisible or null.
	 */
	public static function overlaps(obj1:CitroObject, obj2:CitroObject):Bool {
		if (obj1 == null || obj2 == null || !obj1.visible || !obj2.visible) {
			return false;
		}

		return obj1.x < obj2.x + (obj2.width * obj2.scale.x) &&
			   obj1.x + (obj1.width * obj1.scale.x) > obj2.x &&
			   obj1.y < obj2.y + (obj2.height * obj2.scale.y) &&
			   obj1.y + (obj1.height * obj1.scale.y) > obj2.y;
	}

	/**
	 * Function to Check if the Object is Touched from the 3DS's Bottom Screen.
	 * 
	 * This handles:
	 * - If the object is `null`.
	 * - If the object is not rendered in the bottom screen.
	 * - If the object is invisible.
	 * - If the object is currently being touched.
	 * - Object's scaling.
	 * 
	 * @param obj The object variable to use for checking.
	 * @returns `true` if overlapped, false if not or doesn't match the 1st-4th list above
	 */
	public static function isTouching(obj:CitroObject):Bool {
		if (obj == null || !obj.bottom || !obj.visible || !HID.keyHeld(HIDKey.TOUCH)) {
			return false;
		}

		final t:TouchPosition = HID.touch;
		return (obj.x < t.px) &&
			   (obj.x + (obj.width * obj.scale.x) > t.px) &&
			   (obj.y < t.py) &&
			   (obj.y + (obj.height * obj.scale.y) > t.py);
	}

	/**
	 * A function to filter objects that has been touched in the bottom screen.
	 * 
	 * If you're making a dragging game and need a function to check if one of the objects is touched on the bottom screen to gain points fast, this is the way to do it.
	 * 
	 * Note: This function is techincally O(`n`) where `n` = the length of the objects array, since HXCPP uses simple but slow iterators it may take a while for the 3ds to process all of it if it's a big array (especially 250+ objects).
	 * 
	 * ### Example Usage to Make CitroSprite Array Compatible with this Function:
	 * ```
	 * var blocks:Array<CitroSprite> = [];
	 * 
	 * // To make this function compatible with other types as , you have to do this:
	 * for (sprite in CitroG.scanObjectsTouched(cast blocks) {
	 * 	// do whatever with the sprite here.
	 * }
	 * ```
	 * 
	 * @param objects An array of objects to use and filter out, pass `null` to use the whole state member list (or Substate if it exists yet).
	 * @return An array of Citro Objects currently being touched.
	 */
	public static function scanObjectsTouched(objects:Array<CitroObject> = null):Array<CitroObject> {
		if (objects == null) {
			objects = substate == null ? state.members : substate.members;
		}

		return objects.filter(object -> return isTouching(object));
	}

	/**
	 * A function wrapper to Open an URL, based on [HaxeFlixel](https://haxeflixel.com/)'s [`FlxG.openURL`](https://api.haxeflixel.com/flixel/FlxG.html#openURL) but by launching the Web Browser Applet.
	 * 
	 * This can **Return** bad results if it has failed, You should check the `WebBrowser.launchURL` documentation.
	 * 
	 * @param url The URL to pass into the Wrapper.
	 * @return Result to indicate if it went successful or not.
	 */
	public static function openURL(url:String):Result {
		return WebBrowser.launchURL(url);
	}

	/**
	 * A function to Switch State without doing any of the troubling task.
	 * 
	 * This clears timers, tweens, destroys states, and clears caches to comply with the new State, now with `null` checks!
	 * 
	 * @param State The new state you want to switch to.
	 */
	public static function switchState(State:CitroState) {
		if (State == null) return;

		CitroTimer.reset();
		CitroTween.cta.splice(0, CitroTween.cta.length);

		state.destroy();
		caches.clear();
		(state = State).create();
	}

	/**
	 * A function to clean up and exit game not in a really severe way.
	 * 
	 * This handles:
	 * - Substate Closing (+ null checking)
	 * - Current State Closing.
	 * - Flushing the Save (if you've forgotten it.)
	 * - Clearing the whole cache to get your Memory back.
	 * 
	 * This is a **ONE TIME** call, calling it twice will ***NOT*** do anything to prevent throwing an exception.
	 */
	public static function exitGame() {
		if (CitroGame._shouldQuit) {
			return;
		}

		CitroGame._shouldQuit = true;
		if (substate != null) substate.close();
		state.destroy();

		if (save.flush()) FS.flushAndCommit();
		FS.exit();

		caches.clear();
	}
}