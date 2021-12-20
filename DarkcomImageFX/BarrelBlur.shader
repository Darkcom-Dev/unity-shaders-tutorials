Shader "Image FX/Barrel Blur" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Float) = 0.5
		_Scale("Scale", Float) = 0.5
		_Samples("Samples", Int) = 9
	}
	SubShader {
			ZWrite Off
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _MainTex;
			fixed _Distance, _Scale;
			uint _Samples;

			fixed4 frag(v2f_img i) : COLOR {
				
				return BarrelBlur(_MainTex, i.uv, _Distance, _Scale, _Samples);
			}
			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
