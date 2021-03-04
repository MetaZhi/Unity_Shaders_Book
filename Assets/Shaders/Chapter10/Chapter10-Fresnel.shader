Shader "Unity Shaders Book/Chapter 10/Fresnel" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
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
			half _FresnelScale;
			samplerCUBE _Cubemap;
			
			struct a2v {
				float3 vertex : POSITION;
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
				
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
				
				TRANSFER_SHADOW(o);
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = _MainLightPosition.xyz;
				half3 worldViewDir = normalize(i.worldViewDir);
				
				half3 ambient = _GlossyEnvironmentColor;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				half3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
				
				half fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
				
				half3 diffuse = _MainLightColor.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				
				half3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
				
				return half4(color, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Reflective/VertexLit"
}
