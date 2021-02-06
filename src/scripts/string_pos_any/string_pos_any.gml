/// @function string_pos_any(substrings, str)
/// @argument {array} substrings
/// @argument {string} str
function string_pos_any(substrings, str) {
	for (var i = 0; i < array_length(substrings); i++) {
		var pos = string_pos(substrings[i], str);
		if (pos != 0) return [pos, substrings[i]];
	}
	return [0];
}