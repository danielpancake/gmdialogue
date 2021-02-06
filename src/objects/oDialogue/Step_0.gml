/// @description Input handler and processing
if (char_count == msg_length) {
	// Autoprocessing
	if (autoprocess_enabled && !autoprocess && alarm[1] == -1) {
		alarm[1] = autoprocess_delay;
	}
	
	// Go to next message
	if (autoprocess || keyboard_check_pressed(vk_enter)) {
		if (question_asked) {
			dialogue = question_answers[options_cursor];
			ds_stack_push(dialogue_stack, [stack_index[0], msg_current, stack_option]);
			stack_index[0] = stack_index[1];
			stack_option = options_cursor;
			msg_current = 0;	
		}
		
		event_user(0);
	}
	
	// Option selection
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

// Skip message
if (keyboard_check_pressed(vk_shift)) {
	char_count = msg_length;
}

// Next character
if (!dialogue_is_paused) {
	if (char_count < msg_length) {
		event_user(1);
	}
}

// Sin cycle
_sin = (_sin + 4) % 360;