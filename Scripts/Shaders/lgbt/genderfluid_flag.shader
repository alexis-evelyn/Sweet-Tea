shader_type canvas_item;

// I, Alexis Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Genderfluidity_Pride-Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 blue = vec4(0.2, 0.243137254901961, 0.741176470588235, 1); // Blue - #333ebd rgb(51,62,189)
uniform vec4 black = vec4(0.3, 0.3, 0.3, 1); // Black - #000 (0,0,0) - Modified To Allow Transparency
uniform vec4 purple = vec4(0.745098039215686, 0.094117647058824, 0.83921568627451, 1); // Purple - #be18d6 rgb(190,24,214)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #FFF (255,255,255)
uniform vec4 pink = vec4(1, 0.458823529411765, 0.635294117647059, 1); // Pink - #ff75a2 rgb(255,117,162)


void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_pink = uv.y >= 0.8;
	bool set_white = uv.y < 0.8 && uv.y >= 0.6;
	bool set_purple = uv.y > 0.4 && uv.y < 0.6;
	bool set_black = uv.y < 0.4 && uv.y >= 0.2;
	
	if(set_pink) {
		COLOR.rgb = pink.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else if(set_purple) {
		COLOR.rgb = purple.rgb*v;
	} else if(set_black) {
		COLOR.rgb = black.rgb*v;
	} else {
		COLOR.rgb = blue.rgb*v;
	} 
}