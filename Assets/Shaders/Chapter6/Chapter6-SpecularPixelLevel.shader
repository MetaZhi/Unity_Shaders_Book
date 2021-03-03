Shader "Unity Shaders Book/Chapter 6/Specular Pixel-Level" {
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = TransformObjectToHClip(v.vertex);
				
				// Transform the normal from object space to world space
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				// Transform the vertex from object spacet to world space
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				// Get ambient term
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz);
				
				// Compute diffuse term
				half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				// Get the reflect direction in world space
				half3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				// Get the view direction in world space
				half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				// Compute specular term
				half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				return half4(ambient + diffuse + specular, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Specular"
}
