/// @description Variables
dialogue_setup();
global.dialogue_is_open = true;

question_map = {};             // name -> { options, answers }
dialogue_stack = [];           // { messages, position } to return to
dialogue_building = undefined; // Questions of the dialogue being opened
dialogue_pending = undefined;  // Commands from command-only lines
dialogue_flow = undefined;     // [exit], [pop], [open] or [gotoref]
popped = false;

messages = [];
dialogue = messages;
msg_current = 0;
msg_end = 0;

dialogue_background_colour = c_black;
dialogue_option_colour = c_white;
dialogue_option_selected_colour = c_yellow;
dialogue_option_cursor = "> ";
dialogue_gui_width = 480;
dialogue_gui_height = 320;
dialogue_gui_slider = 0;
dialogue_gui_fader = 0;
dialogue_gui_fading_in = true;
event_perform(ev_alarm, 3);

// Portrait aspect ratio correction, updated in Draw GUI
dialogue_ratio = (view_hport[0] > 0) ? (dialogue_gui_height * view_wport[0]) / (dialogue_gui_width * view_hport[0]) : 1;

default_colour = c_white;
default_effect = ds_effects.NORMAL;
default_font = DefaultComic;
default_textspeed = 1;

// Punctuation pauses, in steps
break_characters = ["!", "?", ".", ";", ":", ","];
break_delays = [50, 50, 50, 20, 20, 20];

_sin = 0;

dialogue_character_index = -1;
dialogue_set_layout(-1);

#region The message on screen
msg_chars = [];       // Visible characters
msg_length = 0;
msg_w = [];           // Character widths
msg_x = [];           // Character x in its line, -1 for line breaks
msg_line = [];        // Character lines
msg_line_start = [0]; // First character of each line
msg_text_left = 0;
msg_text_top = 0;
scroll_line = 0;      // First visible line
char_count = 0;

#region Stuff that changes
colours = new DialogueOptions(default_colour);
effects = new DialogueOptions(default_effect);
fonts = new DialogueOptions(default_font);
highlights = new DialogueOptions(-1);

delays = new DialogueOptions(0);
sounds = new DialogueOptions(-1);
sprites = new DialogueOptions(-1);
images = new DialogueOptions(0);
textspeeds = new DialogueOptions(default_textspeed);
#endregion

question_asked = false;
question_options = [];
question_answers = [];
options_count = 0;
options_cursor = 0;
msg_options = [];      // Options as drawn
msg_options_width = 0;

autoprocess = false;
autoprocess_delay = 0;
autoprocess_enabled = false;
dialogue_is_paused = false;
dialogue_pause_unskippable = false;
skip_enabled = true;
#endregion

/* -- Local callback functions -- */
dialogue_slide = function() {
  dialogue_gui_slider = 0;
  alarm[2] = 1;
}

dialogue_change_sprite = function(value, sliding) {
  dialogue_gui_character_sprite_index = value;
  if (value != -1) {
    dialogue_gui_character_image_width = sprite_get_width(value) * dialogue_gui_character_image_scale;
  }
  if (sliding) { dialogue_slide(); }
}

dialogue_change_image = function(value, sliding) {
  dialogue_gui_character_image_index = value;
  if (sliding) { dialogue_slide(); }
}

dialogue_delay = function(value, unskippable = false) {
  alarm[0] = max(alarm[0], round(value), 1);
  dialogue_is_paused = true;
  dialogue_pause_unskippable = dialogue_pause_unskippable || unskippable;
}

/// Returns undefined for unknown colours
dialogue_get_colour = function(value1, value2) {
  if (value1 == "rgb" || value1 == "bgr" || value1 == "hsv") {
    return make_colour_string(value1, value2);
  }
  return global.mapcolours[? dialogue_value_string(value1)];
}

dialogue_play_sound = function(value) {
  audio_play_sound(value, 1, false);
}

/* -- Opening dialogues -- */

/// Runs a dialogue function, returns its messages and questions
dialogue_build = function(_function, _arguments) {
  var _build = { messages: undefined, questions: {} };
  var _previous = dialogue_building;
  dialogue_building = _build;

  messages = undefined;
  script_execute_ext(_function, _arguments);
  _build.messages = messages;

  dialogue_building = _previous;
  if (!is_array(_build.messages)) {
    show_debug_message("gmdialogue: the dialogue function didn't set a messages array");
    _build.messages = [];
  }
  return _build;
}

/// Starts a built dialogue from scratch
dialogue_start = function(_build, _position, _messages = undefined, _stack = []) {
  messages = _build.messages;
  question_map = _build.questions;
  dialogue = is_undefined(_messages) ? messages : _messages;
  dialogue_stack = _stack;
  msg_current = max(0, _position);
  msg_end = array_length(dialogue);
  popped = false;
  dialogue_pending = undefined;
  dialogue_flow = undefined;
  autoprocess = false;
  alarm[1] = -1;

  // Cancels the fade-out
  if (!dialogue_gui_fading_in) {
    dialogue_gui_fading_in = true;
    if (alarm[3] < 0) { alarm[3] = 1; }
  }

  event_user(0);
}

