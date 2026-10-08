/// @function dialogue_open_at(index, [arg1,arg2,...], position)
/// @argument {Function} index Script or function containing the dialogue (global or local)
/// @argument {Array} arguments Arguments to execute dialogue script with
/// @argument {Real} position The index of the first message in the dialogue
function dialogue_open_at(index, arguments = [], position = 0) {
  dialogue_setup();

  if (!is_callable(index)) {
    show_debug_message("gmdialogue: can't open " + string(index) + ", it is not a script or function");
    exit;
  }

  var _dialogue = instance_exists(oDialogue) ? instance_find(oDialogue, 0) : instance_create_depth(0, 0, 0, oDialogue);
  with (_dialogue) {
    dialogue_set_layout(-1); // Before the dialogue, so it can set its own
    dialogue_start(dialogue_build(index, arguments), position);
  }
}

/// @function dialogue_open(index, [arg1,arg2,...])
/// @argument {Function} index Script or function containing the dialogue (global or local)
/// @argument {Array} arguments Arguments to execute dialogue script with
function dialogue_open(index, arguments = []) {
  dialogue_open_at(index, arguments, 0);
}

/// @function dialogue_from_file(filename)
/// @description This function loads dialogue messages from the file
/// Usage: dialogue_open(dialogue_from_file, [filename]) or "... [open:dialogue_from_file:filename] ..."
/// @argument {string} filename The name of the file to read from
function dialogue_from_file(filename) {
  if (!dialogue_is_building()) {
    dialogue_open(dialogue_from_file, [filename]);
    exit;
  }

  messages = [];

  if (!file_exists(filename)) {
    show_debug_message("gmdialogue: dialogue file \"" + string(filename) + "\" not found");
    exit;
  }

  var f = file_text_open_read(filename);
  if (f == -1) {
    show_debug_message("gmdialogue: can't read dialogue file \"" + string(filename) + "\"");
    exit;
  }

  while (!file_text_eof(f)) {
    array_push(messages, file_text_read_string(f));
    // Ignore all /n and /r's at the end of the lines
    file_text_readln(f);
  }
  file_text_close(f);
}
