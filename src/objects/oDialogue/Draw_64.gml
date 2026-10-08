/// @description Draw dialogue box and text
// Drawn in dialogue_gui_width x dialogue_gui_height, scaled to the GUI without changing its size
var _init_matrix = matrix_get(matrix_world);
matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0,
  display_get_gui_width() / dialogue_gui_width, display_get_gui_height() / dialogue_gui_height, 1));

var _init_alpha = draw_get_alpha();
var _init_colour = draw_get_colour();
var _init_font = draw_get_font();
var _init_halign = draw_get_halign();
var _init_valign = draw_get_valign();

// Portrait aspect ratio correction
var _window_w = window_get_width();
var _window_h = window_get_height();
if (_window_w > 0 && _window_h > 0) {
  dialogue_ratio = (dialogue_gui_height * _window_w) / (dialogue_gui_width * _window_h);
}

draw_set_alpha(dialogue_gui_fader);
if (textbox_show) {
  draw_set_colour(dialogue_background_colour);
  draw_rectangle(textbox_left, textbox_top, textbox_left + textbox_width, textbox_top + textbox_height, false);
}

draw_set_colour(default_colour);
draw_set_font(default_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

colours.Reset(default_colour);
effects.Reset(default_effect);
fonts.Reset(default_font);
highlights.Reset(-1);

// Drawing dialogue text
var cc = (scroll_line < array_length(msg_line_start)) ? msg_line_start[scroll_line] : msg_length;
for (; cc < char_count && cc < msg_length; cc++) {
  effects.Change(cc, -1);
  highlights.Change(cc, -1);
  colours.Change(cc, draw_set_colour);
  fonts.Change(cc, draw_set_font);

  if (msg_x[cc] < 0) continue; // Line break

  var char = msg_chars[cc];
  var w = msg_w[cc];
  var xx = msg_text_left + msg_x[cc];
  var yy = msg_text_top + (msg_line[cc] - scroll_line) * line_spacing;

  // Changing text effect
  switch (effects.current_value) {
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
      var offset = sin(degtorad(textbox_left + textbox_hpadding + msg_x[cc] + _sin));
      xx += offset;
      yy += offset * 2;
    break;
  }

  // Exact size, overlaps would show while fading
  var h = highlights.current_value;
  if (h != -1) {
    draw_sprite_ext(sDSHighlightBackground, 0, xx, yy, w, line_spacing, 0, h, dialogue_gui_fader);
  }

  draw_text(xx, yy, char);
}

// Showing question and its options
if (question_asked && char_count >= msg_length) {
  draw_set_font(default_font);
  var options_first = clamp(options_cursor - line_max + 1, 0, max(options_count - line_max, 0));
  var options_last = min(options_first + line_max, options_count);

  for (var i = options_first; i < options_last; i++) {
    var option = msg_options[i];

    if (i == options_cursor) {
      draw_set_colour(dialogue_option_selected_colour);
      option = dialogue_option_cursor + option;
    } else {
      draw_set_colour(dialogue_option_colour);
    }

    draw_text(textbox_left + textbox_width - textbox_hpadding - msg_options_width,
      textbox_top + textbox_vpadding + (i - options_first) * line_spacing, option);
  }
}

// Drawing sprite
if (dialogue_gui_character_sprite_index != -1) {
  var slider = (1 - (dialogue_gui_fading_in ? dialogue_gui_slider : dialogue_gui_fader));
  draw_sprite_ext(dialogue_gui_character_sprite_index, dialogue_gui_character_image_index,
    dialogue_gui_character_image_x - dialogue_gui_character_image_width * slider,
    dialogue_gui_character_image_y,
    dialogue_gui_character_image_scale,
    dialogue_gui_character_image_scale * dialogue_ratio,
    0, c_white, dialogue_gui_fader);
}

// Leave draw settings intact for other systems
draw_set_alpha(_init_alpha);
draw_set_colour(_init_colour);
draw_set_font(_init_font);
draw_set_halign(_init_halign);
draw_set_valign(_init_valign);
matrix_set(matrix_world, _init_matrix);
