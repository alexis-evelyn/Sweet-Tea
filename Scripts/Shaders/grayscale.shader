shader_type canvas_item;

// Math came from https://xorshaders.weebly.com/tutorials/black-and-white-shader
// Converted to Godot Shader Code by Alexis Evelyn

void fragment() {
	vec4 tex = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	vec3 luminosity = vec3(0.299, 0.587, 0.114);
	COLOR = vec4(vec3(dot(tex.rgb, luminosity)), tex.a);
}