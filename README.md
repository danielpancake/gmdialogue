# gmdialogue

gmdialogue is a dialogue system for GameMaker that uses command blocks to apply effects to the text

## Usage

`dialogue_setup();` creates the small data structures needed for parsing (colours, effects, characters, layouts, text speeds and input). `dialogue_open()` calls it automatically, so you only need to call it yourself if you want to change these values before the first dialogue. Calling it more than once is safe.

Dialogues used with this asset are stored as gml **scripts** of **functions**. To open dialogue call `dialogue_open(dialogue, [ arg1, arg2, arg3 ]);`, where `dialogue` is the name of the script or function (global or local) which contains dialogue. Script or function parameters are passed in the form of a value array, which can be omitted.

Dialogue script / function must contain an array of strings named `messages`. The function runs in the scope of the dialogue instance. E.g.:

```gml
function example_dialogue() {
    messages = [
        "Line 1",
        "Line 2",
        "Line 3"
    ];
}

...

dialogue_open(example_dialogue, []);
```

If you want to open a dialogue from the specific position, use `dialogue_open_at(dialogue, [args], position);` function, where a third argument points to the index of an element in the `messages` array.

Another way of opening dialogue is reading it from a text file with `dialogue_open(dialogue_from_file, [filename]);` (or just `dialogue_from_file(filename);`). It reads the given text file line by line. Each line is treated as a separate message. A missing file closes the dialogue.

You do not need to close (destroy) existing dialogue instance to open another. Calling `dialogue_open();` while a dialogue is open interrupts the current dialogue and starts the requested one: its dialogue stack and questions are dropped. Opening a dialogue while the previous one is fading out brings the box back. To close a dialogue, call `dialogue_destroy();`: the box fades out, then the instance is destroyed.

In order to check the presence of a dialogue instance, use the `global.dialogue_is_open` boolean variable. It is `true` while the dialogue box exists, fade-out included, and goes back to `false` when it is destroyed or when the room changes.

### Controls

Enter goes to the next message or picks the selected option, Up and Down move between options, Shift shows the whole message at once. To use other input, replace the functions in `global.dialogue_input` after calling `dialogue_setup()`, or define the whole struct (with all four functions) before it:

```gml
dialogue_setup();
global.dialogue_input.advance = function() {
    return keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_face1);
};
```

### Command blocks

Dialogue messages are plain strings. There are different **command blocks** which can be used to change the appearance and properties of a message or a textbox, play sound or to control dialogue instance itself.

Each command block has the following structure: in square brackets, name of the command followed by none or more values all separated with colons `[name:value:value:value]`. Square brackets that aren't a known command are shown as text; to show a `[` right before something that looks like a command, write `[[`.

Here is a table of the available commands. Some elements of this table include aspects of the dialogue system which will be discussed later. For some commands such as `colour`, `effect`, `font`, `highlight`, `image index`, `sound`, etc., position matters.

