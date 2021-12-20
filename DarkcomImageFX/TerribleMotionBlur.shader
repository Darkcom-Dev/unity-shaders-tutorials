Shader "Image FX/Terrible motion Blur" {
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

			uniform sampler2D _MainTex;
			fixed _Distance;
			
			fixed4 frag(v2f_img i) : COLOR {
				
				return tex2D(_MainTex,i.uv);
			}
				ENDCG
		}

			GrabPass{ "_BLUR0" }
			GrabPass{ "_BLUR1" }
			GrabPass{ "_BLUR2" }
			GrabPass{ "_BLUR3" }
			GrabPass{ "_BLUR4" }
			GrabPass{ "_BLUR5" }
			GrabPass{ "_BLUR6" }
			GrabPass{ "_BLUR7" }
			GrabPass{ "_BLUR8" }
				Pass
			{
				CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _BLUR0: register(s0);
			uniform sampler2D _BLUR1: register(s1);
			uniform sampler2D _BLUR2: register(s2);
			uniform sampler2D _BLUR3: register(s3);
			uniform sampler2D _BLUR4: register(s4);
			uniform sampler2D _BLUR5: register(s5);
			uniform sampler2D _BLUR6: register(s6);
			uniform sampler2D _BLUR7: register(s7);
			uniform sampler2D _BLUR8: register(s8);
			fixed _Distance;

			fixed4 frag(v2f_img i) : COLOR {
				#if UNITY_UV_STARTS_AT_TOP
				fixed2 uv = fixed2(i.uv.x,1 - i.uv.y);
				#else
				fixed2 uv = i.uv;
				#endif

				fixed4 a = tex2D(_BLUR0, uv);
				fixed4 b = tex2D(_BLUR1, uv);
				fixed4 c = tex2D(_BLUR2, uv);
				fixed4 d = tex2D(_BLUR3, uv);
				fixed4 e = tex2D(_BLUR4, uv);
				fixed4 f = tex2D(_BLUR5, uv);
				fixed4 g = tex2D(_BLUR6, uv);
				fixed4 h = tex2D(_BLUR7, uv);
				fixed4 il = tex2D(_BLUR8, uv);
				return (a+b+c+d+e+f+g+h+il) / 9;
			}
			ENDCG
			}
				
	}
	FallBack "Diffuse"
}
