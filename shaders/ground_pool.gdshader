// Neon ground pool. Runs on a bare ColorRect -- no texture involved at all.
// Quantised radial falloff so the edge stays chunky instead of airbrushed.
shader_type canvas_item;

uniform vec4 glow : source_color = vec4(1.0, 0.2, 0.45, 1.0);
uniform float steps : hint_range(2.0, 12.0) = 4.0;
uniform float squash : hint_range(1.0, 5.0) = 2.6;

void fragment() {
	vec2 d = (UV - vec2(0.5)) * vec2(1.0, squash);
	float a = smoothstep(0.5, 0.0, length(d));
	a = floor(a * steps) / steps;
	COLOR = vec4(glow.rgb, a * glow.a);
}
