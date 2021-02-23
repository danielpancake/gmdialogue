/// @description Text speed controller
if (textspeeds.options[0] != -1) {
	if (char_count >= textspeeds.options[0]) {
		var ts = textspeeds.values[textspeeds.options[1]][0];
		textspeeds.current_value = (ts < 0) ? msg_length : ts;
		
		if (textspeeds.options[1] < textspeeds.size - 1) {
			textspeeds.options[0] = textspeeds.values[++textspeeds.values[1]][1];
			char_limit = textspeeds.options[0];
		} else {
			textspeeds.options[0] = -1;
			char_limit = msg_length;
		}
	}
}

// Punctuation delays
var lookahead = char_array_pos_any(msg_chars, floor(char_count), textspeeds.current_value, break_characters, true);
var char_sublimit = char_limit;
if (lookahead != -1) {
	switch (lookahead[1]) {
		case "!":
		case "?":
		case ".":
			alarm[0] = max(50 / textspeeds.current_value, 15);
		break;
		
		case ";":
		case ":":
		case ",":
			alarm[0] = max(20 / textspeeds.current_value, 15);
		break;
	}
	
	dialogue_is_paused = true;
	char_sublimit = lookahead[0] + 1;
}

char_count = clamp(char_count + textspeeds.current_value, 0, min(char_limit, char_sublimit));
event_user(2);