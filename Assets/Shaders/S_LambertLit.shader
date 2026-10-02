Shader "Custom/S_LambertLit"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Name "UniversalForward"

        Tags { "RenderType" = "Opaque" "LightMode" = "UniversalForward" "RenderPipeline" = "UniversalPipeline" }
    
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

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS);
                
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normal = SafeNormalize(IN.normalWS);
                
                //main directional light stuff
                Light mainLight = GetMainLight();
                float NdotL = saturate(dot(normal, mainLight.direction));
                half3 diffuse = _BaseColor.rgb * mainLight.color.rgb * NdotL;
                
                //ambient light
                half3 ambient = SampleSH(normal) * _BaseColor.rgb;
                
                return half4(diffuse + ambient, 1);
            }
            ENDHLSL
        }
    }
}
