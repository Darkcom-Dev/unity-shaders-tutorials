Shader "Image FX/Animation" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Frame("Frame", Range(0.001,1)) = 0.5
		_Rows("Rows", Int) = 8
		_Columns("Columns", Int) = 8
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
			fixed _Frame;
			uint _Rows, _Columns;

			fixed4 frag(v2f_img i) : COLOR {
				uint frames = _Rows * _Columns;
				fixed frame = (_Time.y / _Frame)% frames;
				uint current = floor(frame);
				fixed2 d = 1 / fixed2(_Columns, _Rows);

				return Shot(_MainTex,i.uv,d,frame,_Columns);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
