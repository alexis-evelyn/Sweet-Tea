shader_type canvas_item;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	uv.x *= (sin(uv.x) / cos(uv.y)) - 0.15;
//	uv.x = clamp(uv.x, 0, 1);
	
	vec3 c = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	COLOR.rgb=c;
}