/// @function DialogueOptions(default_value)
/// @description Creates new data structure which handles all changing values
function DialogueOptions(_default_value) constructor {
  current_count = 0;
  current_extra = 0;
  current_position = -1;
  current_value = _default_value;
  values = []; // [ [value, position, extra], ... ]
  size = 0;
  
  /// @function Put(value, position, extra)
  static Put = function(value, position, extra) {
    array_push(values, [value, position, extra]);
    size++;
  }
  
  /// @function Reset(default_value)
  static Reset = function(_default_value) {
    current_count = 0;
    current_position = (size > 0) ? values[0][1] : -1;
    current_value = _default_value;
  }
  
  /// @function ResetAll(default_value)
  static ResetAll = function(_default_value) {
    values = []; size = 0;
    Reset(_default_value);
  }
  
  /// @function Change(position, callback, extra)
  static Change = function(position, callback, extra) {
    while (current_position != -1 && position >= current_position) {
      current_value = values[current_count][0];
      current_extra = values[current_count][2];
      
      current_position = (current_count < size - 1) ? values[current_count + 1][1] : -1;
      current_count += 1;
      
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
