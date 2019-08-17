shader_type canvas_item;
//render_mode blend_mix;
//render_mode unshaded;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(1.0-tex.r,1.0-tex.g,1.0-tex.b,1);
}