# FlatOut: Ultimate Carnage Shaders

Ultimate Carnage uses pre-compiled shaders, which means you'll need something like FXC to compile your HLSL to an FX file with the FO extension

<br>

# Compiling

Compiling is done with [fxc](https://learn.microsoft.com/en-us/windows/win32/direct3dtools/fxc). It can be found in some Windows SDKs or the Direct X SDK

Open a terminal in the same folder as fxc.exe and run this command:
```
./fxc path-to-script.hlsl /T fx_2_0 /Fo path-to-output.fo
```

The game uses Shader Model 3.0, which for some reason uses the fx_2_0 profile

The ```/Fe path``` flag can be added to output the errors<br>
The ```/Fc path``` flag can be added to output the assembly

The level of support will vary depending on the version of FXC you have. You might need the ```/LD``` or ```/Gec``` flag.

For the most compatibility use the version included in the [June 2010 Direct X SDK](https://www.microsoft.com/en-ca/download/details.aspx?id=6812)

After that's done, it will give you an FO file to pack into your mod, under data/shaders

<br>

# Writing

In FlatOut 2, there was only 1 technique for everything. In UC, every shader has its own set of techniques for all kinds of purposes.

The basic structure of a technique goes like this
```hlsl
struct VS_Inputs
{
    pos : POSITION;
    //...
};

struct PS_Inputs
{
    pos : POSITION; // Position needs to be here but it is not given to the pixel shader
    //...
};


PS_Inputs MyVertexShader(VS_Inputs i)
{
    PS_Inputs o;
    //...
    return o;
}

float4 MyPixelShader(PS_Inputs i) : COLOR
{
    //...
}


Technique Default
{
    Pass P0
    {
        VertexShader = compile ps_3_0 MyVertexShader();
        PixelShader = compile ps_3_0 MyPixelShader();
        // I imagine it's possible to change more settings in here but you don't need to in UC
    }
}
```

The ```Default``` technique is the main one that all shaders need, but some will have a ```Shadow``` or ```Tech_1``` technique as well, that can each have separate shaders.

<br>

It appears to be built on top of the system in FlatOut 2, which makes sense.

As a result, a few defines can be created to make it more like my FlatOut 2 compiler
```hlsl
float4x4 g_VS_matWVP : register(c0);
#define LocalToScreen(x) mul(g_VS_matWVP, x)

float4x4 g_VS_matWorld : register(c4);
#define LocalToWorld(x) mul(g_VS_matWorld, x)

#define RotateToWorld(x) mul((float3x3)g_VS_matWorld, x)
```

<br>

# Disassembling

FXC has the ```/dumpbin``` flag, which means it will take an FO file, and with the help of the ```/Fc``` flag will give you the original shader's assembly.

I've started working on templates that I translated from the assembly of the original shaders, though I'm starting with the basic shaders because my car body recreation is still crashing the game for some reason.
