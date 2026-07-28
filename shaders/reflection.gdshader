// Wet-floor reflection. Goes on a SECOND copy of the sprite with flip_v = true,
// parented to the actor and offset so the mirrored feet meet the real feet.
//
// Fades out with distance from the contact point using a Bayer dither rather
// than alpha, so the reflection dissolves in hard pixels and matches the
// dithering already present in the background art.
//
// If the fade runs the wrong way, invert the `depth` expression -- flip_v
// changes which end of UV.y is the feet.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.6;

float bayer4(vec2 p) {
	int x = int(p.x) & 3;
	int y = int(p.y) & 3;
	int a = x ^ y;
	int v = ((a & 1) << 3) | ((y & 1) << 2) | (((a >> 1) & 1) << 1) | ((y >> 1) & 1);
	return (float(v) + 0.5) * 0.0625;
}

void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 texel = UV * vec2(textureSize(TEXTURE, 0));
	float depth = UV.y;
	COLOR = vec4(tint.rgb, a * step(bayer4(texel), depth * strength));
}
