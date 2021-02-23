/// @description Variables
dialogue_stack = ds_stack_create();

dialogue_background_colour = c_black;
dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_gui_slider = 0;

default_colour = c_white;
default_effect = ds_effects.NORMAL;
default_font = DefaultArial;
default_textspeed = 1;

colours = new DialogueOptions(default_colour);
effects = new DialogueOptions(default_effect);
fonts = new DialogueOptions(default_font);
highlights = new DialogueOptions(-1);

sounds = new DialogueOptions(-1);
sprites = new DialogueOptions(-1);
images = new DialogueOptions(0);
textspeeds = new DialogueOptions(default_textspeed);

question_options = [];
question_answers = [];

break_characters = ["!", "?", ".", ";", ":", ","];
newline_characters = ["", "#"];

global.dialogue_is_open = true;

_sin = 0

/* -- Local callback functions -- */
dialogue_change_sprite = function(value, sliding) {
	dialogue_gui_character_sprite_index = value;
	if (sliding) { event_perform(ev_alarm, 2); }
}

dialogue_change_image = function(value, sliding) {
	dialogue_gui_character_image_index = value;
	if (sliding) { event_perform(ev_alarm, 2); }
}

dialogue_play_sound = function(value) {
	audio_play_sound(value, 1, false);
}