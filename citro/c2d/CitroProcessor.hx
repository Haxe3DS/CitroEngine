package citro.c2d;

/**
 * Class for processing time and other utilities.
 */
@:cppFileCode("#include <citro2d.h>")
class CitroProcessor {
	/**
	 * Retrieves the current command buffer usage.
	 */
	public static var bufferUsage(get, null):Float;
	static function get_bufferUsage():Float
		return untyped __cpp__('C3D_GetCmdBufUsage()');

	/**
	 * Gets time spent by the GPU during last render.
	 */
	public static var drawTime(get, null):Float;
	static function get_drawTime():Float
		return untyped __cpp__('C3D_GetDrawingTime()');

	/**
	 * Gets time elapsed between last `C3D_FrameBegin()` and `C3D_FrameEnd()`. 
	 */
	public static var processingTime(get, null):Float;
	static function get_processingTime():Float
		return untyped __cpp__('C3D_GetProcessingTime()');
}