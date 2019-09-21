shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Bisexual_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 blue = vec4(0, 0.219607843137255, 0.658823529411765, 1); // Blue - #0038a8 rgb(0,56,168)
uniform vec4 purple = vec4(0.607843137254902, 0.309803921568627, 0.588235294117647, 1); // Purple - #9b4f96 rgb(155,79,150)
uniform vec4 pink = vec4(0.83921568627451, 0.007843137254902, 0.43921568627451, 1); // Pink - #d60270 rgb(214,2,112)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_pink = uv.y >= 0.6;
	bool set_purple = uv.y > 0.4 && uv.y < 0.6;
	
	if(set_pink) {
		COLOR.rgb = pink.rgb*v;
	} else if(set_purple) {
		COLOR.rgb = purple.rgb*v;
	} else {
		COLOR.rgb = blue.rgb*v;
	} 
}