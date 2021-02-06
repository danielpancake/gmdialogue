/// @description Parsing message
msg_end = array_length(dialogue);

// Check for the last message
if (msg_current >= msg_end) {
	if (ds_stack_size(dialogue_stack) > 0) {
		var pop = ds_stack_pop(dialogue_stack);
		if (pop[0] == -1) {
			dialogue = messages;
		} else {
			dialogue = questions[pop[0]][1][pop[2]];
		}
		msg_current = pop[1];
			
		event_user(0);
		exit;
	}
	
	instance_destroy();
	exit;
}

msg = dialogue[msg_current];
msg_length = string_length(msg);

// Skip all empty messages
if (msg_length == 0) {
	msg_current++;
	event_user(0);
	exit;
}

// A bunch of variables
autoprocess = false;
autoprocess_delay = 0;
autoprocess_enabled = false;
dialogue_is_paused = false;

var questions_count = array_length(questions);
question_asked = false;
question_options = [];
question_answers = [];
options_count = 0;
options_cursor = 0;

var breaks = 0;
var tspeed = 1;

colours = [];
colours_max = 0;
effects = [];
effects_max = 0;
textspeed = [];

// Parse dialogue commands
for (var i = 1; i <= msg_length; i++) {
	var char = string_char_at(msg, i);
	
	if (char == "[") {
		var command_valid = false;
		var command_length = string_pos("]", string_copy(msg, i, msg_length - i + 1)) - 2;
		// Temporary variable, will be split and removed
		var _command = string_copy(msg, i + 1, command_length);
		
		var values_count = string_count(":", _command);
		var values = array_create(values_count, -1);
		for (var j = 0; j <= values_count; j++) {
			var colon_pos = string_pos(":", _command);
			if (colon_pos == 0) {
				values[j] = _command;
				break;
			} else {
				values[j] = string_copy(_command, 1, colon_pos - 1);
			}
			_command = string_delete(_command, 1, colon_pos);
		}
		
		// Execute commands
		switch (values[0]) {
			case "#": // Reference
				// Exists only for linking messages
				command_valid = true;
			break;
			
			case "auto": // Autoprocess
				var delay = string_digits(values[1]);
				autoprocess_delay = delay == "" ? -1 : real(delay);
				autoprocess_enabled = true;
				command_valid = true;
			break;
			
			case "c":
			case "col":
			case "color":
			case "colour": // Sets text colour
				var colour;
				
				if (values_count == 4) { // Parging rgb / hsv colour
					colour = make_colour_unsafe_strings(values[1], values[2], values[3], values[4]);
					command_valid = true;
				} else { // Picking predefined colour
					colour = global.mapcolour[? values[1]];
					if (is_undefined(colour)) colour = c_white;
					command_valid = true;
				}
				
				if (command_valid) {
					array_push(colours, colour << 32 | (i - breaks));	
					colours_max++;
				}
			break;
			
			case "e":
			case "eff":
			case "effect": // Sets text effect
				var effect = global.mapeffect[? values[1]];
				if (is_undefined(effect)) effect = 0;
				array_push(effects, effect << 32 | (i - breaks));
				effects_max++;
				command_valid = true;
			break;
			
			case "gotoref": // Goes to the specified line in the dialogue
							// Notice, that this command will clear dialogue stack!
				var gotoref_dialogue = asset_get_index(values[1]);
				var gotoref_number = values[2];
				
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
							
							if (ref_number == gotoref_number) {
								ds_stack_clear(dialogue_stack);
								dialogue_open_at(gotoref_dialogue, [], k);
								exit;
							}
						}
					}
						
					// If reference isn't found, dialogue ends
					instance_destroy();
				}
			break;
			
			case "l":
			case "layout": // Sets layout
				var layout = global.maplayout[? values[1]];
				if (!is_undefined(layout)) dialogue_set_layout(layout);
				command_valid = true;
			break;
			
			case "o":
			case "open": // Opens specified dialogue
						 // Notice, that this command will clear dialogue stack!
				var open_dialogue = asset_get_index(values[1]);
				if (open_dialogue != -1) {
					ds_stack_clear(dialogue_stack);
					dialogue_open(open_dialogue, []);
					exit;
				}
				command_valid = true;
			break;
			
			case "ts": // Sets text speed
				tspeed = global.mapspeed[? values[1]];
				if (is_undefined(tspeed)) tspeed = 1;
				command_valid = true;
			break;
			
			case "q":
			case "question": // Asks the question
				var index = real(values[1]);
				if (index >= 0 && index < questions_count) {
					var question = questions[index];
					question_options = question[0];
					question_answers = question[1];
					options_count = array_length(question_options)
					if (array_length(question_answers) > 0 && options_count > 0) {
						question_asked = true;
						stack_index[1] = index;
						command_valid = true;
					}
				}
			break;
		}
		
		if (command_valid) {
			msg = string_delete(msg, i, command_length + 2);
			msg_length -= command_length + 2;
			// Once again skip empty message
			if (msg_length == 0) {
				msg_current++;
				event_user(0);
				exit;
			}
			
			i--;
			continue;
		}
	}
	
	if (char != "#") {
		textspeed[i - breaks - 1] = tspeed;
	} else {
		breaks++;
	}
}

// Add default colour
if (colours_max == 0) {
	colours = [default_colour << 32];
	colours_max = 1;
}

// Add default effect
if (effects_max == 0) {
	effects = [0];
	effects_max = 1;
}

// Word wrapping algorithm
var line_width = 0;
var line_maxwidth = textbox_width - textbox_hpadding * 2;

if (question_asked) {
	line_maxwidth -= textbox_options_width + textbox_hpadding / 2;	
}

draw_set_font(dialogue_font);
for (var i = 1; i <= msg_length; i++) {
	var char = string_char_at(msg, i);
	
	var word_width = 0;
	var word_wrap = i;
	
	while (word_wrap <= msg_length) {
		word_width += string_width(char);
		if (char == "#") word_width = 0;
		if (char == " " || word_width > line_maxwidth) break;
		char = string_char_at(msg, ++word_wrap);
	}
	
	if (line_width + word_width > line_maxwidth) {
		if (line_width == 0) {
			msg = string_insert("#", msg, word_wrap);
			msg_length++;
		} else {
			msg = string_delete(msg, i - 1, 1);
			msg = string_insert("#", msg, i - 1);
			line_width = word_width;
		}
	} else {
		line_width += word_width;	
	}
	
	i = word_wrap;
}

// Set first character's speed
var ts = textspeed[0];
if (ts <= 0) {
	char_count = msg_length;
} else {
	char_count = ts;
}

msg_current++;