Shader "Unity Shaders Book/Chapter 9/Shadow" {
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
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			
			half4 _Diffuse;
			half4 _Specular;
			float _Gloss;
			
			struct a2v {
				float3 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float4 shadowCoord : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = TransformObjectToHClip(v.vertex);
			 	
			 	o.worldNormal = TransformObjectToWorldNormal(v.normal);

			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			 	
			 	// Pass shadow coordinates to pixel shader
			 	o.shadowCoord = TransformWorldToShadowCoord(o.worldPos);
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz);
				
				half3 ambient = _GlossyEnvironmentColor;

			 	half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	half3 halfDir = normalize(worldLightDir + viewDir);
			 	half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				half atten = 1.0;
				
				half shadow = SHADOW_ATTENUATION(i);
				
				return half4(ambient + (diffuse + specular) * atten * shadow, 1.0);
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
				float3 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.position = TransformObjectToHClip(v.vertex);
			 	
			 	o.worldNormal = TransformObjectToWorldNormal(v.normal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					half3 worldLightDir = normalize(_MainLightPosition.xyz);
				#else
					half3 worldLightDir = normalize(_MainLightPosition.xyz - i.worldPos.xyz);
				#endif

			 	half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	half3 halfDir = normalize(worldLightDir + viewDir);
			 	half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					half atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					half atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
			 	
				return half4((diffuse + specular) * atten, 1.0);
			}
			
			ENDHLSL
		}
	}
	FallBack "Specular"
}