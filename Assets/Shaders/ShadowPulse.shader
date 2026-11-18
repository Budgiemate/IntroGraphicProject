Shader "Custom/ShadowPulse"
{
    Properties
    {
       _BaseColor("Base Color",Color) = (1,1,1,1)
       _ShadowPulse("Shadow Pulse", Float) = 1
    }

    SubShader
    {
        
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        
        // 1. MAIN VISUAL PASS (Static mesh, receives shadows normally)
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD5;
                float4 shadowCoord : TEXCOORD6;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _ShadowPulse;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - OUT.positionWS);
                OUT.shadowCoord = TransformWorldToShadowCoord(OUT.positionWS);
                OUT.uv = IN.uv;
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight(IN.shadowCoord);
                half3 normal = normalize(IN.normalWS);
                half NdotL = saturate(dot(normal, mainLight.direction));
                
                // Apply basic lighting + received shadows so you can see the effect
                half3 lighting = mainLight.color * (NdotL * mainLight.shadowAttenuation) + SampleSH(normal);
                half3 color = _BaseColor.rgb * lighting;
                
                return half4(color, 1);
            }
            ENDHLSL
        }

        // 2. CUSTOM SHADOW CASTER PASS (Pulses the cast shadow)
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Required URP global variables for shadow bias
            float3 _LightDirection;
            float3 _LightPosition;

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _ShadowPulse;
            CBUFFER_END

            Varyings ShadowPassVertex(Attributes IN)
            {
                Varyings OUT;

                // Apply your pulsing offset in Object Space
                float3 pulsedPosOS = IN.positionOS.xyz + IN.normalOS * sin(_Time.y) * _ShadowPulse;

                float3 positionWS = TransformObjectToWorld(pulsedPosOS);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                    float3 lightDirectionWS = _LightDirection;


                OUT.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                
                    OUT.positionCS.z = min(OUT.positionCS.z, UNITY_NEAR_CLIP_VALUE);


                return OUT;
            }

            half4 ShadowPassFragment(Varyings IN) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
}
