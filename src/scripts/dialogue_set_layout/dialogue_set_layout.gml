/// @function dialogue_set_layout(index)
/// @argument {number} index Real value representing layout index
function dialogue_set_layout(index) {
	switch (index) {
		default:
		case -1: // Default
			default_font = DefaultArial;
			
			textbox_left = 32;
			textbox_width = dialogue_gui_width - textbox_left * 2;
			textbox_height = 128;
			textbox_top = dialogue_gui_height - textbox_height;
			
			textbox_hpadding = 8;
			textbox_vpadding = 8;
			
			textbox_options_width = 128;
			textbox_show = true;
			
			line_spacing = 16;
			line_max = 6;
		break;
		
		case 1: // TV box 32x24
			default_font = DefaultArial;
			line_spacing = 10;
			
			// Or use monospaced font
			draw_set_font(default_font);
			textbox_width = string_width("0") * 32 + 1;
			textbox_left = (dialogue_gui_width - textbox_width) / 2;
			
			textbox_height = line_spacing * 24;
			textbox_top = 32;
			
			textbox_hpadding = 0;
			textbox_vpadding = 0;
			
			textbox_options_width = 0;
			textbox_show = true;
			
			line_max = 24;
		break;
	}
}