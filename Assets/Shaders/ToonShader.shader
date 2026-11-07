Shader "Custom/ToonShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _RampTexture("Ramp Texture", 2D) = "white"{}
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
            };

            TEXTURE2D(_RampTexture);
            SAMPLER(sampler_RampTexture);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorld(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                half3 lightDirWS = mainLight.direction;
                half3 lightColor = mainLight.color.rgb;
                
                half NdotL = saturate(dot(IN.normalWS, lightDirWS));
                half rampValue =SAMPLE_TEXTURE2D(_RampTexture, sampler_RampTexture, float2(NdotL, 0)).r;
                half3 finalColor = _BaseColor.rgb  * lightColor * rampValue;
                
                return half4(finalColor.rgb, _BaseColor.a);
            }
            ENDHLSL
        }
    }
}
