package citro;

import citro.backend.CitroTimer;
import citro.backend.CitroTween;
import citro.object.CitroText;
import citro.state.CitroSubState;
import citro.state.CitroState;

import haxe3ds.applet.Error;
import haxe3ds.services.APT;
import haxe3ds.OS;

import cxx.num.UInt64;

using StringTools;

/**
 * The settings for this.
 */
private typedef CitroSettings = {
	/**
	 * Whetever or not you want to skip the Citro Intro. **OPTIONAL**: Intro will still be played anyway.
	 */
	var skipIntro:Bool;

	/**
	 * Whetever or not you want to set the current capacity limitation. **OPTIONAL**: Will be set to 400, be aware of exceptions if going higher!
	 */
	var capacityLimit:Int;
}

@:headerCode("
#include <citro2d.h>
#include <citro3d.h>
#include <SDL/SDL.h>
#include <SDL/SDL_mixer.h>
extern C3D_RenderTarget* topScreen;
extern C3D_RenderTarget* bottomScreen;
")

@:cppFileCode('
#include <3ds.h>
#include <stdlib.h>
C3D_RenderTarget* topScreen = nullptr;
C3D_RenderTarget* bottomScreen = nullptr;
')
/**
 * Literally everything to set up citro engine.
 */
class CitroInit {
	/**
	 * A way to say if you want the game to quit, should not be set and instead should call `CitroG.exitGame()`
	 */
	@:noCompletion
	public static var shouldQuit:Bool = false;

	/**
	 * Array of debug texts which gets pushed from `trace`.
	 */
	@:noCompletion
	public static var debugTexts:Array<CitroText> = [];

	/**
	 * Old state that's only purpose is to restore it when startup is finished.
	 */
	@:noCompletion
	public static var oldCS:CitroState;

	/**
	 * Current substate running, `null` means no substate running, can be checked with `CitroG.isNotNull(CitroInit.substate)`
	 */
	@:noCompletion
	public static var subState:CitroSubState;

	/**
	 * Should not be used, but it's used to destroy substate when called.
	 */
	@:noCompletion
	public static var destroySS:Bool = false;

	/**
	 * Global render count, used for capacity check.
	 */
	@:noCompletion
	public static var rendered:Int = 0;

	/**
	 * The limit for the capacity (which also means how many can it render total).
	 */
	@:noCompletion
	public static var capacity(default, null):Int = 0;

	/**
	 * This flips everytime it gets to the debug renders.
	 */
	@:noCompletion
	public static var renderDebug(default, null):Bool = false;

	static function renderSprite(state:CitroState, delta:Int) {
		for (member in state.members) {
			if (member.isDestroyed) {
				state.members.remove(member);
				continue;
			}

			if (rendered > capacity) {
				break;
			}

			if (member.y < 240) {
				untyped __cpp__("C2D_SceneBegin(member->render->index == 1 ? bottomScreen : topScreen)");
				member.update(delta);
			}

			if (member.render == BOTH && member.y + (member.height * member.scale.y) > 240) {
				untyped __cpp__("C2D_SceneBegin(bottomScreen)");
				member.x -= 39.8;
				member.y -= 240;
				member.update(delta);
				member.x += 39.8;
				member.y += 240;
			}
		}
	}
	
	/**
	 * Initializes CitroEngine and brings back your games into the 3DS!
	 * @param state Current state to use as.
	 * @param settings The current settings for Citro Engine to use.
	 */
	public static function init(state:CitroState, settings:Null<CitroSettings> = null) {
		if (settings == null) {
			settings = {
				skipIntro: false,
				capacityLimit: 400
			};
		}

		capacity = settings.capacityLimit;
		CitroG.state = state;
		subState = null;

		if (!settings.skipIntro) {
			oldCS = CitroG.state;
			CitroG.state = new citro.startup.CitroStartup();
		}

		untyped __cpp__('
			C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
			C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
			C2D_Prepare();
			srand(time(NULL));

			topScreen = C2D_CreateScreenTarget(GFX_TOP,	GFX_LEFT);
			bottomScreen = C2D_CreateScreenTarget(GFX_BOTTOM, GFX_LEFT)
		');

		!CitroG.isNotNull(CitroG.state) ? {
			shouldQuit = true;

			var error = new Error(TEXT_WORD_WRAP, English);
			error.homeButton = false;
			error.text = "Citro Engine Error (#1)\n\nCitroG.state is null instead of an actual CitroState, this will now close this program.";
			error.display();
		} : CitroG.state.create();
		
		var deltaTime:Int = 16;
		while (APT.mainLoop() && !shouldQuit) {
			final old:UInt64 = OS.time;
			rendered = 0;

			if (destroySS) {
				subState = null;
				destroySS = false;
			}

			untyped __cpp__('
				C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
				C2D_TargetClear(topScreen, 0xFF000000);
				C2D_TargetClear(bottomScreen, 0xFF000000)
			');
			
			CitroTween.update(deltaTime);
			CitroTimer.update(deltaTime);
			
			final s:Bool = CitroG.isNotNull(subState);
			renderSprite(CitroG.state, deltaTime);
			if (s) renderSprite(subState, deltaTime);
			(s ? subState : CitroG.state).update(deltaTime);

			// Shift first, then update!
			renderDebug = true;
			untyped __cpp__("C2D_SceneBegin(topScreen)");
			while (debugTexts.length > 22) debugTexts.shift();
			for (i => text in debugTexts) {
				text.y = 10.82 * i;
				text.update(deltaTime);
			}
			renderDebug = false;

			untyped __cpp__('C3D_FrameEnd(0)');
			deltaTime = OS.time - old;
		}

		CitroG.sound.clean();

		untyped __cpp__('
			C3D_Fini();
			C2D_Fini();
			Mix_CloseAudio();
			Mix_Quit();
			SDL_Quit()
		');
	}
}