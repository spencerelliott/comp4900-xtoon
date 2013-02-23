float4x4 World;
float4x4 View;
float4x4 Projection;
float3 LightDirection = normalize(float3(1,1,1));

float ToonThresholds[2] = { 0.8, 0.4 };
float ToonBrightnessLevels[3] = { 1.3, 0.9, 0.5 };

bool TextureEnabled;
texture Texture;

sampler	Sampler = sampler_state {
	Texture = (Texture);
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

// TODO: add effect parameters here.

struct VertexShaderInput
{
    float4 Position : POSITION0;
	float3 Normal : NORMAL0;
	float2 TexCoord : TEXCOORD0;

    // TODO: add input channels such as texture
    // coordinates and vertex colors here.
};

struct PixelShaderInput 
{
	float2 TexCoord : TEXCOORD0;
	float LightAmount : TEXCOORD1;
};

struct VertexShaderOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float LightAmount : TEXCOORD1;

    // TODO: add vertex shader outputs such as colors and texture
    // coordinates here. These values will automatically be interpolated
    // over the triangle, and provided as input to your pixel shader.
};

struct NormalDepthVertexShaderOutput 
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

	float4 worldNormal = mul(input.Normal, World);
	output.LightAmount = dot(worldNormal, LightDirection);

	output.TexCoord = input.TexCoord;

    // TODO: add your vertex shader code here.

    return output;
}

float4 ToonPixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float4 color = TextureEnabled ? tex2D(Sampler, input.TexCoord) : 0;

    float light;

	if(input.LightAmount > ToonThresholds[0]) {
		light = ToonBrightnessLevels[0];
	} else if(input.LightAmount > ToonThresholds[1]) {
		light = ToonBrightnessLevels[1];
	} else {
		light = ToonBrightnessLevels[2];
	}

	color.rgb *= light;

    return color;
}

NormalDepthVertexShaderOutput NormalDepthVertexShaderFunction(VertexShaderInput input) 
{
	NormalDepthVertexShaderOutput output;

	float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

	float3 worldNormal = mul(input.Normal, World);
	output.Color.rgb = (worldNormal + 1) / 2;
	output.Color.a = output.Position.z / output.Position.w;

	return output;
}

float4 NormalDepthPixelShaderFunction(float4 color : COLOR0) : COLOR0
{
	return color;
}

Technique ToonShader
{
	pass P0
	{
		VertexShader = compile vs_1_1 VertexShaderFunction();
		PixelShader = compile ps_2_0 ToonPixelShaderFunction();
	}
}

Technique NormalDepth
{
	pass P0
	{
		VertexShader = compile vs_1_1 NormalDepthVertexShaderFunction();
		PixelShader = compile ps_2_0 NormalDepthPixelShaderFunction();
	}
}