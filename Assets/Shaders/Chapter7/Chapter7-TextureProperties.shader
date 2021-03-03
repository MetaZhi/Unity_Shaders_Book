Shader "Unity Shaders Book/Chapter 7/Texture Properties" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="UniversalForward" }
		
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.position = TransformObjectToHClip(v.vertex);

			 	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half4 c = tex2D(_MainTex, i.uv);

				return half4(c.rgb, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Diffuse"
}
