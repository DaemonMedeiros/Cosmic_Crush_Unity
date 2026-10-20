HLSLINCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float4 color : COLOR0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float4 color : COLOR0;
};

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.color = pow(IN.color * 2, 2.2);
    return OUT;
}

float4 frag(Varyings IN) : SV_Target
{
    return IN.color;
}

ENDHLSL

Shader "Custom/bullet"
{
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent"  "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Blend One One
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDHLSL
        }
    }
}
