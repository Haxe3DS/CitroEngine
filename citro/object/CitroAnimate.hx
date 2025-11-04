package citro.object;

import citro.object.CitroSprite;
import haxe3ds.stdutil.FSUtil;

using StringTools;

private typedef CitroAnimateHeader = {
    var frameX:Float;
    var frameY:Float;
    var sprite:CitroSprite;
}

/**
 * A class for animation purpose.
 */
class CitroAnimate extends CitroObject {
    var timeLeft:Float = 0;
    var sprites:Map<String, CitroAnimateHeader> = [];

    /**
     * The framerate for this animation to use.
     */
    public var framerate:Float = 24;

    /**
     * The current frame for this animation playing.
     */
    public var frame:Int = 0;

    /**
     * The current playing animation name that's gonna be used.
     */
    public var curAnim:String = "";

    /**
     * Whetever or not the animation that's currently playing has finished.
     */
    public var finished:Bool = false;

    /**
     * Whetever or not it should loop the entire animation when finished.
     */
    public var looped:Bool = false;

    /**
     * Constructs this sprite.
     * @param craFile Path to the `.cea` (Citro Engine Animate) file to parse.
     * @param defaultAnim The default animation that's going to be used, if `""` then uses the first animation that was parsed.
     */
    public function new(ceaFile:String, defaultAnim:String = "") {
        super();

        final file:String = FSUtil.readFile(ceaFile);
        ceaFile = ceaFile.substr(0, ceaFile.lastIndexOf("/"));
        if (file != "") {
            var i:Int = 0;
            final animationList:Array<String> = [];
            for (line in file.split("\n")) {
                final row:Array<String> = line.split("?");
                if (row.length < 3) break;
                row[3] = row[3].trim();

                if (!animationList.join(" ").contains(row[3])) {
                    animationList.push(row[3]);
                    i = -1;
                }
                i++;

                final n:String = '${row[3]}-$i';
                final sprite:CitroSprite = new CitroSprite();
                if (!sprite.loadGraphic('$ceaFile/${row[0]}')) {
                    i--;
                    sprite.destroy();
                    continue;
                }

                final resultParse:Array<Null<Float>> = [for (i in 1...3) Std.parseFloat(row[i])];
                sprites.set(n, {
                    frameX: resultParse[0] == null ? 0 : resultParse[0],
                    frameY: resultParse[1] == null ? 0 : resultParse[1],
                    sprite: sprite
                });

                if (defaultAnim == "") defaultAnim = n.substr(0, n.length-2);
            }
        }

        play(defaultAnim);
    }

    /**
     * Plays a new animation that's found in the sprite's map.
     * @param animation Animation name to play.
     */
    public function play(animation:String):Bool {
        if (isDestroyed) {
            return false;
        }
        
        final oldFrame:Int = frame;
        frame = 0;

        for (key in sprites.keys()) {
            if (key == '${animation}-0') {
                timeLeft = 1000 / framerate;
                curAnim = animation;
                finished = false;

                final spr:CitroSprite = sprites[key].sprite;
                width  = spr.width;
                height = spr.height;

                return true;
            }
        }

        frame = oldFrame;
        return false;
    }

    function format() {
        return '${curAnim}-$frame';
    }

    override function update(delta:Int):Bool {
        if (isDestroyed) {
            return false;
        }

        if ((timeLeft -= (render == BOTH ? delta / 2 : delta)) < 1) {
            timeLeft = 1000 / framerate;
            frame++;
            if (!sprites.exists(format())) {
                finished = true;
                looped ? play(curAnim) : frame--;
            } else {
                final header:CitroSprite = sprites.get(format()).sprite;
                width = header.width;
                height = header.height;
            }
        }

        if (sprites.exists(format()) && visible) {
            final header:CitroAnimateHeader = sprites.get(format());
            final sprite:CitroSprite = header.sprite;
            sprite.acceleration = acceleration;
            sprite.alpha  = alpha;
            sprite.angle  = angle;
            sprite.render = render;
            sprite.color  = color;
            sprite.factor = factor;
            sprite.scale  = scale;
            sprite.x = x - (header.frameX * scale.x);
            sprite.y = y - (header.frameY * scale.y);
            return sprite.update(delta);
        }

        return false;
    }

    override function destroy() {
        for (key in sprites) key.sprite.destroy();
        super.destroy();
        sprites = null;
    }
}