Shader "Custom/TilingShader"
{
    Properties
    {
        [MainColor] _MyColor("Sample Color", Color) = (1, 1, 1, 1)
        _MyRange("Sample Range",Range(0,5)) = 2.5
        _MyTex("Sample Texture", 2D) = "white" {}
        _MyCube("Sample Cube", Cube) = "" {}
        _MyFloat("Sample Float", Float) = 1.0
        _MyVector("Sample Vector", Vector) = (0.5,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "ForwardLit"
            Tags{ "LightMode" = "UniversalForward"}
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            TEXTURE2D(_MyTex);
            SAMPLER(sampler_MyTex);
            
            TEXTURECUBE(_MyCube);
            SAMPLER(sampler_MyCube);

            CBUFFER_START(UnityPerMaterial)
                float4 _MyColor;
                float _MyRange;
                float _MyFloat;
                float4 _MyVector;
                float4 _MyTex_ST;
                
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 nrmWS = TransformObjectToWorld(IN.normalOS);
                
                OUT.positionWS = posWS;
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.normalWS = nrmWS;
                OUT.uv2 = TRANSFORM_TEX(IN.uv0, _MyTex);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //get base albedo from 2d texture
                half3 texCol = SAMPLE_TEXTURE2D(_MyTex, sampler_MyTex, IN.uv2).rgb;
                half3 albedo = texCol * _MyRange * _MyColor.rgb;
                
                //world normal and view direction
                float3 normal = SafeNormalize(IN.normalWS);
                float3 viewDirection = SafeNormalize(GetWorldSpaceViewDir(IN.positionWS));
                
                //simple lambert main light
                Light mainLight = GetMainLight();
                float ndotl = saturate(dot(normal, mainLight.direction));
                half3 diffuse = albedo * mainLight.color.rgb * ndotl;
                
                //ambient from shader?
                half3 ambient = SampleSH(normal) * albedo;
                
                //emission from cubemap using world reflection
                float3 reflection = reflect(-viewDirection, normal);
                half3 env = SAMPLE_TEXTURECUBE(_MyCube, sampler_MyCube,reflection).rgb;
                
                //optional knobs for extra multipliers if needed
                env *= _MyFloat;
                env *= _MyVector.xyz;
                
                //final color
                half3 color = diffuse + ambient + env;

                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
