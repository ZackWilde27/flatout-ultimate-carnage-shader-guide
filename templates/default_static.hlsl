// Default Static Template

//////////////////////////////////////
// Default Technique

float4x4 g_VS_matWVP : register( c0 );
#define LocalToScreen(x) mul(g_VS_matWVP, x)

sampler2D Tex0 : register( s0 );

struct VSDefault_I
{
	float4 pos : SV_POSITION;
    float4 col : COLOR;
    float2 uv : TEXCOORD0;
};

struct PSDefault_I
{
    float4 pos : SV_POSITION;
	float4 col : COLOR;
	float2 uv : TEXCOORD0;
};

PSDefault_I VS_Default(VSDefault_I input)
{
	PSDefault_I output;
	output.pos = LocalToScreen(input.pos);
    output.col = input.col;
    output.uv = input.uv;
	return output;
}

float4 PS_Default(PSDefault_I i) : COLOR
{
	return tex2D(Tex0, i.uv) * i.col;
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
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
};

struct Shadow_Output
{
	float4 col : COLOR;
};

Shadow_Input VS_Shadow(float4 p : SV_POSITION, float2 u : TEXCOORD0)
{
	Shadow_Input o;
	o.pos = LocalToScreen(p);
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