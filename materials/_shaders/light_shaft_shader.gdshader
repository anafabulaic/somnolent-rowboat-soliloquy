shader_type spatial;
render_mode blend_mix, unshaded, world_vertex_coords;

// Super duper special thanks to:
// https://godotshaders.com/shader/muzzle-flash-z-axis-billboard/

uniform sampler2D shaft_texture : filter_nearest;
uniform float emission = 1.0;
uniform float face_threshold = 0.1;

uniform float mult = 1.0;

uniform vec3 modulate : source_color;

varying float VIEW_ALPHA;

void vertex() {
    vec3 world_pos = VERTEX;
    vec3 center = (MODEL_MATRIX * vec4(0,0,0,1)).xyz;
	
	vec3 cam_pos = (INV_VIEW_MATRIX * vec4(0,0,0,1)).xyz;
	vec3 view_dir = normalize(cam_pos - center);
	
    mat3 view = mat3(VIEW_MATRIX);
    mat3 cam = transpose(view);

    vec3 right = cam[0]; // camera right
    vec3 up    = vec3(0.0, 1.0, 0.0); // camera up
    vec3 fwd = normalize((MODEL_MATRIX * vec4(0,0,1,0)).xyz);

    vec3 offset = world_pos - center;

    vec3 oriented =
        right * offset.x +
        up    * offset.y +
        fwd   * offset.z;
	
    VERTEX = center + oriented;
	VIEW_ALPHA = clamp(-dot(view_dir, up), -1.0, 1.0);
}

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
	vec4 color = texture(shaft_texture, UV);
	
    ALBEDO = color.rgb + modulate;
	EMISSION = color.rgb * emission;
	//ALPHA = color.a * max(0.0, 1.0 - vec_dif);
	ALPHA = color.a * max(0.0, 1.0 - abs(VIEW_ALPHA) - face_threshold) * mult;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
