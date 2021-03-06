#include "Common.hlsl"


Texture2D<float4>   TextureHDR : register(t0);
RWTexture2D<float4> TextureLDR : register(u0);



float3 Uncharted2Function(float A, float B, float C, float D, float E, float F, float3 x) {
    return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

float3 ToneMapUncharted2Function(float3 x, float exposure) {
    const float A = 0.15;
    const float B = 0.50;
    const float C = 0.10;
    const float D = 0.20;
    const float E = 0.02;
    const float F = 0.30;
    const float W = 11.2;

    float3 color = Uncharted2Function(A, B, C, D, E, F, x * exposure);
    float3 white = Uncharted2Function(A, B, C, D, E, F, W);

    return color / white;

}



[numthreads(8, 8, 1)]
void ToneMap(uint3 id : SV_DispatchThreadID) {
    float3 colorHDR = TextureHDR.Load(int3(id.xy, 0)).xyz;
    TextureLDR[id.xy] = float4(ToneMapUncharted2Function(colorHDR, FrameBuffer.Exposure), 1.0f);
}