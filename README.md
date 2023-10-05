# gmdialogue

gmdialogue is a dialogue system for GameMaker Studio 2.3+ that uses command blocks to apply effects to the text

## Usage

Before ever using this dialogue system be sure to put `dialogue_setup();` somewhere in the beginning of the game. This function will create small data structures needed for parsing. Values of these structures can be changed as you wish.

Dialogues used with this asset are stored as gml **scripts** of **functions**. To open dialogue call `dialogue_open(dialogue, [ arg1, arg2, arg3 ]);`, where `dialogue` is the name of the script or function (global or local) which contains dialogue. Script or function parameters are passed in the form of a value array.

Dialogue script / function must contain an array of strings named `messages`. E.g.:

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

Another way of opening  dialogue is upon calling the `dialogue_from_file(filename);` function. It reads the given text file line by line. Each line is treated as a separate message.

You do not need to close (destroy) existing dialogue instance to open another. Calling `dialogue_open();` with a dialogue instance already exists will interrupt the current dialogue and start the requested one.

In order to check the presence of a dialogue instance, use the `global.dialogue_is_open` boolean variable.

Dialogue messages are plain strings. There are different **command blocks** which can be used to change the appearance and properties of a message or a textbox, play sound or to control dialogue instance itself.

Each command block has the following structure: in square brackets, name of the command followed by none or up to 8 values all separated with colons `[name:value:value:value]`.

### Command blocks

Here is a table of the available commands. Some elements of this table include aspects of the dialogue system which will be discussed later. For some commands such as `colour`, `effect`, `font`, `highlight`, `image index`, `sound`, etc., position matters.

| Name | Syntax | Values | Description |
| --- | --- | --- | --- |
| Autoproccess | `[auto:delay]` | `delay` — number of steps before processing to the next message | This command tells dialogue system to automatically go to the next message after current has been displayed |
| Character | `[chr:index]`<br/>`[character:index]` | `index` — value representing character index | Sets dialogue character |
| Colour | `[c:index]`<br/>`[col:index]`<br/>`[color:index]`<br/>`[colour:index]`<br/><br/>`[c:model:colour]`<br/>...same for the rest | `index` — value representing colour index<br/><br/>`model` — one of the colour models: `rgb`, `bgr` or `hsv`<br/>`colour` — three numbers separated by spaces | Sets text colour |
| Highlight | `[h:index]`<br/>`[highlight:index]`<br/><br/>`[h:model:colour]`<br/>...same for the rest | `index` — value representing colour index<br/><br/>`model` — one of the colour models: `rgb`, `bgr` or `hsv`<br/>`colour` — three numbers separated by spaces | Sets text highlight colour |
| Delay | `[d:delay]`<br/>`[delay:delay]`<br/><br/>`[d:delay:unskippable]`<br/>...same for the rest | `delay` — number of steps to wait<br/>`unskippable` — boolean value. If true, delay cannot be skipped. Can be omitted. False by default | Stops dialogue for the given amount of steps |
| Effect | `[e:index]`<br/>`[effect:index]` | `index` — value representing effect index | Sets text effect |
| Exit | `[exit]` | --- | Immediately closes dialogue |
| Font | `[f:index]`<br/>`[font:index]` | `index` — value representing font name | Sets text font |
| Go to reference | `[gotoref:dialogue:refID]` | `dialogue` — asset index of a script / function containing dialogue<br/>`refID` — id of the desired reference | Opens given dialogue from the referenced line. Note: this command will clear the dialogue stack! If the reference is absent, the dialogue ends |
| Reference | `[#refID]` | `refID` — id to be referenced | Only used for referencing messages |
| Image index | `[i:index]`<br/>`[index:index]`<br/><br/>`[i:index:sliding]`<br/>...same for the rest | `index` — number of the sub—image of the current dialogue sprite<br/>`sliding` — boolean value. If true, the sprite will slide from the side. Can be omitted. True by default | Changes sprite image index |
| Layout | `[l:index]`<br/>`[layout:index]` | `index` — value representing layout index | Sets dialogue layout |
| No skip | `[noskip]` | --- | Disables skip for current message |
| New dialogue | `[o:dialogue:arg1:arg2...]`<br/>`[open:dialogue:arg1:arg2...]`<br/><br/>`[open:dialogue_from_file:filename]` | `dialogue` — asset index of a script / function containing dialogue | Opens specified dialogue. Note: this command will clear the dialogue stack! |
| Pop out | `[pop]` | --- | Ends current sub-dialogue (branch created by `question` command) and returns to previous dialogue |
| Sound | `[snd:index]` | `index` — value representing sound name | Plays a sound |
| Sprite index | `[spr:index]`<br/>`[sprite:index]`<br/><br/>`[spr:index:sliding]`<br/>...same for the rest | `index` — asset index of a sprite<br/>`sliding` — boolean value. If true, the sprite will slide from the side. Can be omitted. True by default | Changes sprite |
| Text speed | `[ts:index]` | `index` — value representing text speed (e.g. `slow`, `normal` or `fast`) | Sets text speed |
| Question | `[q:index]`<br/>`[question:index]`| `index` — question name | Shows question |

### Questions and branching (kind of)

There is just one function `dialogue_add_question();` and one command `[q:]` for working with questions. A question consists of options and answers. Similarly to dialogues, the answer is an array of messages. New questions are created inside the dialogue function with `dialogue_add_question(index, option, []);` function, where `index` is a name of the question, it is used in `[q:]` command. To create a question with multiple choices call `dialogue_add_question();` with the same question's name multiple times.

When answer-dialogue (sub-dialogue) ends, previous dialogue continues. This hierarchy is called **dialogue stack**.

Note: opening new dialogue destroys both dialogue stack and question map!

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

- GameMaker Studio 2.3+
