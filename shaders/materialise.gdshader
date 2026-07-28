// Materialise / de-materialise from the feet up, with a dithered edge rather
// than a soft blur -- so it never introduces partial alpha.
//
// Drive `level` 0.0 -> 1.0 with a Tween for a summon, teleport-in or revive.
// Run it backwards for a retreat.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.55, 0.85, 1.0, 1.0);
uniform float level : hint_range(0.0, 1.0) = 0.6;
uniform float softness : hint_range(0.02, 1.0) = 0.5;

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
	float t = smoothstep(1.0 - level - softness, 1.0 - level + softness, UV.y);
	COLOR = vec4(tint.rgb, a * step(bayer4(texel), t));
}
