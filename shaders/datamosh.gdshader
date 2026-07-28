// Datamosh. Random scanlines shift sideways and the colour channels separate,
// tearing the silhouette into coloured fringes.
//
// ATLAS WARNING: max horizontal sample offset is `amount` + 1 px. Keep
// amount <= 3.0 so it stays inside the sheet's 6px cell padding.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float amount : hint_range(0.0, 3.0) = 2.0;
uniform float speed = 9.0;
uniform float density : hint_range(0.0, 1.0) = 0.28;

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 ts = vec2(textureSize(TEXTURE, 0));
	float row = floor(UV.y * ts.y);
	float t = floor(TIME * speed);
	float active = step(1.0 - density, hash(row * 3.77 + t * 1.31));
	float jitter = (hash(row * 7.13 + t) - 0.5) * 2.0 * amount * active;
	vec2 off = vec2(jitter / ts.x, 0.0);
	float ar = texture(TEXTURE, UV + off + vec2(1.0 / ts.x, 0.0)).a;
	float ag = texture(TEXTURE, UV + off).a;
	float ab = texture(TEXTURE, UV + off - vec2(1.0 / ts.x, 0.0)).a;
	float a = max(ar, max(ag, ab));
	COLOR = vec4(vec3(ar, ag, ab) * tint.rgb, a * tint.a);
}
