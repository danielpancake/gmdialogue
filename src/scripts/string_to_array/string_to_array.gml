/* 
 * string_to_array.gml
 *
 * Author: danielpancake
 * Release date: 07.02.21
 * Last updated: 29.07.23
 *
 * https://danielpancake.github.io
 */

/// @function string_to_array(_str, _length)
/// @description Converts a string to a character array using a buffer and UTF-8 byte encoding.
///
///              Does it handle incorrect byte sequence? No. Since it puts a UTF-8 encoded string
///              into the buffer, I do not think it is possible for it to become incorrect mid-way
/// @argument {String} _str The string to split into a character array
/// @argument {Real} _length The length of the given string
/// @pure
/// @returns {Array<String>} Returns an array of characters
function string_to_array(_str, _length) {
  var _output_arr = array_create(_length, chr(0));
  var _output_curr = 0;

  var _str_bytes = string_byte_length(_str);

  // Creating a buffer
  var _buff = buffer_create(_str_bytes, buffer_fixed, 1);
  buffer_seek(_buff, buffer_seek_start, 0);
  buffer_write(_buff, buffer_text, _str);

  // Allocating variables
  var _byte = 0;
  var _byte_offset = 0;
  var _byte_offset_ahead = 0;

  var _bit_offset = 0;

  var _char = chr(0);
  var _peek = 0;

  // Iterating through bytes
  while (_byte_offset < _str_bytes) {
    _byte = buffer_peek(_buff, _byte_offset, buffer_u8);

    //
    // Checking the first 5 bits of each byte to determine how many bytes
    // current Unicode character consists of:
    //
    // 0_xxxxxxx - 1 byte;
    // 110_xxxxx - 2 bytes;
    // 1110_xxxx - 3 bytes;
    // 11110_xxx - 4 bytes.
    //

    _bit_offset = 0;
    repeat (5) {
      // Checking current bit with mask 128 = 2^7 = 0b1000000
      if ((_byte & (128 >> _bit_offset)) == 0) {
        break;
      }
       _bit_offset += 1;
    }

    _byte_offset_ahead = 1;

    // Skipping most significant bits of the first octet
    _char = _byte & (255 >> _bit_offset);

    // ..if encoded with multiple octets
    repeat (_bit_offset - 1) {
      _peek = buffer_peek(_buff, _byte_offset + _byte_offset_ahead, buffer_u8);
      // Each octet after the first one should be in form
      // of 10_xxxxxx. So, we skip two most significant bits
      // and concat the rest to the right of the sequence
      _char = (_char << 6) | (_peek & 63);
      _byte_offset_ahead += 1;
    }

    _output_arr[_output_curr] = chr(_char);
    _output_curr += 1;

    _byte_offset += max(1, _bit_offset);
  }

  buffer_delete(_buff);
  return _output_arr;
}

/*
 * ===== Additional functions for working with character arrays =====
 *
 * These functions have three types of suffixes:
 *   - no suffix - function referseither to the whole character array
 *                 or a specific index
 *
 *   - "_slice"  - function refers to the substring given the starting
 *                 index and the number of characters
 *
 *   - "_range"  - function refers to the substring given the starting
 *                 and stopping indices
 */

/// @function char_array_insert(_char_arr, _index, _char)
/// @description Inserts a character at the given index in the character array.
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array to insert into
/// @argument {Real} _index The index to insert at
/// @argument {String} _char The character to insert
/// @returns {Array<String>} Reference to the original character array
function char_array_insert(_char_arr, _index, _char) {
  var _char_arr_len = array_length(_char_arr);
  array_resize(_char_arr, _char_arr_len + 1);

  for (var _i = _char_arr_len; _i > _index; --_i) {
    _char_arr[@ _i] = _char_arr[_i - 1];
  }

  _char_arr[@ _index] = _char;
  return _char_arr;
}

#region char_array_string
/// @function char_array_string(_char_arr)
/// @description Joins the entire character array into a string
/// @argument {Array<String>} _char_arr The character array
/// @pure
/// @returns {String} String made from the whole character array
function char_array_string(_char_arr) {
  return char_array_string_slice(_char_arr, 0, array_length(_char_arr));
}

/// @function char_array_string_slice(_char_arr, _index, _count)
/// @description Joins a slice of the character array into a string
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to join
/// @pure
/// @returns {String} String made from the slice
function char_array_string_slice(_char_arr, _index, _count) {
  if (_count >= 0) {
    return char_array_string_range(_char_arr, _index, _index + _count);
  }
  return char_array_string_range(_char_arr, _index + _count + 1, _index + 1);
}

