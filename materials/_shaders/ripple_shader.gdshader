// Converted/modified from ShaderToy: https://www.shadertoy.com/view/ldBXDD
// Attach this shader to a ColorRect

shader_type canvas_item;

uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 0.1, 0.001) = 0.003;

uniform float radius:    hint_range(0.0, 1.0) = 0.22;  // where darkening starts (smaller = more encroachment)
uniform float softness:  hint_range(0.0, 1.0) = 0.38;  // feather width toward center
uniform float intensity: hint_range(0.0, 3.0) = 2.00;  // overall darkness
uniform float contrast:  hint_range(0.5, 4.0) = 2.20;  // >1.0 sharpens falloff

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 cPos = -1.0 + 2.0 * UV / (1.0 / TEXTURE_PIXEL_SIZE);
	float cLength = length(cPos);
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy + (cPos/cLength) * cos(cLength * wave_count - TIME * speed) * height;
    vec3 col = texture(SCREEN_TEXTURE,uv).xyz;

	vec2 v_uv = SCREEN_UV;
    vec2 centered = v_uv - vec2(0.5);

	 // Edge-driven shape (0 at center, 1 at edges):
    // Chebyshev distance = pushes from ALL edges uniformly
    float edge_box = max(abs(centered.x) * 2.0, abs(centered.y) * 2.0);

    // Blend a little radial in to avoid a "boxy" look (optional)
    float edge_radial = length(centered) * 2.0; // 0 center -> ~1 corners
    float shape = mix(edge_box, edge_radial, 0.25);

    // Darken from radius inward with feather = softness
    float v = smoothstep(radius, radius + softness, shape);
    v = pow(v, contrast);

	vec2 normal_uv = SCREEN_UV;
	vec3 normal_col = texture(SCREEN_TEXTURE, normal_uv).xyz;

	//COLOR = vec4(normal_col,1.0);
	COLOR = mix(vec4(normal_col,1.0), vec4(col,1.0), v);
}