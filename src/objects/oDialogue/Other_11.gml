/// @description Text speed controller
if (textspeeds.current_position != -1) {
  if (char_count >= textspeeds.current_position) {
    var ts = textspeeds.values[textspeeds.current_count][0];
    textspeeds.current_value = (ts < 0) ? msg_length : ts;
    
    if (textspeeds.current_count < textspeeds.size - 1) {
      textspeeds.current_position = textspeeds.values[++textspeeds.values[1]][1];
      char_limit = textspeeds.current_position;
    } else {
      textspeeds.current_position = -1;
      char_limit = msg_length;
    }
  }
}

// Punctuation delays
var lookahead = char_array_pos_any(msg_chars, floor(char_count), textspeeds.current_value, break_characters, true);
var char_sublimit = char_limit;
if (lookahead[0] != -1) {
  var delay;
  
  switch (lookahead[1]) {
    case "!":
    case "?":
    case ".":
      delay = 50;
    break;
    
    case ";":
    case ":":
    case ",":
      delay = 20;
    break;
  }
  
  dialogue_delay(max(delay / textspeeds.current_value, 15));
  char_sublimit = lookahead[0] + 1;
}

// User defined delays
var delay_position = (delays.current_position == -1) ? char_limit : delays.current_position;
char_count = clamp(char_count + textspeeds.current_value, 0, min(char_limit, char_sublimit, delay_position));
event_user(2);