/// @description Creates new data structure which handles all changing values
function DialogueOptions(_default_value) constructor {
	current_value = _default_value;
	current_extra = 0;
	values = [_default_value, -1, 0]; // [value, position, extra]
	options = [-1, 0]; // [current position, count]
	size = 0;
	
	/// @function Reset(default_value)
	static Reset = function(_default_value) {
		current_value = _default_value;
		options[@ 0] = (size > 0 ? values[0][1] : -1);
		options[@ 1] = 0;
	}
	
	/// @function ResetAll(default_value)
	static ResetAll = function(_default_value) {
		values = []; size = 0;
		self.Reset(_default_value);
	}
	
	/// @function Change(position, callback, extra)
	static Change = function(position, callback, extra) {
		while (options[0] != -1 && position >= options[0]) {
			current_value = values[options[1]][0];
			current_extra = values[options[1]][2];
			options[@ 0] = (options[1] < size - 1) ? values[++options[@ 1]][1] : -1;
			if (callback != -1) { 
				if (extra) {
					callback(current_value, current_extra);
				} else {
					callback(current_value);
				}
			}
		}
	}
}