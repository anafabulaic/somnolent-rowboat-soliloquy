shader_type sky;
uniform sampler2D sky_mat : filter_nearest;
uniform sampler2D noise_texture;
uniform sampler2D gradient_mask;

uniform float speed = 0.5;
uniform float distortion = 0.03;
uniform float power = 1.0;


void sky() {
	vec2 uv = SKY_COORDS;
	vec4 gradient_tex = texture(gradient_mask, uv);
	vec2 noise_value  = (texture(noise_texture, uv + (TIME * speed)).rg * 2.0) - 1.0;
	vec2 noise_distortion = (noise_value * distortion);

	uv = mix(uv, uv + noise_distortion, gradient_tex.x);

	vec4 sky_col = texture(sky_mat, uv);

	COLOR = sky_col.rgb * power;


}
