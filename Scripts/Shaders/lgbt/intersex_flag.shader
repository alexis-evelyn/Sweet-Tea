shader_type canvas_item;

// https://en.m.wikipedia.org/wiki/File:Intersex_Pride_Flag.svg

// Skipped Because I Need to Research Circles

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 yellow = vec4(1, 0.847058823529412, 0, 1); // Yellow - #FFD800 (255,216,0)
uniform vec4 purple = vec4(0.474509803921569, 0.007843137254902, 0.666666666666667, 1); // Purple - #7902aa (121,2,170)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	// Not Correct - Still Need to Research Circles
	bool set_yellow = uv.y >= 0.8;
	
	if(set_yellow) {
		COLOR.rgb = yellow.rgb*v;
	} else {
		COLOR.rgb = purple.rgb*v;
	} 
}