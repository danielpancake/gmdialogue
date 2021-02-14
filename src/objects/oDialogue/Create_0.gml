/// @description Variables
dialogue_stack = ds_stack_create();

default_colour = c_white;
colour_options = [default_colour, -1, 0]; // Colour / position / count

default_effect = ds_effects.NORMAL;
effect_options = [default_effect, -1, 0]; // Effect / position / count

default_font = DefaultArial;
font_options = [default_font, -1, 0]; // Font / position / count

default_textspeed = 1;

dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_background_colour = c_black;

question_options = [];
question_answers = [];

break_characters = ["!", "?", ".", ";", ":", ","];
newline_characters = ["", "#"];

dialogue_set_layout(-1);
global.dialogue_is_open = true;

_sin = 0;