/// @funciton make_colour_unsafe_strings(colour space, channel a, b, c)
/// @argument {string} colour_space Colour space name: "rgb" or "hsv"
/// @argument {string} ch_a Channel №1
/// @argument {string} ch_b Channel №2
/// @argument {string} ch_c Channel №3
function make_colour_unsafe_strings(colour_space, ch_a, ch_b, ch_c) {
	var a = string_digits(ch_a);
	var b = string_digits(ch_b);
	var c = string_digits(ch_c);
	if (a != "" && b != "" && c != "") {
		switch (colour_space) {
			case "rgb": return make_colour_rgb(a, b, c);
			case "hsv": return make_colour_hsv(a, b, c);
			default: return c_white;
		}
	} else {
		return c_white;	
	}
}