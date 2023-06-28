/// @description Draw dialogue box and text
display_set_gui_size(dialogue_gui_width, dialogue_gui_height);

draw_set_alpha(dialogue_gui_fader);
if (textbox_show) {
  draw_set_colour(dialogue_background_colour);
  draw_rectangle(textbox_left, textbox_top, textbox_left + textbox_width, textbox_top + textbox_height, false);
}

var breaks = ffbreaks;
var cc = ff;

var line_current = 0;
var line_width = 0;

draw_set_colour(default_colour);
draw_set_font(default_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

colours.Reset(default_colour);
effects.Reset(default_effect);
fonts.Reset(default_font);
highlights.Reset(-1);

// Drawing dialogue text
while (cc < char_count) {
  var char = msg_chars[cc];
  
  if (char == "\n") breaks++;
  // "" used as second newline character
  // Since it doesn't appear normally, it is used by the parser
  if (char == "" || char == "\n") {
    line_current++;
    line_width = 0;
    cc++;
    continue;
  }
  
  var w = string_width(char);
  
  var xx = (dialogue_gui_character_sprite_index != -1 ?
    dialogue_gui_character_image_x + dialogue_gui_character_image_width : textbox_left) +
    textbox_hpadding + line_width;
    
  var yy = textbox_top + textbox_vpadding + line_current * line_spacing;
  
  // Changing text effect
  effects.Change(cc - breaks, -1);
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
      var offset = sin(degtorad(textbox_left + textbox_hpadding + line_width + _sin));
      xx += offset;
      yy += offset * 2;
    break;
  }
  
  highlights.Change(cc - breaks, -1);
  
  var h = highlights.current_value;
  if (h != -1) {
    draw_sprite_ext(sDSHighlightBackground, 0, xx, yy, w + 1, line_spacing + 1, 0, h, 1);
  }
  
  // Changing text colour and font
  colours.Change(cc - breaks, draw_set_colour);
  fonts.Change(cc - breaks, draw_set_font);
  draw_text(xx, yy, char);
  
  line_width += w;
  cc++;
}

// Text autoscrolling
if (line_current >= line_max) {
  var nl = char_array_pos_any_range(msg_chars, ff, msg_length, newline_characters, false);
  if (nl[0] != -1) { ff = nl[0] + 1; }
  ffbreaks = char_array_count_range(msg_chars, 0, ff - 1, "\n", false);
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

// Drawing sprite
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