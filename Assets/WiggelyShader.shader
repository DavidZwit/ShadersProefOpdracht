//The name of the shader in the unity menu's
Shader "Costum/WiggelyShader"
{
	//The properties (the variables you see in the unity inspector)
	Properties{
		//The variable for the main texture
		_MainTex("Main Texture", 2D) = "white" {}
		//The variable for the noice texture
		_NoiceTex("Noice Texture", 2D) = "white" {}
		
		//The amound the vertices wiggels
		_WiggelyAmound("Wiggely Amound", Range(0, 1)) = 1
		//The speed at wich the object wiggels
		_WiggelySpeed("Wiggely Speed", Range(0.0, 1)) = 1
		//The speed at wich the color turns
		_ColorSpeed("Color Turn Speed", Range(0, 1)) = 1
	}
	//Telling unity this is a indipendent shader (you can have multiple shaders in one script)
	SubShader 
	{
		//Don't really know but it needs to be there :p
		Pass 
		{	//Starting the actuall shader program
			CGPROGRAM
			//Telling the program that the function "vert" is going to be the function for vertex calculations
			#pragma vertex vert
			//Telling the program the function "frag" is going to be the function for fragments
			#pragma fragment frag


			//Use unity code (this is optional but with this you can use unity made structs 
			///wich you can find here : http://wiki.unity3d.com/index.php?title=Shader_Code and maby even more things ( I don't know for sure)
			// you can use this as standard structs so you don't have to write them yourself)
			// ---> #include "Unitycg.cginc"

			//Creating the data you can use in the vertex shader part
			struct appdata 
			{
				//The position of the vertex
				float4 vertex : POSITION;
				//The normal of the vertex (the direction it's face is pointing in)
				float3 normal : NORMAL;
				//The position the texture should be mapped
				float4 texcoord : TEXCOORD0;
			};

			//Creating a struct to return
			struct v2f
			{
				//The position of the vertexes
				float4 vertex : SV_POSITION;
				//The position where the texture should be mapped
				float2 uv : TEXCOORD0;
				//The color or the specific vertex/pixel (could be both I think)
				fixed4 color : COLOR;
			};

			//By creating a variable with the same name as in the properties list unity will automaticly asign that variable to the variable in the actuall shader program 
			//The noice texture to create a smooth randomness
			sampler2D _NoiceTex;
			//The amound it wiggels
			float _WiggelyAmound;
			//The speed at wich it wiggels 
			float _WiggelySpeed;

			float3 Random (sampler2D tex, float3 indiPoint, float speed) {

				//Calculating the offsets based on the noice texture
				//tex2Dlod reads the color of a pixel at a specific position on a texture of type sampler2D
				//_Time[1] is A build in variable for knowing how much in game time went by (only works in play mode. The rest works outside playmode tough). 
				float3 offset = float3 (tex2Dlod(tex, float4 (indiPoint.x + _Time[1] * speed, 0, 0, 0)).r  - .5,
										tex2Dlod(tex, float4 (0, indiPoint.y + _Time[1] * speed, 0, 0)).r - .5,
										tex2Dlod(tex, float4 (indiPoint.z + _Time[1] * speed, indiPoint.z + _Time[1] * speed, 0, 0)).r - .5);
				return offset;
			}

			//The function for manipulating the vertices ("gets called for every vertice")
			v2f vert (appdata v) 
			{
				//Creating the return object
				v2f o;	
				//Calculating the world pos of this vertex
				float3 worldpos = mul(_Object2World, v.vertex);
				
				//Getting the random offset
				float3 offset = Random(_NoiceTex, worldpos, _WiggelySpeed);

				//Setting the vertex position to the offset based on the normals
				v.vertex.xyz += v.normal * (offset * _WiggelyAmound) ;

				//Recalculating vertices object position to worldposition
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				//Setting the texture coords in the return object
				o.uv = v.texcoord;

				//returning the object
				return o;
			}
			//The normal main texture
			sampler2D _MainTex;
			float _ColorSpeed;

			//The function used for calculating the pixels ("gets called for every pixel")
			fixed4 frag (v2f i) : SV_Target
			{
				//Setting the color of a specific pixel
				fixed4 col = tex2D(_MainTex, i.uv);
				//Returning the colors

				//Calculating offset
				float3 offset = Random(_NoiceTex, float3(i.uv, i.uv.y), _ColorSpeed);
				
				col.rgb = offset +.5 ;
				
				//You can do stuff like this. (colors are numbers between 0 and 1). You can also use a variable to change the tint or use freeky lighting stuff to make colors cool 
				//n-->col.r = 0.3;
				


				return col;
			}
			//The end of the shader program
			ENDCG
		}
	}
}