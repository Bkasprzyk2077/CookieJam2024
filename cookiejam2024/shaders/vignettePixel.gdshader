shader_type spatial;
render_mode unshaded, fog_disabled;

uniform vec3 luminance: source_color = vec3(0.3086, 0.6094, 0.0820);
uniform float brightness: hint_range(0.01, 20.0, .01) = 0.26;
uniform float contrast: hint_range(1.0, 4.0, .01) = 3.0;
uniform float scale: hint_range(0.1, 10.0, .01) = 1.0;
uniform float rotation: hint_range(0.00, 6.28, .01) = 0.08;
uniform float resolution_downsampling: hint_range(1.0, 8.0, 1.0) = 4.0;
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest, repeat_disable;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Kolor vignette, domyślnie czarny
uniform float vignette_radius: hint_range(0.0, 1.0, 0.01) = 0.4; // Mniejszy promień vignette dla subtelniejszego efektu

mat2 rotate(float a) {
    float sa = sin(a);
    float ca = cos(a);
    return mat2(vec2(ca, sa), vec2(-sa, ca));
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float dot_matrix(vec2 uv) {
    vec2 rot_uv = rotate(rotation) * uv * scale;
    return sin(rot_uv.x) * sin(rot_uv.y);
}

void fragment() {
    vec2 UV_new = SCREEN_UV - mod(SCREEN_UV, 1.0 / VIEWPORT_SIZE * resolution_downsampling);
    vec2 resolution = VIEWPORT_SIZE;
    vec3 color = texture(screen_texture, UV_new).rgb;

    // Konwersja na szarość i zastosowanie kontrastu
    float grey = dot(color, luminance) * contrast;
    vec3 grey_color = vec3(grey);

    // Rozpikselizowanie - efekt tekstury
    vec3 final_color = color + dot_matrix(UV * resolution);

    // Obliczenie efektu vignette z możliwością zmiany promienia
    float vignette = 1.0 - smoothstep(vignette_radius, vignette_radius - 0.1, distance(UV, vec2(0.5))) * 1.0;

    // Zastosowanie vignette tylko na brzegach, zachowując kolor w środku
    vec3 vignette_effect = mix(final_color, vignette_color.rgb, vignette_color.a * vignette);

    // Ustawienie finalnego koloru z jasnością
    ALBEDO = vignette_effect * brightness;
}
