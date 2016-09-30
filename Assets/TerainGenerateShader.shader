Shader "Custom/TerainGenerateShader" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_NoiceTex ("Noice Texture", 2D) = "white" {}

		_MaxHeight ("Max Height", Range(1, 15)) = 2
	}
	SubShader {
		
		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _NoiceTex;
			float _MaxHeight;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};


			v2f vert (appdata v) 
			{
				v2f o;

				float3 worldpos = mul(_Object2World, v.vertex);

				float height = tex2Dlod( _NoiceTex, float4 (worldpos.xz, 0, 0) ).r;

				v.vertex.xyz += v.normal * (height * _MaxHeight);

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;

				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}

			ENDCG
		}
	}
}
