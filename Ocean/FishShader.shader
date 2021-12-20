//https://www.bitshiftprogrammer.com/2018/01/how-to-animate-fish-swimming-with.html

Shader "VertexFragment/AnimatedFish"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BumpTex("Bump Texture", 2D) = "white" {}
		_EffectRadius("Wave Effect Radius",Range(0.0,1.0)) = 0.5
		_WaveSpeed("Wave Speed", Range(0.0,100.0)) = 3.0
		_WaveHeight("Wave Height", Range(0.0,30.0)) = 5.0
		_WaveDensity("Wave Density", Range(0.0001,1.0)) = 0.007
		_Threshold("Threshold",Range(0,30)) = 3
		_StrideSpeed("Stride Speed",Range(0.0,10.0)) = 2.0
		_StrideStrength("Stride Strength", Range(0.0,20.0)) = 3.0

		[Header(Blend State)]
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 //"One"
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DestBlend", Float) = 0 //"Zero"
	}
		SubShader
		{
			Tags {"Queue" = "AlphaTest" "RenderType" = "Geometry" "IgnoreProjector" = "True" "LightMode" = "Vertex"}//
			//Cull Off
			Blend[_SrcBlend][_DstBlend]
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog

				#include "UnityCG.cginc"
				//#include "UnityLightingCommon.cginc" // for _LightColor0
				#include "Lighting.cginc"
				// compile shader into multiple variants, with and without shadows
				// (we don't care about any lightmaps yet, so skip these variants)
				//#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				#pragma multi_compile_fwdadd_fullshadows
				#include "AutoLight.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float4 tangent : TANGENT;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 diff : COLOR0; // diffuse lighting color
					
					float2 uv : TEXCOORD0;
					half3 tspace0 : TEXCOORD1;
					half3 tspace1 : TEXCOORD2;
					half3 tspace2 : TEXCOORD3;
					float3 worldPos : TEXCOORD4;

					SHADOW_COORDS(6) // put shadows data into TEXCOORD1
					UNITY_FOG_COORDS(5)
				};

				sampler2D _MainTex, _BumpTex;
				float4 _MainTex_ST;
				half _EffectRadius;
				half _WaveSpeed;
				half _WaveHeight;
				half _WaveDensity;
				int _Threshold;
				half _StrideSpeed;
				half _StrideStrength;

				v2f vert(appdata v)
				{
					v2f o;
					half sinUse = sin(_Time.y * _WaveSpeed + v.vertex.z * _WaveDensity);
					half yValue = 2-v.vertex.z;
					half yDirScaling = clamp(pow(yValue * _EffectRadius,_Threshold),0.0,1.0);
					v.vertex.x += sinUse * _WaveHeight* yDirScaling;
					v.vertex.x += sin(_Time.y * _StrideSpeed) * _StrideStrength;
					o.vertex = UnityObjectToClipPos(v.vertex);
					
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					half3 worldNormal = UnityObjectToWorldNormal(v.normal);
					half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
					half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					half3 wBitangent = cross(worldNormal, wTangent) * tangentSign;
					o.tspace0 = half3(wTangent.x, wBitangent.x, worldNormal.x);
					o.tspace1 = half3(wTangent.y, wBitangent.y, worldNormal.y);
					o.tspace2 = half3(wTangent.z, wBitangent.z, worldNormal.z);

					// dot product between normal and light direction for
					// standard diffuse (Lambert) lighting
					half NdotL = saturate(dot(_WorldSpaceLightPos0.xyz, worldNormal));
					// factor in the light color
					o.diff = NdotL * _LightColor0; //Esta ecuacion está correcta

					// the only difference from previous shader:
					// in addition to the diffuse lighting from the main light,
					// add illumination from ambient or light probes
					// ShadeSH9 function from UnityCG.cginc evaluates it,
					// using world space normal
					o.diff.rgb += ShadeSH9(half4(worldNormal, 6));//No funciona si LightMode es diferente de ForwardBase
					o.diff.a = 1;
					
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					// compute shadows data
					//TRANSFER_SHADOW(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
					fixed shadow = SHADOW_ATTENUATION(i);
					//fixed shadow = 1;
					fixed4 col = i.diff * tex2D(_MainTex, i.uv);
					fixed3 normal = UnpackNormal(tex2D(_BumpTex, i.uv));
					
					fixed3 worldNormal;
					worldNormal.x = dot(i.tspace0, normal);
					worldNormal.y = dot(i.tspace1, normal);
					worldNormal.z = dot(i.tspace2, normal);
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 worldRefl = reflect(-worldViewDir, worldNormal);
					fixed4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
					fixed3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);

					

					col *= fixed4(skyColor, 1);
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}

			// pull in shadow caster from VertexLit built-in shader
			// UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
			
			// shadow caster rendering pass, implemented manually
			// using macros from UnityCG.cginc
			/*
			Pass
			{
				Tags {"LightMode" = "ShadowCaster"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#include "UnityCG.cginc"

				half _EffectRadius;
				half _WaveSpeed;
				half _WaveHeight;
				half _WaveDensity;
				int _Threshold;
				half _StrideSpeed;
				half _StrideStrength;

				struct v2f {
					V2F_SHADOW_CASTER;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					half sinUse = sin(_Time.y * _WaveSpeed + v.vertex.z * _WaveDensity);
					half yValue = 2 - v.vertex.z;
					half yDirScaling = clamp(pow(yValue * _EffectRadius, _Threshold), 0.0, 1.0);
					v.vertex.x += sinUse * _WaveHeight* yDirScaling;
					v.vertex.x += sin(_Time.y * _StrideSpeed) * _StrideStrength;

					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}
			*/
		}
}