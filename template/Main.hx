import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroInit;

/**
 * This is where your code will be ran when game is compiled.
 */
function main() {
	GFX.initDefault();
	RomFS.init();

	untyped __cpp__('
		SDL_Init(SDL_INIT_AUDIO);
        Mix_Init(MIX_INIT_OGG);
        Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 1, 4096);
        Mix_AllocateChannels(256);
        Mix_Volume(-1, MIX_MAX_VOLUME);
	');

	/**
	 * This is also where your game state will be located.
	 */
	CitroInit.init(new GameState());

	RomFS.exit();
	GFX.exit();
}