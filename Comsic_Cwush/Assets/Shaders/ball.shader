HLSLINCLUDE

#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 normalOS : NORMAL0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : NORMAL0;
    float3 view : TEXCOORD1;
    float4 shadow : TEXCOORD2;
};

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _BaseMap_ST;
CBUFFER_END

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
    OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

    float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);

    OUT.view = GetCameraPositionWS() - worldPos;
    OUT.shadow = TransformWorldToShadowCoord(worldPos);
    return OUT;
}

float4 frag(Varyings IN) : SV_Target
{
    float4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

    Light light = GetMainLight();

    float3 shLight = SampleSH(IN.normalWS);

    float4 result = color;
    result.xyz += pow(saturate(dot(reflect(normalize(-light.direction), normalize(IN.normalWS)), normalize(IN.view))), 22);// specular
    result.xyz *= max(0, dot(normalize(IN.normalWS), normalize(light.direction))); // diffuse
    result.xyz *= MainLightRealtimeShadow(IN.shadow); // shadow
    result.xyz += shLight * color; // ambient
    result.xyz += shLight * 2 * (1 - dot(normalize(IN.normalWS), normalize(IN.view))); // rim light

    return result;
}

ENDHLSL

Shader "Custom/ball"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
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
    }
}
