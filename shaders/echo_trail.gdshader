// Echo trail. Two fading afterimages offset behind the body, giving a sense of
// speed or a lingering astral double. Distinct from an outline because the
// echoes are whole-shape copies, not an edge.
//
// Set `spacing` negative to throw the trail the other way (i.e. when the actor
// faces left instead of right).
//
// ATLAS WARNING: max sample offset is 2 * spacing px.
shader_type canvas_item;

uniform vec4 body_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 echo_color : source_color = vec4(0.2, 0.9, 1.0, 1.0);
uniform float spacing : hint_range(-3.0, 3.0) = 2.0;
uniform float echo1_alpha : hint_range(0.0, 1.0) = 0.55;
uniform float echo2_alpha : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	float a0 = texture(TEXTURE, UV).a;
	float a1 = texture(TEXTURE, UV + vec2(spacing * px.x, 0.0)).a;
	float a2 = texture(TEXTURE, UV + vec2(2.0 * spacing * px.x, 0.0)).a;

	vec3 col = body_color.rgb;
	float a = a0 * body_color.a;

	if (a0 < 0.5) {
		col = echo_color.rgb;
		a = mix(a2 * echo2_alpha, a1 * echo1_alpha, step(0.5, a1));
	}
	COLOR = vec4(col, a);
}
