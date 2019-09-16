shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Lesbian_Pride_Flag_2019.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 dark_purple = vec4(0.63921568627451, 0.007843137254902, 0.384313725490196, 1); // Dark Purple - #A30262 rgb(163,2,98)
uniform vec4 light_purple = vec4(0.827450980392157, 0.384313725490196, 0.643137254901961, 1); // Light Purple - #D362A4 rgb(211,98,164)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #FFF (255,255,255)
uniform vec4 orange = vec4(1, 0.603921568627451, 0.337254901960784, 1); // Orange - #FF9A56 rgb(255,154,86)
uniform vec4 red = vec4(0.835294117647059, 0.176470588235294, 0, 1); // Red - #D52D00 rgb(213,45,0)


void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_red = uv.y >= 0.8;
	bool set_orange = uv.y < 0.8 && uv.y >= 0.6;
	bool set_white = uv.y > 0.4 && uv.y < 0.6;
	bool set_light_purple = uv.y < 0.4 && uv.y >= 0.2;
	
	if(set_red) {
		COLOR.rgb = red.rgb*v;
	} else if(set_orange) {
		COLOR.rgb = orange.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else if(set_light_purple) {
		COLOR.rgb = light_purple.rgb*v;
	} else {
		COLOR.rgb = dark_purple.rgb*v;
	} 
}