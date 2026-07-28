// Mosaic / digitising. Snaps sampling to a coarse block grid so the silhouette
// degrades into chunky tiles, then breathes the block size over time.
//
// Reads as "low-res", "corrupted", or "still rendering" -- good for a spawn-in
// or a glitch enemy family.
//
// Block size is kept in the 2..6 px range; the sheet's 6px cell padding absorbs
// any snap that reaches past a cell boundary.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.9, 0.95, 1.0, 1.0);
uniform float block : hint_range(2.0, 6.0) = 4.0;
uniform float pulse : hint_range(0.0, 3.0) = 2.0;
uniform float pulse_speed = 1.2;

void fragment() {
	vec2 ts = vec2(textureSize(TEXTURE, 0));
	float b = clamp(floor(block + pulse * sin(TIME * pulse_speed)), 2.0, 6.0);
	vec2 texel = UV * ts;
	vec2 snapped = (floor(texel / b) + 0.5) * b;
	float a = texture(TEXTURE, snapped / ts).a;
	COLOR = vec4(tint.rgb, a * tint.a);
}
