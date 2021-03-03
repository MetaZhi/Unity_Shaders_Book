Shader "Unity Shaders Book/Chapter 10/Reflection" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "AutoLight.cginc"
			
			half4 _Color;
			half4 _ReflectColor;
			half _ReflectAmount;
			samplerCUBE _Cubemap;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				half3 worldNormal : TEXCOORD1;
				half3 worldViewDir : TEXCOORD2;
				half3 worldRefl : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				o.pos = TransformObjectToHClip(v.vertex);
				
				o.worldNormal = TransformObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.worldViewDir = GetCameraPositionWS() - (o.worldPos);
				
				// Compute the reflect dir in world space
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
				
				TRANSFER_SHADOW(o);
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz -(i.worldPos));		
				half3 worldViewDir = normalize(i.worldViewDir);		
				
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				half3 diffuse = _MainLightColor.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				
				// Use the reflect dir in world space to access the cubemap
				half3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				// Mix the diffuse color with the reflected color
				half3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
				
				return half4(color, 1.0);
			}
			
			ENDHLSL
		}
	}
	FallBack "Reflective/VertexLit"
}
