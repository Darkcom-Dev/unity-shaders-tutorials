Shader "Image FX/Terrible Radial Blur" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Range(0,0.1)) = 0.1
		_Samples("Samples", Int) = 9
	}
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _Distance;
			int _Samples;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 blur;
				blur = tex2D(_MainTex, i.uv);
				for (uint j = 1; j < _Samples; j++)
				{

					blur += tex2D(_MainTex, i.uv * (1 - _Distance / (j)) + _Distance / (j + 1 * j + 1));
					//blur += tex2D(_MainTex, i.uv * (1 - _Distance / 2) + _Distance / 4);
					//blur += tex2D(_MainTex, i.uv * (1 - _Distance / 4) + _Distance / 8);
				}
				
				
				return blur/_Samples;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
