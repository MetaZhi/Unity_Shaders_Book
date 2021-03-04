Shader "Unity Shaders Book/Chapter 7/Ramp Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RampTex ("Ramp Tex", 2D) = "white" {}
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
			
			half4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			half4 _Specular;
			float _Gloss;
			
			struct a2v {
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				
				o.worldNormal = TransformObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = _MainLightPosition.xyz;
				
				half3 ambient = _GlossyEnvironmentColor;
				
				// Use the texture to sample the diffuse color
				half halfLambert  = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				half3 diffuseColor = tex2D(_RampTex, half2(halfLambert, halfLambert)).rgb * _Color.rgb;
				
				half3 diffuse = _MainLightColor.rgb * diffuseColor;
				
				half3 viewDir = normalize(GetCameraPositionWS() - (i.worldPos));
				half3 halfDir = normalize(worldLightDir + viewDir);
				half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				return half4(ambient + diffuse + specular, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Specular"
}
