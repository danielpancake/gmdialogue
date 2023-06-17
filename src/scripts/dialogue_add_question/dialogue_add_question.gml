/// @function dialogue_add_question(index, option, answer)
/// @argument {string} index Question name
/// @argument {string} option Option text
/// @argument {array} answer The array of messages to be displayed after selection
// Should only be called inside dialogue script
function dialogue_add_question(index, option, answer) {
  index = string(index); 
  
  if (is_undefined(question_map[? index])) {
    question_map[? index] = [[], []];
  }
  
  array_push(question_map[? index][0], option);
  array_push(question_map[? index][1], answer);
}