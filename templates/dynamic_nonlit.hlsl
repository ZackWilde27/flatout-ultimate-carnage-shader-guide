// Dynamic_NonLit Template

//////////////////////////////////////
// Default Technique

float4x4 g_VS_matWVP : register( c0 );
float4x4 g_VS_matWorld : register( c4 );
float4 g_VS_eyePosWorld : register( c20 );
float4 g_VS_fogVariables : register( c48 );

#define LocalToScreen(x) mul(g_VS_matWVP, x)
#define LocalToWorld(x) mul(g_VS_matWorld, x)

sampler2D Tex0 : register( s0 );

struct VSDefault_I
{
	float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

struct PSDefault_I
{
    float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	half uv1 : TEXCOORD1;
};

PSDefault_I VS_Default(VSDefault_I input)
{
	PSDefault_I output;
	float UVScale = 0.00048828125;
	output.uv = input.uv * UVScale;
	float3 scaledPos;
	scaledPos.xyz = input.pos * 0.0009765625;

	output.pos = LocalToScreen(float4(scaledPos, 1));

	float3 worldPos = LocalToWorld(float4(scaledPos, 1));

	worldPos = -worldPos + g_VS_eyePosWorld;

	worldPos.x = sqrt(dot(worldPos, worldPos));
	worldPos.x = -worldPos.x + g_VS_fogVariables.x;
	worldPos.x *= g_VS_fogVariables.y;
	output.uv1 = min(max(worldPos.x, 0), g_VS_fogVariables.z);

	return output;
}

float4 g_PS_nonLitIntensity : register( c40 );
float4 g_PS_fogColor : register( c44 );

struct PSDefault_O
{
	float4 col : COLOR;
};

// I can't be 100% sure that this is a perfect recreation, since FXC rearranges and optimizes it
PSDefault_O PS_Default(PSDefault_I i)
{
	PSDefault_O o;

	float4 r0 = tex2D(Tex0, i.uv);
	half3 r1 = r0 * g_PS_nonLitIntensity;
	float3 r2 = g_PS_nonLitIntensity;
	r0.rgb = mad(r0, -r2, g_PS_fogColor);

	o.col.a = r0.a;
	o.col.rgb = mad(i.uv1, r0, r1);

	return o;
}

Technique Default
{
	Pass P0
	{
		VertexShader = compile vs_3_0 VS_Default();
		PixelShader = compile ps_3_0 PS_Default();
	}
}

//////////////////////////////////////
// Shadow Technique

struct Shadow_Input
{
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
};

struct Shadow_Output
{
	float4 col : COLOR;
};

Shadow_Input VS_Shadow(float4 p : SV_POSITION)
{
	Shadow_Input o;

	float scale = 0.0009765625;
	float3 scaledPos;
	scaledPos.xyz = p * scale;

	o.pos = LocalToScreen(float4(scaledPos, 1));
	o.uv = o.pos.zwzw;

	return o;
}

Shadow_Output PS_Shadow(float2 uv : TEXCOORD0)
{
	Shadow_Output o;
	o.col.xyz = uv.x * (1/uv.y);
    o.col.w = 1;
	return o;
}

Technique Shadow
{
	Pass P0
	{
		VertexShader = compile vs_3_0 VS_Shadow();
		PixelShader = compile ps_3_0 PS_Shadow();
	}
}

//////////////////////////////////////
// Shadow Alpha Technique

struct ShadowA_I
{
	float4 pos : Position;
	float4 uv : TEXCOORD;
};

struct ShadowA_O
{
	float4 col : COLOR;
};

ShadowA_I VS_ShadowAlpha(Shadow_Input i)
{
	ShadowA_I o;

	float3 r0 = i.pos * 0.0009765625;
	o.pos = LocalToScreen(float4(r0, 1));

	o.uv.zw = o.pos;
	o.uv.xy = i.uv * 0.00048828125;

	return o;
}

float4 g_PS_depthBufferScale : register(c52);

ShadowA_O PS_ShadowAlpha(ShadowA_I i)
{
	ShadowA_O o;

	float4 r0 = tex2D(Tex0, i.uv);
	r0 = r0.a + -g_PS_depthBufferScale.z;
	clip(r0);
	o.col.rgb = (1/i.uv.w) * i.uv.z;
	o.col.a = 1;

	return o;
}

Technique Shadow_Alpha
{
	Pass P0
	{
		VertexShader = compile vs_3_0 VS_ShadowAlpha();
		PixelShader = compile ps_3_0 PS_ShadowAlpha();
	}
}
