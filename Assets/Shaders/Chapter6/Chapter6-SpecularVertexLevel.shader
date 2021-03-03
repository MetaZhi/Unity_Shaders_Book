Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			half4 _Diffuse;
			half4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				half3 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = TransformObjectToHClip(v.vertex);
				
				// Get ambient term
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Transform the normal from object space to world space
				half3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
				half3 worldLightDir = normalize(_MainLightPosition.xyz);
				
				// Compute diffuse term
				half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				// Get the reflect direction in world space
				half3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				// Get the view direction in world space
				half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				
				// Compute specular term
				half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				o.color = ambient + diffuse + specular;
							 	
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				return half4(i.color, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Specular"
}