/// @function char_array_string_range(_char_arr, _from, _to)
/// @description Joins a range of the character array into a string
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @pure
/// @returns {String} String made from the range
function char_array_string_range(_char_arr, _from, _to) {
  var _output = "";

  for (var _i = _from; _i < _to; ++_i) {
    _output += _char_arr[_i];
  }

  return _output;
}
#endregion

#region char_array_count
/// @function char_array_count(_char_arr, _char)
/// @description Counts occurrences of a character in the character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {String} _char The character to count
/// @pure
/// @returns {Real} Count of the character
function char_array_count(_char_arr, _char) {
  return char_array_count_slice(_char_arr, 0, array_length(_char_arr), _char);
}

/// @function char_array_count_slice(_char_arr, _index, _count, _char)
/// @description Counts occurrences of a character in a slice of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @argument {String} _char The character to count
/// @pure
/// @returns {Real} Count of the character in the slice
function char_array_count_slice(_char_arr, _index, _count, _char) {
  if (_count >= 0) {
    return char_array_count_range(_char_arr, _index, _index + _count, _char);
  }
  return char_array_count_range(_char_arr, _index + _count + 1, _index + 1, _char);
}

/// @function char_array_count_range(_char_arr, _from, _to, _char)
/// @description Counts occurrences of a character in a range of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @argument {String} _char The character to count
/// @pure
/// @returns {Real} Count of the character in the range
function char_array_count_range(_char_arr, _from, _to, _char) {
  var _count = 0;

  for (var _i = _from; _i < _to; ++_i) {
    _count += real(_char_arr[_i] == _char);
  }

  return _count;
}
#endregion

#region char_array_pos
/// @function char_array_pos(_char_arr, _char)
/// @description Finds index of first occurrence in the character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {String} _char Character to find
/// @pure
/// @returns {Real} Index of the first occurrence. -1 if found none
function char_array_pos(_char_arr, _char) {
  return char_array_pos_slice(_char_arr, 0, array_length(_char_arr), _char);
}

/// @function char_array_pos_slice(_char_arr, _index, _count, _char)
/// @description Finds index of first occurrence in a slice of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @argument {String} _char Character to find
/// @pure
/// @returns {Real} Index of the first occurrence in the slice. -1 if found none
function char_array_pos_slice(_char_arr, _index, _count, _char) {
  if (_count >= 0) {
    return char_array_pos_range(_char_arr, _index, _index + _count, _char);
  }
  return char_array_pos_range(_char_arr, _index + _count + 1, _index + 1, _char);
}

/// @function char_array_pos_range(_char_arr, _from, _to, _char)
/// @description Finds index of first occurrence in a range of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @argument {String} _char Character to find
/// @pure
/// @returns {Real} Index of the first occurrence in the range. -1 if found none
function char_array_pos_range(_char_arr, _from, _to, _char) {
 for (var _i = _from; _i < _to; ++_i) {
    if (_char_arr[_i] == _char) {
      return _i;
    }
  }

  return -1;
}
#endregion

#region char_array_pos_any_match
/// @function char_array_pos_any(_char_arr, _chars)
/// @description Finds index and character of the first match in the character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Array<String>} _chars Characters to match
/// @pure
/// @returns {Struct} Index and character of the first match
function char_array_pos_any_match(_char_arr, _chars) {
  return char_array_pos_any_match_slice(_char_arr, 0,  array_length(_char_arr), _chars);
}

/// @function char_array_pos_any_match_slice(_char_arr, _index, _count, _chars)
/// @description Finds index and character of the first match in a slice of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @argument {Array<String>} _chars Characters to match
/// @pure
/// @returns {Struct} Index and character of the first match in slice
function char_array_pos_any_match_slice(_char_arr, _index, _count, _chars) {
  if (_count >= 0) {
    return char_array_pos_any_match_range(_char_arr, _index, _index + _count, _chars);
  }
  return char_array_pos_any_match_range(_char_arr, _index + _count + 1, _index + 1, _chars);
}

/// @function char_array_pos_any_match_range(_char_arr, _from, _to, _chars)
/// @description Finds index and character of the first match in a range of character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @argument {Array<String>} _chars Characters to match
/// @pure
/// @returns {Struct} Index and character of the first match in range
function char_array_pos_any_match_range(_char_arr, _from, _to, _chars) {
  var _chars_len = array_length(_chars);

  for (var _i = _from; _i < _to; ++_i) {
    for (var _j = 0; _j < _chars_len; ++_j) {
      var _c = _chars[_j];

      if (_char_arr[_i] == _c) {
        return {
          char: _c,
          position: _i,
        };
      }
    }
  }

  return {
    char: "",
    position: -1,
  };
}
#endregion

