// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Image FX/Render Depth" {
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		Pass{
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	struct v2f {
		float4 pos : SV_POSITION;
		float2 depth : TEXCOORD0;
	};

	v2f vert(appdata_base v) {

		v2f o;// Aqui esta la variable que no se inicializa

		o.pos = UnityObjectToClipPos(v.vertex);
		UNITY_TRANSFER_DEPTH(o.depth);
		//UNITY_INITIALIZE_OUTPUT(Input, o);
		return o;
	}

	half4 frag(v2f i) : SV_Target{
		UNITY_OUTPUT_DEPTH(i.depth);
	}
		ENDCG
	}
	}
}