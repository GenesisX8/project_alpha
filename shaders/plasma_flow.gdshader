// Plasma flow. Value noise scrolls upward through the body and is mapped onto a
// three-stop colour ramp, quantised to `levels` steps so it stays posterised
// rather than smooth. Reads as an elemental / energy being.
//
// Unlike the stripe effects this varies in BOTH axes, so it does not look like
// the hologram family.
shader_type canvas_item;

uniform vec4 cool_color : source_color = vec4(0.35, 0.05, 0.55, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.25, 0.35, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float noise_scale : hint_range(0.05, 1.0) = 0.35;
uniform float speed = 0.6;
uniform float levels : hint_range(2.0, 8.0) = 4.0;

float hash21(vec2 p) {
	p = floor(p);
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 p = UV * vec2(textureSize(TEXTURE, 0)) * noise_scale;
	float n = vnoise(p + vec2(0.0, -TIME * speed * 4.0));
	n = floor(n * levels) / max(levels - 1.0, 1.0);
	vec3 col = mix(cool_color.rgb, mid_color.rgb, clamp(n * 2.0, 0.0, 1.0));
	col = mix(col, hot_color.rgb, clamp(n * 2.0 - 1.0, 0.0, 1.0));
	COLOR = vec4(col, a);
}
