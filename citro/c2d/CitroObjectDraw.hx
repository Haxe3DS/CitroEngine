package citro.util;

import citro.backend.CitroColor;
import cxx.num.UInt32;

/**
 * Cool objects utility for making new styles.
 */
@:cppFileCode('
#include <citro2d.h>
#include "citro_CitroInit.h"
#include "citro_object_CitroSprite.h"
')

class CitroObjectDraw {
	/**
	 * Draws a triangular gradient with arguments specified.
	 * @param arrayX An array of the X's coordinate of this vertex of this triangle, must be 3 or more or it'll return false.
	 * @param arrayY An array of the Y's coordinate of this vertex of this triangle, must be 3 or more or it'll return false.
	 * @param arrayC An array of 32-bit ARGB color of the vertex of the triangle. `0: Bottom Left, 1: Top Middle, 2: Bottom Right`. If len is 1 then it will be a solid color.
	 * @param drawBottom Whetever or not it should draw in the bottom screen.
	 * @return `true` if successfully drawn, `false` if one of the arrays is not greater than 2
	 */
	public static function drawTriangle(arrayX:Array<Float>, arrayY:Array<Float>, arrayC:Array<UInt32>, drawBottom:Bool = false):Bool {
		if (arrayX.length > 2 && arrayY.length > 2 && arrayC.length > 0) {
			while (arrayC.length < 3) {
				arrayC.push(arrayC[0]);
			}

			untyped __cpp__('
				C2D_SceneBegin(drawBottom ? bottomScreen : topScreen);
				C2D_DrawTriangle(
					(*arrayX)[0], (*arrayY)[0], colorConvert((*arrayC)[0]),
					(*arrayX)[1], (*arrayY)[1], colorConvert((*arrayC)[1]),
					(*arrayX)[2], (*arrayY)[2], colorConvert((*arrayC)[2]),
					1
				)
			');
			return true;
		}
		return false;
	}

	/**
	 * Draws a linely gradient with arguments specified
	 * @param arrayX An array of the X's Horizontal position of the vertex of this line, must be 2 or more or it'll return false.
	 * @param arrayY An array of the Y's Vertical position of the vertex of this line, must be 2 or more or it'll return false.
	 * @param arrayC An array of the Color's 32-bit ARGB color of the vertex of this line. `0: Left, 1: Right`. If len is 1 then it will be a solid color.
	 * @param thickness Thickness, in pixels, of the line
	 * @param drawBottom Whetever or not it should draw in the bottom screen.
	 * @return `true` if successfully drawn, `false` if one of the arrays is not greater than 1.
	 */
	public static function drawLine(arrayX:Array<Float>, arrayY:Array<Float>, arrayC:Array<UInt32>, thickness:Float = 4, drawBottom:Bool = false):Bool {
		if (arrayX.length > 1 && arrayY.length > 1 && arrayC.length > 1) {
			if (arrayC.length == 1) {
				arrayC.push(arrayC[0]);
			}

			untyped __cpp__('
				C2D_SceneBegin(drawBottom ? bottomScreen : topScreen);
				C2D_DrawLine(
					(*arrayX)[0], (*arrayY)[0], colorConvert((*arrayC)[0]),
					(*arrayX)[1], (*arrayY)[1], colorConvert((*arrayC)[1]),
					thickness, 1
				)
			');
			return true;
		}
		return false;
	}

	/**
	 * Draws a either solid rectangle color or a gradient rectangle color with specified arguments.
	 * @param x The X's Position to use.
	 * @param y The Y's Position to use.
	 * @param w The Width for the rectangle.
	 * @param h The Height for the rectangle.
	 * @param color An array of colors, if color array has 3> length then uses gradient, else uses solid color. `0: Top Left, 1: Top Right, 2: Bottom Left, 3: Bottom Right.`
	 * @param drawBottom Whetever or not it should draw in the bottom screen.
	 * @return `true` if length is not equal than 0
	 */
	public static function drawRect(x:Float, y:Float, w:Float, h:Float, color:Array<CitroColor>, drawBottom:Bool = false):Bool {
		return color.length > 1 ? {
			while (color.length < 4)
				color.push(color[0]);
			untyped __cpp__('
				C2D_SceneBegin(drawBottom ? bottomScreen : topScreen);
				C2D_DrawRectangle(
					x, y, 1, w, h, colorConvert((*color)[0]), colorConvert((*color)[1]),
					colorConvert((*color)[2]), colorConvert((*color)[3])
				)
			');
			true;
		} : false;
	}
	
	/**
	 * Draws a either solid circle color or a circle ellipse color with specified arguments.
	 * @param x The X's Position to use.
	 * @param y The Y's Position to use.
	 * @param radius Radius of the circle.
	 * @param color An array of colors, if color array has 3> length then uses gradient, else uses solid color.
	 * @param drawBottom Whetever or not it should draw in the bottom screen.
	 * @return `true` if length is not equal than 0
	 **/
	public static function drawCircle(x:Float, y:Float, radius:Float, color:Array<CitroColor>, drawBottom:Bool = false):Bool {
		if (color.length == 0)
			return false;
		
		while (color.length < 4)
			color.push(color[0]);

		untyped __cpp__('
			C2D_SceneBegin(drawBottom ? bottomScreen : topScreen);
			C2D_DrawCircle(x, y, 1, radius, colorConvert((*color)[0]), colorConvert((*color)[1]), colorConvert((*color)[2]), colorConvert((*color)[3]))
		');
		return true;
	}

	/**
	 * Draws a either solid ellipse color or a gradient ellipse color with specified arguments.
	 * @param x The X's Position to use.
	 * @param y The Y's Position to use.
	 * @param w The Width for the rectangle.
	 * @param h The Height for the rectangle.
	 * @param color An array of colors, if color array has 3> length then uses gradient, else uses solid color.
	 * @param drawBottom Whetever or not it should draw in the bottom screen.
	 * @return `true` if length is not equal than 0
	 */
	public static function drawEllipse(x:Float, y:Float, w:Float, h:Float, color:Array<CitroColor>, drawBottom:Bool = false):Bool {
		if (color.length == 0)
			return false;
		
		while (color.length < 4)
			color.push(color[0]);
	
		untyped __cpp__('
			C2D_SceneBegin(drawBottom ? bottomScreen : topScreen);
			C2D_DrawEllipse(x, y, 1, w, y, colorConvert((*color)[0]), colorConvert((*color)[1]), colorConvert((*color)[2]), colorConvert((*color)[3]))
		');
		return true;
	}
}