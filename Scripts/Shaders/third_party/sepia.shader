shader_type canvas_item;

// Source - https://godotengine.org/asset-library/asset/122

// #8b6867
uniform vec4 base : hint_color;

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE,SCREEN_UV,0.0).rgb;
	
	//float v = max(c.r,max(c.g,c.b));
	float v = dot(c,vec3(0.33333,0.33333,0.33333));
	v=sqrt(v);
	//v*=v;
	COLOR.rgb= base.rgb*v;

}