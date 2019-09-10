shader_type canvas_item;

uniform float uv_frequency_x = 60;
uniform float uv_frequency_y = 60;
uniform float blur_phase_frequency = 4;
uniform float depth = 0.005;

void fragment() {
	vec2 uv = SCREEN_UV;
//	uv.y += sin(uv.x*uv_frequency_x+TIME)*depth;
//	uv.y = clamp(uv.y,0,1);
	
	COLOR.rgb = textureLod(SCREEN_TEXTURE, uv, sin(TIME*blur_phase_frequency)).rgb;
}