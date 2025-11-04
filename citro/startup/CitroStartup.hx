package citro.startup;

import citro.CitroG;
import citro.CitroSound;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.object.CitroSprite;
import citro.state.CitroState;

class CitroStartup extends CitroState {
    var logo:CitroSprite = new CitroSprite();
    var coin:CitroSound  = new CitroSound("romfs:/citro/coin.ogg");

    override function create() {
        super.create();

        coin.play();

        logo.loadGraphic("romfs:/citro/startup.t3x");
        logo.screenCenter();
        add(logo);

        CitroTimer.start(0.3, () -> {
            CitroTween.tweenObject(logo, [{
                variableToUse: SCALE_X,
                destination: 0
            }, {
                variableToUse: SCALE_Y,
                destination: 0
            }, {
                variableToUse: ALPHA,
                destination: 0
            }], 0.7, CUBE_IN, () -> {
                CitroTimer.start(0.1, () -> {
                    coin.destroy();
                    coin = null;

                    logo.destroy();
                    logo = null;

                    CitroG.switchState(CitroInit.oldCS);
                    CitroInit.oldCS = null;
                });
            });
        });
    }

    override function update(delta:Int) {
        super.update(delta);
        logo.screenCenter();
    }
}