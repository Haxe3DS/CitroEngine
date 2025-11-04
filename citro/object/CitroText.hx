package citro.object;

import cxx.num.UInt32;

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
@:headerCode('
#include <3ds.h>
#include <citro2d.h>
#include <citro3d.h>
')

@:cppFileCode('
static C2D_Font fnt = NULL;
static C2D_TextBuf sbuf = NULL;
int offsets[8][2] = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}};

static u32 applyAlpha(u32 color, float alpha) {
    u8 a = static_cast<u8>(((color >> 24) & 0xFF) * fmin(alpha, 1)), r = (color >> 16) & 0xFF, g = (color >> 8) & 0xFF, b = color & 0xFF;
    return (a << 24) | (b << 16) | (g << 8) | r;
}
    
void createText(citro::object::CitroText* value) {
    C2D_Text c2dText;
    C2D_TextBufClear(sbuf);
    C2D_TextFontParse(&c2dText, value->defaultFont ? value->defaultFont : fnt, sbuf, value->text.c_str());
    C2D_TextOptimize(&c2dText);
    bool cam = value->_isCam;
    
    float width, height;
    C2D_TextGetDimensions(&c2dText, cam ? value->_scaleOrigin->x : value->scale->x, cam ? value->_scaleOrigin->y : value->scale->y, &width, &height);
    value->width = width;
    value->height = height;
    value->c2dText = c2dText;
}')

@:headerClassCode('
	C2D_Font defaultFont;
	C3D_Mtx matrix;
    C2D_Text c2dText;
')
class CitroText extends CitroObject {
    /**
     * The current text being displayed in screen.
     * 
     * **1.1.0**: Now supports other types of variables!
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
    public var borderColor:UInt32 = 0xFF000000;

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
            Mtx_Identity(&this->matrix);
            this->defaultFont = nullptr;

            if (sbuf == NULL) {
                fnt = C2D_FontLoadSystem(CFG_REGION_USA);
                sbuf = C2D_TextBufNew(4096);
            }

            createText(this)
        ');
    }

    /**
     * Updates and draws the text.
     * @param delta Delta time parsed by `CitroState`
     */
    override function update(delta:Int):Bool {
        if (text.length == 0 || (super.update(delta) && !CitroInit.renderDebug)) {
            return false;
        }

        untyped __cpp__('
            createText(this);
            float newX = this->x, sw = this->scale->x, sh = this->scale->y;
            
            u32 fl = C2D_WithColor;
            switch (this->alignment) {
                case 0: break;
                case 1: newX += {0} ? (320 - this->width) / 2 : (400 - this->width) / 2; break;
                case 2: newX += {0} ? 320 - this->width : 400 - this->width; break;
            }

            C2D_ViewSave(&this->matrix);
            C2D_ViewTranslate(newX * this->factor->x, this->y * this->factor->y);
            C2D_ViewTranslate(this->width * sw / 2, this->height * sh / 2);
            C2D_ViewRotate(this->angle * M_PI / 180);
            C2D_ViewScale(sw, sh);
            C2D_ViewTranslate(-this->width / 2, -this->height / 2);


            if (this->borderStyle != 0 && this->borderSize >= 0) {
                u32 bCol = applyAlpha(this->borderColor, alpha);
                switch(this->borderStyle) {
                    case 0: break;
                    case 1: {
                        for (int i = 0; i < 8; i++) C2D_DrawText(&this->c2dText, fl, (offsets[i][0] * this->borderSize), (offsets[i][1] * this->borderSize), 0, 1, 1, bCol);
                        break;
                    }
                    case 2: {
                        for (int i = 1; i < static_cast<int>(this->borderSize + 1); i++) C2D_DrawText(&this->c2dText, fl, -i, i, .5, 1, 1, bCol);
                        break;
                    }
                }
            }

            C2D_DrawText(&this->c2dText, fl, 0, 0, 0, 1, 1, applyAlpha(this->color, this->alpha));
            C2D_ViewRestore(&this->matrix)
        ', render == BOTTOM);

        return true;
    }

    /**
     * Loads a font path provided.
     * @param path The file path to use, also make sure it's converted to BCFNT.
     */
    public function loadFont(path:String):Bool {
        return untyped __cpp__('(this->defaultFont = C2D_FontLoad(path.c_str())) != NULL');
    }

    override function destroy() {
        super.destroy();
        if (CitroG.isNotNull(untyped __cpp__('this->defaultFont'))) untyped __cpp__('this->defaultFont = nullptr;');
    }
}