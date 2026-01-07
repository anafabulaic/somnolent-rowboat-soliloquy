shader_type spatial;
render_mode blend_mix, unshaded, world_vertex_coords;

uniform float emission = 1.0; // Color multiplier
uniform sampler2D main_tex : filter_nearest; // Main texture

uniform float face_threshold = 0.1; // 0.0-1.0 Angle threshold for revealing the billboard when the camera gets close to Z axis.
uniform float brightness_mult = 1.0;
uniform float size_mult = 1.0;

uniform vec3 modulate : source_color;

varying float VIEW_ALPHA;

void vertex() {
    vec3 world_pos = VERTEX;
    vec3 center = (MODEL_MATRIX * vec4(0,0,0,1)).xyz;
	
	vec3 cam_pos = (INV_VIEW_MATRIX * vec4(0,0,0,1)).xyz;
	vec3 view_dir = normalize(cam_pos - center);
	vec3 world_up = vec3(0.0, 1.0, 0.0);
	float view_dot = dot(view_dir, world_up);
	
    mat3 view = mat3(VIEW_MATRIX);
    mat3 cam = transpose(view);

    vec3 right = cam[0]; // camera right
    vec3 up    = cam[1]; // camera up
    vec3 fwd = normalize((MODEL_MATRIX * vec4(0,0,1,0)).xyz);

    vec3 offset = world_pos - center;

    vec3 oriented =
        right * offset.x +
        up    * offset.y +
        fwd   * offset.z;

	float dist = distance(center, cam_pos);

    VERTEX = center + oriented * ((dist * view_dot) * size_mult);
	VIEW_ALPHA = clamp(-view_dot, 0.0, 1.0);
	
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(VERTEX, 1.0);
	POSITION.z += 0.005 * POSITION.w;
}

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}


void fragment() {
	float vec_dif = dot(MODEL_MATRIX[0].xyz, CAMERA_DIRECTION_WORLD);
	vec4 color = texture(main_tex, UV);

	ALBEDO = color.rgb + modulate;
	EMISSION = color.rgb * emission;
	ALPHA = color.a * max(0.0, VIEW_ALPHA - face_threshold) * brightness_mult;
}