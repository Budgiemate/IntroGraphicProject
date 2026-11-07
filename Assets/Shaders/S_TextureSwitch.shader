Shader "Custom/S_TextureSwitch"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Texture2("Texture 2", 2D) = "white"{}
        _Texture1("Texture 1", 2D) = "white"{}
        _Cooldown("Cooldown", Float) = 1
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

            TEXTURE2D(_Texture1);
            SAMPLER(sampler_Texture1);
            
            TEXTURE2D(_Texture2);
            SAMPLER(sampler_Texture2);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _Texture1_ST;
                float4 _Texture2_ST;
                float _Cooldown;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _Texture1);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //this samples the color from the texture based on the uv coordinate
                half4 color1 = _Texture1.Sample(sampler_Texture1, IN.uv);
                half4 color2 = _Texture2.Sample(sampler_Texture2, IN.uv);
                
                //fmod gives floating point remainder so it could be 0.45
                float currentTime = fmod(_Time.y, _Cooldown * 2.0);
                
                //compares 2 values if cooldown time is less than remainder than result is 1 else 0
                float blendFactor = step(_Cooldown, currentTime);
                
                //interpolates from the 0 or 1 we get from step
                half3 finalColor = lerp(color1, color2, blendFactor);
               
                return half4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}
