package citro.object;

import citro.backend.CitroColor;

using StringTools;

@:headerCode('
#include <citro2d.h>
#include <citro3d.h>
')

@:headerClassCode('struct {
	C2D_SpriteSheet ss;
	C2D_Image image;
} data;')

@:cppFileCode('
#include <citro2d.h>
#include <citro3d.h>
#include "citro/CitroGame.h"
#include "haxe3ds_Utils.h"

C2D_ImageTint tint;
')
class CitroSprite extends CitroObject {
	/**
	 * Creates a new Citro Sprite, which can load images, graphic and even more!
	 * @param xPos The X Position to use.
	 * @param yPos The Y Position to use.
	 */
	public function new(xPos:Float = 0, yPos:Float = 0) {
		super();

		this.x = xPos;
		this.y = yPos;

		untyped __cpp__('
			data.ss = nullptr;
			data.image = {NULL, NULL};
			//{0}
		', this.scale);
	}

	/**
	 * Creates a graphic from sprite to be ready to be rendered.
	 * @param Width The width to set as.
	 * @param Height The height to set as.
	 * @param Col The color in hex 0xAARRGGBB to set as.
	 */
	public function makeGraphic(Width:Float, Height:Float, Col:CitroColor = 0xFFFFFFFF):CitroSprite {
		width  = Width;
		height = Height;
		color  = Col;
		return this;
	}

	/**
	 * Loads an image graphic as a .t3x file
	 * @param file File path to use, file must end with .t3x
	 * @return true if successfully loaded, false if not loaded.
	 */
	public function loadGraphic(file:String):Bool {
		final cacheFile:String = 'CitroSprite_${file.replace("_", "-")}';
		if (CitroG.caches.exists(cacheFile)) {
			final ptr = CitroG.caches[cacheFile];
			untyped __cpp__('data.ss = (C2D_SpriteSheet)({0}.ptr)', ptr);
		}

		untyped __cpp__('
			if (!data.ss) {
				data.ss = C2D_SpriteSheetLoad(file.c_str());
				if (!data.ss) return false;
			}

			C2D_Image ret = C2D_SpriteSheetGetImage(data.ss, 0);
			data.image = ret;
			width = ret.subtex->width;
			height = ret.subtex->height
		');

		CitroG.caches.set(cacheFile, untyped __cpp__('&data.ss'));
		return true;
	}

	/**
	 * Updates and draws the sprite
	 */
	override function update():Bool {
		untyped __cpp__('
			Float sw = scale->x, sh = scale->y;

			C3D_Mtx matrix;
			Mtx_Diagonal(&matrix, 1.0f, 1.0f, 1.0f, 1.0f);

			C2D_ViewSave(&matrix);
			C2D_ViewTranslate(x, y);
			C2D_ViewTranslate(width * sw / 2.0, height * sh / 2.0);
			C2D_ViewRotateDegrees(angle);
			C2D_ViewScale(sw, sh);
			C2D_ViewTranslate(-width / 2.0, -height / 2.0);

			if (data.image.tex == NULL || data.image.subtex == NULL) {
				CONVERT_TO_COMPATIBLE_COLOR(color)
				C2D_DrawRectSolid(0, 0, 0, width, height, finalColor);
			} else {
				C2D_PlainImageTint(
					&tint,
					C2D_Color32(
						(color >> 16) & 0xFF,
						(color >> 8) & 0xFF,
						color & 0xFF,
						((color >> 24) & 0xFF) * C2D_Clamp(alpha, 0, 1)
					),
					fabs(((Float)(color & 0xFFFFFF) / 16777215.0) - 1) / 2.0
				);
				C2D_DrawImageAt(data.image, 0, 0, 0, &tint, 1, 1);
			}

			C2D_ViewRestore(&matrix)
		');
		return true;
	}

	override function destroy() {
		super.destroy();
		
		untyped __cpp__('
			if (data.ss) {
				C2D_SpriteSheetFree(data.ss);
				data.ss = nullptr;
			}
		');
	}
}