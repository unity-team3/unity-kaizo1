
Shader "Effect/Effect_displacement_blend" {
    Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Main Texture", 2D) = "white" {}
    _NoiseTex ("Distort Texture (RG)", 2D) = "white" {}
    _HeatTime  ("Heat Time X", range (-1,1)) = 0
	_HeatTimeY  ("Heat Time Y", range (-1,1)) = 0
    _ForceX  ("Strength X", range (0,1)) = 0.1
    _ForceY  ("Strength Y", range (0,1)) = 0.1
}

Category {
    Tags { "Queue"="Transparent" "RenderType"="Transparent" "Ignoreprojector" = "True"}
    Blend SrcAlpha OneMinusSrcAlpha
    ColorMask RGB
    Cull Off Lighting Off ZWrite Off 

    BindChannels {
        Bind "Color", color
        Bind "Vertex", vertex
        Bind "TexCoord", texcoord
    }

    SubShader {
        Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma multi_compile __ HAS_SCENECOLOR
		#pragma multi_compile __ SCENE_COLOR_ON
		#pragma multi_compile __ FOG_LINEAR
		#pragma multi_compile __ HAS_FOG
		#pragma multi_compile __ HAS_CULL
		#pragma multi_compile __ CULL_BLEND_ON

		#include "UnityCG.cginc"
		#include "../UECGInclude/UECGInclude.cginc"

		struct appdata_t {
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 texcoord: TEXCOORD0;
		};

		struct v2f {
			float4 pos : POSITION;
			fixed4 color : COLOR;
			float2 uvmain : TEXCOORD1;
			float2 uvnoise : TEXCOORD2;
			#if HAS_FOG
			UNITY_FOG_COORDS(3)
			#endif
			
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			float cullZ: TEXCOORD4;
			#endif
		};

		fixed4 _TintColor;
		fixed _ForceX;
		fixed _ForceY;
		fixed _HeatTime;
		fixed _HeatTimeY;
		float4 _MainTex_ST;
		float4 _NoiseTex_ST;
		sampler2D _NoiseTex;
		sampler2D _MainTex;
		
		#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
		half3 _cullBlendRange;
		#endif


		v2f vert (appdata_t v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
			o.uvnoise = TRANSFORM_TEX( v.texcoord, _NoiseTex );
			#if HAS_FOG
			UNITY_TRANSFER_FOG(o,o.pos);
			#endif
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			o.cullZ = ComputeScreenPos(o.pos).z;
			#endif
			return o;
		}

		fixed4 frag( v2f i ) : COLOR
		{
			fixed4 offsetColor1 = tex2D(_NoiseTex, i.uvnoise + _Time.xz*_HeatTimeY);
			fixed4 offsetColor2 = tex2D(_NoiseTex, i.uvnoise + _Time.yx*_HeatTime);
			i.uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceX;
			i.uvmain.y += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceY;
			fixed4 col = 2.0f * i.color * _TintColor * tex2D( _MainTex, i.uvmain);

			#ifdef HAS_SCENECOLOR
				#ifdef SCENE_COLOR_ON
				col.rgb *= _SceneColor; 
				#endif
			#endif

			#if HAS_FOG
			UNITY_APPLY_FOG(i.fogCoord,col.rgb);
			#endif
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			col.a *= (1 - saturate((i.cullZ - _cullBlendRange.x) * _cullBlendRange.z));
			#endif

			return col;
		}
		ENDCG
	}
	}
	CustomEditor "Effect_SceneGUI"
}
}