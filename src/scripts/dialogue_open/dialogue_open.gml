/// @function dialogue_open_at(index, [arg1,arg2,...], position)
/// @argument {number} index Asset index of the script containing the dialogue
/// @argument {array} arguments Arguments to execute dialogue script with
/// @argument {number} position The index of the first message in the dialogue
function dialogue_open_at(index, arguments, position){
	if (!global.dialogue_is_open) {
		instance_create_depth(0, 0, 0, oDialogue);
	}
	
	with (oDialogue) {
		questions = [];
		script_execute_ext(index, arguments);
		
		dialogue = messages;
		stack_index = [-1, -1];
		stack_option = 0;
		
		msg_current = position;
		event_user(0);
	}
}

/// @function dialogue_open(index, [arg1,arg2,...])
/// @argument {number} index Asset index of the script containing the dialogue
/// @argument {array} arguments Arguments to execute dialogue script with
function dialogue_open(index, arguments){
	dialogue_open_at(index, arguments, 0);
}