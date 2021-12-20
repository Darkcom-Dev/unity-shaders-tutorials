Shader "Image FX/Terrible Simple Blur" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Float) = 0.5
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
			fixed _Distance;
			
			fixed4 frag(v2f_img i) : COLOR {
				return Blur(_MainTex,i.uv,_Distance);
			}
			ENDCG
		}

		GrabPass{"_BLUR"}
		Pass
			{
				CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _BLUR: register(s0);
			fixed _Distance;

			fixed4 frag(v2f_img i) : COLOR {
				#if UNITY_UV_STARTS_AT_TOP
				fixed2 uv = fixed2(i.uv.x,1 - i.uv.y);
				#else
				fixed2 uv = i.uv;
				#endif
				
			return Blur(_BLUR, uv, _Distance/2);
			}
			ENDCG
			}
	}
	FallBack "Diffuse"
}
