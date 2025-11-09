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
			CitroTween.tweenObject(logo, [
				SCALE_X => 0,
				SCALE_Y => 0,
				ALPHA   => 0
			], 0.7, {
				ease: CUBE_IN,
				onComplete: () -> {
					CitroTimer.start(0.1, () -> {
						coin.destroy();
						coin = null;
					
						logo.destroy();
						logo = null;
					
						CitroG.switchState(CitroInit.oldCS);
						CitroInit.oldCS = null;
					});
				}
			});
		});
	}

	override function update(delta:Int) {
		super.update(delta);
		logo.screenCenter();
	}
}