/// @function dialogue_set_character(index)
/// @argument {number} index Real value representing character index
function dialogue_set_character(index) {
  switch (index) {
    default:
    case -1: // Default
      dialogue_gui_character_sprite_index = -1;
      dialogue_gui_character_image_index = 0;
      dialogue_gui_character_image_x = 0;
      dialogue_gui_character_image_scale = 1;
      dialogue_gui_character_image_width = 0;
      dialogue_gui_character_image_y = 0;
    break;
    
    case 1: // Mr. Rectangle
      dialogue_gui_character_sprite_index = sImageTemplate;
      dialogue_gui_character_image_index = 0;
      dialogue_gui_character_image_x = 8;
      dialogue_gui_character_image_scale = 1;
      dialogue_gui_character_image_width = sprite_get_width(dialogue_gui_character_sprite_index);
      dialogue_gui_character_image_width *= dialogue_gui_character_image_scale;
      dialogue_gui_character_image_y = dialogue_gui_height;
    break;
  }
}