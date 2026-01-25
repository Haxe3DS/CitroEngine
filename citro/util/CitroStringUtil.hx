package citro.util;

import citro.math.CitroMath;

/**
 * Utility for creating new styles of strings.
 */
class CitroStringUtil {
	/**
	 * Takes an amount of bytes and finds the fitting unit. Makes sure that the
	 * value is below 1024. Example: formatBytes(123456789); -> 117.74MB
	 */
	public static function formatBytes(Bytes:Float, Precision:Int = 2):String {
		var curUnit:Int = 0;
		final units:Array<String> = ["Bytes", "kB", "MB", "GB", "TB", "PB"];
		while (Bytes >= 1024 && curUnit < units.length - 1) {
			Bytes /= 1024;
			curUnit++;
		}

		var spl:Array<String> = Std.string(CitroMath.roundDecimal(Bytes, Precision)).split(".");
		return '${spl[0]}.${spl[1].substr(0, Precision)}${units[curUnit]}';
	}

	/**
	 * Rounds a float and converts to a string.
	 * @param fl The float to parse as.
	 * @param prec How much precision, more numbers means more decimals.
	 * @return A styled floated string.
	 */
	public static function round(fl:Float, prec:Int = 0):String {
		final ret:Array<String> = Std.string(fl).split(".");
		if (prec == 0) return ret[0];
		return '${ret[0]}.${ret[1].substr(0, prec)}';
	}

	/**
	 * Capitalizes the first letter of this string, Example: `text` -> `Text`.
	 * @param text Text to capitalize.
	 * @return A formatted capitalize text string.
	 * @since 1.1.0
	 */
	public static function capitalize(text:String):String {
		return '${text.substr(0, 1).toUpperCase()}${text.substr(1)}';
	}
}