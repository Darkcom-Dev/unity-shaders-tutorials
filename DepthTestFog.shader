Shader "Image FX/DepthTestFog" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_DepthPower("Depth Amount", Range(0,1)) = 0.5
	}
	SubShader {
		Pass{
			//Blend One DstColor
			//Blend SrcColor OneMinusDstColor //Esto genera acumulacion de color similar a los efectos de difuminado de metal gear
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex, _CameraDepthTexture;
			uniform sampler2D _FogTex;
			fixed _DepthPower;

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
			};


			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color.xyz = v.normal * 0.5 + 0.5;
				return o;
			}


			fixed4 frag(v2f_img i) : COLOR{
				float4 fog = tex2D(_MainTex, i.uv);
				float d = UNITY_SAMPLE_DEPTH(fog);
				d = pow(LinearEyeDepth(d), _DepthPower);
				float4 c = tex2D(_MainTex, i.uv);
				
				return c * (d * unity_FogColor);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
