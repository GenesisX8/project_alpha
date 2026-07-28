// Solid body + 1px outline.
// Set body_color alpha to 0 for a hollow / edge-only wireframe look.
//
// Samples the alpha of the 8 neighbouring texels; anywhere this pixel is empty
// but a neighbour is solid, paint the outline colour.
//
// ATLAS WARNING: samples up to `width` px outside the frame. Safe only while
// every sheet cell keeps >= 2px of empty padding on all sides.
shader_type canvas_item;

uniform vec4 body_color : source_color = vec4(0.04, 0.04, 0.07, 1.0);
uniform vec4 outline_color : source_color = vec4(0.15, 0.95, 1.0, 1.0);
uniform float width : hint_range(1.0, 4.0) = 1.0;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * width;
	float a = texture(TEXTURE, UV).a;

	if (a > 0.5) {
		COLOR = vec4(body_color.rgb, body_color.a);
	} else {
		float n = 0.0;
		n = max(n, texture(TEXTURE, UV + vec2( px.x, 0.0)).a);
		n = max(n, texture(TEXTURE, UV + vec2(-px.x, 0.0)).a);
		n = max(n, texture(TEXTURE, UV + vec2(0.0,  px.y)).a);
		n = max(n, texture(TEXTURE, UV + vec2(0.0, -px.y)).a);
		n = max(n, texture(TEXTURE, UV + vec2( px.x,  px.y)).a);
		n = max(n, texture(TEXTURE, UV + vec2(-px.x,  px.y)).a);
		n = max(n, texture(TEXTURE, UV + vec2( px.x, -px.y)).a);
		n = max(n, texture(TEXTURE, UV + vec2(-px.x, -px.y)).a);
		COLOR = vec4(outline_color.rgb, step(0.5, n) * outline_color.a);
	}
}
