// Hologram / projection.
// Scanlines are derived from the TEXEL row, not FRAGCOORD, so they stay locked
// to the pixel grid at any integer window scale. Deriving them from screen
// pixels instead is what makes most scanline shaders shimmer.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.3, 0.95, 1.0, 1.0);
uniform float line_height : hint_range(1.0, 4.0) = 2.0;
uniform float dim : hint_range(0.0, 1.0) = 0.3;
uniform float base_alpha : hint_range(0.0, 1.0) = 0.8;
uniform float flicker_speed = 5.0;

void fragment() {
	float a = texture(TEXTURE, UV).a;
	float row = floor(UV.y * float(textureSize(TEXTURE, 0).y));
	float band = mod(floor(row / line_height), 2.0);
	float scan = mix(1.0, dim, step(0.5, band));
	float flick = 0.88 + 0.12 * sin(TIME * flicker_speed);
	COLOR = vec4(tint.rgb, a * scan * flick * base_alpha);
}
