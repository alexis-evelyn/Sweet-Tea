shader_type canvas_item;

// Source - https://godotengine.org/asset-library/asset/122

uniform float blur : hint_range(0,5);

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur).rgb;
}