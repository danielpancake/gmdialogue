/// @function dialogue_add_question(index, option, answer)
/// @argument {number} index The real number representing question index
/// @argument {string} option The option text to be shown
/// @argument {array} answer The array of messages to be displayed after selection
// Should only be called inside dialogue script
function dialogue_add_question(index, option, answer) {
	if (index >= 0) {
		if (index >= array_length(questions)) {
			array_insert(questions, index, [[], []]);
		}
		
		array_push(questions[index][0], option);
		array_push(questions[index][1], answer);
	}
}