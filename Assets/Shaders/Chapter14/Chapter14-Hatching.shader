///
///  Reference: 	Praun E, Hoppe H, Webb M, et al. Real-time hatching[C]
///						Proceedings of the 28th annual conference on Computer graphics and interactive techniques. ACM, 2001: 581.
///
Shader "Unity Shaders Book/Chapter 14/Hatching" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_TileFactor ("Tile Factor", Float) = 1
		_Outline ("Outline", Range(0, 1)) = 0.1
		_Hatch0 ("Hatch 0", 2D) = "white" {}
		_Hatch1 ("Hatch 1", 2D) = "white" {}
		_Hatch2 ("Hatch 2", 2D) = "white" {}
		_Hatch3 ("Hatch 3", 2D) = "white" {}
		_Hatch4 ("Hatch 4", 2D) = "white" {}
		_Hatch5 ("Hatch 5", 2D) = "white" {}
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		UsePass "Unity Shaders Book/Chapter 14/Toon Shading/OUTLINE"
		
		Pass {
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag 
			
			#pragma multi_compile_fwdbase
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"
			
			half4 _Color;
			float _TileFactor;
			sampler2D _Hatch0;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _Hatch3;
			sampler2D _Hatch4;
			sampler2D _Hatch5;
			
			struct a2v {
				float3 vertex : POSITION;
				float4 tangent : TANGENT; 
				float3 normal : NORMAL; 
				float2 texcoord : TEXCOORD0; 
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				half3 hatchWeights0 : TEXCOORD1;
				half3 hatchWeights1 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				o.pos = TransformObjectToHClip(v.vertex);
				
				o.uv = v.texcoord.xy * _TileFactor;
				
				half3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				half3 worldNormal = TransformObjectToWorldNormal(v.normal);
				half diff = max(0, dot(worldLightDir, worldNormal));
				
				o.hatchWeights0 = half3(0, 0, 0);
				o.hatchWeights1 = half3(0, 0, 0);
				
				float hatchFactor = diff * 7.0;
				
				if (hatchFactor > 6.0) {
					// Pure white, do nothing
				} else if (hatchFactor > 5.0) {
					o.hatchWeights0.x = hatchFactor - 5.0;
				} else if (hatchFactor > 4.0) {
					o.hatchWeights0.x = hatchFactor - 4.0;
					o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				} else if (hatchFactor > 3.0) {
					o.hatchWeights0.y = hatchFactor - 3.0;
					o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				} else if (hatchFactor > 2.0) {
					o.hatchWeights0.z = hatchFactor - 2.0;
					o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
				} else if (hatchFactor > 1.0) {
					o.hatchWeights1.x = hatchFactor - 1.0;
					o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				} else {
					o.hatchWeights1.y = hatchFactor;
					o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				}
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				TRANSFER_SHADOW(o);
				
				return o; 
			}
			
			half4 frag(v2f i) : SV_Target {			
				half4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
				half4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
				half4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
				half4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights1.x;
				half4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.y;
				half4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.z;
				half4 whiteColor = half4(1, 1, 1, 1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z - 
							i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z);
				
				half4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + whiteColor;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
								
				return half4(hatchColor.rgb * _Color.rgb * atten, 1.0);
			}
			
			ENDHLSL
		}
	}
	FallBack "Diffuse"
}
