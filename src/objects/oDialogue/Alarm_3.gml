/// @description Fading in / out
if (dialogue_gui_fading_in) {
  dialogue_gui_fader += (1 - dialogue_gui_fader) * 0.25;

  if (dialogue_gui_fader > 0.995) {
    dialogue_gui_fader = 1;
  } else {
    alarm[3] = 1;
  }
} else {
  dialogue_gui_fader -= dialogue_gui_fader * 0.25;

  if (dialogue_gui_fader < 0.005) {
    dialogue_gui_fader = 0;
    instance_destroy();
  } else {
    alarm[3] = 1;
  }
}
