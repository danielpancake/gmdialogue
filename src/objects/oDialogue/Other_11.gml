/// @description Text speed controller
// Text speed changes (negative is instant)
textspeeds.Change(char_count, -1);
var text_speed = (textspeeds.current_value < 0) ? msg_length : textspeeds.current_value;
var char_limit = (textspeeds.current_position == -1) ? msg_length : textspeeds.current_position;

// Punctuation delays (not at max speed)
var char_sublimit = char_limit;
if (textspeeds.current_value > 0) {
  var lookahead = char_array_pos_any_match_range(msg_chars, ceil(char_count), min(char_count + text_speed, char_limit), break_characters);
  if (lookahead.position != -1) {
    var break_index = array_get_index(break_characters, lookahead.char);
    var delay = (break_index < array_length(break_delays)) ? break_delays[break_index] : 20;
    dialogue_delay(max(delay / text_speed, 15));
    char_sublimit = lookahead.position + 1;
  }
}

// User defined delays
var delay_position = (delays.current_position == -1) ? msg_length : delays.current_position;
char_count = clamp(char_count + text_speed, 0, min(char_limit, char_sublimit, delay_position));
event_user(2);
dialogue_update_scroll();
