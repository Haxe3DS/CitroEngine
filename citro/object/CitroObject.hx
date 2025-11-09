package citro.object;

import citro.backend.CitroColor;
import cxx.num.UInt32;

enum Axes {
	X; Y; XY;
}

enum CitroRenderType {
	/**
	 * Renders on the top screen.
	 */
	TOP;

	/**
	 * Renders on the bottom screen.
	 */
	BOTTOM;

	/**
	 * Both renders in both screens.
	 */
	BOTH;
}

typedef CitroAcceleration = {
	/**
	 * The current X's acceleration.
	 */
	x:Float,

	/**
	 * The current Y's acceleration.
	 */
	y:Float,

	/**
	 * The current Angular's acceleration.
	 */
	angle:Float
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

class CitroObject {
	/**
	 * The current acceleration for this sprite.
	 */
	public var acceleration:CitroAcceleration = {x: 0, y: 0, angle: 0};

	/**
	 * Current visibility, 0 for invisible, 1 for visible.
	 */
	public var alpha:Float = 1;

	/**
	 * Angular rotation for the current object.
	 */
	public var angle:Float = 0;

	/**
	 * Render Type to Use.
	 * 
	 * If from a camera, this will do nothing and is only specified by the camera's rendering type.
	 */
	public var render:CitroRenderType = TOP;

	/**
	 * Hex color in 0xAARRGGBB.
	 */
	public var color:CitroColor = 0xFFFFFFFF;

	/**
	 * The current height for the current object.
	 */
	public var height:Float = 0;

	/**
	 * Whetever or not it should be destroyed. (Read-Only)
	 */
	public var isDestroyed(default, null):Bool = false;

	/**
	 * Current scale for the current object.
	 */
	public var scale:CitroVector2D = new CitroVector2D();

	/**
	 * Scale origin like `scale` but necessary useful for cameras.
	 * 
	 * Useless for Sprite, Useful for text.
	 */
	public var _scaleOrigin:CitroVector2D = new CitroVector2D();

	/**
	 * Variable to check if it's rendering from a camera.
	 */
	public var _isCam:Bool = false;

	/**
	 * Whetever or not if the sprite is currently visible or not.
	 */
	public var visible:Bool = true;

	/**
	 * the current width for the current object.
	 */
	public var width:Float = 0;

	/**
	 * Current X (Horizontal) position for the sprite.
	 */
	public var x:Float = 0;

	/**
	 * Current Y (Vertical) position for the sprite.
	 */
	public var y:Float = 0;

	/**
	 * The screen factor as Vector 2D, useful if using cameras.
	 */
	public var factor:CitroVector2D = new CitroVector2D();

	/**
	 * Current ID for this object (Read-Only)
	 */
	//public var id(default, null):Int = CitroG.random.integer(0, 2147483647);

	/**
	 * This should not be used, if you want a usable version use `CitroSprite` or `CitroText`
	 */
	public function new() {
		_scaleOrigin = scale;
	}

	/**
	 * Destroys the current object and frees up memory.
	 */
	public function destroy() isDestroyed = true;

	/**
	 * Updates and renders the sprite.
	 * @param delta Delta Time for the member.
	 * @return `false` if rendered does not reach capacity of `CitroInit.capacity` members, true if reached, needed to fix a bug about `svcBreak`
	 */
	public function update(delta:Int):Bool {
		x	 += acceleration.x;
		y	 += acceleration.y;
		angle += acceleration.angle;

		//alpha = alpha >= 1 ? 1 : alpha <= 0 ? 0 : alpha;
		//angle += angle >= 360 ? -360 : angle <= -360 ? 360 : 0;
		return CitroInit.rendered++ > CitroInit.capacity || isDestroyed || !visible || alpha <= 0;
	};

	/**
	 * Screen centers the current object.
	 * @param pos Current axes to use as, can be X, Y or XY.
	 */
	public function screenCenter(pos:Axes = XY) {
		final newW:Float = width * scale.x;
		final newX:Float = render == BOTTOM ? (320 - newW) / 2 : (400 - newW) / 2;
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
		if (!visible) {
			return false;
		}

		return !(x + (width * scale.x) < 0 || x > (render == BOTTOM ? 320 : 400) || y + (height * scale.y) < 0 || y > 240);
	}
}