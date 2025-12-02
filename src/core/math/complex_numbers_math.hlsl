#ifndef COMPLEX_NUMBER_MATH
#define COMPLEX_NUMBER_MATH

/// This namespace implements functions used to perform calculations on complex numbers in the
/// representation: z = half2(Re, Im)
namespace ComplexNumbersMath
{
    // Take the product of two complex numbers
    half2 prd(half2 a, half2 b)
    {
        return half2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
    }

    // Take the product of a complex number and a real number
    half dot(half2 a, half2 b)
    {
        return a.x * b.x - a.y * b.y;
    }

    // Divide two complex numbers
    half2 div(half2 a, half2 b)
    {
        return half2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / (b.x * b.x + b.y * b.y);
    }

    // Exponentiate a complex number
    half2 cxp(half2 a)
    {
        return half2(cos(a.y), sin(a.y)) * exp(a.x);
    }

    // Phase-rotate a complex number
    half2 rot(half2 a, half theta)
    {
        half2 r = half2(cos(theta), sin(theta));
        return prd(a, r);
    }

    // Conjugate a complex number
    half2 cnj(half2 a)
    {
        return half2(a.x, -a.y);
    }

    // Add a complex number to another complex number by adding their polar coordinates rather than
    // performing a simple "cartesian" addition.
    half2 polar_sum(half2 v1, half2 v2)
    {
        // obtain the magnitude of the value
        const half mag = length(v1);
        // if the magnitude is 0, return the slope (as it inherently means that the value is 0 or close to it)
        if (mag == 0) return v2;

        // obtain a normalized value for the next calculations
        const half2 normalizedVal = v1 / mag;

        // compute magnitude and phase changes by projecting the slope on the value
        const half dL = dot(normalizedVal, v2);
        const half dPhi = dot(half2(-normalizedVal.y, normalizedVal.x), v2) / mag;

        // apply the phase and magnitude changes to the value
        v1 = rot(v1, dPhi);
        v1 *= 1 + dL / mag;

        return v1;
    }

    // Perform a linear combination of two complex numbers
    half2 scl_sum(half2 v1, half2 v2, half2 w1, half2 w2)
    {
        return prd(v1, w1) + prd(v2, w2);
    }

    half phase(half2 a)
    {
        return atan2(a.y, a.x);
    }
}

#endif
