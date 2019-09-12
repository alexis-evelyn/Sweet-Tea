shader_type canvas_item;

// Modified From - https://www.geeks3d.com/20140213/glsl-shader-library-fish-eye-and-dome-and-barrel-distortion-post-processing-filters/

const float PI = 3.1415926535;

void fragment() {
	float aperture = 178.0;
	float apertureHalf = 0.5 * aperture * (PI / 180.0);
	float maxFactor = sin(apertureHalf);
  
	vec2 uv;
	vec2 xy = 2.0 * SCREEN_UV.xy - 1.0;
	float d = length(xy);
	
	if (d < (2.0-maxFactor)) {
		d = length(xy * maxFactor);
		float z = sqrt(1.0 - d * d);
		float r = atan(d, z) / PI;
		float phi = atan(xy.y, xy.x);
    
		uv.x = r * cos(phi) + 0.5;
		uv.y = r * sin(phi) + 0.5;
	} else {
		uv = SCREEN_UV.xy;
	}
	
	vec4 c = textureLod(SCREEN_TEXTURE, uv, 0.0);
	COLOR = c;
}