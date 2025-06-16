#ifndef COMMON_MATH
#define COMMON_MATH

/// This namespace implements functions used to perform simple common mathematical operations.
namespace CommonMath
{
    const float PI = 3.14159265358979323846;

    float harmonic_mean(float a, float b)
    {
        return a * b / (a + b);
    }

    float2 harmonic_mean(float2 a, float2 b)
    {
        return a * b / (a + b);
    }

    float3 harmonic_mean(float3 a, float3 b)
    {
        return a * b / (a + b);
    }

    float4 harmonic_mean(float4 a, float4 b)
    {
        return a * b / (a + b);
    }

    float sigmoid(float a)
    {
        return 1 / (1 + exp(-a));
    }

    float2 sigmoid(float2 a)
    {
        return 1 / (1 + exp(-a));
    }

    float3 sigmoid(float3 a)
    {
        return 1 / (1 + exp(-a));
    }

    float4 sigmoid(float4 a)
    {
        return 1 / (1 + exp(-a));
    }

    float3 cartesian_to_spherical(float3 cartesian)
    {
        float r = length(cartesian);
        float theta = length(cartesian.xy) ? atan2(cartesian.y, cartesian.x) : 0;
        float phi = r ? acos(cartesian.z / r) : 0;
        return float3(r, theta, phi);
    }

    float3 spherical_to_cartesian(float3 spherical)
    {
        float r = spherical.x;
        float theta = spherical.y;
        float phi = spherical.z;
        return float3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi));
    }

    float gaussian(float x, float stddev)
    {
        return exp(-0.5 * pow(x / stddev, 2)) / (stddev * sqrt(2 * PI));
    }

    float gaussian(float2 x, float stddev)
    {
        return gaussian(length(x), stddev);
    }

    float gaussian(float3 x, float stddev)
    {
        return gaussian(length(x), stddev);
    }

    float gaussian(float4 x, float stddev)
    {
        return gaussian(length(x), stddev);
    }

    float3 hsv2rgb(float3 hsv)
    {
        float h = hsv.x;
        float s = hsv.y;
        float v = hsv.z;
        float3 k = float3(1.0, 2.0 / 3.0, 1.0 / 3.0);
        float3 p = abs(frac(h + k) * 6.0 - 3.0);
        float3 rgb = lerp(k.xxx, saturate(p - k.xxx), 1.0);
        rgb = lerp(float3(1.0, 1.0, 1.0), rgb, s);
        return v * rgb;
    }

    void interpolate_2d(float2 fraction, float values[4], out float result)
    {
        float v00 = values[0];
        float v01 = values[1];
        float v10 = values[2];
        float v11 = values[3];
        float v0 = lerp(v00, v01, fraction.y);
        float v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(float2 fraction, float2 values[4], out float2 result)
    {
        float2 v00 = values[0];
        float2 v01 = values[1];
        float2 v10 = values[2];
        float2 v11 = values[3];
        float2 v0 = lerp(v00, v01, fraction.y);
        float2 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(float2 fraction, float3 values[4], out float3 result)
    {
        float3 v00 = values[0];
        float3 v01 = values[1];
        float3 v10 = values[2];
        float3 v11 = values[3];
        float3 v0 = lerp(v00, v01, fraction.y);
        float3 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(float2 fraction, float4 values[4], out float4 result)
    {
        float4 v00 = values[0];
        float4 v01 = values[1];
        float4 v10 = values[2];
        float4 v11 = values[3];
        float4 v0 = lerp(v00, v01, fraction.y);
        float4 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(float3 fraction, float values[8], out float result)
    {
        float v000 = values[0];
        float v001 = values[1];
        float v010 = values[2];
        float v011 = values[3];
        float v100 = values[4];
        float v101 = values[5];
        float v110 = values[6];
        float v111 = values[7];
        float v00 = lerp(v000, v001, fraction.z);
        float v01 = lerp(v010, v011, fraction.z);
        float v10 = lerp(v100, v101, fraction.z);
        float v11 = lerp(v110, v111, fraction.z);
        float v0 = lerp(v00, v01, fraction.y);
        float v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(float3 fraction, float2 values[8], out float2 result)
    {
        float2 v000 = values[0];
        float2 v001 = values[1];
        float2 v010 = values[2];
        float2 v011 = values[3];
        float2 v100 = values[4];
        float2 v101 = values[5];
        float2 v110 = values[6];
        float2 v111 = values[7];
        float2 v00 = lerp(v000, v001, fraction.z);
        float2 v01 = lerp(v010, v011, fraction.z);
        float2 v10 = lerp(v100, v101, fraction.z);
        float2 v11 = lerp(v110, v111, fraction.z);
        float2 v0 = lerp(v00, v01, fraction.y);
        float2 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(float3 fraction, float3 values[8], out float3 result)
    {
        float3 v000 = values[0];
        float3 v001 = values[1];
        float3 v010 = values[2];
        float3 v011 = values[3];
        float3 v100 = values[4];
        float3 v101 = values[5];
        float3 v110 = values[6];
        float3 v111 = values[7];
        float3 v00 = lerp(v000, v001, fraction.z);
        float3 v01 = lerp(v010, v011, fraction.z);
        float3 v10 = lerp(v100, v101, fraction.z);
        float3 v11 = lerp(v110, v111, fraction.z);
        float3 v0 = lerp(v00, v01, fraction.y);
        float3 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(float3 fraction, float4 values[8], out float4 result)
    {
        float4 v000 = values[0];
        float4 v001 = values[1];
        float4 v010 = values[2];
        float4 v011 = values[3];
        float4 v100 = values[4];
        float4 v101 = values[5];
        float4 v110 = values[6];
        float4 v111 = values[7];
        float4 v00 = lerp(v000, v001, fraction.z);
        float4 v01 = lerp(v010, v011, fraction.z);
        float4 v10 = lerp(v100, v101, fraction.z);
        float4 v11 = lerp(v110, v111, fraction.z);
        float4 v0 = lerp(v00, v01, fraction.y);
        float4 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }
}

#endif
