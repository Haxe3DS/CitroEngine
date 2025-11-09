package citro.backend;

import citro.math.CitroMath;
import citro.util.CitroStringUtil;
import cxx.num.UInt8;
import cxx.num.UInt32;

/**
 * Advanced coloring options.
 */
enum abstract CitroColor(UInt32) from UInt32 to UInt32 {
	/**
	 * Indication of the color alpha in U8.
	 */
	public var alpha(get, set):UInt8;
	function get_alpha():UInt8 return (this >> 24) & 0xFF;
	inline function set_alpha(alpha:UInt8):UInt8 {
		this &= 0x00ffffff;
		this |= Std.int(CitroMath.clamp(alpha, 0, 0xFF)) << 24;
		return alpha;
	}

	/**
	 * Indication of the color red in U8.
	 */
	public var red(get, set):UInt8;
	function get_red():UInt8 return (this >> 16) & 0xFF;
	inline function set_red(red:UInt8):UInt8 {
		this &= 0xff00ffff;
		this |= Std.int(CitroMath.clamp(red, 0, 0xFF)) << 16;
		return red;
	}

	/**
	 * Indication of the color green in U8.
	 */
	public var green(get, set):UInt8;
	function get_green():UInt8 return (this >> 8) & 0xFF;
	inline function set_green(green:UInt8):UInt8 {
		this &= 0xffff00ff;
		this |= Std.int(CitroMath.clamp(green, 0, 0xFF)) << 8;
		return red;
	}

	/**
	 * Indication of the color blue in U8.
	 */
	public var blue(get, set):UInt8;
	function get_blue():UInt8 return this & 0xFF;
	inline function set_blue(blue:UInt8):UInt8 {
		this &= 0xffffff00;
		this |= Std.int(CitroMath.clamp(blue, 0, 0xFF));
		return blue;
	}

	public function toString() {
		return CitroStringUtil.numberToHex(this);
	}
}