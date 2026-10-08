/// @function make_colour_string(colour model, colour)
/// @argument {string} colour_model Colour model name: "rgb", "bgr" or "hsv"
/// @argument {string} colour Three numbers. Any non-digit characters separate them: "255 0 0", "255, 0, 0"
/// @returns {Real|Undefined} The colour, or undefined
function make_colour_string(colour_model, colour) {
  if (!is_string(colour)) return undefined;

  var _separated = "";
  var _length = string_length(colour);
  for (var i = 1; i <= _length; i++) {
    var _char = string_char_at(colour, i);
    _separated += (string_digits(_char) == "") ? " " : _char;
  }

  var _numbers = string_split(_separated, " ", true);
  if (array_length(_numbers) < 3) return undefined;

  var _a = real(_numbers[0]);
  var _b = real(_numbers[1]);
  var _c = real(_numbers[2]);

  switch (colour_model) {
    case "rgb":
      return make_colour_rgb(min(_a, 255), min(_b, 255), min(_c, 255));
    case "bgr":
      return make_colour_rgb(min(_c, 255), min(_b, 255), min(_a, 255));
    case "hsv":
      return make_colour_hsv(min(_a, 360) * 17 / 24, min(_b, 100) * 2.55, min(_c, 100) * 2.55);
    default:
      return undefined;
  }
}
