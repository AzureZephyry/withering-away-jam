shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ground_mask : filter_nearest, repeat_disable;
uniform vec3 map_inverse_x = vec3(1.0, 0.0, 0.0);
uniform vec3 map_inverse_y = vec3(0.0, 1.0, 0.0);
uniform ivec2 mask_origin = ivec2(0);
uniform vec2 drift_offset = vec2(0.0);
uniform float fog_density : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fog_color : source_color = vec4(0.48, 0.54, 0.62, 1.0);
uniform vec2 lamp_positions[5];
uniform int lamp_count = 0;
uniform float lamp_strength = 0.0;
uniform vec4 density_pockets[8];
uniform float pocket_strengths[8];
uniform int density_pocket_count = 0;
varying vec2 source_position;

float hash(vec2 p) {
    vec3 h = fract(vec3(p.xyx) * 0.1031);
    h += dot(h, h.yzx + 33.33);
    return fract((h.x + h.y) * h.z);
}

float mist_noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), f.x),
        mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), f.x), f.y);
}

void vertex() {
    vec3 world = vec3((MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy, 1.0);
    source_position = vec2(dot(map_inverse_x, world), dot(map_inverse_y, world));
}

float ground_density(vec2 p) {
    // Smooth, unbounded tails join the pockets without card edges or overlap seams.
    float clear = 0.975;
    for (int i = 0; i < density_pocket_count; i++) {
        vec4 pocket = density_pockets[i];
        vec2 q = (p - pocket.xy) / max(pocket.zw, vec2(1.0));
        float distance_squared = dot(q, q);
        float weight = pocket_strengths[i] / (1.0 + distance_squared * distance_squared * distance_squared);
        clear *= 1.0 - clamp(weight, 0.0, 1.0);
    }
    return 1.0 - clear;
}

void fragment() {
    vec2 p = floor(source_position) + vec2(0.5);
    ivec2 pixel = ivec2(p) - mask_origin;
    ivec2 dimensions = textureSize(ground_mask, 0);
    if (any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, dimensions))) {
        discard;
    }
    if (texelFetch(ground_mask, pixel, 0).b < 0.5) {
        discard;
    }
    // Sample a fixed source-pixel grid; only the slow advection moves the mist.
    float broad = mist_noise((p - drift_offset) * vec2(0.010, 0.018));
    float detail = mist_noise((p - drift_offset * 0.84) * vec2(0.028, 0.065) + vec2(broad * 1.8, 7.31));
    float strands = mist_noise((p - drift_offset * 1.18) * vec2(0.016, 0.095) + vec2(detail * 0.65, 15.73));
    float banks = smoothstep(0.28, 0.72, broad * 0.6 + detail * 0.4);
    float wisps = 0.25 + 0.75 * smoothstep(0.24, 0.76, strands);
    // Optical depth keeps visible banks while leaving gaps between the wisps.
    float alpha = 1.0 - exp(-fog_density * ground_density(p) * banks * wisps * 1.5);
    float warmth = 0.0;
    for (int i = 0; i < lamp_count; i++) {
        warmth = max(warmth, 1.0 - smoothstep(12.0, 68.0, distance(p, lamp_positions[i])));
    }
    vec3 tint = mix(fog_color.rgb, vec3(0.76, 0.69, 0.54), warmth * lamp_strength * 0.24);
    COLOR = vec4(tint, clamp(alpha, 0.0, 0.52));
}
