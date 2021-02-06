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

var colour = default_colour;
var colour_count = 0;
var colour_pos = colours[colour_count] & 0xffffffff;

var effect = default_effect;
var effect_count = 0;
var effect_pos = effects[effect_count] & 0xffffffff;

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
	
	// Change text effect
	if (cc - breaks >= effect_pos) {
		effect = (effects[effect_count] >> 32) & 0xffffffff;
		if (effect_count < effects_max - 1) effect_count++;
		effect_pos = effects[effect_count] & 0xffffffff;
	}
	
	switch (effect) {
		case 1:	// Shaking
			xx += random_range(-0.5, 0.5);
			yy += random_range(-0.5, 0.5);
		break;
		
		case 2: // Quivering
			xx += irandom_range(-1, 1);
			yy += irandom_range(-1, 1);
		break;
		
		case 3: // Floating
			yy -= sin(degtorad(_sin - xx));
		break;
		
		case 4: // Bouncing
			yy -= abs(sin(degtorad(_sin - xx))) * 2;
		break;
		
		case 5: // Waving
			var offset = sin(degtorad(textbox_left + textbox_hpadding + line_width + _sin));
			xx += offset;
			yy += offset * 2;
		break;
	}
	
	// Change draw colour
	if (cc - breaks >= colour_pos) {
		colour = (colours[colour_count] >> 32) & 0xffffffff;
		if (colour_count < colours_max - 1) colour_count++;
		colour_pos = colours[colour_count] & 0xffffffff;
	}
	
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