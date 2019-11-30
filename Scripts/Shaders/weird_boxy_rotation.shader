shader_type canvas_item;

// I have no idea how this works, this shader was an accidental invention. - Alexis Evelyn
// Modified From Source - https://godotengine.org/asset-library/asset/122

//clamp(TIME, 0, 1);

void fragment() {
	float time = asin(TIME);
	float rotation = 3.0 * time;
	
	vec2 uv = SCREEN_UV;
	vec2 rel = uv - vec2(0.5, 0.5);
	float angle = length(rel) * rotation;
	mat2 rot = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	rel = rot * rel;
	uv = clamp(rel + vec2(0.5, 0.5), vec2(0,0), vec2(1,1));
	COLOR.rgb = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
}