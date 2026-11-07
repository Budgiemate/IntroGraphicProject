Shader "Custom/FlatShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
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
                float3 normalWS : TEXCOORD1;
                float3 posWS : TEXCOORD0;
            };
            

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.posWS = TransformObjectToWorld(IN.positionOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 edge1 = ddx(IN.posWS);
                float3 edge2 = ddy(IN.posWS);
                half3 faceNormalWS = normalize(cross(edge1, edge2));
                
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                
                float NdotL = saturate(dot(faceNormalWS, -lightDir));
                
                half3 finalColor = _BaseColor.rgb * NdotL;

                return half4(finalColor, _BaseColor.a);
            }
            ENDHLSL
        }
    }
}
