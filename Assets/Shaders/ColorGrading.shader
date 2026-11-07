Shader "Custom/ColorGrading"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _LUT("LUT",2D) = "white" {}
        _Contribution("Contribution", Range(0,1)) = 1
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always
        
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        
        
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define COLORS 32.0
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
                        TEXTURE2D(_LUT);
            SAMPLER(sampler_LUT);

            float4 _LUT_TexelSize;
            float _Contribution;
            
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                
                float maxColor = COLORS - 1.0;
                
                float halfColX = 0.5 / _LUT_TexelSize.z;
                float halfColY = 0.5 / _LUT_TexelSize.w;
                float threshold = maxColor / COLORS;
                
                float yOffset = halfColY + color.g * threshold;
                float xOffset = halfColX + color.r * threshold / COLORS;
                float cell = floor(color.b * maxColor);
                
                float2 lutPos = float2(cell / COLORS + xOffset, yOffset);
                half4 gradedColor = SAMPLE_TEXTURE2D(_LUT, sampler_LUT, lutPos);
                
                
                return lerp(color, gradedColor, _Contribution);
            }
            ENDHLSL
        }
    }
}
