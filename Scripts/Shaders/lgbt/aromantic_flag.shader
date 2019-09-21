shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Aromantic_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 dark_green = vec4(0.23921568627451, 0.647058823529412, 0.258823529411765, 1); // Dark Green - #3da542 rgb(61,165,66)
uniform vec4 light_green = vec4(0.654901960784314, 0.827450980392157, 0.474509803921569, 1); // Light Green - #a7d379 rgb(167,211,121)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #FFF (255,255,255)
uniform vec4 gray = vec4(0.662745098039216, 0.662745098039216, 0.662745098039216, 1); // Gray - #a9a9a9 rgb(169,169,169)
uniform vec4 black = vec4(0.3, 0.3, 0.3, 1); // Black - #000 (0,0,0) - Modified To Allow Transparency

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_dark_green = uv.y >= 0.8;
	bool set_light_green = uv.y < 0.8 && uv.y >= 0.6;
	bool set_white = uv.y > 0.4 && uv.y < 0.6;
	bool set_gray = uv.y < 0.4 && uv.y >= 0.2;
	
	if(set_dark_green) {
		COLOR.rgb = dark_green.rgb*v;
	} else if(set_light_green) {
		COLOR.rgb = light_green.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else if(set_gray) {
		COLOR.rgb = gray.rgb*v;
	} else {
		COLOR.rgb = black.rgb*v;
	} 
}