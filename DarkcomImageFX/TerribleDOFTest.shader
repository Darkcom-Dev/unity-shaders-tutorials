Shader "Image FX/Terrible blur of field PassTest" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Distance("Distance", Float) = 0.5
		_DepthPower("blur power", Range(0,200)) = 1

		_Distance2("Distance2", Float) = 0.5
		_DepthPower2("blur power2", Range(0,200)) = 1
	}
SubShader {
			ZWrite Off
		
		Pass{
			Name "DOF"
			//Tags{"LightMode" = "Always"}
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _MainTex;
			uniform sampler2D _CameraDepthTexture;
			fixed _Distance, _DepthPower;
			
			fixed4 frag(v2f_img i) : COLOR {
				fixed4 blur = Blur(_MainTex, i.uv, _Distance);
				fixed4 source = tex2D(_MainTex, i.uv);
				float depth = LinearDepth(_CameraDepthTexture, i.uv, _DepthPower);

				fixed4 far = lerp(blur, source, depth);

				return far;
			}
			ENDCG
		}
		
		GrabPass
			{
			"_DOF"
			}

		Pass
		{
				Name "Blur"
				
				//Tags{"LightMode" = "Always"}
				//Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _DOF: register(s0);
			uniform sampler2D _CameraDepthTexture;
			fixed _Distance, _DepthPower;
			
			fixed4 frag(v2f_img i) :COLOR
			{
				#if UNITY_UV_STARTS_AT_TOP
				fixed2 uv =	fixed2(i.uv.x,1 - i.uv.y);
				#else
				fixed2 uv = i.uv;
				#endif
								
				fixed4 blur = Blur(_DOF, uv, _Distance/2);
				fixed4 source = tex2D(_DOF, uv);
				float depth = LinearDepth(_CameraDepthTexture, uv, _DepthPower);

				fixed4 far = lerp(blur, source, depth);

				return far;
			}
		
			ENDCG
		}
	}
	FallBack "Diffuse"
}
