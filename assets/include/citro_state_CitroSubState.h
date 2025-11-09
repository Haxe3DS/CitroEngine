#pragma once

#include <cstdint>
#include <memory>
#include "_HaxeUtils.h"
#include "citro_object_CitroObject.h"
#include "citro_state_CitroState.h"

namespace citro::state {

class CitroSubState: public CitroState {
public:
	virtual ~CitroSubState() {}

	CitroSubState(uint32_t color = 0);
	void destroy();
	void close();
	void add(std::shared_ptr<citro::object::CitroObject> member);
	virtual void create();
	void insert(int index, std::shared_ptr<citro::object::CitroObject> member);
	void openSubstate(std::shared_ptr<citro::state::CitroSubState> substate);
	virtual void update(int delta);

	HX_COMPARISON_OPERATORS(CitroSubState)
};

}