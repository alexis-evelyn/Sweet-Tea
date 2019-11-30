shader_type canvas_item;

// I, Alexis Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Asexual_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 black = vec4(0.3, 0.3, 0.3, 1); // Black - #000 (0,0,0) - Modified To Allow Transparency
uniform vec4 gray = vec4(0.63921568627451, 0.63921568627451, 0.63921568627451, 1); // Gray - #a3a3a3 rgb(163,163,163)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #fff rgb(255,255,255)
uniform vec4 purple = vec4(0.552941176470588, 0, 0.513725490196078, 1); // Yellow - #8D0083 rgb(141,0,131)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_black = uv.y >= 0.75;
	bool set_gray = uv.y > 0.50 && uv.y < 0.75;
	bool set_white = uv.y > 0.25 && uv.y <= 0.50;
	
	if(set_black) {
		COLOR.rgb = black.rgb*v;
	} else if(set_gray) {
		COLOR.rgb = gray.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else {
		COLOR.rgb = purple.rgb*v;
	} 
}