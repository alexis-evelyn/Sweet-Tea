shader_type canvas_item;
//render_mode blend_mix;
//render_mode unshaded;

// https://stackoverflow.com/a/31325812/6828099

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.r * 0.5, tex.g * 0.5, tex.b * 0.5, 1);
}