/// @description Sliding in
dialogue_gui_slider += (1 - dialogue_gui_slider) * 0.25;

if (dialogue_gui_slider > 0.995) {
  dialogue_gui_slider = 1;
} else {
  alarm[2] = 1;
}
