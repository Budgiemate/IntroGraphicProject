Shader "Custom/RimLightBump"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimStrength ("Rim Strength", Range(0.5, 8.0)) = 1
        
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
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 viewDirWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };
            

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _RimColor;
                float _RimStrength;
            CBUFFER_END

            Varyings vert(Attributes IN)    
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normalWS = normalize(IN.normalWS);
                float3 viewDirWS = normalize(IN.viewDirWS);
                
                half rimFactor = 1 - saturate(dot(viewDirWS, normalWS));
                half rimLighting = pow(rimFactor, _RimStrength);
                half3 finalColor = _BaseColor + _RimColor * rimLighting;
                return half4(finalColor, _BaseColor.a);
            }
            ENDHLSL
        }
    }
}
