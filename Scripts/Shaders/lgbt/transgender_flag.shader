shader_type canvas_item;

// I, Alex Evelyn, Am Releasing This Shader as Public Domain!!!

// https://en.m.wikipedia.org/wiki/File:Transgender_Pride_flag.svg

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 blue = vec4(0.356862745098039, 0.807843137254902, 0.980392156862745, 1); // Blue - #5BCEFA (91,206,250)
uniform vec4 pink = vec4(0.96078431372549, 0.662745098039216, 0.72156862745098, 1); // Pink - #F5A9B8 (245,169,184)
uniform vec4 white = vec4(1, 1, 1, 1); // White - #FFF (255,255,255)

void fragment() {
	// UV Coordinates Come From Bottom Left (Up is Positive and Right is Positive. Also, the coordinates are from 0 to 1, so knock yourself out)
	vec2 uv = SCREEN_UV;
	
	vec3 screen = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
	
	// Make Screen Color Slightly Darker Before Apply Shading
	float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	
	bool set_blue = uv.y >= 0.8 || uv.y <= 0.2;
//	bool set_pink = true; // Just use pink elsewhere!!!
	bool set_white = uv.y > 0.4 && uv.y < 0.6;
	
	if(set_blue) {
		COLOR.rgb = blue.rgb*v;
	} else if(set_white) {
		COLOR.rgb = white.rgb*v;
	} else {
		COLOR.rgb = pink.rgb*v;
	} 
}