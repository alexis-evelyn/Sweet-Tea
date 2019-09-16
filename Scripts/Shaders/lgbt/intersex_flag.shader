shader_type canvas_item;

// I Don't Know What I Am Doing!!! I Will Probably Need Help!!!

// https://en.m.wikipedia.org/wiki/File:Intersex_Pride_Flag.svg

// Circle Came From Playing Around With https://thebookofshaders.com/07/

// This is not perfect because of screen resolution breaking circle radius
// Now if I am correct, technically, the circle radius isn't actually for the circle, it is for the area around the circle.

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 yellow = vec4(1, 0.847058823529412, 0, 1); // Yellow - #FFD800 (255,216,0)
uniform vec4 purple = vec4(0.474509803921569, 0.007843137254902, 0.666666666666667, 1); // Purple - #7902aa (121,2,170)

float draw_circle(vec2 uv, float radius) {
	vec2 dist = uv - vec2(0.5, 0.5);
	return 1.-smoothstep(radius-(radius*0.01), radius+(radius*0.01), dot(dist, dist)*4.0);
}

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
//	vec2 uv = (SCREEN_UV * vec2(2.0, 1.0)) - vec2(0.5, 0.0); // This can create ghost like effects :P
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Shade In Color
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	// Not Correct - Still Need to Research Circles
	bool set_yellow = uv.y >= 0.8;
	float circle = draw_circle(uv, 0.5);
	
	COLOR = vec4(circle, purple.rgb*v);
//	COLOR = vec4(circle+0.01, yellow.rgb*v);
	
//	if(set_yellow) {
//		COLOR.rgb = yellow.rgb*v;
//	} else {
////		COLOR.rgb = purple.rgb*v;
//		COLOR = vec4(draw_circle(uv), purple.rgb*v);
//	} 
}