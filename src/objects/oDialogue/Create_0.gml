/// @description Variables
dialogue_stack = ds_stack_create();

default_colour = c_white;
default_effect = 0;
default_tspeed = 1;

dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_background_colour = c_black;

question_options = [];
question_answers = [];

break_characters = ["!", "?", ".", ";", ":", ","];

dialogue_set_layout(-1);
global.dialogue_is_open = true;

_sin = 0;