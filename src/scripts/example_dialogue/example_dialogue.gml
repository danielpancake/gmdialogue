/// @function example_dialogue()
function example_dialogue() {
  /* Loading external files */
  var file = file_find_first("*.txt", 0), nothing = true;
  
  while (file != "") {
    nothing = false;
    dialogue_add_question(2, file, ["[open:dialogue_from_file:" + file + "]"]);
    file = file_find_next();
  }
  file_find_close();
  dialogue_add_question(2, "Game menu example", ["[open:menu_text]"]);
  dialogue_add_question(2, "Skip", [""]);
  
  messages = [
    "Welcome, [h:yellow][c:black][e:waving]" + environment_get_variable("USERNAME"),
    (nothing ? "" : "Which file do you want to open?[q:2]"),
    
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " +
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet," +
      "consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." +
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore" +
      "et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, " +
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.[q:0]",
    
    "When the text of the question ends, the main dialogue continues.",
    "Play external file:",
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

/// @function menu_text()
function menu_text() {
  messages = ["* Game Title / Main menu *[q:0]", ""];
  
  dialogue_add_question(0, "Play", [
    "[open:menu_text]"
  ]);
  dialogue_add_question(0, "Quit", [
    "Bye bye"
  ]);
}
