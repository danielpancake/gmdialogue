/// @function dialogue_values_changer(array, param, pos, maximum, callback)
/// @description This function changes the values in the specified array of options
/// Used only with the dialogue system for not to copy the same procedure over and over
function dialogue_values_changer(array, param, pos, maximum, callback){
	if (param[2] != -1 && pos >= param[2]) {
		param[@ 0] = (array[param[1]] >> 32) & 0xffffffff;
		param[@ 2] = (param[1] < maximum - 1) ? array[++param[@ 1]] & 0xffffffff : -1;
		if (callback != -1) callback(param[0]);
	}
}

/// @dialogue_values_reset(array, default_value, count, position)
function dialogue_values_reset(array, default_value, count, position) {
	array[@ 0] = default_value;
	array[@ 1] = count;
	array[@ 2] = position;
}