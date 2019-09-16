shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Pansexuality_Pride_Flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 blue = vec4(0.129411764705882, 0.694117647058824, 1, 1); // Blue - #21b1ff (33,177,255)
uniform vec4 pink = vec4(1, 0.129411764705882, 0.549019607843137, 1); // Pink - #ff218c (255,33,140)
uniform vec4 yellow = vec4(1, 0.847058823529412, 0, 1); // Yellow - #ffd800 (255,216,0)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_pink = uv.y >= 0.66;
	bool set_yellow = uv.y > 0.33 && uv.y < 0.66;
	
	if(set_pink) {
		COLOR.rgb = pink.rgb*v;
	} else if(set_yellow) {
		COLOR.rgb = yellow.rgb*v;
	} else {
		COLOR.rgb = blue.rgb*v;
	} 
}