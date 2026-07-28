// Wave warp. Each texel row is displaced sideways by a travelling sine.
// The displacement is floor()ed to whole pixels, so the shape stays on the pixel
// grid instead of smearing -- this is what separates it from a normal wobble.
//
// Distorts SHAPE rather than alpha, which is why it reads differently from the
// stripe effects even though it is also row-driven.
//
// ATLAS WARNING: max sample offset is `amp` px.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.4, 0.9, 1.0, 1.0);
uniform float amp : hint_range(0.0, 4.0) = 2.0;
uniform float freq = 0.18;
uniform float speed = 2.0;

void fragment() {
	vec2 ts = vec2(textureSize(TEXTURE, 0));
	float row = floor(UV.y * ts.y);
	float dx = floor(sin(row * freq + TIME * speed) * amp);
	float a = texture(TEXTURE, UV + vec2(dx / ts.x, 0.0)).a;
	COLOR = vec4(tint.rgb, a * tint.a);
}
