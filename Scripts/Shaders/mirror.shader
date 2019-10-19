shader_type canvas_item;

void fragment() {
	vec2 coord = SCREEN_UV;
	
	// Max coordinate is 1.0 (because it is all relative).
	// To invert it, just subtract x coordinate from max coordinate.
	coord.x = (1.0 - coord.x);

	COLOR = texture(SCREEN_TEXTURE, coord);
}