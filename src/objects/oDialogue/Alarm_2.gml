/// @description Sliding in
if (dialogue_gui_slider < 1) {
	dialogue_gui_slider += (1 - dialogue_gui_slider) * 0.25;
	alarm[2] = 1;
}