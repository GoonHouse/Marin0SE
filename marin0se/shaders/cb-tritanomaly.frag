/*
	this code came from [here](https://github.com/PlanetCentauri/ColorblindFilter)
	
	this is for testing color differences in gameplay so we can consider colorblind players, 
	not to help colorblind players directly (as much as we'd like to)
*/
const mat3 m = mat3(0.967, 0.033, 0.0  ,  0.0  , 0.733, 0.267,  0.0  , 0.183 ,0.817);

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
	vec4 vcolor = Texel(texture, texture_coords);
	return vec4(vcolor.rgb * m, vcolor.a); 
}