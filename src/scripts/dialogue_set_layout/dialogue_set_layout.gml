/// @function dialogue_set_layout(layout)
/// @argumemt {string} layout
function dialogue_set_layout(layout) {
	switch (layout) {
		default:
		case -1: // Default
			dialogue_font = DefaultArial;
			
			textbox_left = 32;
			textbox_width = dialogue_gui_width - textbox_left * 2;
			textbox_height = 128;
			textbox_top = dialogue_gui_height - textbox_height;
			
			textbox_hpadding = 8;
			textbox_vpadding = 8;
			
			textbox_options_width = 128;
			textbox_show = true;
			
			line_spacing = 16;
		break;
	}
}