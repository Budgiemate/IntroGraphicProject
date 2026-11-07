Shader "Custom/S_TextureTransition"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Texture1("Texture 1", 2D) = "white" {}
        _Texture2("Texture 2",2D) = "white" {}
        _SwitchCooldown ("Switch Cooldown", Float) = 1
        
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
                float _SwitchCooldown;
            
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
                half4 color1 = _Texture1.Sample(sampler_Texture1, IN.uv);
                half4 color2 = _Texture2.Sample(sampler_Texture2, IN.uv);
                
                //gets the fade effect value but needs to not cut to 0
                float currentInterval = fmod(_Time.y, (_SwitchCooldown));
                
                
                half3 color = lerp(color1, color2, currentInterval / _SwitchCooldown);
                half3 extraColor = lerp(color1, color2, 1 - (currentInterval / _SwitchCooldown));
                return half4(extraColor * color, 1);
            }
            ENDHLSL
        }
    }
}
