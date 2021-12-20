Shader "Image FX/GrayScale" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LuminosityAmount("GrayScale Amount", Range(0,1)) = 0.5
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
			fixed _LuminosityAmount;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 source = tex2D(_MainTex, i.uv);
				fixed luminosity = Desature(source);
				
				return lerp(source, luminosity, _LuminosityAmount);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
