HLSLINCLUDE

#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 normalOS : NORMAL0;
    float4 color : COLOR0;
    float4 tangent : TANGENT0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normalWS : NORMAL0;
    float3 view : TEXCOORD1;
    float4 shadow : TEXCOORD2;
    float3 positionWS : TEXCOORD3;
    float3 positionOS : TEXCOORD4;
    float3x3 tangentToWorld : TEXCOORD5;
    float color : COLOR0;
};

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_AmbientOcc);
SAMPLER(sampler_AmbientOcc);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_SpecularMap);
SAMPLER(sampler_SpecularMap);
sampler3D _NoiseMap;

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _SpecColor;
    float _SpecPower;
    float _HotSpot;
    float _Flake;
    float4 _BaseMap_ST;
    float4 _NormalMap_ST;
CBUFFER_END

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
    OUT.uv.zw = TRANSFORM_TEX(IN.uv, _NormalMap);
    OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

    float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
    OUT.positionWS = worldPos;
    OUT.positionOS = IN.positionOS.xyz;

    OUT.view = GetCameraPositionWS() - worldPos;

    VertexPositionInputs positions = GetVertexPositionInputs(IN.positionOS.xyz);
    OUT.shadow = GetShadowCoord(positions);

    OUT.color = saturate(2 * IN.color.x);

    float3 tangentWS = TransformObjectToWorldNormal(IN.tangent);

    OUT.tangentToWorld = CreateTangentToWorld(OUT.normalWS, tangentWS.xyz, IN.tangent.w > 0.0 ? 1.0 : -1.0);

    return OUT;
}

float4 frag(Varyings IN) : SV_Target
{
    float4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv.xy) * _BaseColor;
    float4 ambientOcc = SAMPLE_TEXTURE2D(_AmbientOcc, sampler_AmbientOcc, IN.uv.zw); // normal map ambient occlusion
    float4 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, IN.uv.xy);
    float3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv.zw));

    normal = TransformTangentToWorld(normal, IN.tangentToWorld);
    normal = normalize(normal);

    float flakeFalloff = 1.0f / (1.0f + length(IN.view * 0.35f));

    float3 flakeNormal = normalize(normal + (TransformObjectToWorldNormal(tex3Dbias(_NoiseMap, float4(IN.positionOS.xyz * 10, -3))) * _Flake * flakeFalloff));

    //return float4((1 + normal) / 2, 1);

    Light light = GetMainLight();

    float3 shLight = SampleSH(normal);

    float3 diffuse = saturate(0.1 + dot(normal, normalize(light.direction)));
    float RdotV = saturate((dot(reflect(normalize(-light.direction), normal), normalize(IN.view)) + 1) * 0.5);
    float RdotVFlake = saturate((dot(reflect(normalize(-light.direction), flakeNormal), normalize(IN.view)) + 1) * 0.5);
    float NdotV = max(0, dot(normal, normalize(IN.view)));

    float3 specular = pow(RdotVFlake, _SpecPower) * _SpecColor * 2;
    specular += pow(RdotV, _SpecPower * 80) * _HotSpot; // hotspot
    specular *= specMap;

    float shadow = lerp(MainLightRealtimeShadow(IN.shadow), 1.0, GetMainLightShadowFade(IN.positionWS)).x;

    color *= pow(NdotV, 0.5); // extinction

    float4 result = color;
    result.xyz += specular;// specular
    result.xyz *= diffuse; // diffuse
    result.xyz *= light.color; // tint by sun color
    result.xyz *= shadow; // shadow
    result.xyz += shLight * color; // ambient
    result.xyz *= IN.color * ambientOcc; // ambient occlusion
    result.xyz += (shLight + (diffuse * 0.5 * light.color * shadow)) * (1 - pow(NdotV, 0.5)) * 0.25 * ambientOcc * specMap; // rim light

    return result;
}

struct VtoP_shadow
{
    float4 positionHCS : SV_POSITION;
};

VtoP_shadow shadowVS(Attributes IN)
{
    VtoP_shadow OUT;

    float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
    
    Light light = GetMainLight();

    OUT.positionHCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, light.direction));

    #if UNITY_REVERSED_Z
        OUT.positionHCS.z = min(OUT.positionHCS.z, OUT.positionHCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        OUT.positionHCS.z = max(OUT.positionHCS.z, OUT.positionHCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    return OUT;
}

float4 shadowPS(VtoP_shadow IN) : SV_Target
{
    return 0;
}

ENDHLSL

Shader "Custom/ship"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecPower("Specular Power", Float) = 1
        _HotSpot("Specular Hot Spot", Float) = 0.1
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [Normal] _NormalMap("Normal Map", 2D) = "bump" {}
        _AmbientOcc("Ambient Occlusion Map", 2D) = "white" {}
        _SpecularMap("Specular Map", 2D) = "white" {}
        _NoiseMap("Noise Map", 3D) = "white" {}
        _Flake("Flake intensity", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off
            
            HLSLPROGRAM

            #pragma vertex shadowVS
            #pragma fragment shadowPS
            ENDHLSL
        }
    }
}
