shader_type canvas_item;

uniform float open_amount : hint_range(0.0, 1.0) = 0.0; // 0 = Closed, 1 = Fully Awake

void fragment() {
    float center_dist = abs(UV.y - 0.5);
    
    float eyelid_curve = 0.5 * (1.0 - pow(2.0 * UV.x - 1.0, 2.0));
    float current_aperture = open_amount * (0.5 + eyelid_curve * 0.5);
    float eyelid_mask = smoothstep(current_aperture, current_aperture - 0.01, center_dist);
   
    COLOR = vec4(0.0, 0.0, 0.0, 1.0 - eyelid_mask);
}
