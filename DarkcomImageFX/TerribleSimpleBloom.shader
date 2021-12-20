Shader "Image FX/Terrible Simple Bloom" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Float) = 0.5
		_Power("Bloom Power", Range(0,1)) = 1
	}
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _MainTex;
			fixed _Distance,_Power;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 finalColor;
				fixed4 bloom = Blur(_MainTex, i.uv, _Distance);
				fixed4 source = tex2D(_MainTex, i.uv);
				return finalColor = source + ((bloom * bloom) *_Power);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
