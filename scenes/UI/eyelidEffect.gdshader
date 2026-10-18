shader_type canvas_item;

uniform float open_amount : hint_range(0.0, 1.0) = 0.0; // 0 = Closed, 1 = Fully Awake
uniform vec4 eye_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Eyelid color (Black)

void fragment() {
    // 1. Calculate the distance from the vertical center of the screen
    float center_dist = abs(UV.y - 0.5);
    
    // 2. Create the curved eyelid shape (wider in the middle, narrow at the corners)
    float eyelid_curve = 0.5 * (1.0 - pow(2.0 * UV.x - 1.0, 2.0));
    float current_aperture = open_amount * (0.5 + eyelid_curve * 0.5);
    
    // 3. Create a sharp mask: 1.0 represents the black eyelid, 0.0 represents the clear opening
    float eyelid_mask = smoothstep(current_aperture, current_aperture - 0.01, center_dist);
    
    // 4. Output the solid color, but use the mask to drive transparency directly
    COLOR = vec4(eye_color.rgb, eyelid_mask);
}