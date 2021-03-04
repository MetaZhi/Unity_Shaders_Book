Shader "Unity Shaders Book/Chapter 7/Mask Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			half4 _Specular;
			float _Gloss;
			
			struct a2v {
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; 
				float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
				o.lightDir = mul(rotation, TransformWorldToObjectDir(_MainLightPosition.xyz));
				o.viewDir = mul(rotation, TransformWorldToObjectDir(GetCameraPositionWS())-v.vertex);
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
			 	half3 tangentLightDir = normalize(i.lightDir);
				half3 tangentViewDir = normalize(i.viewDir);

				half3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				half3 ambient = _GlossyEnvironmentColor * albedo;
				
				half3 diffuse = _MainLightColor.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				
			 	half3 halfDir = normalize(tangentLightDir + tangentViewDir);
			 	// Get the mask value
			 	half specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
			 	// Compute specular term with the specular mask
			 	half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
			
				return half4(ambient + diffuse + specular, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Specular"
}
