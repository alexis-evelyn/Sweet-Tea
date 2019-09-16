shader_type canvas_item;

// Modified From Demo Provided By Shader Toy (Modified For Godot)
// https://www.shadertoy.com/new

void fragment() {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = SCREEN_UV;

	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;

    // Time varying pixel color
    vec3 color = 0.5 + 0.5*cos(TIME+uv.xyx+vec3(0,2,4));

	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);

    // Output to screen
    COLOR.rgb = color.rgb*v;
}