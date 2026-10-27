shader_type canvas_item;

uniform float open_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 eye_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	float openness = clamp(open_amount, 0.0, 1.0);
	// A partial opening closes inside both edges, rather than running offscreen.
	// Expand the lens smoothly enough to clear the corners before fully open.
	float widening = smoothstep(0.28, 0.95, openness);
	float half_width = mix(0.44, 0.75, widening);
	float x = (UV.x - 0.5) / half_width;
	float curve = sqrt(max(0.0, 1.0 - x * x));
	float half_height = openness * mix(0.45, 0.75, widening);
	float aperture = half_height * curve;
	float softness = max(fwidth(UV.y) * 1.5, 0.001);
	float mask = smoothstep(aperture, aperture + softness, abs(UV.y - 0.5));
	if (openness <= 0.0 || abs(x) >= 1.0) {
		mask = 1.0;
	}
	if (openness >= 1.0) {
		mask = 0.0;
	}
	COLOR = vec4(eye_color.rgb, eye_color.a * mask);
}
