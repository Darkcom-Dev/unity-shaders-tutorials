// Excelente dato, lo que hace Shuriken es mandar datos de color a los vertices, para rapidamente cambiar el color

Shader "Vertex Fragment/Tutorial/Particle Configurable Affected by lights and Fog behaviour"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		
		_PointSpotLightMultiplier("Point/Spot Light Multiplier", Range(0, 10)) = 2
		_DirectionalLightMultiplier("Directional Light Multiplier", Range(0, 10)) = 1
		_AmbientLightMultiplier("Ambient light multiplier", Range(0, 1)) = 0.25
		_InvFade("Soft Particles Factor", Range(0.01, 100.0)) = 1.0
		[Toggle(IS_MIST)]_IsMist("Is Mist?", Float) = 1
		[Header(Mist Settings)]_MistAmount("Mist Amount", Range(-1,1)) = 1
		[Header(Blend State)]
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 //"One"
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DestBlend", Float) = 0 //"Zero"
	}
	SubShader
	{
	  Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
	  LOD 100
		
	  Pass
	  {
		Blend[_SrcBlend][_DstBlend]
		ZWrite Off
		Cull Back
		Lighting On
		AlphaTest Greater 0.01
		ColorMask RGB

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		// make fog work
		#pragma multi_compile_fog
		#pragma shader_feature IS_MIST

		#include "UnityCG.cginc"
		struct appdata
		{
		  float4 vertex : POSITION;
		  float2 uv : TEXCOORD0;
		  float4 color : COLOR;
		};
		struct v2f
		{
		  float2 uv : TEXCOORD0;
		  UNITY_FOG_COORDS(1)
		  float4 vertex : SV_POSITION;
		  float4 color : COLOR;

#if defined(SOFTPARTICLES_ON)
		  float4 projPos : TEXCOORD1;
#endif
		};
		sampler2D _MainTex;
		float4 _MainTex_ST;
		
		float _DirectionalLightMultiplier;
		float _PointSpotLightMultiplier;
		float _AmbientLightMultiplier;
#ifdef IS_MIST
		float _MistAmount;
#endif
#if defined(SOFTPARTICLES_ON)
		float _InvFade;
		sampler2D _CameraDepthTexture;
#endif


		float3 ApplyLight(int index, float3 lightColor, float3 viewPos)
		{
			fixed3 currentLightColor = unity_LightColor[index].rgb;
			float4 lightPos = unity_LightPosition[index];

			if (lightPos.w == 0)
			{
				// directional light, the lightPos is actually the direction of the light
				// for some weird reason, Unity seems to change the directional light position based on the vertex,
				// this hack seems to compensate for that
				lightPos = mul(lightPos, UNITY_MATRIX_V);

				// depending on how the directional light is pointing, reduce the intensity (which goes to 0 as it goes below the horizon)
				fixed multiplier = clamp((lightPos.y * 2) + 1, 0, 1);
				return lightColor + (currentLightColor * multiplier * _DirectionalLightMultiplier);
			}
			else
			{
				float3 toLight = lightPos.xyz - viewPos;
				fixed lengthSq = dot(toLight, toLight);
				fixed atten = 1.0 / (1.0 + (lengthSq * unity_LightAtten[index].z));
				return lightColor + (currentLightColor * atten * _PointSpotLightMultiplier);
			}
		}

		fixed4 LightForVertex(float4 vertex)
		{
			float3 viewPos = UnityObjectToViewPos(vertex).xyz;
			fixed3 lightColor = UNITY_LIGHTMODEL_AMBIENT.rgb * _AmbientLightMultiplier;

			lightColor = ApplyLight(0, lightColor, viewPos);
			lightColor = ApplyLight(1, lightColor, viewPos);
			lightColor = ApplyLight(2, lightColor, viewPos);
			lightColor = ApplyLight(3, lightColor, viewPos);

			return fixed4(lightColor, 1);
		}

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			UNITY_TRANSFER_FOG(o,o.vertex);
#ifdef IS_MIST
			float alpha = saturate(-UnityObjectToViewPos(v.vertex).z* _MistAmount);
			o.color = saturate(LightForVertex(v.vertex) * v.color * alpha);
#else
			o.color = saturate(LightForVertex(v.vertex) * v.color);
#endif
#if defined(SOFTPARTICLES_ON)
			o.projPos = ComputeScreenPos(o.pos);
			COMPUTE_EYEDEPTH(o.projPos.z);
#endif
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			#if defined(SOFTPARTICLES_ON)
				fixed sampleDepht = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))
				fixed sceneZ = LinearEyeDepth(sampleDepth);
				fixed partZ = i.projPos.z;
				i.color.a *= saturate(_InvFade * (sceneZ - partZ));
			#endif
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv) * i.color;
			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);
			return col;
		}
	  ENDCG
	}
	}
	Fallback "Particles/Alpha Blended"
}