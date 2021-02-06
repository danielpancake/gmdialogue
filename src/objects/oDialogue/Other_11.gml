/// @description Next character and delays
var breaks = string_count("#", string_copy(msg, 1, char_count - 1));
var ts = textspeed[char_count - breaks - 1];
if (ts <= 0) {
	char_count = msg_length;
} else {
	var lookahead = string_copy(msg, char_count + 1, ceil(ts));
	var char = string_pos_any(["!", "?", ".", ";", ":", ","], lookahead);
	var val = char[0];
	
	if (char[0] != 0) {
		switch (char[1]) {
			case "!":
			case "?":
			case ".":
				alarm[0] = 50 / ts;
			break;
			
			case ";":
			case ":":
			case ",":
				alarm[0] = 20 / ts;
			break;
		}
		
		dialogue_is_paused = true;
	} else {
		val = ts;
	}
	
	char_count = min(msg_length, char_count + val);
}