/// Opens a dialogue from the message with [#ref]
dialogue_goto_reference = function(_function, _ref) {
  dialogue_set_layout(-1);
  var _build = dialogue_build(_function, []);

  // Answers are searched too, they return after their question
  var _queue = [{ messages: _build.messages, stack: [] }];
  var _searched = {};
  for (var q = 0; q < array_length(_queue); q++) {
    var _messages = _queue[q].messages;
    var _stack = _queue[q].stack;

    for (var k = 0; k < array_length(_messages); k++) {
      var _msg = string(_messages[k]);
      if (dialogue_has_reference(_msg, _ref)) {
        dialogue_start(_build, k, _messages, _stack);
        exit;
      }

      var _asked = dialogue_questions_in(_msg);
      for (var a = 0; a < array_length(_asked); a++) {
        var _question = _build.questions[$ _asked[a]];
        if (is_undefined(_question) || !is_undefined(_searched[$ _asked[a]])) continue;
        _searched[$ _asked[a]] = true;

        for (var o = 0; o < array_length(_question.answers); o++) {
          var _answer_stack = [];
          array_copy(_answer_stack, 0, _stack, 0, array_length(_stack));
          array_push(_answer_stack, { messages: _messages, position: k + 1 });
          array_push(_queue, { messages: _question.answers[o], stack: _answer_stack });
        }
      }
    }
  }

  // If the reference is absent, the dialogue ends
  show_debug_message("gmdialogue: reference \"" + string(_ref) + "\" not found");
  dialogue_destroy();
}

/// Runs [exit], [pop], [open] or [gotoref]
dialogue_run_flow = function(_flow) {
  switch (_flow.type) {
    case "exit": dialogue_destroy(); break;
    case "pop": popped = true; event_user(0); break;
    case "open": dialogue_open(_flow.target, _flow.args); break;
    case "gotoref": dialogue_goto_reference(_flow.target, _flow.ref); break;
  }
}

/* -- Showing messages -- */

/// Sounds and portraits of command-only lines at the end of a branch
dialogue_flush_pending = function() {
  var _message = dialogue_pending;
  dialogue_pending = undefined;
  if (is_undefined(_message)) exit;

  _message.sounds.Reset(-1);
  _message.sounds.Change(infinity, dialogue_play_sound);
  _message.sprites.Reset(-1);
  if (_message.sprites.FastForward(infinity)) {
    dialogue_change_sprite(_message.sprites.current_value, _message.sprites.current_extra);
  }
  _message.images.Reset(0);
  if (_message.images.FastForward(infinity)) {
    dialogue_change_image(_message.images.current_value, _message.images.current_extra);
  }
}

/// Puts a parsed message on screen
dialogue_show = function(_message) {
  msg_chars = _message.chars;
  msg_length = array_length(msg_chars);

  colours = _message.colours;
  effects = _message.effects;
  fonts = _message.fonts;
  highlights = _message.highlights;
  delays = _message.delays;
  sounds = _message.sounds;
  sprites = _message.sprites;
  images = _message.images;
  textspeeds = _message.textspeeds;

  colours.Reset(default_colour);
  effects.Reset(default_effect);
  fonts.Reset(default_font);
  highlights.Reset(-1);
  delays.Reset(0);
  sounds.Reset(-1);
  sprites.Reset(-1);
  images.Reset(0);
  textspeeds.Reset(default_textspeed);

  // No question if the message leaves anyway
  dialogue_flow = _message.flow;
  question_asked = !is_undefined(_message.question) && is_undefined(dialogue_flow);
  question_options = question_asked ? _message.question.options : [];
  question_answers = question_asked ? _message.question.answers : [];
  options_count = array_length(question_options);
  options_cursor = 0;

  autoprocess = false;
  autoprocess_enabled = _message.autoprocess_enabled;
  autoprocess_delay = _message.autoprocess_delay;
  alarm[1] = -1; // Timer left from the previous message
  skip_enabled = _message.skip_enabled;
  dialogue_is_paused = false;
  dialogue_pause_unskippable = false;
  alarm[0] = -1;

  char_count = 0;
  scroll_line = 0;

  // Portrait changes at the start apply before the layout
  sprites.Change(0, dialogue_change_sprite, true);
  images.Change(0, dialogue_change_image, true);

  dialogue_layout();
  event_user(1);
}

