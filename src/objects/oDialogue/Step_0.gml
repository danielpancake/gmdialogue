/// @description Input handling and processing
var input = global.dialogue_input;

// Sin cycle
_sin = (_sin + 4) % 360;

if (char_count >= msg_length) {
  // Options selection
  if (question_asked && options_count > 0) {
    if (input.up()) { options_cursor = (options_cursor + options_count - 1) % options_count; }
    if (input.down()) { options_cursor = (options_cursor + 1) % options_count; }
  }

  // Autoprocessing
  if (autoprocess_enabled && !autoprocess && alarm[1] < 0) {
    if (autoprocess_delay < 1) {
      autoprocess = true;
    } else {
      alarm[1] = autoprocess_delay;
    }
  }

  if (dialogue_gui_fading_in && (autoprocess || input.advance())) {
    dialogue_advance();
  }
} else if (skip_enabled && !dialogue_pause_unskippable && input.skip()) {
  // Completion output of the current message
  dialogue_skip();
} else if (!dialogue_is_paused) {
  event_user(1); // Textspeed controller
}
