#ifndef PAULI_SPINOR_MATH
#define PAULI_SPINOR_MATH

#include "../structures/pauli_spinor.hlsl"
#include "../math/complex_numbers_math.hlsl"

/// This namespace implements functions used to perform basic mathematical operations on a Pauli spinors.
namespace PauliSpinorMath
{
    // Sum a pair of Pauli spinors
    void sum(PauliSpinor spinor1, PauliSpinor spinor2, out PauliSpinor result)
    {
        result[0] = spinor1[0] + spinor2[0];
        result[1] = spinor1[1] + spinor2[1];
    }

    // Scale a Pauli spinor by a complex number
    void scl(PauliSpinor spinor, float2 scalar, out PauliSpinor result)
    {
        result[0] = ComplexNumbersMath::prd(spinor[0], scalar);
        result[1] = ComplexNumbersMath::prd(spinor[1], scalar);
    }

    // Scale a Pauli spinor by a real number
    void scl_rl(PauliSpinor spinor, float scalar, out PauliSpinor result)
    {
        result[0] = scalar * spinor[0];
        result[1] = scalar * spinor[1];
    }
}

#endif
