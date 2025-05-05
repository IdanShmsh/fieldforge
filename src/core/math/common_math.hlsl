#ifndef COMMON_MATH
#define COMMON_MATH

/// This namespace implements functions used to perform simple common mathematical operations.
namespace CommonMath
{
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
}

#endif
