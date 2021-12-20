Shader "Image FX/Glitch" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glitch("Glitch", 2D) = "white" {}
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

			uniform sampler2D _MainTex, _Glitch;
			fixed _Distance;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 aberration = ChromaticAberration(_MainTex, i.uv, _Distance);
				fixed4 source = tex2D(_MainTex, i.uv);
				fixed4 glitch = tex2D(_Glitch, i.uv + _Time % 8);
				return lerp(source,aberration,glitch);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
