shader_type canvas_item;
render_mode unshaded, blend_add;

uniform float interior_strength : hint_range(0.0, 1.0) = 0.0;
instance uniform int opening_type = 0;
varying vec4 light_tint;

void vertex() {
    light_tint = COLOR;
}

void fragment() {
    vec4 artwork = texture(TEXTURE, UV);
    float brightest = max(artwork.r, max(artwork.g, artwork.b));
    // The original dark opening defines the stencil; frames and masonry stay intact.
    float opening = 1.0 - smoothstep(0.24, 0.30, brightest);
    float response = 1.0;
    if (opening_type == 1) {
        // Warm reflected light inside recesses, preserving dark doors and railings.
        float luminance = dot(artwork.rgb, vec3(0.2126, 0.7152, 0.0722));
        response = 0.18 + 0.82 * smoothstep(0.065, 0.24, luminance);
    }
    COLOR = vec4(light_tint.rgb, light_tint.a * interior_strength * opening * response * artwork.a);
}