/// Word wrap: sets the line and x of each character, without adding or removing any
dialogue_layout = function() {
  // Text starts right of the portrait
  var _portrait_right = -1;
  if (dialogue_gui_character_sprite_index != -1) {
    _portrait_right = dialogue_gui_character_image_x + dialogue_gui_character_image_width;
  }
  for (var k = 0; k < sprites.size; k++) {
    var _sprite_width = sprite_get_width(sprites.values[k][0]) * dialogue_gui_character_image_scale;
    _portrait_right = max(_portrait_right, dialogue_gui_character_image_x + _sprite_width);
  }

  msg_text_left = max(textbox_left, _portrait_right) + textbox_hpadding;
  msg_text_top = textbox_top + textbox_vpadding;

  var _font = draw_get_font();
  draw_set_font(default_font);

  // Options column fits the longest option, up to half the box
  msg_options = [];
  msg_options_width = 0;
  if (question_asked) {
    var _cursor_width = string_width(dialogue_option_cursor);
    var _widest = 0;
    for (var k = 0; k < options_count; k++) {
      _widest = max(_widest, _cursor_width + string_width(question_options[k]));
    }
    msg_options_width = max(textbox_options_width, min(_widest, (textbox_width - textbox_hpadding * 2) / 2));

    for (var k = 0; k < options_count; k++) {
      var _option = question_options[k];
      if (_cursor_width + string_width(_option) > msg_options_width) {
        while (_option != "" && _cursor_width + string_width(_option + "...") > msg_options_width) {
          _option = string_delete(_option, string_length(_option), 1);
        }
        _option += "...";
      }
      array_push(msg_options, _option);
    }
  }

  var _max_width = max(textbox_left + textbox_width - textbox_hpadding - msg_text_left -
    (msg_options_width + textbox_hpadding / 2) * question_asked, 15);

  // Character widths
  fonts.Reset(default_font);
  msg_w = array_create(msg_length, 0);
  for (var k = 0; k < msg_length; k++) {
    fonts.Change(k, draw_set_font);
    if (msg_chars[k] != "\n") { msg_w[k] = string_width(msg_chars[k]); }
  }
  fonts.Reset(default_font);
  draw_set_font(_font);

  msg_x = array_create(msg_length, -1);
  msg_line = array_create(msg_length, 0);
  msg_line_start = [0];
  var _line = 0;
  var _x = 0;
  var k = 0;

  while (k < msg_length) {
    if (msg_chars[k] == "\n") {
      msg_line[k] = _line;
      _line++;
      _x = 0;
      array_push(msg_line_start, k + 1);
      k++;
      continue;
    }

    // Spaces followed by a word
    var _space_start = k;
    while (k < msg_length && msg_chars[k] == " ") { k++; }
    var _word_start = k;
    while (k < msg_length && msg_chars[k] != " " && msg_chars[k] != "\n") { k++; }

    var _spaces_width = 0;
    var _word_width = 0;
    for (var j = _space_start; j < _word_start; j++) { _spaces_width += msg_w[j]; }
    for (var j = _word_start; j < k; j++) { _word_width += msg_w[j]; }

    if (_x > 0 && _word_start < k && _x + _spaces_width + _word_width > _max_width) {
      // Word goes to the next line
      for (var j = _space_start; j < _word_start; j++) { msg_line[j] = _line; }
      _line++;
      _x = 0;
      array_push(msg_line_start, _word_start);
    } else {
      for (var j = _space_start; j < _word_start; j++) {
        msg_line[j] = _line;
        msg_x[j] = _x;
        _x += msg_w[j];
      }
    }

    // Words longer than a line are split
    for (var j = _word_start; j < k; j++) {
      if (_x > 0 && _x + msg_w[j] > _max_width) {
        _line++;
        _x = 0;
        array_push(msg_line_start, j);
      }
      msg_line[j] = _line;
      msg_x[j] = _x;
      _x += msg_w[j];
    }
  }
}

/// Scrolls to the line being typed
dialogue_update_scroll = function() {
  var _last = min(ceil(char_count), msg_length) - 1;
  if (_last >= 0) {
    scroll_line = max(scroll_line, msg_line[_last] - line_max + 1);
  }
}

/* -- Player actions -- */

/// Goes to the next message, the chosen answer, or runs the flow command
dialogue_advance = function() {
  autoprocess = false;
  alarm[1] = -1;

  if (!is_undefined(dialogue_flow)) {
    var _flow = dialogue_flow;
    dialogue_flow = undefined;
    dialogue_run_flow(_flow);
    exit;
  }

  if (question_asked) { // Dialogue stack pushing
    array_push(dialogue_stack, { messages: dialogue, position: msg_current });
    dialogue = question_answers[options_cursor];
    msg_current = 0;
    msg_end = array_length(dialogue);
  }

  event_user(0); // Parsing next message
}

/// Skips to the next unskippable delay or to the end
dialogue_skip = function() {
  var _target = msg_length;
  for (var k = delays.current_count; k < delays.size; k++) {
    if (delays.values[k][2]) {
      _target = max(delays.values[k][1], char_count);
      break;
    }
  }

  if (dialogue_is_paused) {
    dialogue_is_paused = false;
    alarm[0] = -1;
  }

  // Skipped delays and sounds don't fire
  delays.Skip(_target);
  sounds.Skip(_target);
  textspeeds.FastForward(_target);
  if (sprites.FastForward(_target)) { dialogue_change_sprite(sprites.current_value, sprites.current_extra); }
  if (images.FastForward(_target)) { dialogue_change_image(images.current_value, images.current_extra); }

  char_count = _target;
  event_user(2);
  dialogue_update_scroll();
}
