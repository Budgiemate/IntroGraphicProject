Shader "Custom/ManualMetallic"
{
    Properties
    {
        _BaseColor ("Base Color (Reflection Tint)", Color) = (1, 1, 1, 1)
        _Metallic ("Metallic (0 = Dielectric, 1 = Full Metal)", Range(0.0, 1.0)) = 1.0
        _Glossiness ("Smoothness / Shininess", Range(1.0, 128.0)) = 64.0
        _RealColor("real color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Basic includes for transformation matrices
            #include "UnityCG.cginc" 

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
            };

            float4 _BaseColor;
            float _Metallic;
            float _Glossiness;
            float4 _RealColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Get normal and view direction in world space
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Normalize inputs
                float3 N = normalize(i.worldNormal);
                float3 V = normalize(i.worldViewDir);
                
                // Fetch the main directional light parameters from Unity
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 H = normalize(L + V); // Halfway vector for Blinn-Phong

                // 1. Diffuse Reflection (Lambertian)
                float diffuseLight = max(dot(N, L), 0.0);
                // Non-metals have diffuse albedo; pure metals have ZERO diffuse energy
                float3 diffuseColor = _BaseColor.rgb * diffuseLight * (1.0 - _Metallic);

                // 2. Specular Reflection (Blinn-Phong Highlights)
                float specLight = pow(max(dot(N, H), 0.0), _Glossiness);
                
                // The Core Rule of Metallic Workflow:
                // Non-metals (Dielectrics) have white specular highlights.
                // Metals tint their specular highlights with their Base Color.
                float3 specularTint = lerp(float3(1.0, 1.0, 1.0), _BaseColor.rgb, _Metallic);
                float3 specularColor = specularTint * specLight;

                // 3. Fake Environment Reflection (To make it look "shiny" without a Cubemap)
                // Reflect the view vector across the normal to get reflection direction
                float3 R = reflect(-V, N); 
                // Fake environment reflection using light source alignment
                float envReflection = pow(max(dot(R, L), 0.0), _Glossiness * 0.2); 
                float3 environmentColor = specularTint * envReflection * _Metallic * 0.5;

                // Combine all elements together
                float3 finalColor = _RealColor + diffuseColor + specularColor + environmentColor;

                return float4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}
