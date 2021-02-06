/// @function dialogue_open_at(index, [arg1,arg2,...], position)
/// @argument {real} index
/// @argument {array} arguments
/// @argument {real} position
function dialogue_open_at(index, arguments, position){
	if (!global.dialogue_is_open) {
		instance_create_depth(0, 0, 0, oDialogue);
	}
	
	with (oDialogue) {
		dialogue_index = index;
		dialogue_arguments = arguments;
		
		msg_current = position;
		script_execute_ext(index, arguments);
		event_user(0);
	}
}

/// @function dialogue_open(index, [arg1,arg2,...])
/// @argument {real} index
/// @argument {array} arguments
function dialogue_open(index, arguments){
	dialogue_open_at(index, arguments, 0);
}