shader_type canvas_item;
//render_mode blend_mix;
//render_mode unshaded;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.r * 0.5, tex.g * 0.5,tex.b * 0.5,1);
}