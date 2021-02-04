/// @description Parsing message
msg = messages[msg_current];
msg_end = array_length(messages);
msg_length = string_length(msg);

// Skip all empty messages
if (msg_length == 0) {
	msg_current++;
	event_user(0);
	exit;
}

char_count = 1;
dialogue_is_paused = false;

var questions_count = array_length(questions);
question_asked = false;
question_options = [];
question_answers = [];
options_count = 0;
options_cursor = 0;

colours = [];
effects = [];
textspeed = [];

var colour = c_white;
var effect = 0;
var tspeed = 1;

for (var i = 1; i <= msg_length; i++) {
	var char = string_char_at(msg, i);
	
	if (char == "[") {
		var command_valid = false;
		var command_length = string_pos("]", msg) - i - 1;
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
			
			case "c":
			case "col":
			case "color":
			case "colour": // Sets text colour
				colour = global.mapcolour[? values[1]];
				if (is_undefined(colour)) colour = c_white;
				
				command_valid = true;
			break;
			
			case "e":
			case "eff":
			case "effect": // Sets text effect
				effect = global.mapeffect[? values[1]];
				if (is_undefined(effect)) effect = 0;
				
				command_valid = true;
			break;
			
			case "goto": // Opens specified dialogue from the beginning
				var gotoref_dialogue = asset_get_index(values[1]);
				if (gotoref_dialogue != -1) {
					// Prevent infinite recursion
					if !(msg_current == 0 && gotoref_dialogue == dialogue_index) {
						dialogue_open(gotoref_dialogue, []);
						exit;
					}
				}
			break;
			
			case "gotoref": // Goes to the specified line in the dialogue
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
								// Prevent infinite recursion
								if !(msg_current == k && gotoref_dialogue == dialogue_index) {
									dialogue_open_at(gotoref_dialogue, [], k);
									exit;
								}
							}
						}
					}
					
					instance_destroy(); // If reference isn't found, dialogue ends
				}
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
					if (array_length(question_answers) > 0 &&
						options_count > 0) {
						question_asked = true;
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
		array_push(colours, colour);
		array_push(effects, effect);
		array_push(textspeed, tspeed);
	}
}

msg_current++;

// Word wrapping algorithm
var line_width = 0;
var line_maxwidth = dialogue_gui_width - (dialogue_textbox_offset + dialogue_textbox_hpadding) * 2;

if (question_asked) {
	line_maxwidth -= dialogue_options_width + dialogue_textbox_hpadding / 2;	
}

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
			msg_length++;
			
			line_width = word_width;
		}
	} else {
		line_width += word_width;	
	}
	
	i = word_wrap;
}