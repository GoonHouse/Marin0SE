/*
	Helper functions came from: [vrld on love2d forums](https://love2d.org/forums/viewtopic.php?f=4&t=3733&start=30#p38739)
*/
 
float round(float f, float prec)
{ 
   return (floor(f*(1.0/prec) + 0.5)/(1.0/prec));
}

// helper function, please ignore
number _hue(number s, number t, number h)
{
   h = mod(h, 1.);
   number six_h = 6.0 * h;
   if (six_h < 1.) return (t-s) * six_h + s;
   if (six_h < 3.) return t;
   if (six_h < 4.) return (t-s) * (4.-six_h) + s;
   return s;
}

// input: vec4(h,s,l,a), with h,s,l,a = 0..1
// output: vec4(r,g,b,a), with r,g,b,a = 0..1
vec4 hsl_to_rgb(vec4 c)
{
   if (c.y == 0)
      return vec4(vec3(c.z), c.a);

   number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
   number s = 2.0 * c.z - t;
   return vec4(_hue(s,t,c.x + 1./3.), _hue(s,t,c.x), _hue(s,t,c.x - 1./3.), c.w);
}

// input: vec4(r,g,b,a), with r,g,b,a = 0..1
// output: vec4(h,s,l,a), with h,s,l,a = 0..1
vec4 rgb_to_hsl(vec4 c)
{
   number low = min(c.r, min(c.g, c.b));
   number high = max(c.r, max(c.g, c.b));
   number delta = high - low;
   number sum = high+low;

   vec4 hsl = vec4(.0, .0, .5 * sum, c.a);
   if (delta == .0)
      return hsl;

   hsl.y = (hsl.z < .5) ? delta / sum : delta / (2.0 - sum);

   if (high == c.r)
      hsl.x = (c.g - c.b) / delta;
   else if (high == c.g)
      hsl.x = (c.b - c.r) / delta + 2.0;
   else
      hsl.x = (c.r - c.g) / delta + 4.0;

   hsl.x = mod(hsl.x / 6., 1.);
   return hsl;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 hsl = rgb_to_hsl(Texel(texture, texture_coords.xy));
	hsl.x = round(hsl.x, 0.25);
	hsl.y = round(hsl.y, 0.25);
	hsl.z = round(hsl.z, 0.25);
	//hsl.w = round(hsl.w, 0.25);
	return hsl_to_rgb(hsl);
}