shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Nonbinary_flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 black = vec4(0, 0, 0, 1); // Black - #000 (0,0,0)
uniform vec4 purple = vec4(0.611764705882353, 0.349019607843137, 0.819607843137255, 1); // Purple - #9C59D1 (156,89,209)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #fff (255,255,255)
uniform vec4 yellow = vec4(1, 0.956862745098039, 0.188235294117647, 1); // Yellow - #FFF430 (255,244,48)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_yellow = uv.y >= 0.75;
	bool set_white = uv.y > 0.50 && uv.y < 0.75;
	bool set_purple = uv.y > 0.25 && uv.y <= 0.50;
	
	if(set_yellow) {
		COLOR.rgb = yellow.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else if(set_purple) {
		COLOR.rgb = purple.rgb*v;
	} else {
		COLOR.rgb = black.rgb*v;
	} 
}