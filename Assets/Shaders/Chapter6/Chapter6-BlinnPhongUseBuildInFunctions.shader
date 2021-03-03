Shader "Unity Shaders Book/Chapter 6/Blinn-Phong Use Built-in Functions" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(1.0, 500)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="UniversalForward" }
		
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
           
			
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
				float4 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				
				// Use the build-in funtion to compute the normal in world space
				o.worldNormal = TransformObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				return o;
			}
			
			half4 frag(v2f i) : SV_Target {
				// 使用HLSL的函数获取主光源数据
                Light light = GetMainLight();
				
				half3 worldNormal = normalize(i.worldNormal);
				//  Use the build-in funtion to compute the light direction in world space
				// Remember to normalize the result
				half3 worldLightDir = normalize(TransformObjectToWorldDir(light.direction));
				
				half3 diffuse = LightingLambert(light.color.rgb, worldLightDir, worldNormal) * _Diffuse.rgb;
				// _MainLightColor.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				
				// Use the build-in funtion to compute the view direction in world space
				// Remember to normalize the result
				half3 viewDir = normalize(GetCameraPositionWS() - i.worldPos);
				half3 halfDir = normalize(worldLightDir + viewDir);
				half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				// 获取环境光方式多种，且得到效果不一
                //half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //half3 ambient = (glstate_lightmodel_ambient).xyz;
                //half3 ambient = i.vertexSH.xyz;
                //half3 ambient = SampleSH(worldNormal);
                half3 ambient = _GlossyEnvironmentColor;
                //half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) ;
                //half3 ambient = SAMPLE_GI(i.lightmapUV, i.vertexSH, worldNormal);
                //half3 ambient =unity_AmbientEquator; ;
				
				return half4(ambient + diffuse + specular, 1.0);
			}
			
			ENDHLSL
		}
	} 
	FallBack "Specular"
}
