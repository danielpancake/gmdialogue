/// @description Parsing dialogue message
// Check for the last message in the dialogue
if (popped || msg_current >= msg_end) {
  popped = false;
  
  if (ds_stack_size(dialogue_stack) > 0) {
    var pop = ds_stack_pop(dialogue_stack);
    if (pop[0] == -1) {
      dialogue = messages;
    } else {
      dialogue = question_map[? pop[0]][1][pop[2]];
    }
    
    msg_current = pop[1];
    msg_end = array_length(dialogue);
    event_user(0); exit;
  }
  
  dialogue_destroy(); exit;
}

// Getting the message
var msg = dialogue[msg_current++];
msg_length = string_length(msg);

if (msg_length == 0) {
  event_user(0); exit;
}

// Splitting the message into character array
msg_chars = string_to_array(msg, msg_length);

question_asked = false;
options_count = 0;
options_cursor = 0;

autoprocess = false;
autoprocess_delay = 0;
autoprocess_enabled = false;
dialogue_is_paused = false;
skip_enabled = true;

// Draw related stuff
colours.ResetAll(default_colour);
effects.ResetAll(default_effect);
fonts.ResetAll(default_font);
highlights.ResetAll(-1);

// ..everything else
delays.ResetAll(0);
sounds.ResetAll(-1);
sprites.ResetAll(-1);
images.ResetAll(0);
textspeeds.ResetAll(default_textspeed);

var omitted = 0;
var breaks = 0;

char_count = 0;
char_limit = msg_length;
ffbreaks = 0;
ff = 0;

// Don't care about values presence
// Extend if more values are needed
var values = array_create(8, undefined);

// Parsing dialogue message
for (var i = 0; i < msg_length; i++) {
  var char = msg_chars[i];
  
  // Looking for command blocks
  if (char == "[") {
    var command_valid = true;
    var command_length = char_array_pos_range(msg_chars, i + 1, msg_length, "]", false) - i - 1;
    
    if (command_length <= 0) continue;
    
    var values_count = char_array_count(msg_chars, i + 1, command_length, ":", false) + 1;
    
    for (var j = 0, jj = i + 1; j < values_count; j++) {
      var colon_pos = char_array_pos_range(msg_chars, jj, i + command_length + 1, ":", false);
      var no_colon = (colon_pos == -1);
      
      values[j] = char_array_string(msg_chars, jj,
        no_colon * (i + command_length + 1) + !no_colon * colon_pos - jj, false);
        
      if (no_colon) break;
      jj = colon_pos + 1;
    }
    
    switch (values[0]) {
      case "#": // Reference
        // Only used for linking messages
        command_valid = true;
      break;
      
      case "auto": // Autoproccess
        var delay = string_digits(values[1]);
        autoprocess_delay = (delay == "") ? -1 : real(delay);
        autoprocess_enabled = true;
        command_valid = true;
      break;
      
      case "chr":
      case "character": // Sets dialogue character preset
        var character = global.mapcharacters[? values[1]];
        if (!is_undefined(character)) dialogue_set_character(character);
        event_perform(ev_alarm, 2);
        command_valid = true;
      break;
      
      case "c":
      case "col":
      case "color":
      case "colour": // Sets text colour
        colours.Put(dialogue_get_colour(values[1], values[2]), i - breaks - omitted, 0);
        command_valid = true;
      break;
      
      case "h":
      case "highlight": // Sets text highlight colour
        highlights.Put(dialogue_get_colour(values[1], values[2]), i - breaks - omitted, 0);
        command_valid = true;
      break;
      
      case "d":
      case "delay":
        var delay = string_digits(values[1]);
        if (delay != "") {
          var unskippable = (values[2] == undefined) ? false : bool(values[2]);
          delays.Put(max(real(delay), 1), i - breaks - omitted, unskippable);
          command_valid = true;
        }
      break;
      
      case "e":
      case "effect": // Sets text effect
        var effect = global.mapeffects[? values[1]];
        if (is_undefined(effect)) effect = default_effect;
        effects.Put(effect, i - breaks - omitted, 0);
        command_valid = true;
      break;
      
      case "exit": // Immediately closes dialogue
        dialogue_destroy(); exit;

      case "f":
      case "font": // Sets text font
        var font = asset_get_index(values[1]);
        if (font == -1) { font = default_font; }
        fonts.Put(font, i - breaks - omitted, 0);
        command_valid = true;
      break;
      
      // Opens dialogue from referenced line
      case "gotoref": // Note that this command will clear dialogue stack!
        var gotoref_dialogue = asset_get_index(values[1]);
        if (gotoref_dialogue != -1) {
          script_execute(gotoref_dialogue);
          for (var k = 0; k < array_length(messages); k++) {
            var _msg = messages[k];
            var ref_pos = string_pos("[#", _msg);
            if (ref_pos != 0) {
              var ref_id = string_copy(_msg, ref_pos + 3,
                string_pos("]", string_copy(_msg, ref_pos, string_length(_msg) - ref_pos + 1)) - 4
              );
              
              if (ref_id == values[2]) {
                ds_map_clear(question_map);
                ds_stack_clear(dialogue_stack);
                dialogue_open_at(gotoref_dialogue, [], k);
                exit;
              }
            }
          }
          
          dialogue_destroy(); // If the reference is absent, the dialogue ends
        }
      break;
      
      case "i":
      case "index": // Changes sprite image index
        var index = string_digits(values[1]);
        if (index != "") {
          var sliding = (values[2] == undefined) ? true : bool(values[2]);
          images.Put(real(index), i - breaks - omitted, sliding);
          command_valid = true;
        }
      break;
      
      case "l":
      case "layout": // Sets dialogue layout
        var layout = global.maplayouts[? values[1]];
        if (!is_undefined(layout)) dialogue_set_layout(layout);
        command_valid = true;
      break;
      
      case "method": // Call a method
        var method_name = asset_get_index(values[1]);
        if (is_callable(method_name)) {
          var args = array_create(max(0, values_count - 2), "");
          for (var i = 0; i < values_count - 2; i++;) {
            args[i] = values[i + 2];
          }
          method_call(method_name, args);
        }
      break;
      
      case "noskip": // Disables skip
        skip_enabled = false;
        command_valid = true;
      break;
      
      case "o":    // Opens specified dialogue
      case "open": // Note that this command will clear dialogue stack!
        var open_dialogue = asset_get_index(values[1]);
        if (open_dialogue != -1) {
          var args = array_create(max(0, values_count - 2), "");
          for (var i = 0; i < values_count - 2; i++;) {
            args[i] = values[i + 2];
          }
          ds_map_clear(question_map);
          ds_stack_clear(dialogue_stack);
          dialogue_open(open_dialogue, args);
          exit;
        }
        command_valid = true;
      break;
      
      case "pop": // Leaves current branch
        popped = true;
        event_user(0);
      exit;
      
      case "snd": // Plays a sound
        var sound = asset_get_index(values[1]);
        if (sound != -1) {
          sounds.Put(sound, i - breaks - omitted, 0);
          command_valid = true;
        }
      break;
      
      case "spr":
      case "sprite": // Changes sprite index
        var sprite = asset_get_index(values[1]);
        if (sprite != -1) {
          var sliding = values[2] == undefined ? true : bool(values[2]);
          sprites.Put(sprite, i - breaks - omitted, sliding);
          command_valid = true;
        }
      break;
      
      case "ts": // Sets text speed
        var ts = global.mapspeeds[? values[1]];
        if (is_undefined(ts)) ts = default_textspeed;
        textspeeds.Put(ts, i - breaks - omitted, 0);
        command_valid = true;
      break;
      
      case "q":
      case "question": // Shows question
        var index = values[1];
        var question = question_map[? index];
        if (!is_undefined(question)) {
          question_options = question[0];
          question_answers = question[1];
          options_count = array_length(question_options);
          if (array_length(question_answers) > 0 && options_count > 0) {
            stack_index[1] = index;
            question_asked = true;
            command_valid = true;
          }
        }
      break;
      
      /*
      case "command name": // Brief description
        // Command body
        command_valid = true;
      break;
      */
    }
    
    if (command_valid) { // Removing valid commands from the message
      msg_chars = char_array_replace(msg_chars, i, command_length + 2, "", false);
      omitted += command_length + 2;
      i += command_length + 1;
    }
  } else if (char == newline_characters[1]) {
    breaks++;
  }
}

