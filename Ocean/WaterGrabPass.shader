// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Vertex Fragment/Custom/WaterGrabPass" {
	Properties{
		[Header(Reflection)]
		_RimPower("rim power", Range(0.0,1.0)) = 1.0
		
		[Header(Refraction)]
		_Distortion("XZ displace | Y Scale | W Distortion", Vector) = (1,1,0.05,0)
		[NoScaleOffset]_NormalMap("normal map", 2D) = "bump"{}
		
		[Header(Depth)]
		[MaterialToggle(DEPTH_ENABLED)]_ifDepth("Depth enabled", Float) = 1
		[ShowIf(DEPTH_ENABLED)]_WaterColor("Water color| Alpha = depth", Color) = (0.5,0.5,0.5,1)

		[Header(Foam)]
		[NoScaleOffset]_FoamRamp("Foam Ramp", 2D) = "white"{}
		[ShowIf(DEPTH_ENABLED)]_FoamDepth("Foam depth", Range(0.1,5)) = 1.0
		[ShowIf(DEPTH_ENABLED)]_FoamPeak("Foam Peak", Range(-55,55)) = 1.0
		[ShowIf(DEPTH_ENABLED)]_FoamPower("Foam Power", Range(-55,55)) = 1.0

		[Header(Vertex modification)]
		[NoScaleOffset]_VertexDistortionTex("Water distortion",2D) = "white"{}
		_WaveSpeed("Wave speed", Float) = 1.0
		_WaveAmp("Wave Amplitude", Range(0,10)) = 0.1
		_VertexDistortion("WaterDistortion", Range(0,100)) = 1.0
		
		[Header(Other)]
		_SpecPower("Specular power", Float) = 1.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True"  "Queue" = "Transparent"}
			ZWrite On
			Cull Off
			LOD 200

			GrabPass{"_Water"}

			Pass
			{
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma shader_feature DEPTH_ENABLED
					#pragma multi_compile_fog    

				#pragma target 2.0
				#pragma debug
				#pragma fragmentoption ARB_precision_hint_fastest
				//#pragma shader_feature VERTEX_MOD_ENABLED
				#include "UnityCG.cginc"

			fixed _SpecPower;

			//Reflection
			fixed _RimPower;

			//Refraction
			sampler2D _Water;//GrabPass
			sampler2D _NormalMap;
			fixed4 _Distortion;

			//Vertex modification
			sampler2D _VertexDistortionTex;
			
			fixed _WaveSpeed, _WaveAmp;
			fixed _VertexDistortion;
			fixed _FoamPeak, _FoamPower;
			
			sampler2D _FoamRamp;
			sampler2D _CameraDepthTexture;
			fixed _FoamDepth;

#if DEPTH_ENABLED
			fixed4 _WaterColor;
#endif
			
				struct vertInput {
					fixed4 pos: POSITION;
					fixed3 normal : NORMAL;
					//VR Single pass
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct vert2frag {
					
					fixed4 screenPos : TEXCOORD0;
					fixed4 uvgrab: TEXCOORD1;
					fixed3 worldRefl : TEXCOORD2;
					fixed3 worldPos : TEXCOORD3;
					fixed3 data : COLOR;//R = rim, G = Foam, B = Specular

					//Used to pass fog amount around number should be a free texcoord.
					fixed4 pos : SV_POSITION; //Es obligatorio o los vertices no apareceran.
					UNITY_FOG_COORDS(4)
					//VR Single pass
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				//TODO: se puede ahorar una textura si uno la espuma como alpha, con el ruido perlin generado como RGB,
				//TODO: Quizas considerar el color del sol para el brillo especular.
				vert2frag vert(vertInput v) {
					vert2frag o;
					
					UNITY_SETUP_INSTANCE_ID(v); //Insert
					UNITY_INITIALIZE_OUTPUT(vert2frag, o); //Insert
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

					//Vertex Deformation
					fixed3 worldPos = mul(unity_ObjectToWorld, v.pos);// posicion mundial del objeto
					o.pos = UnityObjectToClipPos(v.pos);// posicion local del objeto

					fixed2 offsetA = _Time.xz * _WaveSpeed;
					fixed2 offsetB = _Time.xy * _WaveSpeed;
					fixed2 offsetC = -_CosTime.yw * _WaveSpeed;
					fixed2 worldUV = worldPos.xz * (_WaveAmp/1000);
					fixed noiseSampleA = tex2Dlod(_VertexDistortionTex, fixed4(worldUV + offsetA,0,0)).r;
					fixed noiseSampleB = tex2Dlod(_VertexDistortionTex, fixed4(worldUV/3 + offsetB, 0, 0)).g;
					fixed noiseSampleC = tex2Dlod(_VertexDistortionTex, fixed4(worldUV/2 + offsetC, 0, 0)).b;
					fixed noiseTex = sinh(noiseSampleA + noiseSampleB + noiseSampleC)/3;
					
					o.pos.y -= sin(_VertexDistortion * (noiseTex -0.5));
					//fixed foamPeak = ((noiseSampleB - noiseSampleC) / noiseSampleA)*_FoamPeak;//(pow (noiseTex * 2 - 1, _FoamPeak));
		
					//UVs
					float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldRefl = reflect(-worldViewDir, worldNormal);
					o.uvgrab = ComputeGrabScreenPos(o.pos);
					o.screenPos = ComputeScreenPos(o.pos);
					o.worldPos = worldPos.xzy;

					//TODO: Hay un problema con el calculo de NdotV, resulta que rim funciona bien si la normal apunta hacia arriba,
					//en otras palabras si estas sobre el agua el efecto llega a funcionar bien, pero debajo del agua no.
					//Lo mismo ocurre con el specular, de un lado llega a funcionar, pero del otro no.

					//Rim
					fixed3 viewDir = normalize(ObjSpaceViewDir(v.pos));
					float NdotV = saturate(dot(v.normal, abs(viewDir)));
					fixed rim = smoothstep(1 - _RimPower, 1, 1 - NdotV);

					//Spec
					//fixed NdotL = dot(v.normal, _WorldSpaceLightPos0);
					//fixed WNdotV = dot(worldNormal, worldViewDir);//NDotV es casi lo mismo.
					//fixed LdotV = saturate(dot(NdotL, NdotV));


					//fixed spec = pow(LdotV,_SpecPower);
					o.data = fixed3(rim, cos(noiseTex * _FoamPeak), 0);//spec

					//Compute fog amount from clip space position.
					UNITY_TRANSFER_FOG(o, o.pos);

					return o;
				}

				//UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex); //Insert

				half4 frag(vert2frag i) : COLOR{

					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

					fixed4 waterColor;
					fixed foam;
					fixed foamData;
#if DEPTH_ENABLED
					fixed depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
					depthSample = LinearEyeDepth(depthSample);
					
					fixed depth = pow(depthSample,-_WaterColor.a);
					waterColor = lerp(_WaterColor, 1, depth);
				
					fixed foamLine = 1 - saturate(_FoamDepth * (depthSample - i.screenPos.w));
					fixed foamTex = tex2D(_FoamRamp, i.worldPos + _SinTime.zw);
					foamTex += tex2D(_FoamRamp, i.worldPos * 2 + _CosTime.xy);

					foamData = (abs(foamLine + pow(sin(i.data.g),_FoamPower)) / 2);
					foam = saturate(foamTex * foamData);
				#else
					waterColor = 1;
					foam = 0;
					foamData = 0;
				#endif		
				
					
					//Distortion
					fixed2 displacement = _Distortion.xz * _SinTime.xz;
					fixed3 norm = UnpackNormal(tex2D(_NormalMap, i.worldPos *_Distortion.y + displacement));
					i.uvgrab.xy += norm * _Distortion.w;

					fixed4 col = tex2Dproj(_Water, UNITY_PROJ_COORD(i.uvgrab)) * waterColor ;
					
					
					fixed4 reflData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
					half3 refl = DecodeHDR(reflData, unity_SpecCube0_HDR);

					fixed4 result = lerp(col, fixed4(refl, 1), i.data.r);
					result += foam; // (foam + norm.g *  sin(i.data.b));

					//Apply fog (additive pass are automatically handled)
					UNITY_APPLY_FOG(i.fogCoord, result);

					//to handle custom fog color another option would have been 
					//#ifdef UNITY_PASS_FORWARDADD
					//  UNITY_APPLY_FOG_COLOR(i.fogCoord, color, float4(0,0,0,0));
					//#else
					//  fixed4 myCustomColor = fixed4(0,0,1,0);
					//  UNITY_APPLY_FOG_COLOR(i.fogCoord, color, myCustomColor);
					//#endif

					return result;// fixed4(i.data, 1);

				}
				ENDCG
			}
		}
	FallBack "Diffuse"
}
/*
http://www.alanzucconi.com/2015/07/01/vertex-and-fragment-shaders-in-unity3d/
Semantica de entrada VertInput
POSITION, SV_POSITION: posicion de un vertice o coordenadas mundiales(espacio objetos)
NORMAL:la normal de un vertice, en relacion al mundo(no a la camara);
COLOR,COLOR0,DIFUSE,SV_TARGET:informacion almacenada en el vertice
COLOR1,SPECULAR:informacion de color secundaria almacenada en el vertice
FOGCOORD:coordinar niebla
TEXCOORD0,TEXCOORD1,...TEXCOORD10: datos almacenados en el vertice de UVs

Semantica de salida VertOutput
POSITION,SV_POSITION,HPOS:
COLOR,COLOR0,COL0,COL,SV_TARGET:
COLOR1,COL1:
FOGC,FOG:
TEXCOORD0,TEXCOORD1,...TEXCOORDx,TEXI:
PSIZE,PSIZ:
WPOS:
*/