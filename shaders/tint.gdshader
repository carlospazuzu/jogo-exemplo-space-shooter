// Pinta o sprite com uma cor sólida mantendo a transparência.
// Usado no "flash" de dano (branco) e nas afterimagens dos chefes.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1.0);
// 0 = sprite original, 1 = totalmente pintado com "tint".
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(mix(tex.rgb * COLOR.rgb, tint.rgb, amount), tex.a * COLOR.a);
}
