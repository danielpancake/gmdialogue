/// @description Sliding in
if (dialogue_gui_slider == 1) {
  dialogue_gui_slider = 0;
  alarm[2] = 1;
} else if (dialogue_gui_slider < 1) {
  dialogue_gui_slider += (1 - dialogue_gui_slider) * 0.25;
  
  if (dialogue_gui_slider < 1) {
    alarm[2] = 1;
  } else {
    dialogue_gui_slider = 1;
  }
}