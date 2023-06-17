/// @description Variables
question_map = ds_map_create();
dialogue_stack = ds_stack_create();
popped = false;

dialogue_background_colour = c_black;
dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_gui_slider = 0;
dialogue_gui_fader = 0;
dialogue_gui_fading_in = true;
event_perform(ev_alarm, 3);

dialogue_ratio = (dialogue_gui_height * view_wport[view_current]) / (dialogue_gui_width * view_hport[view_current]);

default_colour = c_white;
default_effect = ds_effects.NORMAL;
default_font = DefaultComic;
default_textspeed = 1;

#region Stuff that changes
colours = new DialogueOptions(default_colour);
effects = new DialogueOptions(default_effect);
fonts = new DialogueOptions(default_font);
highlights = new DialogueOptions(-1);

delays = new DialogueOptions(0);
sounds = new DialogueOptions(-1);
sprites = new DialogueOptions(-1);
images = new DialogueOptions(0);
textspeeds = new DialogueOptions(default_textspeed);
#endregion

question_options = [];
question_answers = [];

break_characters = ["!", "?", ".", ";", ":", ","];
newline_characters = ["", "\n"]; // Additional and main newline characters

global.dialogue_is_open = true;

_sin = 0;

/* -- Local callback functions -- */
dialogue_change_sprite = function(value, sliding) {
  dialogue_gui_character_sprite_index = value;
  if (sliding) { event_perform(ev_alarm, 2); }
}

dialogue_change_image = function(value, sliding) {
  dialogue_gui_character_image_index = value;
  if (sliding) { event_perform(ev_alarm, 2); }
}

dialogue_delay = function(value) {
  alarm[0] = value;
  dialogue_is_paused = true;
}

dialogue_get_colour = function(value1, value2) {
  var colour;
  
  if (value1 == "rgb" || value1 == "hsv") {
    colour = make_colour_string(value1, value2);
  } else {
    colour = global.mapcolours[? value1];
  }
  
  if (is_undefined(colour)) colour = default_colour;
  return colour;
}

dialogue_play_sound = function(value) {
  audio_play_sound(value, 1, false);
}