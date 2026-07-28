// Ordered-dither transparency.
// Instead of blending alpha, this PUNCHES HOLES on a 4x4 Bayer grid -- every
// pixel stays fully opaque or fully gone. This is how 16-bit hardware faked
// transparency, and unlike alpha blending it stays crisp at any integer scale.
//
// `amount`: 1.0 = solid, 0.0 = invisible. Tween it for a dithered fade.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.75, 0.9, 1.0, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.5;

// Classic 4x4 Bayer threshold, computed rather than table-looked-up.
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
	COLOR = vec4(tint.rgb, a * step(bayer4(texel), amount));
}
