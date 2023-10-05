# gmdialogue

This is a desing document for the dialogue system and its syntax.

## Syntax

All commands works either as text modifiers or external commands.

### Text modifiers

Text modifiers are commands that are used to modify the text in some way. There is a list of common (already implemented) text modifiers:

- `colour` - changes the colour of the text;
- `effect` - adds an effect to the text;
- `font` - changes the font of the text;
- `highlight` - highlights the text.

It is a good idea to also add these text modifiers:

- `size` - changes the size of the text;
- `style` - changes the style of the text (bold, italic, etc.);
- `link` - adds a link to the text.

### External commands

External commands are commands that are used to do something outside of the text. There is a list of common (already implemented) external commands:

- `autoproceed` - automatically proceeds to the next dialogue line when the current one is finished;
- `character` - changes the character that is speaking;
- `delay` - stops the dialogue for a specified amount of time at specified character;
- `exit` - exits the dialogue;
- `gotoref` - goes to a specified reference in the other dialogue;
- `image index` - changes the image of the character (should be renamed to `expression` or something like that);
- `layout` - changes the layout of the dialogue box;
- `open` - opens a new dialogue;
- `pop` - exits the current subdialogue created by `question`;
- `question` - shows a question and branches the dialogue depending on the answer;
- `reference` - creates a reference to the current dialogue line;
- `sound` - plays a sound;
- `speed` - changes the speed of the text;
- `sprite` - changes the sprite of the character.
