#ifndef RELATIVITY
#define RELATIVITY

/// This namespace implements functions used to perform relativity related calculations.
namespace Relativity
{
    half minkowski_dot(half4 a, half4 b)
    {
        return a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w;
    }

    half interval(half4 a)
    {
        return sqrt(minkowski_dot(a, a));
    }
}

#endif
