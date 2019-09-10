shader_type canvas_item;

uniform float frequency_x = 60;
uniform float frequency_y = 60;
uniform float depth = 0.005;

void fragment() {
	
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y*frequency_x+TIME)*depth;
	uv.x = clamp(uv.x,0,1);
	
	uv.y += sin(uv.x*frequency_y+TIME)*depth;
	uv.y = clamp(uv.y,0,1);
	
	vec3 c = textureLod(SCREEN_TEXTURE,uv,0.0).rgb;
	
	COLOR.rgb=c;
}
