shader_type canvas_item;

// Deterministic tint, edge darkening and slow bands; no TIME, noise or strobing.
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 edge_distance = abs(UV - vec2(0.5)) * 2.0;
	float edge = max(edge_distance.x * edge_distance.x, edge_distance.y * edge_distance.y);
	float upper = 1.0 - smoothstep(0.02, 0.08, abs(UV.y - (0.28 + 0.08 * amount)));
	float lower = 1.0 - smoothstep(0.03, 0.10, abs(UV.y - (0.72 - 0.06 * amount)));
	float opacity = amount * (0.035 + 0.16 * edge + 0.035 * upper + 0.025 * lower);
	COLOR = vec4(0.12, 0.16, 0.22, opacity);
}
