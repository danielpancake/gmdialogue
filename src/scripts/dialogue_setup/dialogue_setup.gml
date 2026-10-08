// @description Creates data structures required for the dialog parsing process
// Feel free to change these values or add new ones
// Safe to call more than once, dialogue_open() calls it too
function dialogue_setup() {
  if (variable_global_exists("__dialogue_ready") && global.__dialogue_ready) exit;
  global.__dialogue_ready = true;

  #region Dialogue system colours map
  global.mapcolours = ds_map_create();
  global.mapcolours[? "aqua"] = c_aqua;
  global.mapcolours[? "black"] = c_black;
  global.mapcolours[? "blue"] = c_blue;
  global.mapcolours[? "darkgray"] = c_dkgray;
  global.mapcolours[? "gray"] = c_gray;
  global.mapcolours[? "green"] = c_green;
  global.mapcolours[? "lime"] = c_lime;
  global.mapcolours[? "ltgray"] = c_ltgray;
  global.mapcolours[? "maroon"] = c_maroon;
  global.mapcolours[? "navy"] = c_navy;
  global.mapcolours[? "olive"] = c_olive;
  global.mapcolours[? "orange"] = c_orange;
  global.mapcolours[? "purple"] = c_purple;
  global.mapcolours[? "red"] = c_red;
  global.mapcolours[? "silver"] = c_silver;
  global.mapcolours[? "teal"] = c_teal;
  global.mapcolours[? "white"] = c_white;
  global.mapcolours[? "yellow"] = c_yellow;
  #endregion
  #region Dialogue system effects map
  enum ds_effects {
    NORMAL,
    SHAKING,
    QUIVERING,
    FLOATING,
    BOUNCING,
    WAVING
  }
  global.mapeffects = ds_map_create();
  global.mapeffects[? "normal"] = ds_effects.NORMAL;
  global.mapeffects[? "shaking"] = ds_effects.SHAKING;
  global.mapeffects[? "quivering"] = ds_effects.QUIVERING;
  global.mapeffects[? "floating"] = ds_effects.FLOATING;
  global.mapeffects[? "bouncing"] = ds_effects.BOUNCING;
  global.mapeffects[? "waving"] = ds_effects.WAVING;
  #endregion
  #region Dialogue system characters map
  global.mapcharacters = ds_map_create();
  global.mapcharacters[? "default"] = -1;
  global.mapcharacters[? "rectangle"] = 1;
  #endregion
  #region Dialogue system layouts map
  global.maplayouts = ds_map_create();
  global.maplayouts[? "default"] = -1;
  global.maplayouts[? "badapple"] = 1;
  #endregion
  #region Dialogue system text speeds map
  // Speed can be expressed by any real number
  // Note that all negative numbers will set the maximum text speed
  global.mapspeeds = ds_map_create();
  global.mapspeeds[? "max"] = -1;
  global.mapspeeds[? "slow"] = 0.5;
  global.mapspeeds[? "normal"] = 1;
  global.mapspeeds[? "fast"] = 2;
  #endregion
  #region Dialogue system input
  // Replace these functions to use other input. An existing global.dialogue_input is kept
  if (!variable_global_exists("dialogue_input")) {
    global.dialogue_input = {
      advance: function() { return keyboard_check_pressed(vk_enter); },
      skip: function() { return keyboard_check_pressed(vk_shift); },
      up: function() { return keyboard_check_pressed(vk_up); },
      down: function() { return keyboard_check_pressed(vk_down); },
    };
  }
  #endregion
}

// Use this variable to check if dialogue is opened
global.dialogue_is_open = false;
