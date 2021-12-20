Shader "Unlit/Projector"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Scale ("Scale", Float) = 1.0
	}
		SubShader
	{
		Blend One One
		ZWrite Off
		Offset -1, -1  // evite las peleas en profundidad (debe ser "Offset -1, -1")
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
		fixed _Scale;

	struct vertInput {
		fixed4 pos : POSITION;
	};

	struct vert2frag {
		fixed4 pos : SV_POSITION;
		fixed4 worldPos : TEXCOORD1;
	};

	vert2frag vert(vertInput v) {
		vert2frag o;
		// posicion local del objeto
		o.pos = UnityObjectToClipPos(v.pos);
		// posicion mundial del objeto
		o.worldPos = mul(unity_ObjectToWorld, v.pos);
		return o;
	}

	half4 frag(vert2frag i) : COLOR{
			if (i.worldPos.w > 0.0) // in front of projector?
			{
				fixed4 caustic = tex2D(_MainTex , (i.worldPos.xz + _SinTime.zw) * _Scale);
				fixed4 caustic2 = tex2D(_MainTex, (i.worldPos.xz + _CosTime.xy) * _Scale);
				fixed4 caustic3 = tex2D(_MainTex, (i.worldPos.xz + _CosTime.zw) * _Scale);
				return (caustic + caustic2 + caustic3)/2;
			}
			else // behind projector
			{
			   return float4(0.0, 0.0, 0.0, 0.0);
			}
	}
		ENDCG
		}
	}
}
