function test_dialogue() {
	messages = [
		"Hello, " + environment_get_variable("USERNAME") + "!",
		"This is my dialogue system.",
		"What colour do you like?[q:0]",
	];
	
	dialogue_add_question(0, "Red",
		[
			"Brilliant! I like red too.",
			"[goto:test_dialogue2]"
		]);
		
	dialogue_add_question(0, "Green",
		[
			"Oh.. wow"
		]);
}