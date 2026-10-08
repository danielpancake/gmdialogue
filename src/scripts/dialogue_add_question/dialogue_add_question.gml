/// @function dialogue_add_question(index, option, answer)
/// @argument {string} index Question name
/// @argument {string} option Option text
/// @argument {array} answer The array of messages to be displayed after selection
// Should only be called inside dialogue script
function dialogue_add_question(index, option, answer) {
  index = string(index);
  if (!is_array(answer)) { answer = [answer]; }

  // The dialogue being opened, or the open one
  var _questions = undefined;
  with (oDialogue) {
    _questions = is_undefined(dialogue_building) ? question_map : dialogue_building.questions;
  }

  if (is_undefined(_questions)) {
    show_debug_message("gmdialogue: dialogue_add_question() was called without a dialogue");
    exit;
  }

  var _question = _questions[$ index];
  if (is_undefined(_question)) {
    _question = { options: [], answers: [] };
    _questions[$ index] = _question;
  }

  array_push(_question.options, string(option));
  array_push(_question.answers, answer);
}
