Shader "Image FX/TexturasExtras" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Noise("Glitch", 2D) = "white" {}
		_Refract("refract", 2D) = "bump" {}
		_Frame("Frame", Range(0.001,1)) = 0.5
		_Rows("Rows", Int) = 8
		_Columns("Columns", Int) = 8
		_NoiseAmount("Noise Amount", Range(-0.5,0.5)) = 0
		_VignetteAmount("Vignette Amount", Range(-1,1)) = 0
		_TextureAmount("TextureAmount", Range(-0.5,0.5)) = 0
		_Dirtness("Dirtness", Range(0,1)) = 1
		_RefractVector("Refrac Vector", Vector) = (0,0,0,0)
	}
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex, _Noise, _Refract;
			fixed _Frame,_NoiseAmount, _VignetteAmount, _TextureAmount,_Dirtness;
			fixed4 _RefractVector;
			uint _Rows, _Columns;
			
		//https://gist.github.com/mattatz/f5b8e1b34035395013fe
		fixed4 Shot(sampler2D tex, fixed2 uv, fixed2 d, int frame) {
			return tex2D(	tex,
							fixed2(	uv.x * d.x + (frame % _Columns) * d.x,
									uv.y * d.y + (frame / _Columns) * d.y)
			);
		}

			fixed4 frag(v2f_img i) : COLOR {
				float4 result;
				
				uint frames = _Rows * _Columns;
				fixed frame = (_Time.y / _Frame)% frames;
				uint current = floor(frame);
				fixed2 d = 1 / fixed2(_Columns, _Rows);

				fixed noise = Shot(_Noise,i.uv,d,frame).b;

				half3 refract = UnpackNormal(tex2D(_Refract, (i.uv.xy + _RefractVector.xy * _Time.y) * _RefractVector.zw));
				float4 preset = tex2D(_MainTex, i.uv  + refract.xy * refract.z);
				
				result = lerp(preset, preset * noise, _NoiseAmount);
				fixed4 texAdd = tex2D(_Noise, i.uv);
				result = result + (texAdd.r * _Dirtness);
				result = lerp(result, result * texAdd.g, _VignetteAmount);
				result = (result + (texAdd.a * _TextureAmount));
				
				return result;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
