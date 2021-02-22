/// @description Variables
dialogue_stack = ds_stack_create();

default_colour = c_white;
colour_options = [default_colour, -1, 0]; // Colour / position / count

default_effect = ds_effects.NORMAL;
effect_options = [default_effect, -1, 0]; // Effect / position / count

default_font = DefaultArial;
font_options = [default_font, -1, 0]; // Font / position / count

sprite_options = [-1, -1, 0, 1]; // Sprite / position / count / sliding
image_options = [0, -1, 0, 1]; // Image / position / count / sliding

default_textspeed = 1;

dialogue_background_colour = c_black;
dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_gui_slider = 0;

question_options = [];
question_answers = [];

break_characters = ["!", "?", ".", ";", ":", ","];
newline_characters = ["", "#"];

global.dialogue_is_open = true;

_sin = 0;

// Local functions
dialogue_values_changer = function(array, param, pos, maxval, callback, index){
	while (param[2] != -1 && pos >= param[2]) {
		param[@ 0] = array[param[1]][0];
		param[@ 2] = (param[1] < maxval - 1) ? array[++param[@ 1]][1] : -1;
		if (callback != -1) {
			if (index != -1) {
				callback(param[index]);
			} else {
				callback(param);
			}
		}
	}
}

dialogue_values_reset = function(array, default_value, count, position) {
	array[@ 0] = default_value;
	array[@ 1] = count;
	array[@ 2] = position;
}

dialogue_change_sprite = function(param) {
	dialogue_gui_character_sprite_index = param[0];
	if (param[3]) { dialogue_gui_slider = 0; event_perform(ev_alarm, 2); }
}

dialogue_change_image = function(param) {
	dialogue_gui_character_image_index = param[0];
	if (param[3]) { dialogue_gui_slider = 0; event_perform(ev_alarm, 2); }
}