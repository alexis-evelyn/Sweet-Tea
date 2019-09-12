shader_type canvas_item;

const float PI = 3.1415926535;

// The problem with this is it starts rotating too fast after a few seconds until it just stops.
// This was when it was only sinh(TIME). The below code is my attempt to fix it, but that doesn't help.

void fragment() {
	float number_of_rotations = 1.0;
	float starting_position = 0.0;
	starting_position += sinh(TIME) / (360.0 * number_of_rotations);
	
	if (starting_position == 360.0) {
		number_of_rotations += 1.0;
	}
	
	float angle = starting_position;
	float convert = PI/180.0;
	
	vec2 coord = SCREEN_UV;
	float sin_factor = sin(angle * convert);
	float cos_factor = cos(angle * convert);
	
	coord = (coord - 0.5) * mat2(vec2(cos_factor, sin_factor), vec2(-sin_factor, cos_factor));
	coord += 0.5;

	COLOR = texture(SCREEN_TEXTURE, coord);
}