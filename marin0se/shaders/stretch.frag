vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords)
{
	return Texel(texture, texcoord*texcoord);
} 
