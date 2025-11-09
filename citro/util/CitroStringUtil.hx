package citro.util;

import citro.math.CitroMath;

@:cppInclude('math.h')
/**
 * Utility for creating new styles of strings.
 */
class CitroStringUtil {
	/**
	 * Takes an amount of bytes and finds the fitting unit. Makes sure that the
	 * value is below 1024. Example: formatBytes(123456789); -> 117.74MB
	 */
	public static function formatBytes(Bytes:Float, Precision:Int = 2):String {
		var units:Array<String> = ["Bytes", "kB", "MB", "GB", "TB", "PB"];
		var curUnit:Int = 0;
		while (Bytes >= 1024 && curUnit < units.length - 1) {
			Bytes /= 1024;
			curUnit++;
		}

		var spl:Array<String> = Std.string(CitroMath.roundDecimal(Bytes, Precision)).split(".");
		return '${spl[0]}.${spl[1].substr(0, Precision)}${units[curUnit]}';
	}

	/**
	 * Returns the fomatted time from the `ms` arg.
	 * 
	 * You can add any amount of precision if you want, suggested to be 0 for less CPU work.
	 * 
	 * @param ms The amount milliseconds to add as.
	 * @param precision The very amount of precision to use, more means more decimals.
	 * @returns A formatted time string `XX:XX.XX`
	 */
	public static function formatTime(ms:Float, precision:Int = 0):String {
		var out:String = "";
		untyped __cpp__('
			int total = static_cast<int>(ms / 1000);
	
			int seconds = total % 60;
			int minutes = (total / 60) % 60;
			int hours = total / 3600;

			std::string secs = (seconds < 10) ? "0" + std::to_string(seconds) : std::to_string(seconds);
			std::string mins = (hours > 0) ? "0" + std::to_string(minutes) : std::to_string(minutes);
			out = mins + ":" + secs;

			if (hours > 0)
				out = std::to_string(hours) + ":" + out;

			if (precision > 0) {
				std::string precision_str = std::to_string(static_cast<int>(total * std::pow(10, precision)));
				if (precision_str.length() < static_cast<size_t>(precision))
					precision_str = std::to_string(precision - precision_str.length()) + precision_str;

				precision_str = precision_str.replace(precision, precision_str.length(), "");
				out += "." + precision_str;
			}
		');
		return out;
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

	/**
	 * Converts a number to a hexadecimal string.
	 * @param number The number to use.
	 * @return Converted hexadecimal string.
	 */
	public static function numberToHex(number:Int):String {
		untyped __cpp__('
			char out[32];
			sprintf(out, "0x%lX", number)
		');
		return untyped __cpp__("out");
	}
}