// Banded vertical gradient fill.
// The ramp is quantised into `bands` discrete steps so it still reads as pixel
// art rather than a smooth 24-bit blend. Push bands above ~10 and it stops
// looking like it belongs in this game.
shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(1.0, 0.75, 0.15, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.85, 0.05, 0.35, 1.0);
uniform float bands : hint_range(2.0, 16.0) = 6.0;

void fragment() {
	float a = texture(TEXTURE, UV).a;
	float t = floor(UV.y * bands) / max(bands - 1.0, 1.0);
	COLOR = vec4(mix(top_color.rgb, bottom_color.rgb, clamp(t, 0.0, 1.0)), a);
}
