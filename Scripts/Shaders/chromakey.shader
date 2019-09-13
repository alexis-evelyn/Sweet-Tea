shader_type canvas_item;

// This is nowhere near completed yet, so don't expect it to work.

uniform vec4 color = vec4(255, 0, 177, 64); // Green Screen Color
uniform vec3 forgiveness = vec3(0.0, 0.0, 0.0); // Amount to offset by to include more than strict definition of color

void fragment() {
    vec4 alpha = texture(SCREEN_TEXTURE, SCREEN_UV);

    if(alpha.r == color.r && alpha.g == color.g && alpha.b == color.b) {
        alpha.a = 0.0;
    }

    COLOR = alpha;
}