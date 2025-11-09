package citro.backend;

import cxx.VoidPtr;
import citro.math.CitroMath;
import citro.object.CitroObject;

enum abstract CitroObjVar(Int) {
	var X;
	var Y;
	var WIDTH;
	var HEIGHT;
	var ANGLE;
	var ALPHA;
	var SCALE_X;
	var SCALE_Y;
}

enum abstract CitroEase(Int) {
	var LINEAR;
	var SINE_IN;
	var SINE_OUT;
	var SINE_INOUT;
	var QUAD_IN;
	var QUAD_OUT;
	var QUAD_INOUT;
	var CUBE_IN;
	var CUBE_OUT;
	var CUBE_INOUT;
	var QUART_IN;
	var QUART_OUT;
	var QUART_INOUT;
	var QUINT_IN;
	var QUINT_OUT;
	var QUINT_INOUT;
	var SMOOTHSTEP_IN;
	var SMOOTHSTEP_OUT;
	var SMOOTHSTEP_INOUT;
	var SMOOTHERSTEP_IN;
	var SMOOTHERSTEP_OUT;
	var SMOOTHERSTEP_INOUT;
	var BOUNCE_IN;
	var BOUNCE_OUT;
	var BOUNCE_INOUT;
	var CIRC_IN;
	var CIRC_OUT;
	var CIRC_INOUT;
	var EXPO_IN;
	var EXPO_OUT;
	var EXPO_INOUT;
	var BACK_IN;
	var BACK_OUT;
	var BACK_INOUT;
	var ELASTIC_IN;
	var ELASTIC_OUT;
	var ELASTIC_INOUT;
}

enum CTTypes {
	OBJECT;
	VARIABLE;
}

private typedef CitroTweenProps = {
	/**
	 * Common variable to use from CitroObject
	 * 
	 * @see enum abstract CitroEase
	 */
	var variableToUse:CitroObjVar;

	/**
	 * The destination for the float number to use.
	 */
	var destination:Float;

	/**
	 * Should not be used.
	 */
	var ?oldVar:Float;
}

typedef CitroTweenOptions = {
	/**
	 * The style of ease to use as.
	 */
	var ?ease:CitroEase;

	/**
	 * Callback function for tween completion.
	 */
	var ?onComplete:Void->Void;

	/**
	 * Callback function per frame called, if it's by a number then it returns the number, else returns as a percentage (0 - 1).
	 */
	var ?onUpdate:Float->Void;
}

private typedef CitroTweenArray = {
	variable:CitroObject,
	props:Array<CitroTweenProps>,
	length:Float,
	elapsed:Float,
	isState:Bool,
	tweenType:CTTypes,
	options:CitroTweenOptions
}

/**
 * Class for doing tweens and such.
 */
