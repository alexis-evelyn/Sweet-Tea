shader_type canvas_item;

// Source - https://godotengine.org/asset-library/asset/122

uniform float frequency_x = 60;
uniform float depth = 0.005;

// https://stackoverflow.com/questions/12964279/whats-the-origin-of-this-glsl-rand-one-liner
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	uv.x += sin((uv.y / 20.0) * frequency_x + (20.0 * rand(vec2(TIME, 0.0)))) * depth;
	uv.x = clamp(uv.x,0,1);
	
	uv.y += sin((uv.x / 20.0) * frequency_x + rand(vec2(TIME, 0.0))) * depth;
	uv.y = clamp(uv.y,0,1);
	
	vec3 c = textureLod(SCREEN_TEXTURE,uv,0.0).rgb;
	COLOR.rgb=c;
}