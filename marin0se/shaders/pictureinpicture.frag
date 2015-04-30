const number mult = 2;

vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords)
{
	if(pixel_coords.x < love_ScreenSize.x/mult &&
		pixel_coords.y > love_ScreenSize.y/mult){
		return Texel(texture, texcoord*mult);
	}else{
		return Texel(texture, texcoord);
	}
}