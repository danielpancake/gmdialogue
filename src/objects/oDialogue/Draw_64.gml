/// @description Draw dialogue box and text
display_set_gui_size(dialogue_gui_width, dialogue_gui_height);

if (textbox_show) {
	draw_set_alpha(1);
	draw_set_colour(c_black);
	draw_rectangle(textbox_left, textbox_top,
		textbox_left + textbox_width, textbox_top + textbox_height, false);
}

var breaks = 0;
var cc = 1;

var line_current = 0;
var line_width = 0;

draw_set_font(dialogue_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

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
	
	var xx = textbox_left + textbox_hpadding + line_width;
	var yy = textbox_top + textbox_vpadding + line_current * line_spacing;
	
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

// Show questions and options
if (question_asked && char_count == msg_length) {
	for (var i = 0; i < options_count; i++) {
		var option = question_options[i];
		draw_set_colour(c_white);
		if (i == options_cursor) {
			draw_set_colour(c_yellow);
			option = "> " + option;
		}
		
		draw_text(textbox_left + textbox_width - textbox_hpadding - textbox_options_width,
			textbox_top + textbox_vpadding + i * line_spacing, option);
	}
}