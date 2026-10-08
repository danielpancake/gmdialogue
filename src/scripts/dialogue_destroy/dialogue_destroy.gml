/// @description Closes the dialogue
function dialogue_destroy() {
  with (oDialogue) {
    if (dialogue_gui_fading_in) {
      dialogue_gui_fading_in = false;
      if (alarm[3] < 0) { alarm[3] = 1; }
    }
  }
}
