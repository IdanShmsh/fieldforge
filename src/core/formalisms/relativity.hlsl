#ifndef RELATIVITY
#define RELATIVITY

/// This namespace implements functions used to perform relativity related calculations.
namespace Relativity
{
    float minkowski_dot(float4 a, float4 b)
    {
        return a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w;
    }

    float interval(float4 a)
    {
        return sqrt(minkowski_dot(a, a));
    }
}

#endif
