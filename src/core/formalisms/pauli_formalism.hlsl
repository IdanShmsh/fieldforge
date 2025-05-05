#ifndef PAULI_FORMALISM
#define PAULI_FORMALISM

#include "../structures/pauli_spinor.hlsl"
#include "../math/pauli_spinor_math.hlsl"

/// This namespace implements functions used to manipulate pauli spinors in the pauli formalism.
namespace PauliFormalism
{
    // Apply the sigma-1 matrix to a pauli spinor
    // ψ' = σ₁ψ
    void sigma1(PauliSpinor spinor, out PauliSpinor transformed_spinor)
    {
        transformed_spinor[0] = spinor[1];
        transformed_spinor[1] = spinor[0];
    }

    // Apply the sigma-2 matrix to a pauli spinor
    // ψ' = σ₂ψ
    void sigma2(PauliSpinor spinor, out PauliSpinor transformed_spinor)
    {
        transformed_spinor[0] = float2(spinor[1][1], -spinor[1][0]);
        transformed_spinor[1] = float2(-spinor[0][1], spinor[0][0]);
    }

    // Apply the sigma-3 matrix to a pauli spinor
    // ψ' = σ₃ψ
    void sigma3(PauliSpinor spinor, out PauliSpinor transformed_spinor)
    {
        transformed_spinor[0] = spinor[0];
        transformed_spinor[1] = -spinor[1];
    }

    // Apply the sigma matrix associated with a specified axis to a pauli spinor
    // ψ' = γᵘψ
    void apply_pauli_vector(PauliSpinor spinor, float3 coordinates, out PauliSpinor transformed_spinor)
    {
        PauliSpinor x_transformed;
        PauliSpinor y_transformed;
        PauliSpinor z_transformed;
        sigma1(spinor, x_transformed);
        sigma2(spinor, y_transformed);
        sigma3(spinor, z_transformed);
        transformed_spinor[0] = coordinates[0] * x_transformed[0] + coordinates[1] * y_transformed[0] + coordinates[2] * z_transformed[0];
        transformed_spinor[1] = coordinates[0] * x_transformed[1] + coordinates[1] * y_transformed[1] + coordinates[2] * z_transformed[1];
    }

    // Construct a pauli spinor representing a spin state with the specified spherical coordinates (r, theta, phi)
    void construct_pauli_spinor(float r, float theta, float phi, out PauliSpinor pauli_spinor)
    {
        float2 exp_theta = ComplexNumbersMath::cxp(float2(0, theta));
        float2 cos_phi = float2(cos(phi / 2), 0);
        float2 sin_phi = float2(sin(phi / 2), 0);
        pauli_spinor[0] = r * cos_phi;
        pauli_spinor[1] = r * ComplexNumbersMath::prd(sin_phi, exp_theta);
    }

    // Construct a pauli spinor representing a spin state with the spin vector
    void construct_pauli_spinor(float3 spin_vector, out PauliSpinor pauli_spinor)
    {
        float3 spherical_coordinates = CommonMath::cartesian_to_spherical(spin_vector);
        construct_pauli_spinor(spherical_coordinates[0], spherical_coordinates[1], spherical_coordinates[2], pauli_spinor);
    }
}

#endif
