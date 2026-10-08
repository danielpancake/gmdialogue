/// @description Parsing dialogue message
// Loops over empty and command-only lines
while (true) {
  // Check for the last message in the dialogue
  if (popped || msg_current >= msg_end) {
    popped = false;
    dialogue_flush_pending();

    var pop = array_pop(dialogue_stack);
    if (!is_undefined(pop)) {
      dialogue = pop.messages;
      msg_current = pop.position;
      msg_end = array_length(dialogue);
      continue;
    }

    dialogue_destroy(); exit;
  }

  // Getting the message
  var msg = dialogue[msg_current++];
  if (!is_string(msg)) { msg = string(msg); }

  var message = is_undefined(dialogue_pending) ? new DialogueMessage() : dialogue_pending;
  dialogue_pending = undefined;

  // Splitting the message into character array
  var source = string_to_array(msg, string_length(msg));
  var source_length = array_length(source);
  var chars = message.chars; // Visible characters

  // Parsing dialogue message
  for (var i = 0; i < source_length; i++) {
    var char = source[i];

    // Looking for command blocks
    if (char == "[") {
      // "[[" is an escaped "["
      if (i + 1 < source_length && source[i + 1] == "[") {
        array_push(chars, "[");
        i++;
        continue;
      }

      var command_end = char_array_pos_range(source, i + 1, source_length, "]");
      if (command_end > i + 1) {
        var command = char_array_string_range(source, i + 1, command_end);
        var position = array_length(chars);

        // Missing values are undefined
        var values_list = string_split(command, ":");
        var values_count = array_length(values_list);
        var values = array_create(max(8, values_count), undefined);
        array_copy(values, 0, values_list, 0, values_count);

        var command_valid = true;
        if (string_char_at(values[0], 1) == "#") {
          // Reference, only used for linking messages
        } else switch (values[0]) {
          case "auto": // Autoproccess
            var delay = string_digits(dialogue_value_string(values[1]));
            message.autoprocess_enabled = true;
            message.autoprocess_delay = (delay == "") ? 0 : real(delay);
          break;

          case "chr":
          case "character": // Sets dialogue character preset
            var character = global.mapcharacters[? dialogue_value_string(values[1])];
            if (is_undefined(character)) {
              dialogue_warn("unknown character", command);
            } else if (character != dialogue_character_index) {
              dialogue_set_character(character);
              dialogue_slide();
            }
          break;

          case "c":
          case "col":
          case "color":
          case "colour": // Sets text colour
            var colour = dialogue_get_colour(values[1], values[2]);
            if (is_undefined(colour)) {
              if (dialogue_value_string(values[1]) != "") dialogue_warn("unknown colour", command);
              colour = default_colour;
            }
            message.colours.Put(colour, position, 0);
          break;

          case "h":
          case "highlight": // Sets text highlight colour
            var highlight = dialogue_get_colour(values[1], values[2]);
            if (is_undefined(highlight)) {
              if (dialogue_value_string(values[1]) != "") dialogue_warn("unknown colour", command);
              highlight = -1;
            }
            message.highlights.Put(highlight, position, 0);
          break;

          case "d":
          case "delay":
            var delay = string_digits(dialogue_value_string(values[1]));
            if (delay == "") {
              dialogue_warn("missing delay", command);
            } else {
              message.delays.Put(max(real(delay), 1), position, dialogue_value_bool(values[2], false));
            }
          break;

          case "e":
          case "effect": // Sets text effect
            var effect = global.mapeffects[? dialogue_value_string(values[1])];
            if (is_undefined(effect)) {
              if (dialogue_value_string(values[1]) != "") dialogue_warn("unknown effect", command);
              effect = default_effect;
            }
            message.effects.Put(effect, position, 0);
          break;

          case "exit": // Closes dialogue
            if (is_undefined(message.flow)) message.flow = { type: "exit" };
          break;

          case "f":
          case "font": // Sets text font
            var font_name = dialogue_value_string(values[1]);
            var font = default_font;
            if (asset_get_type(font_name) == asset_font) {
              font = asset_get_index(font_name);
            } else if (font_name != "") {
              dialogue_warn("unknown font", command);
            }
            message.fonts.Put(font, position, 0);
          break;

          // Opens dialogue from referenced line
          case "gotoref": // Note that this command will clear dialogue stack!
            var gotoref_dialogue = dialogue_find_function(values[1]);
            if (is_undefined(gotoref_dialogue)) {
              dialogue_warn("unknown dialogue", command);
            } else if (is_undefined(message.flow)) {
              message.flow = { type: "gotoref", target: gotoref_dialogue, ref: dialogue_value_string(values[2]) };
            }
          break;

          case "i":
          case "index": // Changes sprite image index
            var index = string_digits(dialogue_value_string(values[1]));
            if (index == "") {
              dialogue_warn("missing image index", command);
            } else {
              message.images.Put(real(index), position, dialogue_value_bool(values[2], true));
            }
          break;

          case "l":
          case "layout": // Sets dialogue layout
            var layout = global.maplayouts[? dialogue_value_string(values[1])];
            if (is_undefined(layout)) {
              dialogue_warn("unknown layout", command);
            } else {
              dialogue_set_layout(layout);
            }
          break;

          case "method": // Call a method
            var method_function = dialogue_find_function(values[1]);
            if (is_undefined(method_function)) {
              dialogue_warn("unknown function", command);
            } else {
              var method_args = [];
              for (var k = 2; k < values_count; k++) { array_push(method_args, values[k]); }
              method_call(method_function, method_args);
            }
          break;

          case "noskip": // Disables skip
            message.skip_enabled = false;
          break;

          case "o":    // Opens specified dialogue
          case "open": // Note that this command will clear dialogue stack!
            var open_dialogue = dialogue_find_function(values[1]);
            if (is_undefined(open_dialogue)) {
              dialogue_warn("unknown dialogue", command);
            } else if (is_undefined(message.flow)) {
              var open_args = [];
              for (var k = 2; k < values_count; k++) { array_push(open_args, values[k]); }
              message.flow = { type: "open", target: open_dialogue, args: open_args };
            }
          break;

          case "pop": // Leaves current branch
            if (is_undefined(message.flow)) message.flow = { type: "pop" };
          break;

          case "snd": // Plays a sound
            var sound_name = dialogue_value_string(values[1]);
            if (asset_get_type(sound_name) == asset_sound) {
              message.sounds.Put(asset_get_index(sound_name), position, 0);
            } else {
              dialogue_warn("unknown sound", command);
            }
          break;

          case "spr":
          case "sprite": // Changes sprite index
            var sprite_name = dialogue_value_string(values[1]);
            if (asset_get_type(sprite_name) == asset_sprite) {
              message.sprites.Put(asset_get_index(sprite_name), position, dialogue_value_bool(values[2], true));
            } else {
              dialogue_warn("unknown sprite", command);
            }
          break;

          case "ts": // Sets text speed
            var ts = global.mapspeeds[? dialogue_value_string(values[1])];
            if (is_undefined(ts)) {
              dialogue_warn("unknown text speed", command);
              ts = default_textspeed;
            }
            message.textspeeds.Put(ts, position, 0);
          break;

          case "q":
          case "question": // Shows question
            var question = question_map[$ dialogue_value_string(values[1])];
            if (is_undefined(question) || array_length(question.options) == 0) {
              dialogue_warn("unknown question", command);
            } else {
              message.question = question;
            }
          break;

          /*
          case "command name": // Brief description
            // Command body
          break;
          */

          default: // Shown as text
            command_valid = false;
          break;
        }

        if (command_valid) { // Removing valid commands from the message
          i = command_end;
          continue;
        }
        dialogue_warn("unknown command, shown as text", command);
      }
    }

    array_push(chars, char);
  }

  // Newlines alone don't count as text
  var has_chars = false;
  var has_text = false;
  for (var k = 0; k < array_length(chars); k++) {
    var c = chars[k];
    if (c != "\n") {
      has_chars = true;
      if (c != " " && c != "\t" && c != "\r") { has_text = true; break; }
    }
  }

  if (!is_undefined(message.flow) && !has_text) {
    // Command-only line: flow commands run now
    var flow = message.flow;
    dialogue_pending = message;
    if (flow.type == "pop") { popped = true; continue; }
    dialogue_flush_pending();
    dialogue_run_flow(flow);
    exit;
  }

  if (!has_chars) {
    // Command-only line: applies to the next line
    message.Rewind();
    dialogue_pending = message;
    continue;
  }

  dialogue_show(message);
  exit;
}
