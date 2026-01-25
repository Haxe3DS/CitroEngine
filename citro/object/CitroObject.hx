package citro.object;

import cpp.UInt16;
import citro.state.CitroState;
import citro.backend.CitroColor;

enum abstract CitroAxes(Int) {
	var X;
	var Y;
	var XY;
}

typedef CitroAcceleration = {
	/**
	 * The current X's acceleration.
	 */
	var x:Float;

	/**
	 * The current Y's acceleration.
	 */
	var y:Float;

	/**
	 * The current Angular's acceleration.
	 */
	var angle:Float;
}

class CitroVector2D {
	/**
	 * X in vector.
	 */
	public var x:Float = 1;

	/**
	 * Y in vector.
	 */
	public var y:Float = 1;

	/**
	 * Sets the current vectors without needing to use 2 lines.
	 * @param xTo X vector to use.
	 * @param yTo Y vector to use.
	 */
	public function set(xTo:Float, yTo:Float) {
		x = xTo;
		y = yTo;
	}

	public function new() {};
}

@:headerCode('
#define CONVERT_TO_COMPATIBLE_COLOR(color) \\
	u32 finalColor = ((color & 0xFF00FF00) | ((color >> 16) & 0xFF) | ((color & 0xFF) << 16)); \\
	if (alpha < 1) finalColor = (color & 0x00FFFFFF) | ((u8)((u8)((color >> 24) & 0xFF) * alpha) << 24);
')
class CitroObject {
	/**
	 * A typedef for the Acceleration, containing 3 variables.
	 */
	public var acceleration:CitroAcceleration = {x: 0, y: 0, angle: 0};

	/**
	 * Current Object's Transparency, 0 being transparent and 1 being Opaque. 
	 */
	public var alpha:Float = 1;

	/**
	 * Angular rotation for the current object in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Should the Object Render in the Bottom Screen Instead?
	 * 
	 * If this is `true`, then functions such as `CitroG.isTouching` will be compatible.
	 */
	public var bottom:Bool = false;

	/**
	 * Hex color in 0xAARRGGBB.
	 */
	public var color:CitroColor = 0xFFFFFFFF;

	/**
	 * The current height for the current object.
	 */
	public var height(default, null):Float = 0;

	/**
	 * The current index of this object from the State / Substate, returns -1 if it's not added.
	 * 
	 * You can also set the Index too, by doing `this.index = number`, this removes and adds to another index.
	 */
	public var index(get, set):UInt16;

	function get_index():UInt16 {
		final pos = CitroG.state.members.indexOf(this);
		if (pos == -1 && CitroG.substate != null) {
			return CitroG.substate.members.indexOf(this);
		}

		return pos;
	}

	function set_index(index:UInt16):UInt16 {
		var state:CitroState = CitroG.state;
		if (!CitroG.state.members.contains(this)) {
			if (CitroG.substate == null || !CitroG.substate.members.contains(this)) {
				return -1;
			}

			state = CitroG.substate;
		}

		state.remove(this);
		state.insert(index, this);
		return index;
	}

	/**
	 * Checker if this object is destroyed or not.
	 */
	@:noCompletion
	public var isDestroyed(default, null):Bool = false;

	/**
	 * Current scale for the current object.
	 */
	public var scale:CitroVector2D = new CitroVector2D();

	/**
	 * Whetever or not if this object is currently visible or not.
	 */
	public var visible:Bool = true;

	/**
	 * The current width for the current object.
	 */
	public var width(default, null):Float = 0;

	/**
	 * Current X (Horizontal) position for this object in the Top Left World Screen.
	 */
	public var x:Float = 0;

	/**
	 * Current Y (Vertical) position for this object in the Top Left World Screen.
	 */
	public var y:Float = 0;

	/**
	 * This should not be used, if you want a usable version use `CitroSprite` or `CitroText`
	 */
	public function new() {}

	/**
	 * Destroys the current object and frees up memory.
	 */
	public function destroy() {
		isDestroyed = true;
		acceleration = null;
		scale = null;
	}

	/**
	 * Updates and renders this object.
	 * @return `false` if sprite can be rendered, true if cannot.
	 */
	public function update():Bool {
		x += acceleration.x;
		y += acceleration.y;
		angle += acceleration.angle;
		return isOnScreen() || isDestroyed;
	};

	/**
	 * Screen centers the current object.
	 * @param pos Current axes to use as, can be X, Y or XY.
	 */
	public function screenCenter(pos:CitroAxes = XY) {
		final newW:Float = width * scale.x;
		final newX:Float = bottom ? (320 - newW) / 2 : (400 - newW) / 2;
		final newY:Float = (240 - (height * scale.y)) / 2;

		switch(pos) {
			case X:  x = newX;
			case Y:  y = newY;
			case XY: x = newX; y = newY;
		}
	}
	
	/**
	 * Checks if the current object is in the screen or not.
	 * @return true if currently visible in screen, false if not visible or not in screen, useful if you don't want it render offscreen to save CPU cycles.
	 */
	public function isOnScreen():Bool {
		if (!visible || alpha <= 0) return false; 

		return x - (width * scale.x) > 0 &&
			   x < (bottom ? 320 : 400) &&
			   y - (height * scale.y) > 0 &&
			   y < 240;
	}
}