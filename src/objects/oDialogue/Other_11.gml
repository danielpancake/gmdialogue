/// @description Text speed controller
if (textspeed_pos != -1) {
	if (char_count >= textspeed_pos) {
		var ts = textspeeds[textspeed_cursor][0];
		textspeed = (ts < 0) ? msg_length : ts;
		
		if (textspeed_cursor < textspeeds_max - 1) {
			textspeed_pos = textspeeds[++textspeed_cursor][1];
			char_limit = textspeed_pos;
		} else {
			textspeed_pos = -1;
			char_limit = msg_length;
		}
	}
}

// Punctuation delays
var lookahead = char_array_pos_any(msg_chars, floor(char_count), textspeed, break_characters, true);
var char_sublimit = char_limit;
if (lookahead != -1) {
	switch (lookahead[1]) {
		case "!":
		case "?":
		case ".":
			alarm[0] = max(50 / textspeed, 15);
		break;
		
		case ";":
		case ":":
		case ",":
			alarm[0] = max(20 / textspeed, 15);
		break;
	}
	
	dialogue_is_paused = true;
	char_sublimit = lookahead[0] + 1;
}

char_count = clamp(char_count + textspeed, 0, min(char_limit, char_sublimit));

// Changing sprites and images
dialogue_values_changer(sprites, sprite_options, char_count, sprites_max, dialogue_change_sprite, -1);
dialogue_values_changer(images, image_options, char_count, images_max, dialogue_change_image, -1);