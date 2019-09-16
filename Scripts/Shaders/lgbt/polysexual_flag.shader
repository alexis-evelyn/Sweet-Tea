shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Polysexuality_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 blue = vec4(0.109803921568627, 0.572549019607843, 0.964705882352941, 1); // Blue - #1c92f6 (28,146,246)
uniform vec4 pink = vec4(0.96078431372549, 0.662745098039216, 0.72156862745098, 1); // Pink - #f61cb9 (245,169,184)
uniform vec4 green = vec4(0.027450980392157, 0.835294117647059, 0.411764705882353, 1); // Green - #07d569 (7,213,105)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_pink = uv.y >= 0.66;
	bool set_green = uv.y > 0.33 && uv.y < 0.66;
	
	if(set_pink) {
		COLOR.rgb = pink.rgb*v;
	} else if(set_green) {
		COLOR.rgb = green.rgb*v;
	} else {
		COLOR.rgb = blue.rgb*v;
	} 
}