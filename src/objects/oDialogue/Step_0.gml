/// @description Input handler and processing
if (char_count == msg_length) {
	// Autoprocessing
	if (autoprocess_enabled && !autoprocess && alarm[1] == -1) {
		alarm[1] = autoprocess_delay;
	}
	
	// Go to next message
	if (autoprocess || keyboard_check_pressed(vk_enter)) {
		if (question_asked) {
			messages = question_answers[options_cursor];
			msg_current = 0;
			event_user(0);
		} else if (msg_current < msg_end) {
			event_user(0);
		} else {
			instance_destroy();	
		}
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