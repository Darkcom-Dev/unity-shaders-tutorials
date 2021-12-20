Shader "Surface/Triplanar"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_RockTex0("Base (RGB)", 2D) = "white" {}
		_Rough0("Roughness", 2D) = "white" {}
		_RockTex1("Base (RGB)", 2D) = "white" {}
		_Rough1("Roughness", 2D) = "white" {}
		_RockTex2("Base (RGB)", 2D) = "white" {}
		_Rough2("Roughness", 2D) = "white" {}
		_RockNormal0("Normal (RGB)", 2D) = "white" {}
		_RockNormal1("Normal (RGB)", 2D) = "white" {}
		_RockNormal2("Normal (RGB)", 2D) = "white" {}
		_SizeX("SizeX", Float) = 20
		_SizeY("SizeY", Float) = 20
		_NX("NX", Range(0,1)) = 1
		_NY("NY", Range(0,1)) = 1
		_NZ("NZ", Range(0,1)) = 1

		[MaterialToggle(IF_SNOW)] _IfSnow("if Snow", Float) = 1
		[ShowIf(IF_SNOW)]_SnowDepth("Snow Depth", Range(0,1)) = 1
		
		[ShowIf(IF_SNOW)]_SnowDirection("Snow Direction", Vector) = (0,1,0)
		[ShowIf(IF_SNOW)]_Wetness("Wetness", Range(0, 0.5)) = 0.3
		[ShowIf(IF_SNOW)]_SnowLevel("Snow level", Float) = 1
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf Standard
#pragma shader_feature IF_SNOW
		sampler2D _RockTex0, _RockTex1, _RockTex2;
		sampler2D _Rough0, _Rough1, _Rough2;
		sampler2D _RockNormal0, _RockNormal1, _RockNormal2;
		fixed4 _Color;
		fixed _NX, _NY, _NZ;
		half _SizeX, _SizeY;

#if IF_SNOW
		float _SnowDepth, _Wetness;
		float4 _SnowDirection;
		float _SnowLevel;
#endif

	struct Input
	{
		half3 worldPos;
		fixed3 worldNormal;
		INTERNAL_DATA
	};

	fixed4 TriplanarProjection(sampler2D Texture, fixed3 worldPosition, fixed3 worldNormal, fixed2 scale) {
	
		fixed2 UVxz = worldPosition.xz / scale;
		fixed2 UVxy = worldPosition.xy / scale;
		fixed2 UVzy = worldPosition.zy / scale;

		fixed4 albedo_xz = tex2D(Texture, UVxz);
		fixed4 albedo_xy = tex2D(Texture, UVxy);
		fixed4 albedo_zy = tex2D(Texture, UVzy);

		fixed3 nWNormal = normalize(worldNormal * fixed3(_NX,_NY,_NZ));
		fixed3 projnormal = saturate(pow(nWNormal * 1.5, 4));

		fixed4 finalAlbedo = lerp(albedo_xz, albedo_xy, projnormal.z);
		return finalAlbedo = lerp(finalAlbedo, albedo_zy, projnormal.x);
	}


	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		half2 scale = half2(_SizeX, _SizeY);

		fixed4 roug0 = TriplanarProjection(_Rough0, IN.worldPos, IN.worldNormal, scale);
		fixed4 roug1 = TriplanarProjection(_Rough1, IN.worldPos, IN.worldNormal, scale);
		fixed4 roug2 = TriplanarProjection(_Rough2, IN.worldPos, IN.worldNormal, scale);
		
		fixed4 roug = lerp(roug0, roug1, _Color.r);
		roug = lerp(roug, roug2, _Color.g);

		fixed4 albedo0 = TriplanarProjection(_RockTex0, IN.worldPos, IN.worldNormal, scale);
		fixed4 albedo1 = TriplanarProjection(_RockTex1, IN.worldPos, IN.worldNormal, scale);
		fixed4 albedo2 = TriplanarProjection(_RockTex2, IN.worldPos, IN.worldNormal, scale);

		fixed4 albedo = lerp(albedo0, albedo1, _Color.r);
		albedo = lerp(albedo, albedo2, _Color.g);

		fixed3 normal0xz = (tex2D(_RockNormal0, IN.worldPos.xz));
		fixed3 normal0xy = (tex2D(_RockNormal0, IN.worldPos.xy));
		fixed3 normal0zy = (tex2D(_RockNormal0, IN.worldPos.zy));

		fixed3 nWNormal = normalize(IN.worldNormal * fixed3(_NX, _NY, _NZ));
		fixed3 projnormal = saturate(pow(nWNormal * 1.5, 4));

		//fixed3 resultNormal0 = lerp(1,normal0xz,projnormal);
		fixed3 planarNormal = lerp(normal0xz, normal0xy, projnormal.z);
		o.Normal = UnpackNormal(fixed4(lerp(planarNormal, normal0zy, projnormal.x), 1));//;

#if IF_SNOW
		half difference = dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) - lerp(1, -1, _SnowDepth);
		difference = saturate(difference / _Wetness);
		fixed worldPos = dot(IN.worldPos, fixed3(0, 1 / _SnowLevel, 0));
		o.Albedo = lerp(albedo.rgb, difference + (1 - difference) * albedo.rgb, worldPos);
#else
		
		o.Albedo = albedo.rgb;
#endif
		o.Smoothness = 1-roug.r;
		o.Alpha = _Color.a;
	}
	ENDCG
	}

		Fallback "VertexLit"
}