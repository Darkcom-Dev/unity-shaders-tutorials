//https://forum.unity.com/threads/making-a-local-pixelation-image-effect-shader.183210/

Shader "Image FX/Pixelation" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CellSize("CellSize", range(0,0.1)) = 0.1
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
			fixed _CellSize;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed2 steppedUV = SteppedUV(i.uv, _CellSize);
				return tex2D(_MainTex, steppedUV);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
