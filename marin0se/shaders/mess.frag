vec2 rand(vec2 co){
	return vec2(
		fract(sin(dot(co.yx ,vec2(12.9898,78.233))) * 43758.5453),
		fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453)
	);
}

vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixel_coords)
{
	return Texel(
		texture,
		rand(
			texcoord
		)
	); //Now I've got someone else's coordinates.
} 
