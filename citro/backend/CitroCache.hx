package citro.backend;

import citro.CitroG.VoidPtr;

@:cppFileCode('
#include <citro2d.h>
void SUPER_FREE(void **ptr2ptr) {
	if (ptr2ptr && *ptr2ptr) {
		free(*ptr2ptr);
		*ptr2ptr = NULL;
	}
}')
class CitroCache {
	public var cache:Map<String, VoidPtr> = [];

	public function new() {}

	public function get(path:String):VoidPtr {
		if (cache.exists(path)) {
			return cache[path];
		}
		return null;
	}

	public function set(path:String, ptr:VoidPtr) {
		if (cache.exists(path)) {
			var _ptr = cache[path];
			if (ptr == _ptr) {
				return;
			}
			freeMemory(path);
		}
		cache[path] = ptr;
	}

	public function remove(path:String) {
		if (cache.exists(path)) {
			freeMemory(path);
			cache.remove(path);
		}
	}

	public function keyValueIterator() {
		return cache.keyValueIterator();
	}

	function freeMemory(key:String) {
		final ptr = cache[key];
		untyped __cpp__('if (!{0}) return', ptr);

		var extension = key.split(".");
		switch (extension[extension.length - 1]) {
			case "t3x":
				untyped __cpp__('C2D_SpriteSheetFree((C2D_SpriteSheet)ptr);');
			case "bcfnt":
				untyped __cpp__('C2D_FontFree((C2D_Font)ptr)');
			default:
				untyped __cpp__('SUPER_FREE((void**)&ptr)');
		}
	}

	public function clear() {
		for (key in cache.keys()) {
			freeMemory(key);
		}
		cache.clear();
	}
}