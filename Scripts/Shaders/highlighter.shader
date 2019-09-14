shader_type canvas_item;

// This is nowhere near completed yet, so don't expect it to work.

// Note to Self, Alpha goes on the end and everything is on a range of 0 to 1. So, take your rgba values and divide each by 255.
uniform vec4 shading = vec4(0.66274509803, 0.66274509803, 0.66274509803, 1); // Dark Gray #A9A9A9
uniform vec4 color = vec4(0, 0.69411764705, 0.25098039215, 1); // Green Screen (Chromakey) Color
uniform vec3 forgiveness = vec3(0.0, 0.0, 0.0); // Amount to offset by to include more than strict definition of color

void fragment() {
	vec3 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	
	// Add forgiveness here so the shader can get similar colors in the mix too.
	if(screen.r != color.r || screen.g != color.g || screen.b != color.b) {
		// Shade In Color
		float v = dot(screen, vec3(0.33333, 0.33333, 0.33333));
		v = sqrt(v);
		
		COLOR.rgb = shading.rgb*v;
	} else {
		// Matches Color to Keep
		COLOR.rgb = screen.rgb;
	}
}