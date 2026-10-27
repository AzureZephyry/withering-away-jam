shader_type canvas_item;
uniform bool prototype_shadows_enabled = false;
uniform sampler2D prototype_shadow_mask : filter_nearest, repeat_disable;
uniform ivec2 prototype_mask_origin = ivec2(0, 0);
uniform vec4 prototype_shadow_tint : source_color = vec4(0.25, 0.31, 0.43, 1.0);
uniform float prototype_sun_opacity = 0.0;
uniform float prototype_contact_opacity = 0.16;
uniform bool shadow_layer_enabled = false;
uniform sampler2D shadow_layer : source_color, filter_nearest, repeat_disable;
uniform float grade_saturation = 1.0;
uniform float grade_contrast = 1.0;
uniform float shadow_strength = 1.0;
uniform sampler2D occlusion_mask : filter_nearest, repeat_disable;
varying flat vec3 screen_to_map_x;
varying flat vec3 screen_to_map_y;
void vertex() {
    // The map starts at (0, 0), and every artwork sprite uses its scale.
    mat4 canvas_inverse = inverse(CANVAS_MATRIX);
    vec2 source_scale = vec2(length(MODEL_MATRIX[0].xy), length(MODEL_MATRIX[1].xy));
    screen_to_map_x = vec3(canvas_inverse[0].x, canvas_inverse[1].x, canvas_inverse[3].x) / source_scale.x;
    screen_to_map_y = vec3(canvas_inverse[0].y, canvas_inverse[1].y, canvas_inverse[3].y) / source_scale.y;
}
void fragment() {
    // Use the same pixel grid for the background and cropped foreground sprites.
    ivec2 dimensions = textureSize(TEXTURE, 0);
    vec3 screen_point = vec3(FRAGCOORD.xy, 1.0);
    vec2 map_point = vec2(dot(screen_to_map_x, screen_point), dot(screen_to_map_y, screen_point));
    ivec2 pixel = clamp(ivec2(floor(map_point + vec2(0.001))), ivec2(0), dimensions - ivec2(1));
    if (texelFetch(occlusion_mask, pixel, 0).a > 0.0) {
        discard;
    }
    COLOR = texelFetch(TEXTURE, pixel, 0);
    vec4 prototype_mask = vec4(0.0);
    if (prototype_shadows_enabled) {
        ivec2 mask_pixel = pixel - prototype_mask_origin;
        if (all(greaterThanEqual(mask_pixel, ivec2(0))) && all(lessThan(mask_pixel, textureSize(prototype_shadow_mask, 0)))) {
            prototype_mask = texelFetch(prototype_shadow_mask, mask_pixel, 0);
        }
    }
    if (shadow_layer_enabled) {
        vec4 shade = texelFetch(shadow_layer, pixel, 0);
        // Replace only matched casts on receiving ground; keep painted contact details.
        if (prototype_mask.b > 0.0 && prototype_mask.a > 0.0) {
            shade.a = 0.0;
        }
        // Preserve painted dark edges and never brighten the map with shadows.
        COLOR.rgb = mix(COLOR.rgb, min(COLOR.rgb, shade.rgb), clamp(shade.a * shadow_strength, 0.0, 1.0));
    }
    vec3 sunlight = mix(vec3(1.0), prototype_shadow_tint.rgb, prototype_mask.r * prototype_sun_opacity);
    vec3 contact = mix(vec3(1.0), vec3(0.20, 0.24, 0.30), prototype_mask.g * prototype_contact_opacity);
    COLOR.rgb *= mix(vec3(1.0), sunlight * contact, prototype_mask.b);
    float luminance = dot(COLOR.rgb, vec3(0.2126, 0.7152, 0.0722));
    COLOR.rgb = clamp((mix(vec3(luminance), COLOR.rgb, grade_saturation) - 0.5) * grade_contrast + 0.5, 0.0, 1.0);
}
