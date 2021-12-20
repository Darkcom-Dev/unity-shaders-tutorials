// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Image FX/Refraction"
{
	Properties
	{
		_SpeedStrength("Speed (XY), Strength (ZW)", Vector) = (1, 1, 1, 1)
		_RefractTexTiling("Refraction Tilefac", Float) = 1
		_RefractTex("Refraction (RG), Colormask (B)", 2D) = "bump" {}
		_Color("Color (RGB)", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB) DON`T TOUCH IT! :)", RECT) = "white" {}
	//_VignetteTex("Vignette Texture", 2D) = "white" {}
	//_VignetteAmount("Vignette Opacity", Range(-1,1)) = 0.0
	}

		SubShader
	{
		Pass
	{
		ZTest Always Cull Off ZWrite Off
		Fog{ Mode off }

		CGPROGRAM
		#pragma vertex vert_img
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest 
		#include "UnityCG.cginc"
		#include "IFX.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _RefractTex;
	uniform float4 _SpeedStrength;
	uniform float _RefractTexTiling;
	uniform float4 _Color;

	float4 frag(v2f_img i) : COLOR
	{

		fixed2 uv = RefractionUV(_RefractTex,i.uv,_SpeedStrength.xy, _SpeedStrength.zw, _RefractTexTiling);

		float4 original = tex2D(_MainTex, uv);

		//float4 output = lerp(original, original*_Color, refract.b);
		//output.a = original.a;

		return original;
	}
		ENDCG
	}
	}
		Fallback off
}