shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

#define PALETTE_X(X) \
	X(0x491d3a) \
	X(0x732444) \
	X(0xb72d3d) \
	X(0xcc672d) \
	X(0xf2901f) \
	X(0xf1c833) \
	X(0x3a172f) \
	X(0x461b2d) \
	X(0x5e2525) \
	X(0x792917) \
	X(0x99330e) \
	X(0xd5560c) \
	X(0x35154e) \
	X(0x151b75) \
	X(0x0045a5) \
	X(0x0074dc) \
	X(0x00c8ff) \
	X(0x4ee3e6) \
	X(0x1b0a29) \
	X(0x2b1739) \
	X(0x380b5a) \
	X(0x401186) \
	X(0x4c24b2) \
	X(0x6441e3) \
	X(0x063025) \
	X(0x064015) \
	X(0x00611a) \
	X(0x068425) \
	X(0x06aa25) \
	X(0x6bcd4d)

#define X_COUNT(x) + 1

#define X_VEC(hex) vec3( \
		float((hex) >> 16) / 255.0, \
		float(((hex) >> 8) & 0xff) / 255.0, \
		float((hex) & 0xff) / 255.0 \
	),

const vec3 palette[] = {
	PALETTE_X(X_VEC)
	vec3(0,0,0)
};
const int palette_size = PALETTE_X(X_COUNT);

vec3 get_closest_palette(vec3 color) {
	vec3 closest_color = color;
	float closest_dist = 9999.0;
	for (int i = 0; i < palette_size; ++i) {
		float d = distance(color, palette[i]);
		if (d < closest_dist) {
			closest_dist = d;
			closest_color = palette[i];
		}
	}
	return closest_color;
}

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR.rgb = get_closest_palette(COLOR.rgb);
}
