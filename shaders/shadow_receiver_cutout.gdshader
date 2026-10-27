shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform bool texture_cutout = false;
uniform float alpha_cutoff = 0.5;
uniform bool keep_static_detail = false;
uniform bool skip_foreground_pixels = false;
uniform sampler2D foreground_regions : filter_nearest, repeat_disable;
uniform vec4 rotated_source_rect = vec4(0.0);

void fragment() {
    float artwork_alpha = texture(TEXTURE, UV).a;
    if (rotated_source_rect.z > 0.0) {
        ivec2 pixel = ivec2(floor(UV * vec2(textureSize(TEXTURE, 0))));
        ivec2 origin = ivec2(rotated_source_rect.xy);
        ivec2 end = origin + ivec2(rotated_source_rect.zw);
        if (all(greaterThanEqual(pixel, origin)) && all(lessThan(pixel, end))) {
            // Match the selected vehicle's rotated silhouette, including its mirrors.
            artwork_alpha = texelFetch(TEXTURE, origin + end - ivec2(1) - pixel, 0).a;
        }
    }
    if (texture_cutout && artwork_alpha < alpha_cutoff) {
        discard;
    }
    if (skip_foreground_pixels) {
        ivec2 pixel = clamp(ivec2(UV * vec2(textureSize(TEXTURE, 0))), ivec2(0), textureSize(TEXTURE, 0) - ivec2(1));
        int object_id = int(round(texelFetch(foreground_regions, pixel, 0).a * 255.0));
        // Fading artwork reveals ground; the two opaque gatehouses remain solid.
        if (object_id > 0 && object_id != 28 && object_id != 29) {
            discard;
        }
    }
    // Exclude painted vertical surfaces without changing the shadow channels.
    COLOR = keep_static_detail ? vec4(1.0, 1.0, 1.0, 0.0) : vec4(1.0, 1.0, 0.0, 1.0);
}
