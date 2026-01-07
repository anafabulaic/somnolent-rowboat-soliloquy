shader_type spatial;
render_mode shadows_disabled;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
uniform sampler2D normal_map_texture : hint_normal;
uniform vec3 water_color : source_color = vec3(0.0625, 0.1992, 0.3594);

void fragment() {
	ROUGHNESS = 0.0;

	// Basic waves
	float time = TIME * 0.05;
	vec3 normal_sample_1 = texture(normal_map_texture, UV + vec2(-1, 1) * time).xyz * 2.0 - 1.0;
	vec3 normal_sample_2 = texture(normal_map_texture, -UV + vec2(0, 1) * time).xyz * 2.0 - 1.0;
	vec3 normal_map = vec3(normal_sample_1.xy + normal_sample_2.xy, 0.0);
	
	// Set NORMAL directly since we need to use it later
	//NORMAL_MAP_DEPTH = 1.0;
	//normal_map.z = sqrt(max(0.0, 1.0 - dot(normal_map.xy, normal_map.xy)));
	//NORMAL = normalize(mix(NORMAL, TANGENT * normal_map.x + BINORMAL * normal_map.y + NORMAL * normal_map.z, NORMAL_MAP_DEPTH));
	
	// use depth texture to make shallow areas more translucent
	float depth = texture(depth_texture, SCREEN_UV).x;
	//vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	float object_depth = FRAGCOORD.z;
	//vec3 object_ndc = vec3(SCREEN_UV, object_depth) * 2.0 - 1.0;
	vec3 object_ndc = vec3(SCREEN_UV * 2.0 - 1.0, object_depth);
	vec4 object_view = INV_PROJECTION_MATRIX * vec4(object_ndc, 1.0);
	object_view.xyz /= object_view.w;
	float linear_object_depth = -object_view.z;
	
	// Screen distortion
	vec2 distorted_uv = SCREEN_UV - normal_map.xy;
	float final_depth = smoothstep(0.0, 4.0, linear_depth - linear_object_depth);
	vec3 final_albedo = texture(screen_texture, distorted_uv).rgb;
	ALBEDO = final_albedo;
	ALBEDO = mix(final_albedo, water_color, final_depth);

}