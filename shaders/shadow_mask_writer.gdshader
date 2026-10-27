shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;
uniform bool static_exclusion = false;

void fragment() {
    // RGB unions hold sunlight, contact and ground; alpha marks static casts to replace.
    COLOR = static_exclusion ? vec4(0.0, 0.0, 0.0, 1.0) : vec4(COLOR.rgb, 0.0);
}
