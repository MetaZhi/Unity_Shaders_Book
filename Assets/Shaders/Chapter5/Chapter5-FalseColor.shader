Shader "Unity Shaders Book/Chapter 5/False Color" {
	SubShader {
		Pass {
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			struct appdata_full {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				half4 color : COLOR;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				half4 color : COLOR0;
			};
			
			v2f vert(appdata_full v) {
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex.xyz);
				
				// Visualize normal
				o.color = half4(v.normal * 0.5 + half3(0.5, 0.5, 0.5), 1.0);
				
				// Visualize tangent
				o.color = half4(v.tangent.xyz * 0.5 + half3(0.5, 0.5, 0.5), 1.0);
				
				// Visualize binormal
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.color = half4(binormal * 0.5 + half3(0.5, 0.5, 0.5), 1.0);
				
				// Visualize the first set texcoord
				o.color = half4(v.texcoord.xy, 0.0, 1.0);
				
				// Visualize the second set texcoord
				o.color = half4(v.texcoord1.xy, 0.0, 1.0);
				
				// Visualize fractional part of the first set texcoord
				o.color = frac(v.texcoord);
				if (any(saturate(v.texcoord) - v.texcoord)) {
					o.color.b = 0.5;
				}
				o.color.a = 1.0;
				
				// Visualize fractional part of the second set texcoord
				o.color = frac(v.texcoord1);
				if (any(saturate(v.texcoord1) - v.texcoord1)) {
					o.color.b = 0.5;
				}
				o.color.a = 1.0;
				
				// Visualize vertex color
//				o.color = v.color;
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				return i.color;
			}
			
			ENDHLSL
		}
	}
}
