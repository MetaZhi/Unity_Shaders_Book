Shader "Unity Shaders Book/Chapter 9/Alpha Blend With Shadow" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			Tags { "LightMode"="UniversalForward" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			HLSLPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "AutoLight.cginc"
			
			half4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = TransformObjectToHClip(v.vertex);
			 	
			 	o.worldNormal = TransformObjectToWorldNormal(v.normal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			 	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			 	
			 	// Pass shadow coordinates to pixel shader
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_MainLightPosition.xyz -(i.worldPos));
				
				half4 texColor = tex2D(_MainTex, i.uv);
				
				half3 albedo = texColor.rgb * _Color.rgb;
				
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				half3 diffuse = _MainLightColor.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

			 	// UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			 	
				return half4(ambient + diffuse * atten, texColor.a * _AlphaScale);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Transparent/VertexLit"
	// Or  force to apply shadow
//	FallBack "VertexLit"
}
