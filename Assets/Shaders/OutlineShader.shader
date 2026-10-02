Shader "Custom/OutlineShader"
{
    Properties
    {
        [MainColor] _LineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineThickness("Outline Thickness", Float) = 0.0f
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Cull Front

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes // can have attributes of the vertex 
            /*
            this includes
            POSITION - vertex position float3 or float4
            NORMAL - vertex normal float3
            TEXCOORD0 - first UV coordinate
            TEXCOORD1 - second third and fourth UV coordinate
            TEXCOORD2
            TEXCOORD3
            TANGENT - used for normal maps
            COLOR - per vertex color
            */
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
            };


            Varyings vert(Attributes vertexData)
            {
                Varyings vertex;

                vertex.

            }

            half4 frag(Varyings In) : SV_Target
            {

            }
            ENDHLSL
        }
    }
}
