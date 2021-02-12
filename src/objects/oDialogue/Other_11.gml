/// @description Text speed controller
var limit = msg_length;
if (textspeed_pos != -1) {
	limit = textspeed_pos;
	
	if (char_count >= textspeed_pos) {
		var ts = textspeed[textspeed_cursor][0];
		if (ts < 0) {
			tspeed = msg_length;
		} else {
			tspeed = ts;
		}
		
		if (textspeed_cursor < textspeed_max - 1) {
			textspeed_pos = textspeed[++textspeed_cursor][1];
		} else {
			textspeed_pos = -1;
		}
	}
}

// Punctuation delays
var lookahead = char_array_pos_any(msg_chars, floor(char_count), tspeed, break_characters, true);
if (lookahead != -1) {
	switch (lookahead[1]) {
		case "!":
		case "?":
		case ".":
			alarm[0] = max(50 / tspeed, 15);
		break;
		
		case ";":
		case ":":
		case ",":
			alarm[0] = max(20 / tspeed, 15);
		break;
	}
	
	limit = lookahead[0] + 1;
	dialogue_is_paused = true;
}

char_count = clamp(char_count + tspeed, 0, limit);