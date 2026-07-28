// Contour bands -- concentric colour rings measured inward from the silhouette
// edge, like a topographic map.
//
// This is the one that actually ADDS INFORMATION to a flat shape: thin limbs
// stay edge-coloured while thick masses reveal a core, so the body reads as
// having volume without any shading being authored.
//
// NOTE: the ring sampling is written out inline rather than pulled into a
// helper function. Godot's shader built-ins (TEXTURE, UV, ...) only exist
// inside the shader stage that declares them -- passing TEXTURE to a custom
// function fails to compile with "Unknown identifier in expression".
//
// ATLAS WARNING: samples up to 3 * band_px outside the pixel. Keep
// band_px <= 2.0 against a sheet with 6px cell padding.
shader_type canvas_item;

uniform vec4 edge_color : source_color = vec4(1.0, 0.95, 0.6, 1.0);
uniform vec4 band1_color : source_color = vec4(1.0, 0.35, 0.55, 1.0);
uniform vec4 band2_color : source_color = vec4(0.45, 0.15, 0.75, 1.0);
uniform vec4 core_color : source_color = vec4(0.05, 0.05, 0.12, 1.0);
uniform float band_px : hint_range(1.0, 2.0) = 1.0;

void fragment() {
	float a = texture(TEXTURE, UV).a;

	if (a < 0.5) {
		COLOR = vec4(0.0);
	} else {
		vec2 px = TEXTURE_PIXEL_SIZE * band_px;

		float r1 = texture(TEXTURE, UV + vec2( px.x, 0.0)).a;
		r1 = min(r1, texture(TEXTURE, UV + vec2(-px.x, 0.0)).a);
		r1 = min(r1, texture(TEXTURE, UV + vec2(0.0,  px.y)).a);
		r1 = min(r1, texture(TEXTURE, UV + vec2(0.0, -px.y)).a);

		float r2 = texture(TEXTURE, UV + vec2( px.x * 2.0, 0.0)).a;
		r2 = min(r2, texture(TEXTURE, UV + vec2(-px.x * 2.0, 0.0)).a);
		r2 = min(r2, texture(TEXTURE, UV + vec2(0.0,  px.y * 2.0)).a);
		r2 = min(r2, texture(TEXTURE, UV + vec2(0.0, -px.y * 2.0)).a);

		float r3 = texture(TEXTURE, UV + vec2( px.x * 3.0, 0.0)).a;
		r3 = min(r3, texture(TEXTURE, UV + vec2(-px.x * 3.0, 0.0)).a);
		r3 = min(r3, texture(TEXTURE, UV + vec2(0.0,  px.y * 3.0)).a);
		r3 = min(r3, texture(TEXTURE, UV + vec2(0.0, -px.y * 3.0)).a);

		float depth = step(0.5, r1) + step(0.5, r2) + step(0.5, r3);

		vec3 col = edge_color.rgb;
		col = mix(col, band1_color.rgb, step(0.5, depth));
		col = mix(col, band2_color.rgb, step(1.5, depth));
		col = mix(col, core_color.rgb, step(2.5, depth));
		COLOR = vec4(col, 1.0);
	}
}
