Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}
	SubShader {
        Pass {
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex vert
            #pragma fragment frag
            
            uniform half4 _Color;

			struct a2v {
                float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                half3 color : COLOR0;
            };
            
            v2f vert(a2v v) {
            	v2f o;
            	o.pos = TransformObjectToHClip(v.vertex);
            	o.color = v.normal * 0.5 + half3(0.5, 0.5, 0.5);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
            	half3 c = i.color;
            	c *= _Color.rgb;
                return half4(c, 1.0);
            }

            ENDHLSL
        }
    }
}
