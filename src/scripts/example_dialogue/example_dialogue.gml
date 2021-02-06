/// @function example_dialogue()
function example_dialogue() {
	messages = [
		"Welcome, [c:yellow]" + environment_get_variable("USERNAME"),
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.[q:0]",
		
		"When the text of the question ends, the main dialogue continues.",
		"The end."
	];
	
	dialogue_add_question(0, "Okay!", [
		"Thank you for testing this dialogue system!",
		"It's still in its early stage.",
		"Repeat?[q:1]"
	]);
	
	dialogue_add_question(1, "Yeah", ["[open:example_dialogue]"]);
	dialogue_add_question(1, "No", ["Bye!"]);
}