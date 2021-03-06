/*
	this code came from [here](https://github.com/PlanetCentauri/ColorblindFilter)
	
	this is for testing color differences in gameplay so we can consider colorblind players, 
	not to help colorblind players directly (as much as we'd like to)
*/
const int index = 0;
const mat3 m[] = mat3[9](
		mat3(1.0  , 0.0  , 0.0  ,  0.0  , 1.0  , 0.0  ,  0.0  , 0.0  , 1.0  ), // 0 normal
		mat3(0.567, 0.433, 0.0  ,  0.558, 0.442, 0.0  ,  0.0  , 0.242, 0.758), // 1 protanopia
		mat3(0.817, 0.183, 0.0  ,  0.333, 0.667, 0.0  ,  0.0  , 0.125 ,0.875), // 2 protanomaly
		mat3(0.625, 0.375, 0.0  ,  0.7  , 0.3  , 0.0  ,  0.0  , 0.3   ,0.7  ), // 3 deuteranopia
		mat3(0.8  , 0.2  , 0.0  ,  0.258, 0.742, 0.0  ,  0.0  , 0.142 ,0.858), // 4 deuteranomaly
		mat3(0.95 , 0.05 , 0.0  ,  0.0  , 0.433, 0.567,  0.0  , 0.475 ,0.525), // 5 tritanopia
		mat3(0.967, 0.033, 0.0  ,  0.0  , 0.733, 0.267,  0.0  , 0.183 ,0.817), // 6 tritanomaly
		mat3(0.299, 0.587, 0.114,  0.299, 0.587, 0.114,  0.299, 0.587 ,0.114), // 7 achromatopsia
		mat3(0.618, 0.320, 0.062,  0.163, 0.775, 0.062,  0.163, 0.320 ,0.516)  // 8 achromatomaly
	);

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
	vec4 vcolor = Texel(texture, texture_coords);
	return vec4(vcolor.rgb * m[index], vcolor.a); 
}