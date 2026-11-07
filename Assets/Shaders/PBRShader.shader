Shader "Custom/PBRShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _MetallicTex("Metallic (r)", 2D) = "white"{}
        _Metallic("Metallic", Range(0.0,1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
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
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            TEXTURE2D(_MetallicTex);
            SAMPLER(sampler_MetallicTex);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _Metallic;
            
                float _Smoothness;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                
                half metallicTex = SAMPLE_TEXTURE2D(_MetallicTex, sampler_MetallicTex, IN.uv).r;
                half metallic = metallicTex * _Metallic;
                half smoothness = _Smoothness;
                
                float3 lightDir = normalize(GetMainLight().direction);
                float3 normalWS = normalize(IN.normalWS);
                half NdotL = max(saturate(dot(normalWS, lightDir)), 0.0);
                
                half3 viewDir = normalize(GetWorldSpaceViewDir(IN.positionWS));
                half fresnel = pow(1.0 - saturate(dot(viewDir, normalWS)), 5.0);
                
                half3 diffuse = color.rgb * NdotL * (1.0 - _Metallic);
                half3 specular = lerp(half3(1, 1, 1), color.rgb, metallic) * fresnel * smoothness;
                half3 finalColor = diffuse + specular;
                return half4(finalColor, color.a);
            }
            ENDHLSL
        }
    }
}
