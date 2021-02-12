/// @description Parsing dialogue messages
msg_end = array_length(dialogue);

// Check for the last message in the dialogue
if (msg_current >= msg_end) {
	if (ds_stack_size(dialogue_stack) > 0) {
		var pop = ds_stack_pop(dialogue_stack);
		if (pop[0] == -1) {
			dialogue = messages;
		} else {
			dialogue = questions[pop[0]][1][pop[2]];
		}
		
		msg_current = pop[1];
		event_user(0); exit;
	}
	
	instance_destroy(); exit;
}

// Getting the message
var msg = dialogue[msg_current++];
msg_length = string_length(msg);

if (msg_length == 0) {
	event_user(0); exit;
}

// Splitting the message into character array
msg_chars = string_to_array(msg, msg_length);

var questions_count = array_length(questions);
question_asked = false;
options_count = 0;
options_cursor = 0;

autoprocess = false;
autoprocess_delay = 0;
autoprocess_enabled = false;
dialogue_is_paused = false;

var omitted = 0;
var breaks = 0;

colours = [];
colours_max = 0;

effects = [];
effects_max = 0;

textspeed = [];
textspeed_max = 0;
textspeed_cursor = 0;

char_count = 0;

// Parsing dialogue message
for (var i = 0; i < msg_length; i++) {
	var char = msg_chars[i];
	
	if (char == "[") {
		var command_valid = true;
		var command_length = char_array_pos_range(msg_chars, i + 1, msg_length, "]", false) - i - 1;
		if (command_length <= 0) continue;
		
		var values_count = char_array_count(msg_chars, i + 1, command_length, ":", false) + 1;
		var values = array_create(values_count, -1);
		
		var jj = i + 1;
		for (var j = 0; j < values_count; j++) {
			var colon_pos = char_array_pos_range(msg_chars, jj, i + command_length + 1, ":", false);
			if (colon_pos == -1) {
				values[j] = char_array_string(msg_chars, jj, i + command_length - jj + 1, false);
				break;
			} else {
				values[j] = char_array_string(msg_chars, jj, colon_pos - jj, false);
			}
			jj = colon_pos + 1;
		}
		
		switch (values[0]) {
			case "#": // Reference
				// Only used for linking messages
				command_valid = true;
			break;
			
			case "auto": // Autoproccess
				var delay = string_digits(values[1]);
				autoprocess_delay = delay == "" ? -1 : real(delay);
				autoprocess_enabled = true;
				command_valid = true;
			break;
			
			case "c":
			case "color":
			case "colour": // Text colour
				var colour;
				
				if (values_count == 5) { // Parging rgb / hsv colour
					colour = make_colour_unsafe_strings(values[1], values[2], values[3], values[4]);
					command_valid = true;
				} else { // Picking predefined colour
					colour = global.mapcolour[? values[1]];
					if (is_undefined(colour)) colour = c_white;
					command_valid = true;
				}
				
				if (command_valid) {
					array_push(colours, colour << 32 | (i - breaks - omitted));
					colours_max++;
				}
			break;
			
			case "e":
			case "effect": // Text effect
				var effect = global.mapeffect[? values[1]];
				if (is_undefined(effect)) effect = 0;
				array_push(effects, effect << 32 | (i - breaks - omitted));
				effects_max++;
				command_valid = true;
			break;
			
			// Open dialogue from referenced line
			case "gotoref": // Note that this command will clear dialogue stack!
				if (values_count == 3) {
					var gotoref_dialogue = asset_get_index(values[1]);
					if (gotoref_dialogue != -1) {
						script_execute(gotoref_dialogue);
						
						for (var k = 0; k < array_length(messages); k++) {
							var _msg = messages[k];
							var ref_pos = string_pos("[#", _msg);
							if (ref_pos != 0) {
								var ref_number = real(
									string_copy(_msg, ref_pos + 3,
										string_pos("]", string_copy(_msg, ref_pos, string_length(_msg) - ref_pos + 1)) - 4
									)
								);
								
								if (ref_number == values[2]) {
									ds_stack_clear(dialogue_stack);
									dialogue_open_at(gotoref_dialogue, [], k);
									exit;
								}
							}
						}
						
						instance_destroy(); // If the reference is absent, the dialogue ends
					}
				}
			break;
			
			case "l":
			case "layout": // Dialogue layout
				var layout = global.maplayout[? values[1]];
				if (!is_undefined(layout)) dialogue_set_layout(layout);
				command_valid = true;
			break;
			
			case "o":	 // Open specified dialogue
			case "open": // Note that this command will clear dialogue stack!
				var open_dialogue = asset_get_index(values[1]);
				if (open_dialogue != -1) {
					ds_stack_clear(dialogue_stack);
					dialogue_open(open_dialogue, []);
					exit;
				}
				command_valid = true;
			break;
			
			case "ts": // Text speed
				var ts = global.mapspeed[? values[1]];
				if (is_undefined(ts)) ts = 0;
				array_push(textspeed, [ts, i - breaks - omitted]);
				textspeed_max++;
				command_valid = true;
			break;
			
			case "q":
			case "question": // Show question
			var index = real(values[1]);
				if (index >= 0 && index < questions_count) {
					var question = questions[index];
					question_options = question[0];
					question_answers = question[1];
					options_count = array_length(question_options)
					if (array_length(question_answers) > 0 && options_count > 0) {
						stack_index[1] = index;
						question_asked = true;
						command_valid = true;
					}
				}
			break;
		}
		
		if (command_valid) {
			msg_chars = char_array_replace(msg_chars, i, command_length + 2, "", false);
			omitted += command_length + 2;
			i += command_length + 1;
		}
	} else if (char == "#") {
		breaks++;
	}
}

// Removing all ommited characters
msg_chars = char_array_remove(msg_chars, "");
msg_length -= omitted;

// Word wrapping algorithm
var line_width = 0;
var line_maxwidth = textbox_width - textbox_hpadding * 2;
if (question_asked) {
	line_maxwidth -= textbox_options_width + textbox_hpadding / 2;	
}

draw_set_font(dialogue_font);

for (var i = 0; i < msg_length; i++) {
	var char = msg_chars[i];
	var word_width = 0;
	var word_wrap = i;
	
	while (word_wrap < msg_length) {
		if (char == "#") {
			word_width = 0;
		} else {
			word_width += string_width(char);
		}
		
		if (char == " " || word_width > line_maxwidth) break;
		char = msg_chars[++word_wrap - 1];
	}													
	
	if (line_width + word_width > line_maxwidth) {
		if (line_width == 0) {
			msg_chars = char_array_insert(msg_chars, word_wrap, "#", false);
			msg_length++;
		} else {
			msg_chars[i - 1] = "#";
			line_width = word_width;
		}
	} else {
		line_width += word_width;
	}	
	
	i = word_wrap;
}

// Setting initial textspeed
if (textspeed_max == 0) {
	textspeed_pos = -1;
} else {
	textspeed_pos = textspeed[0][1];
}

tspeed = default_tspeed;
char_count = 0;