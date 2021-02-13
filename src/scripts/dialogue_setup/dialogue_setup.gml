// This script creates data structures required for the dialog parsing process
// Feel free to change these values or add new ones
function dialogue_setup() {
	#region Dialogue colours map
	global.mapcolour = ds_map_create();
	global.mapcolour[? "aqua"] = c_aqua;
	global.mapcolour[? "black"] = c_black;
	global.mapcolour[? "blue"] = c_blue;
	global.mapcolour[? "darkgray"] = c_dkgray;
	global.mapcolour[? "gray"] = c_gray;
	global.mapcolour[? "green"] = c_green;
	global.mapcolour[? "lime"] = c_lime;
	global.mapcolour[? "ltgray"] = c_ltgray;
	global.mapcolour[? "maroon"] = c_maroon;
	global.mapcolour[? "navy"] = c_navy;
	global.mapcolour[? "olive"] = c_olive;
	global.mapcolour[? "orange"] = c_orange;
	global.mapcolour[? "purple"] = c_purple;
	global.mapcolour[? "red"] = c_red;
	global.mapcolour[? "silver"] = c_silver;
	global.mapcolour[? "teal"] = c_teal;
	global.mapcolour[? "white"] = c_white;
	global.mapcolour[? "yellow"] = c_yellow;
	#endregion
	#region Dialogue effects map
	// Effects MUST be expressed by whole positive numbers as
	// they will be stored with bit-shifting algorithm
	enum ds_effects {
		NORMAL,
		SHAKING,
		QUIVERING,
		FLOATING,
		BOUNCING,
		WAVING
	}
	global.mapeffect = ds_map_create();
	global.mapeffect[? "normal"] = ds_effects.NORMAL;
	global.mapeffect[? "shaking"] = ds_effects.SHAKING;
	global.mapeffect[? "quivering"] = ds_effects.QUIVERING;
	global.mapeffect[? "floating"] = ds_effects.FLOATING;
	global.mapeffect[? "bouncing"] = ds_effects.BOUNCING;
	global.mapeffect[? "waving"] = ds_effects.WAVING;
	#endregion
	#region Dialogue layout map
	global.maplayout = ds_map_create();
	global.maplayout[? "default"] = -1;
	global.maplayout[? "tv"] = 1;
	#endregion
	#region Dialogue text speed map
	// Speed can be expressed by any real number
	// Note that all negative numbers will set the maximum text speed
	global.mapspeed = ds_map_create();
	global.mapspeed[? "max"] = -1;
	global.mapspeed[? "slow"] = 0.5;
	global.mapspeed[? "normal"] = 1;
	global.mapspeed[? "fast"] = 2;
	#endregion
	
	// Use this value to check if dialogue is opened
	global.dialogue_is_open = false;
}