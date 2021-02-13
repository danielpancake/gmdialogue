/// @description Draw dialogue box and text
display_set_gui_size(dialogue_gui_width, dialogue_gui_height);

if (textbox_show) {
	draw_set_alpha(1);
	draw_set_colour(dialogue_background_colour);
	draw_rectangle(textbox_left, textbox_top, textbox_left + textbox_width, textbox_top + textbox_height, false);
}

var breaks = 0;
var cc = 0;

var line_current = 0;
var line_width = 0;

draw_set_colour(default_colour);
draw_set_font(default_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

dialogue_values_reset(colour_options, default_colour, 0, (colours_max > 0) ? colours[0] & 0xffffffff : -1);
dialogue_values_reset(effect_options, default_effect, 0, (effects_max > 0) ? effects[0] & 0xffffffff : -1);
dialogue_values_reset(font_options, default_font, 0, (fonts_max > 0) ? fonts[0] & 0xffffffff : -1);

// Drawing dialogue text
while (cc < char_count) {
	var char = msg_chars[cc];
	
	if (char == "#") breaks++;
	// "" used as second newline character
	// Since it doesn't appear normally, it is used by by parser
	if (char == "" || char == "#") {
		line_current++;
		line_width = 0;
		cc++;
		continue;
	}
	
	var xx = textbox_left + textbox_hpadding + line_width;
	var yy = textbox_top + textbox_vpadding + line_current * line_spacing;
	
	// Changing text effect
	dialogue_values_changer(effects, effect_options, cc - breaks, effects_max, -1);
	
	switch (effect_options[0]) {
		case ds_effects.SHAKING:
			xx += random_range(-0.5, 0.5);
			yy += random_range(-0.5, 0.5);
		break;
		
		case ds_effects.QUIVERING:
			xx += irandom_range(-1, 1);
			yy += irandom_range(-1, 1);
		break;
		
		case ds_effects.FLOATING:
			yy -= sin(degtorad(_sin - xx));
		break;
		
		case ds_effects.BOUNCING:
			yy -= abs(sin(degtorad(_sin - xx))) * 2;
		break;
		
		case ds_effects.WAVING:
			var offset = sin(degtorad(textbox_left + textbox_hpadding + line_width + _sin));
			xx += offset;
			yy += offset * 2;
		break;
	}
	
	// Changing text colour and font
	dialogue_values_changer(colours, colour_options, cc - breaks, colours_max, draw_set_colour);
	dialogue_values_changer(fonts, font_options, cc - breaks, fonts_max, draw_set_font);
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