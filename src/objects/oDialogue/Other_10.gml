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
skip_enabled = true;
dialogue_is_paused = false;

var omitted = 0;
var breaks = 0;

colours = [];
colours_max = 0;
effects = [];
effects_max = 0;
fonts = [];
fonts_max = 0;

textspeeds = [];
textspeeds_max = 0;
sprites = [];
sprites_max = 0;
images = [];
images_max = 0;

ffbreaks = 0;
ff = 0;

// Parsing dialogue message
for (var i = 0; i < msg_length; i++) {
	var char = msg_chars[i];
	
	if (char == "[") {
		var command_valid = true;
		var command_length = char_array_pos_range(msg_chars, i + 1, msg_length, "]", false) - i - 1;
		if (command_length <= 0) continue;
		
		var values_count = char_array_count(msg_chars, i + 1, command_length, ":", false) + 1;
		var values = array_create(8, undefined); // Don't care about values presence anymore 
		
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
			case "colour": // Sets text colour
				var colour;
				if (values[1] == "rgb" || values[1] == "hsv") { // Parsing rgb / hsv colour
					colour = make_colour_unsafe_strings(values[1], values[2], values[3], values[4]);
					command_valid = true;
				} else { // Picking predefined colour
					colour = global.mapcolours[? values[1]];
					if (is_undefined(colour)) colour = default_colour;
					command_valid = true;
				}
				
				if (command_valid) {
					array_push(colours, [colour, i - breaks - omitted]);
					colours_max++;
				}
			break;
			
			case "e":
			case "effect": // Sets text effect
				var effect = global.mapeffects[? values[1]];
				if (is_undefined(effect)) effect = default_effect;
				array_push(effects, [effect, i - breaks - omitted]);
				effects_max++;
				command_valid = true;
			break;
			
			case "exit": // Immediately closes dialogue
				instance_destroy(); exit;
			break;

			case "f":
			case "font": // Sets text font
				var font = asset_get_index(values[1]);
				if (font == -1) { font = default_font; }
				array_push(fonts, [font, i - breaks - omitted]);
				fonts_max++;
				command_valid = true;
			break;
			
			// Opens dialogue from referenced line
			case "gotoref": // Note that this command will clear dialogue stack!
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
			break;
			
			case "h":
			case "character": // Sets dialogue character preset
				var character = global.mapcharacters[? values[1]];
				if (!is_undefined(character)) dialogue_set_character(character);
				dialogue_gui_slider = 0;
				event_perform(ev_alarm, 2);
				command_valid = true;
			break;
			
			case "i":
			case "index": // Changes character image index
				var sliding = 1;
				var index = string_digits(values[1]);
				if (index != "") {
					index = real(index);
					if (values_count >= 3) { sliding = bool(values[2]); }
					array_push(images, [index, i - breaks - omitted, sliding]);
					images_max++;
					command_valid = true;
				}
			break;
			
			case "l":
			case "layout": // Sets dialogue layout
				var layout = global.maplayouts[? values[1]];
				if (!is_undefined(layout)) dialogue_set_layout(layout);
				command_valid = true;
			break;
			
			case "noskip": // Disables skip
				skip_enabled = false;
				command_valid = true;
			break;
			
			case "o":	 // Opens specified dialogue
			case "open": // Note that this command will clear dialogue stack!
				var open_dialogue = asset_get_index(values[1]);
				if (open_dialogue != -1) {
					var args = array_create(values_count - 2, "");
					if (values_count - 2 > 0) {
						for (var i = 0; i < values_count - 2; i++;) {
							args[i] = values[i + 2];
						}
					}
					ds_stack_clear(dialogue_stack);
					dialogue_open(open_dialogue, args);
					exit;
				}
				command_valid = true;
			break;
			
			case "snd": // Plays a sound
				/// TODO: make this
			break;
			
			case "spr":
			case "sprite": // Changes character sprite index
				var sliding = 1;
				var sprite = asset_get_index(values[1]);
				if (sprite != -1) {
					if (values_count >= 3) { sliding = bool(values[2]); }
					array_push(sprites, [sprite, i - breaks - omitted, sliding]);
					sprites_max++;
					command_valid = true;
				}
			break;
			
			case "ts": // Sets text speed
				var ts = global.mapspeeds[? values[1]];
				if (is_undefined(ts)) ts = default_textspeed;
				array_push(textspeeds, [ts, i - breaks - omitted]);
				textspeeds_max++;
				command_valid = true;
			break;
			
			case "q":
			case "question": // Shows question
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
		
		if (command_valid) { // Removing valid command from the message
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

/// Reset sprite and image options
dialogue_values_reset(sprite_options, -1, 0, (sprites_max > 0) ? sprites[0][1] : -1); sprite_options[3] = 1;
dialogue_values_changer(sprites, sprite_options, 0, sprites_max, dialogue_change_sprite, -1);

dialogue_values_reset(image_options, 0, 0, (images_max > 0) ? images[0][1] : -1); image_options[3] = 1;
dialogue_values_changer(images, image_options, 0, images_max, dialogue_change_image, -1);

if (msg_length - breaks <= 0) {
	event_user(0); exit;
}

// Word wrapping algorithm
var line_maxwidth = textbox_width - textbox_hpadding * 2;
var line_width = 0;

if (question_asked) {
	line_maxwidth -= textbox_options_width + textbox_hpadding / 2;	
}

if (dialogue_gui_character_sprite_index != -1) {
	line_maxwidth -= dialogue_gui_character_image_x + dialogue_gui_character_image_width - textbox_left;
}

breaks = 0;

draw_set_font(default_font);
dialogue_values_reset(font_options, default_font, 0, (fonts_max > 0) ? fonts[0][1] : -1);
for (var i = 0; i < msg_length; i++) {
	var word_width = 0;
	var word_wrap = i;
	
	if (msg_chars[i] == " ") {
		word_width += string_width(char);
		word_wrap++;
	}
	
	while (word_wrap < msg_length) {
		dialogue_values_changer(fonts, font_options, word_wrap - breaks, fonts_max, draw_set_font, 0);
		var char = msg_chars[word_wrap];
		if (char == "#") {
			line_width = 0;
			word_width = 0;
		} else if (char == " " || word_width > line_maxwidth) {
			break;
		} else {
			word_width += string_width(char);
		}
		
		word_wrap++;
	}
	
	if (line_width + word_width > line_maxwidth) {
		if (line_width == 0) {
			msg_chars = char_array_insert(msg_chars, word_wrap - 1, "#", false);
			msg_length++;
			breaks++;
		} else {
			msg_chars[i] = "";
			line_width = word_width;
		}
	} else {
		line_width += word_width;
	}
	
	i = word_wrap - 1;
}

// Setting initial textspeed
char_count = 0;
char_limit = msg_length;

textspeed = default_textspeed;
textspeed_cursor = 0;
textspeed_pos = (textspeeds_max > 0) ? textspeeds[0][1] : -1;
event_user(1);