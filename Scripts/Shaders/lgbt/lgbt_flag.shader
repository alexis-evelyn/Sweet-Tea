shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Gay_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 red = vec4(0.894117647058824, 0.011764705882353, 0.011764705882353, 1); // Red - #e40303 (228,3,3)
uniform vec4 orange = vec4(1, 0.549019607843137, 0, 1); // Orange - #ff8c00 (255,140,0)
uniform vec4 yellow = vec4(1, 0.929411764705882, 0, 1); // Yellow - #ffed00 (255,237,0)
uniform vec4 green = vec4(0, 0.501960784313725, 0.149019607843137, 1); // Green - #008026 (0,128,38)
uniform vec4 blue = vec4(0, 0.301960784313725, 1, 1); // Blue - #004dff (0,77,255)
uniform vec4 purple = vec4(0.458823529411765, 0.027450980392157, 0.529411764705882, 1); // Purple - #750787 (117,7,135)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	// 0.1655
	bool set_red = uv.y >= 0.8345;
	bool set_orange = uv.y < 0.8345 && uv.y >= 0.669;
	bool set_yellow = uv.y < 0.669 && uv.y >= 0.5035;
	bool set_green = uv.y < 0.5035 && uv.y >= 0.338;
	bool set_blue = uv.y < 0.338 && uv.y >= 0.1725;
	
	if(set_red) {
		COLOR.rgb = red.rgb*v;
	} else if(set_orange) {
		COLOR.rgb = orange.rgb*v;
	} else if(set_yellow) {
		COLOR.rgb = yellow.rgb*v;
	} else if(set_green) {
		COLOR.rgb = green.rgb*v;
	} else if(set_blue) {
		COLOR.rgb = blue.rgb*v;
	} else {
		COLOR.rgb = purple.rgb*v;
	} 
}