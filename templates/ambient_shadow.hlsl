// ambient_shadow template

//////////////////////////////////////
// Default Technique

float4x4 g_VS_matWVP : register( c0 );
float4x4 g_VS_matWorld : register( c4 );

float4 g_VS_decompBias : register( c9 );
float4 g_VS_ambientPlaneX : register( c10 );
float4 g_VS_ambientPlaneY : register( c11 );
float4 g_VS_ambientPlaneZ : register( c12 );
float4 g_VS_eyePosWorld : register( c20 );
float4 g_VS_fogVariables : register( c48 );

sampler2D Tex0 : register(s0);

#define LocalToScreen(x) mul(g_VS_matWVP, x)
#define LocalToWorld(x) mul(g_VS_matWorld, x)

struct VSDefault_I
{
	float4 pos : SV_POSITION;
    float3 nrm : NORMAL;
};

struct PSDefault_I
{
    float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
};

PSDefault_I VS_Default(VSDefault_I input)
{
	PSDefault_I output;

    float4 var1;
    var1.xyz = (input.pos + g_VS_decompBias) * g_VS_decompBias.w;
    
    output.pos = LocalToScreen(float4(var1.xyz, 1));

    var1.xyz = LocalToWorld(float4(var1.xyz, 1));
    var1.w = 1;

    float var2 = dot(g_VS_ambientPlaneX, var1);
    output.uv.x = (var2 * 0.5) + 0.5;
    output.uv.y = dot(g_VS_ambientPlaneY, var1);

    var1.w = dot(g_VS_ambientPlaneZ, var1);
    var1.xyz = -var1 + g_VS_eyePosWorld;
    var1.x = sqrt(dot((float3)var1, (float3)var1));
    output.uv.z = (var1.w * 0.5) + 0.5;

    var1.y = -var1.x + g_VS_fogVariables.x;
    var1.x += -256;
    var1.x = saturate(var1.x * 0.03125);

    var1.x = -var1.x + 1;
    var1.y *= g_VS_fogVariables.y;
    var1.y = -min(max(var1.y, 0), g_VS_fogVariables.z) + 1;

    var1.x *= var1.y;
    var1.y = (input.nrm.y > -0.100000001) ? 1 : 0;
    output.uv.w = var1.x * var1.y;

	return output;
}

struct PSDefault_O
{
	float4 col : COLOR;
};


PSDefault_O PS_Default(PSDefault_I i)
{
	PSDefault_O o;

    float var1 = saturate(abs(i.uv.y));
    var1 *= var1;
    var1 *= var1;
    var1 = mad(var1, -var1, 1);
    float4 tex = tex2D(Tex0, i.uv.xzzw);
    var1 *= tex.a;

    o.col.w = (var1 * -i.uv.w) + 1;
    o.col.rgb = 0;

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