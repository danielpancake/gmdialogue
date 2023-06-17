/// @description Fading in / out
if (dialogue_gui_fading_in) {
  if (dialogue_gui_fader < 1) {
    dialogue_gui_fader += (1 - dialogue_gui_fader) * 0.25;
  
    if (dialogue_gui_fader < 1) {
      alarm[3] = 1;
    } else {
      dialogue_gui_fader = 1;
    }
  }
} else {
  if (dialogue_gui_fader > 0) {
    dialogue_gui_fader -= dialogue_gui_fader * 0.25;
    alarm[3] = 1;
  } else {
    instance_destroy();
  }
}