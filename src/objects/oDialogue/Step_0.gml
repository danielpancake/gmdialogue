/// @description Input handler
if (char_count == msg_length) {
	if (keyboard_check_pressed(vk_enter)) {
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

_sin = (_sin + 4) % 360;