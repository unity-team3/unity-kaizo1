//additive vertexcolor to tex in blend alpha
Shader "Effect/Additive_0" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _tintColor("Tint Color",Color) = (0.5,0.5,0.5,1)
    }
    SubShader {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" "Ignoreprojector" = "True"}
        LOD 200
        lighting off
        zwrite off
        Blend SrcAlpha One
        colormask rgb
        cull off
        pass{
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

		#pragma multi_compile __ VERTEX_COLOR
		#pragma multi_compile __ HAS_FOG
		#pragma multi_compile __ FOG_LINEAR
		#pragma multi_compile __ HAS_CULL
		#pragma multi_compile __ CULL_BLEND_ON

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _tintColor;

		#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
		half3 _cullBlendRange;
		#endif

        struct VertexInput {
            fixed4 vertex : POSITION;
            #if VERTEX_COLOR
            fixed4 color : COLOR;
            #endif
            fixed4 texcoord : TEXCOORD0;
        };

        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            #if VERTEX_COLOR
            float4 color : Color;
            #endif
			#if HAS_FOG
			UNITY_FOG_COORDS(2)
			#endif
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			float cullZ: TEXCOORD3;
			#endif
        };
        
        v2f vert (VertexInput v) 
        {
            v2f o;
            o.pos = UnityObjectToClipPos (v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            #if VERTEX_COLOR
            o.color = v.color;
            #endif
			#if HAS_FOG
			UNITY_TRANSFER_FOG(o,o.pos);
			#endif
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			o.cullZ = ComputeScreenPos(o.pos).z;
			#endif
            return o;
        }
        
        fixed4 frag(v2f i) : color 
        {
            fixed4 c = tex2D(_MainTex, i.uv) * 2 * _tintColor; 
            #if VERTEX_COLOR
            c *= i.color;
            #endif

			#if HAS_FOG
			UNITY_APPLY_FOG(i.fogCoord,c.rgb);
			#if defined(FOG_LINEAR)
				c.a *= i.fogCoord.x;
			#endif
			#endif
				 
			#if (defined (HAS_CULL)) && (defined (CULL_BLEND_ON))
			c.a *= (1 - saturate((i.cullZ - _cullBlendRange.x) * _cullBlendRange.z));
			#endif
			
            return c;
        }
        
        ENDCG
        }
    }
    CustomEditor "Effect_Alpha_Blend_AdditiveGUI"
}
