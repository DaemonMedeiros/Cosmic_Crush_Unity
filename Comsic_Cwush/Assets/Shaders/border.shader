HLSLINCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float4 normalOS : NORMAL0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float3 normalWS : NORMAL0;
    float3 view : TEXCOORD0;
};

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
CBUFFER_END

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

    float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);

    OUT.view = GetCameraPositionWS() - worldPos;
    return OUT;
}

float4 frag(Varyings IN) : SV_Target
{
    float4 color = _BaseColor;

    float4 result = color;
    result.xyz *= pow(1 - dot(normalize(IN.normalWS), normalize(IN.view)), 4); // rim light

    return result;
}

ENDHLSL

Shader "Custom/arena border"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            ZWrite Off
            Blend One One
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
}
