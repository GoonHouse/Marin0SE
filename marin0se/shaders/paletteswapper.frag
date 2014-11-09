extern Image spcolortable;		// Colors for Sprites. Remaining 8 Rows, for the full set.
extern Image indexedimage;		// A texture using indexed color
extern number colourset;		// The palette of the entity.

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	//was texcoord0, made texture_coords
	vec4 curcolor = Texel(indexedimage, texture_coords);  //This is the current pixel color
	curcolor.y = colourset - 8;
	return Texel(spcolortable, curcolor.xy);
	//return Texel(texture, texture_coords) * color; //return with no operations because we didn't do anything
}