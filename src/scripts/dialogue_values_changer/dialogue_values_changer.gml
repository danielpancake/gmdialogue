/// @function dialogue_values_changer(array, options, position, max)
/// @description This function changes the values in the specified array of options
/// Used only with the dialogue system for not to copy the same procedure over and over
function dialogue_values_changer(a, v, p, m){
	if (v[2] != -1 && p >= v[2]) {
		v[@ 0] = (a[v[1]] >> 32) & 0xffffffff;
		v[@ 2] = (v[1] < m - 1) ? a[@ ++v[@ 1]] & 0xffffffff : -1;
	}
}