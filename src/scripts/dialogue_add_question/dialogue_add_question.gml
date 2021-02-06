/// @function dialogue_add_question(index, option, answer)
/// @argument {real} index
/// @argument {string} option
/// @argument {array} answer
// Should only be called inside dialogue script
function dialogue_add_question(index, option, answer) {
	if (index >= 0) {
		if !(index < array_length(questions)) {
			array_insert(questions, index, [[], []]);
		}
		
		array_push(questions[index][0], option);
		array_push(questions[index][1], answer);
	}
}