@:cppFileCode('
#include <3ds.h>
#include "citro_CitroInit.h"

template<typename T>
bool functionIsValid(const std::optional<T>& func) {
	return func.has_value() && static_cast<bool>(func.value());
}
')
class CitroTween {
	public static var cta:Array<CitroTweenArray> = [];

	static function hasValue(self:VoidPtr):Bool
		return untyped __cpp__('{0}', self);

	static function setupOptions(input:Null<CitroTweenOptions>):CitroTweenOptions {
		if (!hasValue(untyped __cpp__('(void*&)({0})', input))) {
			return {
				ease: LINEAR,
				onComplete: () -> {},
				onUpdate: _ -> {}
			};
		}
		
		if (!untyped __cpp__('(input.has_value() ? input.value() : std::make_shared<citro::backend::CitroTweenOptions>())->ease.has_value()')) input.ease = LINEAR;
		if (!untyped __cpp__('functionIsValid({0})', input.onComplete)) input.onComplete = () -> {};
		if (!untyped __cpp__('functionIsValid({0})', input.onUpdate)) input.onUpdate = _ -> {};
		return input;
	}

	/**
	 * Creates and starts a new tween from number to number.
	 * @param from Starting number.
	 * @param to Ending number.
	 * @param duration How long in seconds do you want it to tween for?
	 * @param options The current options to set up for the tween, can be null for default settings.
	 */
	public static function tweenNumber(from:Float, to:Float, duration:Float = 1, options:Null<CitroTweenOptions> = null):Bool {
		return cta.push({
			variable: null,
			props: [{
				variableToUse: X,
				destination: to,
				oldVar: from
			}],
			elapsed: 0,
			length: duration * 1000,
			isState: !CitroG.isNotNull(CitroInit.subState),
			tweenType: VARIABLE,
			options: setupOptions(options)
		}) != 0;
	}

	/**
	 * Creates and starts a new tween from object.
	 * @param object Object to use as.
	 * @param props A mapper for the properties to use for this object.
	 * @param duration How long in seconds do you want it to tween for?
	 * @param options The current options to set up for the tween, can be null for default settings.
	 */
	public static function tweenObject(object:CitroObject, props:Map<CitroObjVar, Float>, duration:Float = 1, options:Null<CitroTweenOptions> = null):Bool {
		final propStates:Array<CitroTweenProps> = [for (prop in props.keys()) {
			variableToUse: prop,
			destination: props[prop],
			oldVar: switch (prop) {
				case X: object.x;
				case Y: object.y;
				case WIDTH: object.width;
				case HEIGHT: object.height;
				case ANGLE: object.angle;
				case ALPHA: object.alpha;
				case SCALE_X: object.scale.x;
				case SCALE_Y: object.scale.y;
			}
		}];

		if (propStates.length == 0)
			return false;

		return cta.push({
			variable: object,
			props: propStates,
			elapsed: 0,
			length: duration * 1000,
			isState: !CitroG.isNotNull(CitroInit.subState),
			tweenType: OBJECT,
			options: setupOptions(options)
		}) != 0;
	}

	/**
	 * Updates all tweens, should not be used.
	 * @param delta Time since last frame in milliseconds.
	 */
	public static function update(delta:Int) {
		for (spr in cta) {
			if (spr.isState == hasValue(untyped __cpp__('(void*&)({0})', CitroInit.subState)))
				continue;

			spr.elapsed += delta;
			final progress:Float = CitroMath.clamp(spr.elapsed / spr.length, 0, 1);

			var useVar:Float = progress;
			for (prop in spr.props) {
				final res:Float = CitroMath.lerp(prop.oldVar, prop.destination, applyEase(spr.options.ease, progress));
				switch (spr.tweenType) {
					case OBJECT:
						switch(prop.variableToUse) {
							case ALPHA: spr.variable.alpha = res;
							case ANGLE: spr.variable.angle = res;
							case HEIGHT: spr.variable.height = res;
							case SCALE_X: spr.variable.scale.x = res;
							case SCALE_Y: spr.variable.scale.y = res;
							case WIDTH: spr.variable.width = res;
							case X: spr.variable.x = res;
							case Y: spr.variable.y = res;
						}
					
					case VARIABLE:
						useVar = res;
				}
			}

			if (progress >= 1) {
				spr.options.onComplete();
				cta.remove(spr);
			}
			
			spr.options.onUpdate(useVar);
		}
	}

	/**
	 * Cancels any tweens provided from the object argument.
	 * @param object Object to cancel tweens.
	 */
	public static function cancelTweensFrom(object:CitroObject) {
		for (s in cta)
			if (s.variable == object)
				cta.remove(s);
	}

	static function smoothStepInOut(t:Float):Float {
		return t * t * (t * -2 + 3);
	}

	static function smootherStepInOut(t:Float):Float {
		return t * t * t * (t * (t * 6 - 15) + 10);
	}

	static final B3:Float = 1.5 / 2.75;
	static final B5:Float = 2.25 / 2.75;
	static final B6:Float = 2.625 / 2.75;

	static function bounceOut(t:Float):Float {
		if (t < 1 / 2.75) return 7.5625 * t * t;
		if (t < 2 / 2.75) return 7.5625 * (t - B3) * (t - B3) + .75;
		if (t < 2.5 / 2.75) return 7.5625 * (t - B5) * (t - B5) + .9375;
		return 7.5625 * (t - B6) * (t - B6) + .984375;
	}

	static function backInOut(t:Float):Float {
		t *= 2;
		if (t < 1) return t * t * (2.70158 * t - 1.70158) / 2;
		t--;
		return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
	}

	static function applyEase(ease:CitroEase, t:Float):Float {
		return switch(ease) {
			case LINEAR: t;

			case SINE_IN: 1 - Math.cos((t * Math.PI) / 2);
			case SINE_OUT: Math.sin((t * Math.PI) / 2);
			case SINE_INOUT: -(Math.cos(Math.PI * t) - 1) / 2;

			case QUAD_IN: t * t;
			case QUAD_OUT: -t * (t - 2);
			case QUAD_INOUT: t <= .5 ? t * t * 2 : 1 - (t--) * t * 2;

			case CUBE_IN: t * t * t;
			case CUBE_OUT: 1 + (t--) * t * t;
			case CUBE_INOUT: t <= .5 ? t * t * t * 4 : 1 + (t--) * t * t * 4;
			
			case QUART_IN: t * t * t * t;
			case QUART_OUT: 1 - (t -= 1) * t * t * t;
			case QUART_INOUT: t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
			
			case QUINT_IN: t * t * t * t * t;
			case QUINT_OUT: (t = t - 1) * t * t * t * t + 1;
			case QUINT_INOUT: ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
			
			case SMOOTHSTEP_IN: 2 * smoothStepInOut(t / 2);
			case SMOOTHSTEP_OUT: 2 * smoothStepInOut(t / 2 + 0.5) - 1;
			case SMOOTHSTEP_INOUT: smoothStepInOut(t);
			
			case SMOOTHERSTEP_IN: 2 * smootherStepInOut(t / 2);
			case SMOOTHERSTEP_OUT: 2 * smootherStepInOut(t / 2 + 0.5) - 1;
			case SMOOTHERSTEP_INOUT: smootherStepInOut(t);

			case BOUNCE_IN: 1 - bounceOut(1 - t);
			case BOUNCE_OUT: bounceOut(t);
			case BOUNCE_INOUT: t < 0.5 ? (1 - bounceOut(1 - 2 * t)) / 2 : (1 + bounceOut(2 * t - 1)) / 2;
			
			case CIRC_IN: -(Math.sqrt(1 - t * t) - 1);
			case CIRC_OUT: Math.sqrt(1 - (t - 1) * (t - 1));
			case CIRC_INOUT: t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
			
			case EXPO_IN: Math.pow(2, 10 * (t - 1));
			case EXPO_OUT: -Math.pow(2, -10 * t) + 1;
			case EXPO_INOUT: t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
			
			case BACK_IN: t * t * (2.70158 * t - 1.70158);
			case BACK_OUT: 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
			case BACK_INOUT: backInOut(t);
			
			case ELASTIC_IN: -(1 * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - (.4 / (2 * Math.PI) * Math.asin(1 / 1))) * (2 * Math.PI) / .4));
			case ELASTIC_OUT: (1 * Math.pow(2, -10 * t) * Math.sin((t - (.4 / (2 * Math.PI) * Math.asin(1 / 1))) * (2 * Math.PI) / .4) + 1);
			case ELASTIC_INOUT: t < 0.5 ? -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (.4 / 4)) * (2 * Math.PI) / .4)) : Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (.4 / 4)) * (2 * Math.PI) / .4) * 0.5 + 1;
			
			default: t;
		}
	}
}