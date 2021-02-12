/// @description Draw dialogue box and text
display_set_gui_size(dialogue_gui_width, dialogue_gui_height);

if (textbox_show) {
	draw_set_alpha(1);
	draw_set_colour(dialogue_background_colour);
	draw_rectangle(textbox_left, textbox_top,
		textbox_left + textbox_width, textbox_top + textbox_height, false);
}

var breaks = 0;
var cc = 0;

var colour = default_colour;
var colour_pos;

if (colours_max > 0) {
	colour_pos = colours[0] & 0xffffffff;
} else {
	colour_pos = -1;
}

var colour_count = 0;

var effect = default_effect;
var effect_pos;

if (effects_max > 0) {
	effect_pos = effects[0] & 0xffffffff;
} else {
	effect_pos = -1;
}

var effect_count = 0;

var line_current = 0;
var line_width = 0;

draw_set_font(dialogue_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Drawing dialogue text
while (cc < char_count) {
	var char = msg_chars[cc];
	
	if (char == "#") {
		line_current++;
		line_width = 0;
		breaks++;
		cc++;
		continue;
	}
	
	var xx = textbox_left + textbox_hpadding + line_width;
	var yy = textbox_top + textbox_vpadding + line_current * line_spacing;
	
	// Changing text effect
	if (effect_pos != -1) {
		if (cc - breaks >= colour_pos) {
			effect = (effects[effect_count] >> 32) & 0xffffffff;
			
			if (effect_count < effects_max - 1) {
				effect_pos = effects[++colour_count] & 0xffffffff;
			} else {
				effect_pos = -1;	
			}
		}
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
	
	// Changing draw colour
	if (colour_pos != -1) {
		if (cc - breaks >= colour_pos) {
			colour = (colours[colour_count] >> 32) & 0xffffffff;
			
			if (colour_count < colours_max - 1) {
				colour_pos = colours[++colour_count] & 0xffffffff;
			} else {
				colour_pos = -1;	
			}
		}
	}
	
	draw_set_color(colour);
	draw_text(xx, yy, char);
	
	line_width += string_width(char);
	cc++;
}

// Showing question and its options
if (question_asked && char_count == msg_length) {
	for (var i = 0; i < options_count; i++) {
		var option = question_options[i];
		
		if (i == options_cursor) {
			draw_set_colour(c_yellow);
			option = "> " + option;
		} else {
			draw_set_colour(c_white);
		}
		
		draw_text(textbox_left + textbox_width - textbox_hpadding - textbox_options_width,
			textbox_top + textbox_vpadding + i * line_spacing, option);
	}
}