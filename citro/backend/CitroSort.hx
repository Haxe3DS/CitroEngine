package citro.backend;

/**
 * Sorting class for creating cleaner usual sortings with some tools to help you get better at sorting.
 */
class CitroSort {
	/**
	 * Ascending sorting order, will sort from A-Z.
	 */
	public static var ascending:Int = -1;

	/**
	 * Descending sorting order, will sort from Z-A
	 */
	public static var descending:Int = 1;

	/**
	 * Compares both `x` and `y` to sort between 1 or -1 or 0.
	 * 
	 * ### Example Usage:
	 * ```
	 * // Sort by Sprite's X Position and converts to ascending array.
	 * members.sort((object1, object2) -> {
	 *	 CitroSort.byValues(CitroSort.ascending, object1.x, object2.x);
	 * });
	 * ```
	 * 
	 * @param order Ordering to use (ascending or descending)
	 * @param x X's float value to use.
	 * @param y Y's float value to use.
	 * @return Ordering integer that can be used with array's sorting.
	 */
	public static function byValues(order:Int, x:Float, y:Float):Int {
		return x < y ? order : x > y ? -order : 0;
	}
}