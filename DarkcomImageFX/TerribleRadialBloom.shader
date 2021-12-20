Shader "Image FX/Terrible Radial Bloom" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Range(0,0.1)) = 0.1
		_Power("Power Bloom", Range(0,1)) = 1
	}
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _Distance, _Power;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 finalColor;
				finalColor = tex2D(_MainTex, i.uv);
				finalColor += tex2D(_MainTex, i.uv * (1 - _Distance) + _Distance/2);	//1-0.1 + 0.1/2
				finalColor += tex2D(_MainTex, i.uv * (1 - _Distance/2) + _Distance/4);//1-0.5 + 
				finalColor += tex2D(_MainTex, i.uv * (1 - _Distance/4) + _Distance/8);
				return tex2D(_MainTex, i.uv) + (finalColor/4) * _Power;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
