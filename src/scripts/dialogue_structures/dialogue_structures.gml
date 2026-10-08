/// @function DialogueOptions(default_value)
/// @description Creates new data structure which handles all changing values
function DialogueOptions(_default_value) constructor {
  current_count = 0;
  current_extra = 0;
  current_position = -1;
  current_value = _default_value;
  values = []; // [ [value, position, extra], ... ]
  size = 0;

  /// @function Put(value, position, extra)
  static Put = function(value, position, extra) {
    array_push(values, [value, position, extra]);
    size++;
  }

  /// @function Reset(default_value)
  static Reset = function(_default_value) {
    current_count = 0;
    current_extra = 0;
    current_position = (size > 0) ? values[0][1] : -1;
    current_value = _default_value;
  }

  /// @function ResetAll(default_value)
  static ResetAll = function(_default_value) {
    values = []; size = 0;
    Reset(_default_value);
  }

  /// @function Change(position, callback, [extra])
  static Change = function(position, callback, extra = false) {
    while (current_position != -1 && position >= current_position) {
      Next();

      if (callback != -1) {
        if (extra) {
          callback(current_value, current_extra);
        } else {
          callback(current_value);
        }
      }
    }
  }

  /// @function Skip(position)
  /// @description Passes values before the position without applying them
  static Skip = function(position) {
    while (current_position != -1 && position > current_position) {
      Next();
    }
  }

  /// @function FastForward(position)
  /// @description Passes values up to the position without applying them, true if any
  static FastForward = function(position) {
    var _passed = false;
    while (current_position != -1 && position >= current_position) {
      Next();
      _passed = true;
    }
    return _passed;
  }

  /// @function Next()
  static Next = function() {
    current_value = values[current_count][0];
    current_extra = values[current_count][2];
    current_count += 1;
    current_position = (current_count < size) ? values[current_count][1] : -1;
  }
}

/// @function DialogueMessage()
/// @description Parsed message: visible characters, changes and settings
function DialogueMessage() constructor {
  chars = []; // Visible characters

  colours = new DialogueOptions(-1);
  effects = new DialogueOptions(-1);
  fonts = new DialogueOptions(-1);
  highlights = new DialogueOptions(-1);
  delays = new DialogueOptions(-1);
  sounds = new DialogueOptions(-1);
  sprites = new DialogueOptions(-1);
  images = new DialogueOptions(-1);
  textspeeds = new DialogueOptions(-1);

  question = undefined; // { options, answers }
  flow = undefined;     // [exit], [pop], [open] or [gotoref]
  autoprocess_enabled = false;
  autoprocess_delay = 0;
  skip_enabled = true;

  /// @function Rewind()
  /// @description Moves every change to the start, for command-only lines
  static Rewind = function() {
    chars = [];
    var _lists = [colours, effects, fonts, highlights, delays, sounds, sprites, images, textspeeds];
    for (var i = 0; i < array_length(_lists); i++) {
      var _values = _lists[i].values;
      for (var j = 0; j < array_length(_values); j++) {
        var _entry = _values[j];
        _entry[@ 1] = 0;
      }
    }
  }
}

#region Helpers
/// @function dialogue_value_string(value)
/// @description Value as a string, "" if missing
function dialogue_value_string(_value) {
  return is_undefined(_value) ? "" : string(_value);
}

/// @function dialogue_value_bool(value, default)
/// @description Reads true/false, yes/no, on/off or a number
function dialogue_value_bool(_value, _default) {
  var _text = string_lower(string_trim(dialogue_value_string(_value)));
  
  switch (_text) {
    case "":
      return _default;
    case "true":
    case "yes":
    case "on":
      return true;
    case "false":
    case "no":
    case "off":
      return false;
  }
  
  var _digits = string_digits(_text);
  return (_digits != "") && (real(_digits) != 0);
}

/// @function dialogue_find_function(name)
/// @description Script function by name, or undefined
function dialogue_find_function(_name) {
  var _function = asset_get_index(dialogue_value_string(_name));
  return is_callable(_function) ? _function : undefined;
}

/// @function dialogue_warn(problem, command)
function dialogue_warn(_problem, _command) {
  show_debug_message("gmdialogue: " + _problem + " in [" + string(_command) + "]");
}

/// @function dialogue_is_building()
/// @description True while dialogue_open() runs a dialogue function
function dialogue_is_building() {
  var _building = false;
  with (oDialogue) {
    if (!is_undefined(dialogue_building)) {
        _building = true;
    }
  }
  return _building;
}

/// @function dialogue_has_reference(message, ref)
/// @description True if the message contains [#ref] or [#:ref]
function dialogue_has_reference(_message, _ref) {
  var _pos = string_pos("[#", _message);
  
  while (_pos > 0) {
    var _end = string_pos_ext("]", _message, _pos);
    if (_end == 0) break;

    var _id = string_copy(_message, _pos + 2, _end - _pos - 2);
    if (string_char_at(_id, 1) == ":") {
        _id = string_delete(_id, 1, 1);
    }
    if (_id == _ref) {
        return true;
    }

    _pos = string_pos_ext("[#", _message, _end);
  }
  return false;
}

/// @function dialogue_questions_in(message)
/// @description Names of the questions asked in the message
function dialogue_questions_in(_message) {
  var _names = [];
  var _pos = string_pos("[", _message);
  while (_pos > 0) {
    var _end = string_pos_ext("]", _message, _pos);
    if (_end == 0) break;

    var _values = string_split(string_copy(_message, _pos + 1, _end - _pos - 1), ":");
    if (array_length(_values) > 1 && (_values[0] == "q" || _values[0] == "question")) {
      array_push(_names, _values[1]);
    }

    _pos = string_pos_ext("[", _message, _end);
  }
  return _names;
}
#endregion
