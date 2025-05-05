#ifndef PAULI_SPINOR_OPS
#define PAULI_SPINOR_OPS

#include "../structures/pauli_spinor.hlsl"

/// This namespace implements functions used to perform basic operations on the Pauli spinor data structure.
namespace PauliSpinorOps
{
    // Empty (zero) a Pauli spinor
    void empty(out PauliSpinor spinor)
    {
        spinor[0] = float2(0, 0);
        spinor[1] = float2(0, 0);
    }
}

#endif
