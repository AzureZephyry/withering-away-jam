shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

uniform bool contact = false;
uniform float strength : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    float coverage;
    if (contact) {
        coverage = 1.0 - smoothstep(0.45, 1.0, length(UV * 2.0 - 1.0));
    } else {
        // A small alpha-only filter softens the cast without changing the artwork.
        vec2 step_uv = TEXTURE_PIXEL_SIZE * 0.5;
        coverage = texture(TEXTURE, UV).a * 0.6;
        coverage += texture(TEXTURE, UV + vec2(step_uv.x, 0.0)).a * 0.1;
        coverage += texture(TEXTURE, UV - vec2(step_uv.x, 0.0)).a * 0.1;
        coverage += texture(TEXTURE, UV + vec2(0.0, step_uv.y)).a * 0.1;
        coverage += texture(TEXTURE, UV - vec2(0.0, step_uv.y)).a * 0.1;
    }
    // Add only cast/contact coverage; preserve ground and static-replacement channels.
    COLOR = contact ? vec4(0.0, coverage * strength, 0.0, 0.0)
                    : vec4(coverage * strength, 0.0, 0.0, 0.0);
}
