shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float outer_radius : hint_range(0.0, 1.0) = 1.0;
uniform vec4 vignette_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float x = abs(UV.r - 0.5) * 2.0;
    float y = abs(UV.g - 0.5) * 2.0;
    float distance = sqrt(x * x + y * y);
    float q = 1.0 - (1.0 - distance / outer_radius) / (1.0 - inner_radius);
    q = clamp(q, 0.0, 1.0); // Zapobiega przekroczeniu wartości
    COLOR = vec4(vignette_color.rgb, q * vignette_color.a * alpha);
}
