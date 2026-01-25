package citro.backend;

import haxe3ds.OS;

private typedef TimerMetadata = {
	targetTime:Int,
	osTime:Int,
	onComplete:Void->Void,
	loopsLeft:Int,
	ranInState:Bool
}

/**
 * Class for timer handlers and for callbacks.
 */
class CitroTimer {
	static var timers:Array<TimerMetadata> = [];

	/**
	 * Creates a new timer specified from arguments provided.
	 * 
	 * Note:
	 * - If you use a small number, it will not run as per say 0.01 seconds, it triggers per frame.
	 * 
	 * @param seconds The current total of seconds to use.
	 * @param onComplete Callback function to use.
	 * @param loops How many loops do you wanna use? 0 or less for Infinite.
	 */
	public static function start(seconds:Float, onComplete:Void->Void, loops:Int = -1) {
		timers.push({
			targetTime: Std.int(seconds * 1000),
			osTime: OS.time.toInt(),
			onComplete: onComplete,
			loopsLeft: loops < 1 ? -1 : Std.int(Math.abs(loops)),
			ranInState: CitroG.substate == null
		});
	}

	/**
	 * Should not be used.
	 */
	public static function update() {
		if (timers.length == 0) {
			return;
		}

		final osTime:Int = OS.time.toInt();
		for (timer in timers) {
			if (timer.ranInState == (CitroG.substate != null)) {
				continue;
			}

			if (osTime >= timer.osTime + timer.targetTime) {
				timer.onComplete();
				timer.osTime += timer.targetTime;

				if (timer.loopsLeft != -1) {
					if (timer.loopsLeft < 1) {
						timers.remove(timer);
						continue;
					}

					timer.loopsLeft--;
				}
			}
		}
	}

	/**
	 * Reset the entire array for timers.
	 */
	public static function reset() {
		timers = [];
	}
}