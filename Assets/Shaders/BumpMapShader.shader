Shader "Custom/BumpMapShader"
{
    Properties
    {
        _MyDiffuse("Diffuse Map", 2D) = "white"{}
        _MyBump("Bump Map", 2D) = "white"{}
        _MySlider("Bump Amount", Range(0,10)) = 1
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
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float2 uv : TEXCOORD0;
                float3 biTangent : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
            };

            TEXTURE2D(_MyDiffuse);
            SAMPLER(sampler_MyDiffuse);
            
             TEXTURE2D(_MyBump);
            SAMPLER(sampler_MyBump);

            CBUFFER_START(UnityPerMaterial)
                float _MySlider;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                OUT.normalWS = normalize(TransformObjectToWorld(IN.normalOS.xyz));
                OUT.tangentWS = normalize(TransformObjectToWorldNormal(IN.tangentOS.xyz));
                OUT.biTangent = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;
                
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);
                
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 albedo = SAMPLE_TEXTURE2D(_MyDiffuse, sampler_MyDiffuse, IN.uv);
                
                half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_MyBump, sampler_MyBump, IN.uv));
                    
                normalTS.xy *= _MySlider;
                
                half3x3 TBN = half3x3(IN.tangentWS, IN.biTangent, IN.normalWS);
                half3 normalWS = normalize(mul(normalTS, TBN));
                
                Light mainLight = GetMainLight();
                float3 lightDir =  normalize(mainLight.direction);
                
                half NdotL = saturate(dot(normalWS, lightDir));
                half3 diffuse =albedo.rgb * NdotL;
                
                return half4(diffuse, albedo.a);
            }
            ENDHLSL
        }
    }
}