// Removing all ommited characters
msg_chars = char_array_remove(msg_chars, "");
msg_length -= omitted;

// Setting initial sprite and image index
delays.Reset(0);
sounds.Reset(-1);
sprites.Reset(-1);
images.Reset(0);

// Ending if message is empty
if (msg_length - breaks <= 0) {
  event_user(2); // Calling to apply changes
  event_user(0); exit;
}

// Word wrapping algorithm

var line_maxwidth = max(textbox_width - textbox_hpadding * 2 -
  (textbox_options_width + textbox_hpadding / 2) * question_asked -
  (dialogue_gui_character_image_x + dialogue_gui_character_image_width - textbox_left) *
  (dialogue_gui_character_sprite_index != -1), 15);
var line_width = 0;

breaks = 0;

draw_set_font(default_font);
fonts.Reset(default_font);
fonts.Change(0, draw_set_font);

for (var i = 0; i < msg_length; i++) {
  var word_width = 0;
  var word_wrap = i;
  
  if (msg_chars[i] == " ") {
    word_width += string_width(char);
    word_wrap++;
  }
  
  while (word_wrap < msg_length) {
    fonts.Change(word_wrap - breaks, draw_set_font);
    
    var char = msg_chars[word_wrap];
    if (char == "\n") {
      line_width = 0;
      word_width = 0;
    } else if (char == " " || word_width > line_maxwidth) {
      break;
    } else {
      word_width += string_width(char);
    }
    
    word_wrap++;
  }
  
  if (line_width + word_width > line_maxwidth) {
    if (line_width == 0) {
      msg_chars = char_array_insert(msg_chars, word_wrap - 1, "\n", false);
      msg_length++;
      breaks++;
    } else {
      msg_chars[i] = "";
      line_width = word_width;
    }
  } else {
    line_width += word_width;
  }
  
  i = word_wrap - 1;
}

// Setting initial textspeed
textspeeds.Reset(default_textspeed);
event_user(1);