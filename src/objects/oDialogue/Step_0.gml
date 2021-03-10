/// @description Input handling and processing
if (char_count == msg_length) {
	
	// Autoprocessing
	if (autoprocess_enabled && !autoprocess && alarm[1] == -1) {
		alarm[1] = autoprocess_delay;
	}
	
	if (autoprocess || keyboard_check_pressed(vk_enter)) {
		if (question_asked) { // Dialogue stack pushing
			dialogue = question_answers[options_cursor];
			ds_stack_push(dialogue_stack, [stack_index[0], msg_current, stack_option]);
			stack_index[0] = stack_index[1];
			stack_option = options_cursor;
			msg_current = 0;
		}
		
		event_user(0); // Parsing next message
	}
	
	// Options selection
	if (keyboard_check_pressed(vk_up)) {
		if (options_cursor > 0) {
			options_cursor--;
		} else {
			options_cursor = options_count - 1;
		}
	}
	
	if (keyboard_check_pressed(vk_down)) {
		if (options_cursor < options_count - 1) {
			options_cursor++;
		} else {
			options_cursor = 0;
		}
	}
}

// Completion output of the current message
if (skip_enabled && keyboard_check_pressed(vk_shift)) {
	var count = delays.options[1];
	show_debug_message(count);
	var delay = msg_length;
	
	if (delays.options[0] != -1 && count < delays.size) {
		if (delays.values[count][2]) {
			delay = delays.values[count][1];
		}
	}
	
	char_count = delay;
	event_user(2); // Triggering sprites and images to change
}

// Textspeed controller
if (!dialogue_is_paused) {
	if (char_count < msg_length) { event_user(1); }
}

// Sin cycle
_sin = (_sin + 4) % 360;