#region char_array_delete
/// @function char_array_delete(_char_arr, _index)
/// @description Deletes character at index.
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index Index to delete
/// @returns {Array<String>} Reference to the original character array
function char_array_delete(_char_arr, _index) {
  return char_array_delete_slice(_char_arr, _index, 1);
}

/// @function char_array_delete_slice(_char_arr, _index, _count)
/// @description Deletes a slice of characters
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @returns {Array<String>} Reference to the original character array
function char_array_delete_slice(_char_arr, _index, _count) {
  if (_count >= 0) {
    return char_array_delete_range(_char_arr, _index, _index + _count);
  }
  return char_array_delete_range(_char_arr, _index + _count + 1, _index + 1);
}

/// @function char_array_delete_range(_char_arr, _from, _to)
/// @description Deletes a range of characters
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @returns {Array<String>} Reference to the original character array
function char_array_delete_range(_char_arr, _from, _to) {
  var _char_arr_len = array_length(_char_arr);

  for (var _i = _to; _i < _char_arr_len; ++_i) {
    _char_arr[@ _i + _from - _to] = _char_arr[_i];
  }

  array_resize(_char_arr, _char_arr_len + _from - _to);
  return _char_arr;
}
#endregion

#region char_array_set
/// @function char_array_set(_char_arr, _index, _char)
/// @description Sets character at index of the character array
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index Index to set
/// @argument {String} _char Character to set
/// @returns {Array<String>} Reference to the original character array
function char_array_set(_char_arr, _index, _char) {
  _char_arr[@ _index] = _char;
  return _char_arr;
}

/// @function char_array_set_slice(_char_arr, _index, _count, _char)
/// @description Sets a slice of characters in the character array
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @argument {String} _char Character to set to
/// @returns {Array<String>} Reference to the original character array
function char_array_set_slice(_char_arr, _index, _count, _char) {
  if (_count >= 0) {
    return char_array_set_range(_char_arr, _index, _index + _count, _char);
  }
  return char_array_set_range(_char_arr, _index + _count + 1, _index + 1, _char);
}

/// @function char_array_set_range(_char_arr, _from, _to, _char)
/// @description Sets a range of characters in the character array
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @argument {String} _char Character to set to
/// @returns {Array<String>} Reference to the original character array
function char_array_set_range(_char_arr, _from, _to, _char) {
  for (var _i = _from; _i < _to; ++_i) {
    _char_arr[@ _i] = _char;
  }
  
  return _char_arr;
}
#endregion

#region char_array_remove
/// @function char_array_remove(_char_arr, _char)
/// @description Removes all occurrences of a character
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {String} _char Character to remove
/// @returns {Array<String>} Reference to the original character array
function char_array_remove(_char_arr, _char) {
  return char_array_remove_slice(_char_arr, 0, array_length(_char_arr), _char);
}

/// @function char_array_remove_slice(_char_arr, _index, _count, _char)
/// @description Removes occurrences of a character from a slice of the character array
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _index The starting index
/// @argument {Real} _count Number of characters to check
/// @argument {String} _char Character to remove
/// @returns {Array<String>} Reference to the original character array
function char_array_remove_slice(_char_arr, _index, _count, _char) {
  if (_count >= 0) {
    return char_array_remove_range(_char_arr, _index, _index + _count, _char);
  }
  return char_array_remove_range(_char_arr, _index + _count + 1, _index + 1, _char);
}

/// @function char_array_remove_range(_char_arr, _from, _to, _char)
/// @description Removes occurrences of a character from a range of the character array
///              Note: this affects the original array!
/// @argument {Array<String>} _char_arr The character array
/// @argument {Real} _from The starting index
/// @argument {Real} _to The ending index
/// @argument {String} _char Character to remove
/// @returns {Array<String>} Reference to the original character array
function char_array_remove_range(_char_arr, _from, _to, _char) {
  var _char_arr_len = array_length(_char_arr);
  var _removed_count = 0;

  for (var _i = _from; _i < _char_arr_len; ++_i) {
    if (_i < _to && _char_arr[_i] == _char) {
      _removed_count += 1;
    } else {
      _char_arr[@ _i - _removed_count] = _char_arr[_i];
    }
  }

  array_resize(_char_arr, _char_arr_len - _removed_count);
  return _char_arr;
}
#endregion