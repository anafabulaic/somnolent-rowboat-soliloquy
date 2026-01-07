shader_type spatial;

uniform sampler2D first_texture : source_color;
uniform sampler2D second_texture : source_color;
uniform float offset = 0.0;
uniform float mult = 1.0;

float compare(vec3 one, vec3 two, float epsilon, float offset_val, float mult_val) {
	float absolute =  abs(one.r - two.r);
	
	if (absolute > ((epsilon + offset_val) * mult_val)) {
		return 1.0;
	} else {
		return 0.0;
	}
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.b, c.g, K.b, K.a), vec4(c.g, c.b, K.a, K.z), step(c.b, c.g));
    vec4 q = mix(vec4(p.r, p.g, p.a, c.r), vec4(p.g, p.r, c.r, p.b), step(p.r, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0 / (d + 1e-10);
    return vec3(abs(q.z + (q.w - q.y) * e), d * e, q.x); // x=H, y=S, z=V
}


void fragment() {
	vec3 tex1 = texture(first_texture, UV).rgb;
	vec3 tex2 = texture(second_texture, UV).rgb;
	vec3 vertex_colors = COLOR.rgb;
	float vertex_color_value = rgb2hsv(vertex_colors).z;
	
	//ALBEDO = vertex_colors;
	//ALBEDO = other_compare(tex1, tex2, vertex_colors);
	ALBEDO = mix(tex1, tex2, compare(tex1, tex2, vertex_color_value, offset, mult));
}