package citro.math;

import cxx.num.UInt32;

@:cppInclude("citro2d.h")

/**
 * Class that uses a randomizer by using stdlib and stuff.
 * 
 * Do not use this class, instead use `CitroG.random`.
 */
class CitroRandom {
	/**
	 * Returns a pseudorandom integer between min and max.
	 * @param min The minimum value that should be returned. 1 by default.
	 * @param max The maximum value that should be returned. 2,147,483,647 by default.
	 * @return A Random number depending on the arguments.
	 */
	public function integer(from:Int = 1, to:Int = 2147483647):Int
		return from + Std.random(to + 1 - from);

	/**
	 * Returns a pseudorandom float value between Min (inclusive) and Max (exclusive).
	 * @param min The minimum value that should be returned. 1 by default.
	 * @param max The maximum value that should be returned. 2,147,483,647 by default.
	 * @return A Random number depending on the arguments.
	 */
	public function floating(from:Float = 1, to:Float = 2147483647):Float
		return from + (Math.random() * (to - from));

	/**
	 * Returns true or false based on the chance value (default 50%).
	 * 
	 * For example if you wanted a player to have a 30.5% chance of getting a bonus, call `boolean(30.5)` - true means the chance passed, false means it failed.
	 * @param chance The chance of receiving the value. Should be given as a number between 0 and 100 (effectively 0% to 100%). 50 by default.
	 * @return Whether the roll passed or not.
	 */
	public function boolean(chance:Float = 50):Bool
		return floating(0, CitroMath.clamp(chance, 0, 100)) < chance;

	/**
	 * Returns a random color depending by the arguments, does a lot of bit-shifting though?
	 * @param from The mininum value to use.
	 * @param to The maximum value to use.
	 * @return A UInt32 color bit shifted.
	 */
	public function color(from:Int = 0xFF000000, to:Int = 0xFFFFFFFF):UInt32 {
		final fromArr:Array<Int> = [for (i in 0...4) (from >> i * 8) & 0xFF], toArr = [for (i in 0...4) (to >> i * 8) & 0xFF];

		return integer(fromArr[3], toArr[3]) << 24 |
			integer(fromArr[2], toArr[2]) << 16 |
			integer(fromArr[1], toArr[1]) << 8 |
			integer(fromArr[0], toArr[0]);
	}

	/**
	 * Gets and picks a random option from this array.
	 * @param Array The array to pick.
	 * @return The random option that was received.
	 */
	public function array<T>(Array:Array<T>):T
		return Array[integer(0, Array.length - 1)];

	public function new() {};
}