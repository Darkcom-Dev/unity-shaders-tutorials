// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Image FX/Radial Blur" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Ddistance("Distance", Range(0,1)) = 0.5
		_Rotation("Rotation", Range(0,90)) = 1
	}
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _Ddistance;
			float _Rotation;


			struct appdata
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f_img o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float s = sin(_Rotation * _Time.y);
				float c = cos(_Rotation * _Time.y);
				float2x2 rotationMatrix = float2x2(c, -s, s, c);
				v.texcoord.xy = mul(v.texcoord.xy , rotationMatrix+ _Ddistance);
				o.uv = v.texcoord;
				return o;
			}

			
			fixed4 frag(v2f i) : COLOR {
				fixed4 finalColor;
				finalColor = tex2D(_MainTex, i.uv);
				return finalColor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
