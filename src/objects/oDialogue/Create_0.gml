/// @description Variables
_sin = 0;

dialogue_index = 0;
dialogue_arguments = [];

dialogue_gui_width = 480;
dialogue_gui_height = 320;

dialogue_textbox_offset = 32;
dialogue_textbox_height = 120;
dialogue_textbox_hpadding = 16;
dialogue_textbox_vpadding = 28;
dialogue_textbox_show = true;

dialogue_options_width = 128;

dialogue_origin_x = dialogue_textbox_offset + dialogue_textbox_hpadding;
dialogue_origin_y = dialogue_gui_height - dialogue_textbox_height + dialogue_textbox_vpadding;

questions = [];

global.dialogue_is_open = true;