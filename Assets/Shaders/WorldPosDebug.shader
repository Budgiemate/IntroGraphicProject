Shader "Custom/WorldPosDebug"
{
    Properties
    {
        _Scale("WorldPos Scale (tiling)", Float) = 1.0
        _Offset("WorldPos Offset", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward"}
            LOD 100
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float _Scale;
                vector _Offset;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionWS = posWS;
                OUT.positionHCS = TransformWorldToHClip(posWS);

                return OUT;
            }

            float3 WorldPosToColor (float3 wPos, float scale){
                float3 vertex = wPos * max(scale, 1e-4);

                float3 base = frac(vertex);

                float3 edge = step(0.98, frac(vertex));

                return saturate(base + edge * 0.2);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 wp = IN.positionWS + _Offset.xyz;
                float3 col = WorldPosToColor(wp, _Scale);
                
                return half4(col,1);
            }
            ENDHLSL
        }
    }
}
