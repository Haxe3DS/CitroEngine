import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;

/**
 * This is where your code will be ran when game is compiled.
 */
function main() {
	/**
	 * This is also where your game state will be located.
	 */
	CitroGame.init(new GameState());
}