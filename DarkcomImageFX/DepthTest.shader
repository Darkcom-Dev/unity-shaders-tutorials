Shader "Image FX/DepthTest - Simplex" {
	Properties{

		_DepthPower("Depth Amount", Range(0,001)) = 0.5
		_MainTex("Main Texture", 2D) = "gray"{}
		_Fog("Fog_Color", Color) = (0.3, 0.4, 0.5, 0.3)
	}

		
	SubShader {
		
		Pass{
			//Tags{"RenderType" = "Foreground"}
			//Blend One DstColor
			//Blend SrcColor OneMinusDstColor //Esto genera acumulacion de color similar a los efectos de difuminado de metal gear
			//ZTest Always Cull Off ZWrite Off
		//Tags { "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma debug
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D  _CameraDepthTexture, _MainTex;
			fixed4 _Color;
			fixed _DepthPower;

			fixed4 frag(v2f_img i) : COLOR{
				float d = LinearDepth(_CameraDepthTexture, i.uv, _DepthPower);
				fixed4 source = tex2D(_MainTex, i.uv.xy);

				return lerp(_Color, source, 1 - d);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
