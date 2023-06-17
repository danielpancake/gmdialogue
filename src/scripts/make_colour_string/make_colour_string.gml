/// @function make_colour_string(colour model, colour)
/// @argument {string} colour_model Colour model name: "rgb", "bgr" or "hsv"
/// @argument {string} colour Colour values separated with space
function make_colour_string(colour_model, colour) {
  var buffer = buffer_create(11, buffer_fixed, 1);
  buffer_seek(buffer, buffer_seek_start, 0);
  buffer_write(buffer, buffer_text, colour);
  
  static __colour = array_create(3, 0);
  __colour[0] = 0; __colour[1] = 0; __colour[2] = 0;
  
  for (var i = 0, j = 0; i < 11 && j < 3; i++) {
    var value = buffer_peek(buffer, i, buffer_u8) - 48;
    // Any other characters than digits are treated as space
    // Thus they show where a number ends
    var in_range = value >= 0 && value <= 9;
    
    __colour[j] += (9 * __colour[j] + value) * in_range;
    j += !in_range;
  }
  
  buffer_delete(buffer);
  
  switch (colour_model) {
    case "rgb":
      return make_colour_rgb(__colour[0], __colour[1], __colour[2]);
    case "bgr":
      return make_colour_rgb(__colour[2], __colour[1], __colour[0]);
    case "hsv":
      return make_colour_hsv(__colour[0] * 17 / 24, __colour[1] * 2.55, __colour[2] * 2.55);
    default: return undefined;
  }
}