#ifndef IFX_INCLUDED
#define IFX_INCLUDED

//https://gist.github.com/mattatz/f5b8e1b34035395013fe
fixed4 Shot(sampler2D tex, fixed2 uv, fixed2 d, int frame, uint columns) {
	fixed2 framedUV = fixed2(uv.x * d.x + (frame % columns) * d.x, uv.y * d.y + (frame / columns) * d.y);
	return tex2D(tex, framedUV);
}

fixed4 Blur(sampler2D image, fixed2 uv, fixed distance) {
	fixed4 blur;
	blur = tex2D(image, uv);
	blur += tex2D(image, uv + fixed2(distance, 0));
	blur += tex2D(image, uv - fixed2(distance, 0));
	blur += tex2D(image, uv + distance);
	blur += tex2D(image, uv - distance);
	blur += tex2D(image, uv + fixed2(0, distance));
	blur += tex2D(image, uv - fixed2(0, distance));
	blur += tex2D(image, uv + fixed2(distance, -distance));
	blur += tex2D(image, uv - fixed2(distance, -distance));
	return (blur) / 9;
}

fixed4 ChromaticAberration(sampler2D image, fixed2 uv, fixed distance) {
	fixed4 aberration;
	aberration.r = tex2D(image, uv - fixed2(distance, 0)).r;
	aberration.g = tex2D(image, uv + fixed2(distance, 0)).g;
	aberration.ba = tex2D(image, uv).ba;
	return aberration;
}

fixed4 ScreenBlend(fixed4 colorA, fixed4 colorB) {
	return 1.0 - ((1.0 - colorA)*(1.0 - colorB));
}

fixed4 AddBlend(fixed4 colorA, fixed4 colorB) {
	return colorA + colorB;
}

fixed4 MultiplyBlend(fixed4 colorA, fixed4 colorB) {
	return colorA * colorB;
}

fixed OverlayBlend(fixed basePixel, fixed blendPixel) {
	if (basePixel < 0.5) return 2.0 * basePixel * blendPixel;
	else return 1.0 - 2.0 * (1.0 - basePixel)*(1.0 - blendPixel);
}

fixed3 OverlayColor(fixed3 colorA, fixed3 colorB) {
	fixed3 overlayed;
	overlayed.r = OverlayBlend(colorA.r, colorB.r);
	overlayed.g = OverlayBlend(colorA.g, colorB.g);
	overlayed.b = OverlayBlend(colorA.b, colorB.b);
	return overlayed;
}

fixed3 ContrastSaturationBrightness(fixed3 color, fixed brt, fixed sat, fixed con) {
	
	//Funcion a probar
	//Luminance(fixed3 color); Retorna dot(c.fixed3(0.22, 0.707, 0.071));
	fixed3 LuminanceCoeff = float3(0.2125, 0.7154, 0.0721);
	// Operacion para el brillo
	fixed3 avgLum = fixed3(0.5, 0.5, 0.5);
	fixed3 brtColor = color * brt;
	fixed intensityf = dot(brtColor, LuminanceCoeff);
	fixed3 intensity = fixed3(intensityf, intensityf, intensityf);
	//Operacion para saturacion
	fixed3 satColor = lerp(intensity, brtColor, sat);
	//Operacion para contraste
	fixed3 conColor = lerp(avgLum, satColor, con);
	return conColor;
}

float2 Barrel(float2 uv, fixed distortion, fixed cubicDistortion, fixed scale)
{
	// Inspired by SynthEyes lens distortion algorithm  
	// See http://www.ssontech.com/content/lensalg.htm  
	float2 h = uv.xy - float2(0.5, 0.5);
	float r2 = h.x * h.x + h.y * h.y;
	float f = 1.0 + r2 * (distortion + cubicDistortion * sqrt(r2));

	return f * scale * h + 0.5;
}

float2 Barrel(float2 uv, fixed distortion, fixed scale)
{
	// Inspired by SynthEyes lens distortion algorithm  
	// See http://www.ssontech.com/content/lensalg.htm  
	float2 h = uv.xy - float2(0.5, 0.5);
	float r2 = h.x * h.x + h.y * h.y;
	float f = 1.0 + r2 * (distortion * sqrt(r2));

	return f * scale * h + 0.5;
}

fixed4 ChromaticAberration(sampler2D image, fixed2 uv, fixed distortion, fixed scale) {
	fixed blue = tex2D(image, Barrel(uv, 0, scale)).b;
	fixed red = tex2D(image, Barrel(uv, distortion, scale)).r;
	fixed green = tex2D(image, Barrel(uv, -distortion, scale)).g;
	return fixed4(red, green, blue, 1);
}

fixed4 BarrelBlur(sampler2D image, fixed2 uv, fixed distortion, fixed scale, int samples) {

	fixed4 blur;

	for (int iter = 1; iter <= samples; iter++) {
		if (iter == 0)blur = tex2D(image, Barrel(uv, 0, scale));
		else {
			blur += tex2D(image, Barrel(uv, -distortion * iter, scale)) / 2;
			blur += tex2D(image, Barrel(uv, distortion * iter, scale)) / 2;
		}

				}

	return blur / samples;
}

fixed2 RefractionUV(sampler2D refractionTexture, fixed2 uv, fixed2 speed, fixed2 strength, fixed tile) {
	float2 tileUV = uv * tile;
	float4 refract = tex2D(refractionTexture, tileUV + speed *_Time.x);
	refract.rg = refract.rg * 2.0 - 1.0;
	
	return uv + refract.rg * strength;

}

fixed2 SteppedUV(fixed2 uv, fixed pixelSize) {

	if (pixelSize > 0) 	return round(uv / pixelSize)*pixelSize;
	else return uv;
}

fixed LinearDepth(sampler2D depthTexture, fixed2 uv, fixed depthPower) {
	float depth = UNITY_SAMPLE_DEPTH(tex2D(depthTexture, uv));
	depth = pow(Linear01Depth(depth), depthPower);
	return depth;
}



fixed Desature(fixed3 color) {
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
	
}

fixed DesatureB(fixed3 color) {
	
	fixed3 coeff = fixed3(0.299, 0.587, 0.114);
	float sat = dot(coeff, color);
	return sat;
}

#endif