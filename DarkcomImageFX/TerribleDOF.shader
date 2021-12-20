Shader "Image FX/Terrible blur of field" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Float) = 0.5
		_DepthPower("blur power", Range(0,200)) = 1
	}
	SubShader {
			//ZWrite Off
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			fixed _Distance, _DepthPower;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 blur = Blur(_MainTex, i.uv, _Distance);
				fixed4 source = tex2D(_MainTex, i.uv);
				float depth = LinearDepth(_CameraDepthTexture,i.uv,_DepthPower);

				return lerp(blur, source, 1 - depth);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