| Name | Syntax | Values | Description |
| --- | --- | --- | --- |
| Autoprocess | `[auto]`<br/>`[auto:delay]` | `delay` — number of steps before processing to the next message. Omitted or `0`: right away | This command tells dialogue system to automatically go to the next message after current has been displayed |
| Character | `[chr:index]`<br/>`[character:index]` | `index` — value representing character index | Sets dialogue character |
| Colour | `[c:index]`<br/>`[col:index]`<br/>`[color:index]`<br/>`[colour:index]`<br/><br/>`[c:model:colour]`<br/>...same for the rest | `index` — value representing colour index<br/><br/>`model` — one of the colour models: `rgb`, `bgr` or `hsv`<br/>`colour` — three numbers separated by spaces or commas. For `hsv`: hue 0–360, saturation and value 0–100 | Sets text colour. `[c:]` goes back to the default colour |
| Highlight | `[h:index]`<br/>`[highlight:index]`<br/><br/>`[h:model:colour]`<br/>...same for the rest | Same as for colour | Sets text highlight colour. `[h:]` removes the highlight |
| Delay | `[d:delay]`<br/>`[delay:delay]`<br/><br/>`[d:delay:unskippable]`<br/>...same for the rest | `delay` — number of steps to wait<br/>`unskippable` — `true` or `false` (`1`/`0` work too). If true, delay cannot be skipped. Can be omitted. False by default | Stops dialogue for the given amount of steps |
| Effect | `[e:index]`<br/>`[effect:index]` | `index` — value representing effect index | Sets text effect. `[e:]` goes back to normal |
| Exit | `[exit]` | --- | Closes dialogue |
| Font | `[f:index]`<br/>`[font:index]` | `index` — name of a font asset | Sets text font. `[f:]` goes back to the default font |
| Go to reference | `[gotoref:dialogue:refID]` | `dialogue` — name of a script / function containing dialogue<br/>`refID` — id of the desired reference | Opens given dialogue from the referenced line. The reference can also be in an answer: when that answer ends, the dialogue continues after its question. Note: this command will clear the dialogue stack! If the reference is absent, the dialogue ends |
| Reference | `[#refID]`<br/>`[#:refID]` | `refID` — id to be referenced | Only used for referencing messages |
| Image index | `[i:index]`<br/>`[index:index]`<br/><br/>`[i:index:sliding]`<br/>...same for the rest | `index` — number of the sub—image of the current dialogue sprite<br/>`sliding` — `true` or `false`. If true, the sprite will slide from the side. Can be omitted. True by default | Changes sprite image index |
| Layout | `[l:index]`<br/>`[layout:index]` | `index` — value representing layout index | Sets dialogue layout |
| Method | `[method:function:arg1:arg2...]` | `function` — name of a script function<br/>`arg1...` — its arguments (strings) | Calls the function as soon as the message is reached (not at its position in the text). Any script function can be called this way, so don't use it with dialogue files players can edit |
| No skip | `[noskip]` | --- | Disables skip for current message |
| New dialogue | `[o:dialogue:arg1:arg2...]`<br/>`[open:dialogue:arg1:arg2...]`<br/><br/>`[open:dialogue_from_file:filename]` | `dialogue` — name of a script / function containing dialogue | Opens specified dialogue. Note: this command will clear the dialogue stack! |
| Pop out | `[pop]` | --- | Ends current sub-dialogue (branch created by `question` command) and returns to previous dialogue |
| Sound | `[snd:index]` | `index` — name of a sound asset | Plays a sound |
| Sprite index | `[spr:index]`<br/>`[sprite:index]`<br/><br/>`[spr:index:sliding]`<br/>...same for the rest | `index` — name of a sprite asset<br/>`sliding` — `true` or `false`. If true, the sprite will slide from the side. Can be omitted. True by default | Changes sprite |
| Text speed | `[ts:index]` | `index` — value representing text speed (e.g. `slow`, `normal`, `fast` or `max`) | Sets text speed. At `max` the text appears at once, without pauses after punctuation |
| Question | `[q:index]`<br/>`[question:index]` | `index` — question name | Shows question |

`[exit]`, `[pop]`, `[open]` and `[gotoref]` take effect when the player moves on from the message, so text written before them is shown first. On a line without text they take effect right away.

A line that contains only commands (no text) is not shown as a separate message: its commands apply from the start of the next line. For example, a line with just `[d:60]` waits 60 steps before the next line starts.

Unknown commands, characters, colours and other values are reported with `show_debug_message()`.

### Questions and branching (kind of)

There is just one function `dialogue_add_question();` and one command `[q:]` for working with questions. A question consists of options and answers. Similarly to dialogues, the answer is an array of messages (a single string works too). New questions are created inside the dialogue function with `dialogue_add_question(index, option, []);` function, where `index` is a name of the question, it is used in `[q:]` command. To create a question with multiple choices call `dialogue_add_question();` with the same question's name multiple times.

When answer-dialogue (sub-dialogue) ends, previous dialogue continues. This hierarchy is called **dialogue stack**. Answers can ask questions of their own.

Note: opening a new dialogue (from code or with `[open:]`) destroys both dialogue stack and questions of the current one!

```gml
function example_dialogue() {
    messages = [
        "Line 1",
        "Line 2",
        "Line 3 [q:MORE]",

        "Line 6",
        "Line 7"
    ];

    dialogue_add_question("MORE", "MORE!", [
        "Line 4",
        "Line 5"
    ]);
}
```

Output of this dialogue will be as following:

```output
Line 1
Line 2
Line 3
Line 4
Line 5
Line 6
Line 7
```

Besides, it is possible to use `[open:]` command to switch between dialogues imperceptibly.

Thank you for checking out this asset!

## Requirements

- A recent GameMaker version (tested with GameMaker LTS 2026, runtime 2026.0.0.23)
