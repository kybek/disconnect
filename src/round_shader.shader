shader_type canvas_item;

uniform float radius;

void fragment () {
	float dist = sqrt(pow(UV.x - 0.5, 2) + pow(UV.y - 0.5, 2));
	
// Uncomment to restore original texture
//	if (dist > radius) {
//		COLOR = vec4(texture(TEXTURE, UV).xyz, 0.0);
//	}
//	else {
//		COLOR = vec4(texture(TEXTURE, UV).xyz, 1.0);
//	}
	if (dist > radius) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
	else {
		COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	}
}