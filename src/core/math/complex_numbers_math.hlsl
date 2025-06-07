#ifndef COMPLEX_NUMBER_MATH
#define COMPLEX_NUMBER_MATH

/// This namespace implements functions used to perform calculations on complex numbers in the
/// representation: z = float2(Re, Im)
namespace ComplexNumbersMath
{
    // Take the product of two complex numbers
    float2 prd(float2 a, float2 b)
    {
        return float2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
    }

    // Take the product of a complex number and a real number
    float dot(float2 a, float2 b)
    {
        return a.x * b.x - a.y * b.y;
    }

    // Divide two complex numbers
    float2 div(float2 a, float2 b)
    {
        return float2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / (b.x * b.x + b.y * b.y);
    }

    // Exponentiate a complex number
    float2 cxp(float2 a)
    {
        return float2(cos(a.y), sin(a.y)) * exp(a.x);
    }

    // Phase-rotate a complex number
    float2 rot(float2 a, float theta)
    {
        float2 r = float2(cos(theta), sin(theta));
        return prd(a, r);
    }

    // Conjugate a complex number
    float2 cnj(float2 a)
    {
        return float2(a.x, -a.y);
    }

    // Add a complex number to another complex number by adding their polar coordinates rather than
    // performing a simple "cartesian" addition.
    float2 polar_sum(float2 v1, float2 v2)
    {
        // obtain the magnitude of the value
        const float mag = length(v1);
        // if the magnitude is 0, return the slope (as it inherently means that the value is 0 or close to it)
        if (mag == 0) return v2;

        // obtain a normalized value for the next calculations
        const float2 normalizedVal = v1 / mag;

        // compute magnitude and phase changes by projecting the slope on the value
        const float dL = dot(normalizedVal, v2);
        const float dPhi = dot(float2(-normalizedVal.y, normalizedVal.x), v2) / mag;

        // apply the phase and magnitude changes to the value
        v1 = rot(v1, dPhi);
        v1 *= 1 + dL / mag;

        return v1;
    }

    // Perform a linear combination of two complex numbers
    float2 scl_sum(float2 v1, float2 v2, float2 w1, float2 w2)
    {
        return prd(v1, w1) + prd(v2, w2);
    }

    float phase(float2 a)
    {
        return atan2(a.y, a.x);
    }
}

#endif
