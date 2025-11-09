#include "haxe_Log.h"

#include <deque>
#include <string>
#include "cxx_DynamicToString.h"
#include "haxe_NativeStackTrace.h"
#include "haxe_PosInfos.h"

#include "citro_object_CitroText.h"
#include "citro_CitroInit.h"

using namespace std::string_literals;

std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](haxe::DynamicToString v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	std::shared_ptr<citro::object::CitroText> text = std::make_shared<citro::object::CitroText>((double)(1), (double)(0), haxe::Log::formatOutput(v, infos));
	text->scale->set(0.4, 0.4);
	citro::CitroInit::debugTexts->push_back(text);
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!infos.has_value()) return v;

	std::string pstr = infos.value_or(nullptr)->fileName + ":"s + std::to_string(infos.value_or(nullptr)->lineNumber);
	std::string extra = ""s;
	if(infos.value_or(nullptr)->customParams.has_value()) {
		std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> _g1 = infos.value_or(nullptr)->customParams;
		for (int _g = 0; _g < (int)(_g1.value_or(nullptr)->size()); _g++) extra += ", "s + (*_g1.value())[_g];
	}

	return pstr + ": "s + v + extra;
}
