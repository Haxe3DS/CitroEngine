#pragma once

#include <deque>
#include <memory>
#include "_HaxeUtils.h"
#include "citro_object_CitroObject.h"

namespace citro::state {
    class CitroSubState;
}

namespace citro::state {

class CitroState {
public:
    std::shared_ptr<std::deque<std::shared_ptr<citro::object::CitroObject>>> members;
    virtual ~CitroState() {}

    CitroState();
    virtual void create();
    virtual void update(int delta);
    virtual void destroy();
    virtual bool check(std::shared_ptr<citro::object::CitroObject> member);
    virtual void add(std::shared_ptr<citro::object::CitroObject> member);
    virtual void insert(int index, std::shared_ptr<citro::object::CitroObject> member);
    virtual void remove(std::shared_ptr<citro::object::CitroObject> member);
    virtual void openSubstate(std::shared_ptr<citro::state::CitroSubState> substate);

    HX_COMPARISON_OPERATORS(CitroState)
};

}