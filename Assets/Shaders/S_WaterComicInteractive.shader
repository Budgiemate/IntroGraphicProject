Shader "Custom/S_WaterComicInteractive"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        
        _ScrollSpeed("Scroll Speed", Float) = 0.5 // for scrolling texture
        
        _WaveFrequency ("Wave Frequency", Float) = 0.5 // for how fast the wave appear
        _WaveMagnitude ("Wave Magnitude", Float) = 0.5 // for how big the waves are
        _TopThreshold ("Top Threshold", Float) = .75 // determines how vertical the normal needs to be pointing up
        
        _SplashIntensity ("Splash Intensity", Float) = .5 // determines largeness of splashing
        _SplashColor ("Splash Color", Color) = (1,1,1,1) // determines color of splash  
        _CollisionPoint ("Collision Point", Vector) = (0,0,0,1) // location where splash will occur
        _Colliding ("Colliding", Float) = 0 // if colliding is happening
        
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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS: NORMAL;
            };

            struct Varyings
            {
                float3 positionWS : TEXCOORD1;
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _ScrollSpeed;
                float _TopThreshold;
                float _WaveMagnitude;
                float _WaveFrequency;
                float _SplashIntensity;
                float _SplashColor;
                float4 _CollisionPoint;
                int _Colliding;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                
                //if vertex is within the top of the mesh
                if (IN.positionOS.z > _TopThreshold)
                {
                    //apply wave affect 
                    float wave = cos(positionWS.z * _Time.y * _WaveFrequency) * _WaveMagnitude;
                    
                    //increase y of vertex
                    positionWS.y += wave;
                }
                
                // something collides with object
                if (_Colliding == 1)
                {
                    float wave = abs(cos(positionWS.z * _Time.x - _CollisionPoint.z + positionWS.x * _Time.x - _CollisionPoint.x) * _SplashIntensity );
                    
                    positionWS.y += wave;
                }
                
                OUT.positionWS = positionWS;
                OUT.positionHCS = TransformWorldToHClip(OUT.positionWS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv + _Time.y * _ScrollSpeed) * _BaseColor;
                return color;
            }
            ENDHLSL
        }
    }
}
