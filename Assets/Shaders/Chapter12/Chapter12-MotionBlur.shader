Shader "Unity Shaders Book/Chapter 12/Motion Blur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount ("Blur Amount", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		
		sampler2D _MainTex;
		half _BlurAmount;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			
			o.pos = TransformObjectToHClip(v.vertex);
			
			o.uv = v.texcoord;
					 
			return o;
		}
		
		half4 fragRGB (v2f i) : SV_Target {
			return half4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}
		
		half4 fragA (v2f i) : SV_Target {
			return tex2D(_MainTex, i.uv);
		}
		
		ENDHLSL
		
		ZTest Always Cull Off ZWrite Off
		
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			
			HLSLPROGRAM
			
			#pragma vertex vert  
			#pragma fragment fragRGB  
			
			ENDHLSL
		}
		
		Pass {   
			Blend One Zero
			ColorMask A
			   	
			HLSLPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment fragA
			  
			ENDHLSL
		}
	}
 	FallBack Off
}
