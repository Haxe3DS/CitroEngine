package citro.object;

import citro.object.CitroObject;
import citro.math.CitroMath;

/**
 * A backend for camera only, useful if you wanna make a camera like view.
 * 
 * Note: It is a object, so it must be added from this state!
 * 
 * @since 1.1.0
 */
@:include("citro/CitroGame.h")
class CitroCamera extends CitroObject {
	/**
	 * Don't use this.
	 */
	var curX:Float = 0;
	var curY:Float = 0;
	var bottomCam:Bool = false;
	var scX:Int = 0;

	/**
	 * Lists of members currently added in this Camera.
	 */
	public var members:Array<CitroObject> = [];

	/**
	 * Per update lerping to update X and Y's Position.
	 */
	public var lerp:Float = 0.5;

	/**
	 * Current zoom usage.
	 */
	public var zoom:Float = 1;

	/**
	 * Constructor for making the camera.
	 * @param bottom Whetever or not the camera positions at the bottom.
	 */
	public function new(bottom:Bool = false) {
		super();

		bottomCam = bottom;
		scX = bottom ? 160 : 200;
	}

	override function update():Bool {
		super.update();

		curX = CitroMath.lerp(curX, x, lerp);
		curY = CitroMath.lerp(curY, y, lerp);
		bottom = bottomCam;

		untyped __cpp__("C2D_SceneBegin(this->bottomCam ? bottomScreen : topScreen)");
		for (spr in members.filter(f -> f.visible && f.alpha > 0)) {
			if (spr.isDestroyed) {
				members.remove(spr);
				continue;
			}

			renderObj(spr);
		}

		return true;
	}

	/**
	 * Renders a sprite from a camera instead of from a object.
	 * @param spr Sprite to use to render as, has error handling!
	 * @param delta Delta to use (needed for sprite's update time)
	 */
	public function renderObj(spr:CitroObject):Bool {
		if (spr == null) {
			return false;
		}

		final oldX = spr.x,
			oldY = spr.y,
			oldSX = spr.scale.x,
			oldSY = spr.scale.y,
			oldA = spr.alpha;

		spr.scale.x *= zoom;
		spr.scale.y *= zoom;
		spr.x = (oldX + curX - scX) * zoom + scX;
		spr.y = (oldY + curY - 120) * zoom + 120;
		spr.alpha *= alpha;

		final out:Bool = spr.update();

		spr.x = oldX;
		spr.y = oldY;
		spr.scale.x = oldSX;
		spr.scale.y = oldSY;
		spr.alpha = oldA;

		return out;
	}

	/**
	 * Follows the object and sets the position to the object's position.
	 * @param object Object to use and set the camera's position.
	 * @since 1.1.0
	 */
	public function follow(object:CitroObject) {
		x = object.x - (bottomCam ? 160 : 200) + (object.width / 2);
		y = object.y - 120 + (object.height / 2);
	}

	/**
	 * Adds a CitroObject to camera and displays it every frame if you call `update`.
	 * @param member An object to add as.
	 */
	public function add(member:CitroObject) {
		members.push(member);
	}

	/**
	 * Inserts a CitroObject to a layer index specified.
	 * @param index Layer number to insert from.
	 * @param member An object to insert as.
	 */
	public function insert(index:Int, member:CitroObject) {
		members.insert(index, member);
	}

	/**
	 * Will destroy every sprite from camera and cleans memory, Only call this on `override function destroy` state function.
	 */
	override function destroy() {
		super.destroy();
		for (member in members) {
			member.destroy();
		}
		members = [];
	}
}