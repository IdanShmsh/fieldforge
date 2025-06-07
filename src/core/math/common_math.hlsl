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
}

#endif
