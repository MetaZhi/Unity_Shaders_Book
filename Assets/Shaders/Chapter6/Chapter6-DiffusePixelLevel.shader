Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="UniversalForward" }
		
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			half4 _Diffuse;
			
			struct a2v {
				float3 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = TransformObjectToHClip(v.vertex);

				// Transform the normal from object space to world space
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				// Get ambient term
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Get the normal in world space
				half3 worldNormal = normalize(i.worldNormal);
				// Get the light direction in world space
				half3 worldLightDir = normalize(_MainLightPosition.xyz);
				
				// Compute diffuse term
				half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				half3 color = ambient + diffuse;
				
				return half4(color, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Diffuse"
}
