/// @description Destroy dialogue object
global.dialogue_is_open = false;
ds_map_destroy(question_map);
ds_stack_destroy(dialogue_stack);