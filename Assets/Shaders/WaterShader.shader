Shader "Custom/WaterShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1) // color of water
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {} // texture of water
        _ScrollSpeedX ("Scroll Speed", float) = 0
        _ScrollSpeedY ("Scroll Speed", float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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

            sampler2D _BaseMap;
            SAMPLER(sampler_BaseMap);
            float2 _ScrollSpeedX;
            float _ScrollSpeedY;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN) // takes 3d vertex
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target // fragment runs per pixel
            {
                float2 scrolledUV = IN.uv;

                float scrollValueX = _ScrollSpeedX * _Time.x;
                float scrollValueY = _ScrollSpeedY * _Time.y;

                scrolledUV += float2(scrollValueX, scrollValueY);

                half4 color = tex2D(_BaseMap, scrolledUV);
                color *= _BaseColor;
                return color;
            }
            ENDHLSL
        }
    }
}
