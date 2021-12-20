Shader "Image FX/Chromatic Aberration" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Range(0,1)) = 0.5
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
			fixed _Distance;
			
			fixed4 frag(v2f_img i) : COLOR {
				
				return ChromaticAberration(_MainTex, i.uv, _Distance);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
