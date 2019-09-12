shader_type canvas_item;

uniform float angle;
const float PI = 3.1415926535;

void fragment() {
	float convert = PI/180.0;
	
	vec2 coord = SCREEN_UV;
	float sin_factor = sin(angle * convert);
	float cos_factor = cos(angle * convert);
	
	coord = (coord - 0.5) * mat2(vec2(cos_factor, sin_factor), vec2(-sin_factor, cos_factor));
	coord += 0.5;

	COLOR = texture(SCREEN_TEXTURE, coord);
}