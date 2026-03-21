package citro.state;

import citro.object.CitroObject;

/**
 * State for Handling What this state should do, Like for Adding Sprites, Checking Members, and More.
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

		members.splice(0, members.length);
	}

	function check(member:CitroObject):Bool {
		if (member == null) return true;
		if (members.indexOf(member) > -1) return true;
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
	 * @param once Only do the action once?
	 */
	public function remove(member:CitroObject, once:Bool = true) {
		while (members.remove(member) && once) {}
	}

	/**
	 * Opens a new substate and pauses this current state.
	 * Note: If currently in a substate, ignore this 
	 * @param substate Substate to use.
	 */
	public function openSubstate(substate:CitroSubState) {
		if (CitroG.substate != null) {
			return;
		}
		
		CitroG.substate = substate;
		substate.create();
	}
}