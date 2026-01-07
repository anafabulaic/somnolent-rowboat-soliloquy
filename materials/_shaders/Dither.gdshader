//SHADER ORIGINALY CREADED BY "abelcamarena" FROM SHADERTOY
//MODIFIED AND PORTED TO GODOT BY AHOPNESS (@ahopness)
//LICENSE : CC0
//COMATIBLE WITH : GLES2, GLES3, WEBGL
//SHADERTOY LINK : https://www.shadertoy.com/view/tsKGDm

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float SCREEN_WIDTH = 320.; // Lower num - bigger pixels (this will be the screen width)
uniform float COLOR_FACTOR = 4.;   // Higher num - higher colors quality
uniform float DITHERING_STRENTH :hint_range(0., .07) = 0.005; // Be carefull with this one, dithering can get messy really easily

uniform vec4 Shadows :source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 Midtones :source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 Hilights :source_color = vec4(0.0, 0.0, 0.0, 1.0);

vec3 InvLerp( vec3 A, vec3 B, vec3 t){
	return (t - A) / (B - A);
}

vec3 ColorGrade( in vec3 InColor ){
	// Calculate the three offseted colors up-front
	vec3 OffShadows  = InColor + Shadows.xyz;
	vec3 OffMidtones = InColor + Midtones.xyz;
	vec3 OffHilights = InColor + Hilights.xyz;

	// Linearly interpolate between the 3 new colors, piece-wise
	return mix(
		// We pick which of the two control points to interpolate from based on which side of
		// 0.5 the input color channel lands on
		mix(OffShadows,  OffMidtones, InvLerp(vec3(0.0), vec3(0.5), InColor)), // <  0.5
		mix(OffMidtones, OffHilights, InvLerp(vec3(0.5), vec3(1.0), InColor)), // >= 0.5
		greaterThanEqual(InColor, vec3(0.5))
	);
}

int PSXDither(ivec2 fragcoord) {
    const int dither_table[16] = {
        -4, +0, -3, +1, 
        +2, -2, +3, -1, 
        -3, +1, -4, +0, 
        +3, -1, +2, -2
    };
    
    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;
    
    return dither_table[y * 4 + x];
}

void fragment(){                  
    // Reduce pixels            
    vec2 size = SCREEN_WIDTH * SCREEN_PIXEL_SIZE.xy/SCREEN_PIXEL_SIZE.x;
    vec2 coor = floor( UV * size) ;
    vec2 uv =  FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
    
    // Get source color
    vec3 col = texture(SCREEN_TEXTURE, uv).xyz;     
    
    // Dithering
    col += float(PSXDither(ivec2(FRAGCOORD.xy))) * DITHERING_STRENTH;
    
    // Reduce colors    
    col = floor(col * COLOR_FACTOR) / COLOR_FACTOR;    
	
	col = ColorGrade(col);
    
    // Output to screen
    COLOR = vec4(col,1.);
}