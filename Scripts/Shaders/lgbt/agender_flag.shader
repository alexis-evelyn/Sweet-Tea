shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Agender_pride_flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 green = vec4(0.72156862745098, 0.956862745098039, 0.513725490196078, 1); // Green - #b8f483 rgb(184,244,131)
uniform vec4 black = vec4(0, 0, 0, 1); // Black - #000 (0,0,0)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #FFF (255,255,255)
uniform vec4 gray = vec4(0.725490196078431, 0.725490196078431, 0.725490196078431, 1); // Gray - #b9b9b9 rgb(185,185,185)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	// This one ended up being trickier to measure out than it should have been.
	bool set_black = (uv.y >= 0.86 || uv.y <= 0.14);
	bool set_gray = (uv.y >= 0.72 && uv.y < 0.86) || (uv.y > 0.14 && uv.y < 0.28);
	bool set_white = (uv.y >= 0.28 && uv.y < 0.42) || (uv.y > 0.58 && uv.y < 0.72);
	
	if(set_black) {
		COLOR.rgb = black.rgb*v;
	} else if(set_gray) {
		COLOR.rgb = gray.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else {
		COLOR.rgb = green.rgb*v;
	} 
}