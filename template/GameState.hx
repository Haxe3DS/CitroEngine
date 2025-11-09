package;

import citro.object.CitroText;
import citro.state.CitroState;

/**
 * Your current state, you can modify as much as you want.
 */
class GameState extends CitroState {
	override function create() {
		super.create();

		var text = new CitroText(0, 0, "Hello, World!");
		text.screenCenter();
		add(text);
	}

	override function update(delta:Int) {
		super.update(delta);
	}
}