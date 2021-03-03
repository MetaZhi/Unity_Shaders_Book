Shader "Unity Shaders Book/Chapter 9/Attenuation And Shadow Use Build-in Functions" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		Pass {
			// Pass for ambient light & first pixel light (directional light)
			Tags { "LightMode"="UniversalForward" }
		
			HLSLPROGRAM
			
			// Apparently need to add this declaration
			#pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			// Need these files to get built-in macros
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "AutoLight.cginc"
			
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
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = TransformObjectToHClip(v.vertex);
			 	
			 	o.worldNormal = TransformObjectToWorldNormal(v.normal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			 	
			 	// Pass shadow coordinates to pixel shader
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz -(i.worldPos));
				
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
			 	half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	half3 viewDir = normalize(GetCameraPositionWS() - (i.worldPos));
			 	half3 halfDir = normalize(worldLightDir + viewDir);
			 	half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				// UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				return half4(ambient + (diffuse + specular) * atten, 1.0);
			}
			
			ENDHLSL
		}
	
		Pass {
			// Pass for other pixel lights
			Tags { "LightMode"="ForwardAdd" }
			
			Blend One One
		
			HLSLPROGRAM
			
			// Apparently need to add this declaration
			#pragma multi_compile_fwdadd
			// Use the line below to add shadows for point and spot lights
//			#pragma multi_compile_fwdadd_fullshadows
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "AutoLight.cginc"
			
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
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = TransformObjectToHClip(v.vertex);
			 	
			 	o.worldNormal = TransformObjectToWorldNormal(v.normal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			 	
			 	// Pass shadow coordinates to pixel shader
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz -(i.worldPos));
				
			 	half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	half3 viewDir = normalize(GetCameraPositionWS() - (i.worldPos));
			 	half3 halfDir = normalize(worldLightDir + viewDir);
			 	half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				// UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			 	
				return half4((diffuse + specular) * atten, 1.0);
			}
			
			ENDHLSL
		}
	}
	FallBack "Specular"
}
