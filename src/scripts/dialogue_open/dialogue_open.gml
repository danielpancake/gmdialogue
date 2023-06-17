/// @function dialogue_open_at(index, [arg1,arg2,...], position)
/// @argument {number} index Asset index of the script containing the dialogue
/// @argument {array} arguments Arguments to execute dialogue script with
/// @argument {number} position The index of the first message in the dialogue
function dialogue_open_at(index, arguments, position) {
  if (!global.dialogue_is_open) {
    instance_create_depth(0, 0, 0, oDialogue);
  }
  
  with (oDialogue) {
    stack_index = [-1, -1];
    stack_option = 0;
    
    script_execute_ext(index, arguments);
    
    dialogue = messages;
    msg_current = position;
    msg_end = array_length(dialogue);
    
    dialogue_set_layout(-1);
    event_user(0);
  }
}

/// @function dialogue_open(index, [arg1,arg2,...])
/// @argument {number} index Asset index of the script containing the dialogue
/// @argument {array} arguments Arguments to execute dialogue script with
function dialogue_open(index, arguments) {
  dialogue_open_at(index, arguments, 0);
}

/// @function dialogue_from_file(filename)
/// @description This function loads dialogue messages from the file
/// Usage (in dialogue): "... [open:dialogue_from_file:filename] ..."
/// @argument {string} filename The name of the file to read from
function dialogue_from_file(filename) {
  messages = [];
  
  var f = file_text_open_read(filename);
  while (!file_text_eof(f)) {
    array_push(messages, file_text_read_string(f));
    // Ignore all /n and /r's at the end of the lines
    file_text_readln(f);
  }
  file_text_close(f);
}