package citro.object;

import citro.backend.CitroColor;

using StringTools;

enum abstract Align(Int) {
	/**
	 * Sets the text's alignment to the left screen.
	 */
	var LEFT;

	/**
	 * Sets the text's alignment to the center screen.
	 */
	var CENTER;

	/**
	 * Sets the text's alignment to the right screen.
	 */
	var RIGHT;
}

enum abstract BorderStyle(Int) {
	/**
	 * Do not display any border to it.
	 */
	var NONE;

	/**
	 * Displays border in all direction even diagonal.
	 */
	var OUTLINE;

	/**
	 * Displays a shadowy text (`y++` then `x--`);
	 */
	var SHADOW;
}

/**
 * Text Class for making, styling, and Making some useful modification for this text.
 */
@:cppFileCode('
#include "haxe3ds_Utils.h"

static C2D_Font fnt = NULL;
static C2D_TextBuf sbuf = NULL;
C2D_Text c2dText;

const Float offsets[8][2] = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}};

namespace textUtil {
void createText(citro::object::CitroText_obj* value) {
	C2D_TextBufClear(sbuf);
	C2D_TextFontParse(&c2dText, value->defaultFont ? value->defaultFont : fnt, sbuf, value->text.utf8_str());
	C2D_TextOptimize(&c2dText);

	float width, height;
	C2D_TextGetDimensions(&c2dText, value->scale->x, value->scale->y, &width, &height);
	value->width = width;
	value->height = height;
}
}')

@:headerCode('
#include <citro2d.h>
#include <citro3d.h>
')
@:headerClassCode('C2D_Font defaultFont;')
class CitroText extends CitroObject {
	/**
	 * The current text being displayed in screen.
	 */
	public var text:String = "";

	/**
	 * Current alignment usage.
	 * 
	 * ### Warning:
	 * If added to camera and not in state, it will mess up! Leave it as `LEFT`.
	 */
	public var alignment:Align = LEFT;

	/**
	 * Current color for this border
	 */
	public var borderColor:CitroColor = 0xFF000000;

	/**
	 * Current size of this border.
	 */
	public var borderSize:Float = 1;

	/**
	 * Style to use as.
	 * @see borderStyle enum
	 */
	public var borderStyle:BorderStyle = NONE;

	/**
	 * Creates a new object text that can display whetever text you wanna use, or have fun with it.
	 * @param x The X position to use.
	 * @param y The Y position to use.
	 * @param Text The current text string to use.
	 */
	public function new(x:Float = 0, y:Float = 0, Text:String = "") {
		super();

		this.x = x;
		this.y = y;
		this.text = Text;

		untyped __cpp__('
			if (sbuf == NULL) {
				fnt = C2D_FontLoadSystem(CFG_REGION_USA);
				sbuf = C2D_TextBufNew(512);
			} textUtil::createText(this) // {0}
		', this.scale);
	}

	/**
	 * Updates and draws the text.
	 */
	override function update():Bool {
		if (text.length == 0 || super.update()) {
			return false;
		}

		untyped __cpp__('
			textUtil::createText(this);
			float newX = x, sw = scale->x, sh = scale->y;

			u32 fl = C2D_WithColor;
			switch (alignment) {
				case 0: break;
				case 1: newX += {0} ? (320 - width) / 2 : (400 - width) / 2; break;
				case 2: newX += {0} ? 320 - width : 400 - width; break;
			}

			C3D_Mtx matrix;
			Mtx_Diagonal(&matrix, 1.0f, 1.0f, 1.0f, 1.0f);
			C2D_ViewSave(&matrix);
			C2D_ViewTranslate(newX, y);
			C2D_ViewTranslate(width * sw / 2.0, height * sh / 2.0);
			C2D_ViewRotateDegrees(angle);
			C2D_ViewScale(sw, sh);
			C2D_ViewTranslate(-width / 2.0, -height / 2.0);

			if (borderStyle != 0 && borderSize >= 0) {
				CONVERT_TO_COMPATIBLE_COLOR(borderColor)
				switch(borderStyle) {
					case 1: {
						for (int i = 0; i < 8; i++) C2D_DrawText(&c2dText, fl, (offsets[i][0] * borderSize), (offsets[i][1] * borderSize), 0, 1, 1, finalColor);
						break;
					}
					case 2: {
						for (int i = 1; i < borderSize + 1; i++) C2D_DrawText(&c2dText, fl, -i, i, 0, 1, 1, finalColor);
						break;
					}
				}
			}

			CONVERT_TO_COMPATIBLE_COLOR(color)
			C2D_DrawText(&c2dText, fl, 0, 0, 0, 1, 1, finalColor);
			C2D_ViewRestore(&matrix)
		', bottom);

		return true;
	}

	/**
	 * Loads a font path provided.
	 * @param path The file path to use, also make sure it's converted to BCFNT.
	 */
	public function loadFont(path:String):Bool {
		final cacheFile:String = 'CitroText_${path.replace("_", "-")}';

		var success:Bool = untyped __cpp__('(defaultFont = C2D_FontLoad(path.c_str())) != NULL');
		if (success) {
			CitroG.caches.set(cacheFile, untyped __cpp__('&defaultFont'));
		} else {
			success = CitroG.caches.exists(cacheFile);
			if (success) {
				final ptr = CitroG.caches[cacheFile];
				untyped __cpp__('
					defaultFont = (C2D_Font){0}.ptr;
					if (!defaultFont) success = false;
				', ptr);
			}
		}
		return success;
	}

	/**
	 * Sets all of border related variables to whatever you like, returns the same variable if you want to chain it.
	 * @param color The Border Color to use, Defaults to Black.
	 * @param size The Size for the Border to use, Defaults to 1.
	 * @param style The Style for the Border to use, Defaults to OUTLINE.
	 * @return The same variable if you want to chain them.
	 */
	public function setBorderStyle(color:CitroColor = 0xFF000000, size:Float = 1, style:BorderStyle = OUTLINE):CitroText {
		borderColor = color;
		borderSize = size;
		borderStyle = style;
		return this;
	}

	override function destroy() {
		super.destroy();
		untyped __cpp__('
			if (defaultFont) {
				C2D_FontFree(defaultFont);
				defaultFont = nullptr;
			}
		');
	}
}