// Phasing bands. Alpha scrolls in horizontal bands so the figure looks like it
// is tuning in and out of reception.
//
// NOTE: visually this is close to hologram.gdshader -- same horizontal-stripe
// family. Kept for comparison; probably only one of the two survives.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.35, 0.95, 1.0, 1.0);
uniform float band_h : hint_range(1.0, 8.0) = 3.0;
uniform float speed = 0.35;
uniform float low : hint_range(0.0, 1.0) = 0.12;
uniform float high : hint_range(0.0, 1.0) = 0.9;

void fragment() {
	float a = texture(TEXTURE, UV).a;
	float row = floor(UV.y * float(textureSize(TEXTURE, 0).y));
	float phase = fract(row / (band_h * 2.0) - TIME * speed);
	COLOR = vec4(tint.rgb, a * mix(low, high, step(0.5, phase)));
}
