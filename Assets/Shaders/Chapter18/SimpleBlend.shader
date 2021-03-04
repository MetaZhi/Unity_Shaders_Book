Shader "Unity Shaders Book/Chapter 18/Simple Blend" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			half4 _Color;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			
			struct a2v {
				float3 vertex : POSITION;
				half4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half4 c = tex2D(_MainTex, i.uv);
				c.rgb = _Color.rgb;
				return c;
			}
			
			ENDHLSL
		}
	} 
	FallBack "Transparent/VertexLit"
}
