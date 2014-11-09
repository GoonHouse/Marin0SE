/*
	This was translated to love2d by EntranceJew
	
	He found it [at this site randomly on google](http://cpansearch.perl.org/src/CORION/App-VideoMixer-0.02/filters/greentint.glsl).
	
	I left out the vertex shader part because it didn't seem necessary for this to function.
*/

const vec4 tintcolor = vec4(1.0,1.0,0.0,1.0);

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 tickets = Texel(texture, texture_coords.xy); //this was .st but that doesn't make sense
	float gray = dot(
		vec3(tickets[0], tickets[1], tickets[2]),
		vec3(0.3, 0.59, 0.11)
	);
	
	return tintcolor * vec4(gray,gray,gray,1.0);
}