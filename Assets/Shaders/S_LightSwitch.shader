Shader "Custom/S_LightSwitch"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _LightMode ("Diffuse Lighting", Float) = 0
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Float) = 1
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
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _LightMode;
                float4 _SpecColor;
                float _Shininess;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                float3 worldDirWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldDirWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //default stuff
                half3 albedo = _BaseColor * _BaseMap.Sample(sampler_BaseMap, IN.uv);
                float3 normal = normalize(IN.normalWS);
                
                //diffuse lighting
                if (_LightMode == 0){
                    Light mainLight = GetMainLight();
                    
                    float NdotL = saturate(dot(normal, mainLight.direction));
                    
                    //multiply diffuse effect
                    albedo *= NdotL;
                }
                //ambient lighting
                else if (_LightMode == 1)
                {
                    float3 ambient = SampleSH(normal);
                    
                    albedo = ambient + albedo;
                }
                //specular lighting
                else
                {
                    Light mainLight = GetMainLight();
                    float3 lightDir = normalize(mainLight.direction);
                    
                    float NdotL = saturate(dot(normal, mainLight.direction));
                    
                    
                    half3 reflectDir = reflect(-lightDir, normal);
                    half3 viewDir = normalize(IN.viewDirWS);
                    half specFactor = pow(saturate(dot(reflectDir,viewDir)), _Shininess);
                    half3 specular = _SpecColor.rgb * specFactor;
                    
                    albedo += specular;
                }
                
                return half4(albedo, 1);
            }
            ENDHLSL
        }
    }
}
