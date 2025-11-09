package citro.math;

import citro.object.CitroObject;

// 100% from haxeflixel https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxMath.hx
// maybe not.

/**
 * Math class for creating new types of numbers.
 */
class CitroMath {
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 *
	 * ```haxe
	 * roundDecimal(1.2485, 2) = 1.25
	 * ```
	 *
	 * @param Value Any number.
	 * @param Precision Number of decimals the result should have.
	 * @return The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float {
		var mult:Float = 1;
		for (i in 0...Precision)
			mult *= 10;

		return Math.fround(Value * mult) / mult;
	}

	/**
	 * Returns the linear interpolation of two numbers if `ratio`
	 * is between 0 and 1, and the linear extrapolation otherwise.
	 *
	 * Examples:
	 *
	 * ```haxe
	 * lerp(a, b, 0) = a
	 * lerp(a, b, 1) = b
	 * lerp(5, 15, 0.5) = 10
	 * lerp(5, 15, -1) = -5
	 * ```
	 */
	public static function lerp(a:Float, b:Float, ratio:Float):Float {
		return a + ratio * (b - a);
	}

	/**
	 * Find the distance (in pixels, rounded) between two CitroObjects, taking their origin into account.
	 *
	 * @param SpriteA The first CitroObject
	 * @param SpriteB The second CitroObject
	 * @return Distance between the sprites in pixels
	 */
	public static function distanceBetween(SpriteA:CitroObject, SpriteB:CitroObject):Int {
		var dx:Float = SpriteA.x - SpriteB.x;
		var dy:Float = SpriteA.y - SpriteB.y;
		return Std.int(Math.sqrt(dx * dx + dy * dy));
	}

	/**
	 * Converts an array of float to the exact total in float, Example would be if the array is `[5, 8, 3]`, it would return as 16, because 5 + 8 + 3 == 16.
	 * @param array The array to addition as.
	 * @return Totalled array addition as a float.
	 */
	public static function arrayAddition(array:Array<Float>):Float {
		var fl:Float = 0;
		for (num in array) {
			fl += num;
		}
		return fl;
	}

	/**
	 * Clamps a value between bounds.
	 * @param x The value to clamp.
	 * @param min The lower bound.
	 * @param max The upper bound.
	 * @return The clamped value.
	 */
	public static function clamp(x:Float, min:Float = 0, max:Float = 1):Float {
		return x > max ? max : x < min ? min : x;
	}
}