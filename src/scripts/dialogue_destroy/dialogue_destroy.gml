/// @description Closes the dialogue
function dialogue_destroy() {
  if (global.dialogue_is_open) {
    with (oDialogue) {
      dialogue_gui_fading_in = false;
      event_perform(ev_alarm, 3);
    }
  }
}