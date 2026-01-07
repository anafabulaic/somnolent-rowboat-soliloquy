shader_type sky;

uniform sampler2D sky_texture : source_color;
uniform vec3 sky_texture_modulate : source_color = vec3(1.0,1.0,1.0);
uniform bool lock_aspect = false;
uniform float aspect_ratio = 1.3333333;
uniform vec2 fov = vec2(180.0, 90.0);
uniform ivec2 tiling = ivec2(1, 1);
uniform vec2 offset = vec2(0.0, 0.0);

uniform bool use_bg = false;
uniform sampler2D background : source_color;
uniform vec3 background_color : source_color;

uniform float size : hint_range(0.01, 10.0, 0.001) = 1.0;

// handled by code
uniform float cam_x;
uniform float cam_y;
uniform vec2 viewport_size;

uniform bool use_sin = false;
uniform vec2 scroll_speed;
uniform float sin_mult = 1.0;

uniform float jitter : hint_range(0.01, 0.5, 0.001) = 0.2;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hash2(vec2 p) {
    return vec2(
        hash(p),
        hash(p + 19.19)
    );
}

void sky() {
	float y = cam_y;
	float x = cam_x;
	
	vec4 bg_coords;
	bg_coords.xy = vec2(y * -0.5, x) / PI;
	bg_coords.y += 0.5;
	
	bg_coords.w = fov.y / 180.0;
	bg_coords.z = !lock_aspect ? fov.x / 360.0 : viewport_size.x / (viewport_size.y * aspect_ratio) * bg_coords.w;
	
	vec2 uv_offset = vec2(-offset.x, offset.y);
	vec2 uv = (SCREEN_UV + uv_offset) * bg_coords.zw + bg_coords.xy;
	
	//uv += scroll_speed * TIME;
	//uv *= vec2(tiling);
	//uv = fract(uv);
	//uv = (uv - 0.5) / size + 0.5;
	
	vec2 tiled_uv = uv * vec2(tiling);
	vec2 modified_scroll = !use_sin ? scroll_speed : scroll_speed * vec2(1.0, (sin(TIME) * sin_mult));
	tiled_uv += modified_scroll * TIME;
	
	vec2 tile_id  = floor(tiled_uv);
	vec2 local_uv = fract(tiled_uv);
	
	//vec2 rnd = hash2(tile_id) - 0.5; 
	//local_uv += rnd * jitter;
	local_uv = (local_uv - 0.5) / size + 0.5;
	
	vec3 bg = texture(background, SKY_COORDS).rgb;
	vec3 bg_color = background_color;
	vec3 bg_or_color = mix(bg, bg_color, 1.0 - float(use_bg));
	
	
	if (any(lessThan(local_uv, vec2(0.0))) ||
        any(greaterThan(local_uv, vec2(1.0)))) {
        COLOR = bg_or_color;
    } else {
		vec4 sky_tex = texture(sky_texture, local_uv);
		
		COLOR = mix(bg_or_color, sky_tex.rgb * sky_texture_modulate, sky_tex.a);
	}
}

//void fragment() {
	//vec2 uv_offset = vec2(-offset.x, offset.y);
	//vec2 uv = (SCREEN_UV + uv_offset) * bg_coords.zw + bg_coords.xy;
	//uv *= vec2(tiling);
	//ALBEDO = texture(sky_texture, uv).rgb;
//}