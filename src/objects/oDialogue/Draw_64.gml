/// @description Draw dialogue box and text
display_set_gui_size(dialogue_gui_width, dialogue_gui_height);

if (dialogue_textbox_show) {
	draw_set_alpha(1);
	draw_set_colour(c_black);
	draw_rectangle(dialogue_textbox_offset,
		dialogue_gui_height - dialogue_textbox_height,
		dialogue_gui_width - dialogue_textbox_offset,
		dialogue_gui_height, false);
}

var breaks = 0;
var cc = 1;

var line_current = 0;
var line_spacing = 16;
var line_width = 0;

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

// Draw dialogue text
while (cc <= char_count) {
	var char = string_char_at(msg, cc);
	if (char == "#") {
		line_current++;
		line_width = 0;
		
		breaks++;
		cc++;
		
		continue;
	}
	
	var xx = dialogue_origin_x + line_width;
	var yy = dialogue_origin_y + line_current * line_spacing;
	
	switch (effects[cc - breaks - 1]) {
		case 1:	// Shaking
			xx += random_range(-0.5, 0.5);
			yy += random_range(-0.5, 0.5);
		break;
	}
	
	var colour = colours[cc - breaks - 1];
	draw_text_colour(xx, yy, char, colour, colour, colour, colour, 1);
	
	line_width += string_width(char);
	cc++;
}

// Proccess dialogue
if (!dialogue_is_paused) {
	if (char_count < msg_length) {
		var char = string_char_at(msg, char_count);
		switch (char) {
			case ",":
			case ":":
			case ";":
				alarm[0] = 20;
				dialogue_is_paused = true;
			break;
			
			case ".":
			case "!":
			case "?":
				alarm[0] = 40;
				dialogue_is_paused = true;
			break;
		}
		
		char_count = min(msg_length, char_count + textspeed[char_count - breaks - 1]);
	}
}

// Show questions and options
if (question_asked && char_count == msg_length) {
	for (var i = 0; i < options_count; i++) {
		var option = question_options[i];
		draw_set_colour(c_white);
		if (i == options_cursor) {
			draw_set_colour(c_yellow);
			option = "> " + option;
		}
		
		draw_text(dialogue_gui_width - dialogue_options_width
			- dialogue_textbox_offset - dialogue_textbox_hpadding, dialogue_origin_y + i * line_spacing, option);
	}
}