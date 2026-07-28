// Ember dissolve. Per-texel noise eats the sprite away; pixels sitting right at
// the burn threshold flare bright.
//
// Drive `progress` 0.0 -> 1.0 on death. The noise is sampled in atlas space, so
// it re-rolls each animation frame -- that shimmer reads as fire. If you ever
// need it to hold still, sample cell-local coordinates instead.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1.0, 0.45, 0.15, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.95, 0.65, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.42;
uniform float edge_width : hint_range(0.0, 0.4) = 0.14;

float hash21(vec2 p) {
	p = floor(p);
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	float a = texture(TEXTURE, UV).a;
	float n = hash21(UV * vec2(textureSize(TEXTURE, 0)));
	float keep = step(progress, n);
	float edge = keep * step(n, progress + edge_width);
	COLOR = vec4(mix(tint.rgb, edge_color.rgb, edge), a * keep);
}
