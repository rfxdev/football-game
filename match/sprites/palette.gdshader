shader_type canvas_item;
// Colours a sheet from a palette, per Sheets in Sprites: each pixel's grey
// value is a palette entry, and entry 0 is transparent. An entry past the end
// of the palette draws nothing.

uniform sampler2D palette : filter_nearest;

void fragment() {
	int entry = int(round(texture(TEXTURE, UV).r * 255.0));
	if (entry == 0 || entry >= textureSize(palette, 0).x) {
		discard;
	}
	COLOR = vec4(texelFetch(palette, ivec2(entry, 0), 0).rgb, 1.0);
}
