shader_type canvas_item;

uniform vec4 water_color : source_color = vec4(1.0);
uniform float water_transparency = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = water_color * water_transparency;
	//color = mix(color, water_color, water_transparency);
	//COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
