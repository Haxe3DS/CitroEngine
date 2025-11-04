package citro.state;

import citro.backend.CitroCamera;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.object.CitroText;
import citro.object.CitroObject;
import haxe.Timer;

@:cppInclude("citro_CitroInit.h")
@:cppInclude("citro2d.h")

/**
 * States used for creating states and for whatever sprites to behave as.
 */
class CitroState {
    /**
     * Lists of members currently added in this state.
     */
    public var members:Array<CitroObject> = [];

    /**
     * Constructor for creating this state.
     */
    public function new() {};

    /**
     * Constructor called when state is ready to be created.
     */
    public function create() {};

    /**
     * Constructor called when state's frame has been passed.
     * 
     * @param delta Delta Time in MS.
     */
    public function update(delta:Int) {}

    /**
     * Constructor called when state has been switched.
     * 
     * ## DO NOT CALL THIS CONSTRUCTOR.
     */
    public function destroy() {
        for (member in members) {
            member.destroy();
        }

        members = [];
    }

    function check(member:CitroObject):Bool {
        if (member == null)
            return true;

        if (members.indexOf(member) > -1)
            return true;

        return false;
    }

    /**
     * Adds a CitroObject to game and displays it every frame.
     * @param member An object to add as.
     */
    public function add(member:CitroObject) {
        if (check(member))
            return;

        final index:Int = members.indexOf(null);
        if (index != -1) {
            members[index] = member;
            return;
        }

        members.push(member);
    }

    /**
     * Inserts a CitroObject to a layer index specified.
     * @param index Layer number to insert from.
     * @param member An object to insert as.
     */
    public function insert(index:Int, member:CitroObject) {
        if (check(member))
            return;

        if (index < members.length && members[index] == null) {
            members[index] = member;
            return;
        }

        members.insert(index, member);
    }

    /**
     * Removes a sprite from member lists.
     * @param member Member to remove from list.
     */
    public function remove(member:CitroObject) {
        var i:Int = members.length-1;
        while (i != -1) {
            if (members[i] == member) {
                members.splice(i, 1);
            }
            i--;
        }
    }

    /**
     * Opens a new substate and pauses this current state.
     * Note: If currently in a substate, ignore this 
     * @param substate Substate to use.
     */
    public function openSubstate(substate:CitroSubState) {
        if (CitroG.isNotNull(CitroInit.subState)) {
            return;
        }
        
        CitroInit.subState = substate;
        substate.create();
    }
}