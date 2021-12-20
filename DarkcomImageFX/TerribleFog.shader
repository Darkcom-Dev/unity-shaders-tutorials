//Thickness increases linearly with distance
//Use linear fog to create more easily controlled fog, though less realistic
//Set front and back distances to control density
//effect = (back - distance) / (back - front)
//color = effect * shapeColor + (1 - effect) * fogColor
//--------------------------------------------------------
//ExponentialFog extends the Fog class
//Thickness increases exponentially with distance
//Use exponential fog to create thick, realistic fog
//Vary fog density to control thickness
//effect = e(-density * distance)
//color = effect * shapeColor + (1 - effect) * fogColor

Shader "Image FX/Terrible Fog" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Fog("fog color", Color) = (0.5,1,1,1)
		_DepthPower("Depth power", Range(0,200)) = 1
	}
	SubShader {
			ZWrite On
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "IFX.cginc"

			uniform sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			fixed4 _Fog;
			fixed _DepthPower;
			
			fixed4 frag(v2f_img i) : COLOR {
				
				fixed4 source = tex2D(_MainTex, i.uv);

				float d = LinearDepth(_CameraDepthTexture, i.uv, _DepthPower);

				fixed4 Dither = fixed4(_ScreenParams.x % 2, _ScreenParams.y % 2 + 1, 0, 1);
				
				

				fixed4 far = lerp(Dither, source, 1-d*d);

				return far;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
