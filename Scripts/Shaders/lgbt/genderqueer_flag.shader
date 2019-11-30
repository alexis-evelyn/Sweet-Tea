shader_type canvas_item;

// I, Alexis Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Genderqueer_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 green = vec4(0.290196078431373, 0.505882352941176, 0.137254901960784, 1); // Green - #4a8123 rgb(74,129,35)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #fff (255,255,255)
uniform vec4 purple = vec4(0.709803921568627, 0.494117647058824, 0.862745098039216, 1); // Purple - #b57edc rgb(181,126,220)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_purple = uv.y >= 0.66;
	bool set_white = uv.y > 0.33 && uv.y < 0.66;
	
	if(set_purple) {
		COLOR.rgb = purple.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else {
		COLOR.rgb = green.rgb*v;
	} 
}