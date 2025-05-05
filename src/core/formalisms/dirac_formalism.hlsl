#ifndef DIRAC_FORMALISM
#define DIRAC_FORMALISM

#include "../math/fermion_field_state_math.hlsl"
#include "pauli_formalism.hlsl"

/// This namespace implements functions used to manipulate fermion field states in the Dirac formalism.
namespace DiracFormalism
{
    // Apply the gamma-0 matrix to a fermion state
    // ψ' = γ⁰ψ
    void gamma0(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state[0] = fermion_state[0];
        transformed_fermion_state[1] = fermion_state[1];
        transformed_fermion_state[2] = fermion_state[2];
        transformed_fermion_state[3] = fermion_state[3];
        transformed_fermion_state[4] = fermion_state[4];
        transformed_fermion_state[5] = fermion_state[5];
        transformed_fermion_state[6] = -fermion_state[6];
        transformed_fermion_state[7] = -fermion_state[7];
        transformed_fermion_state[8] = -fermion_state[8];
        transformed_fermion_state[9] = -fermion_state[9];
        transformed_fermion_state[10] = -fermion_state[10];
        transformed_fermion_state[11] = -fermion_state[11];
    }

    // Apply the gamma-1 matrix to a fermion state
    // ψ' = γ¹ψ
    void gamma1(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state[0] = fermion_state[9];
        transformed_fermion_state[1] = fermion_state[10];
        transformed_fermion_state[2] = fermion_state[11];
        transformed_fermion_state[3] = fermion_state[6];
        transformed_fermion_state[4] = fermion_state[7];
        transformed_fermion_state[5] = fermion_state[8];
        transformed_fermion_state[6] = -fermion_state[3];
        transformed_fermion_state[7] = -fermion_state[4];
        transformed_fermion_state[8] = -fermion_state[5];
        transformed_fermion_state[9] = -fermion_state[0];
        transformed_fermion_state[10] = -fermion_state[1];
        transformed_fermion_state[11] = -fermion_state[2];
    }

    // Apply the gamma-2 matrix to a fermion state
    // ψ' = γ²ψ
    void gamma2(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state[0] = float2(fermion_state[9][1], -fermion_state[9][0]);
        transformed_fermion_state[1] = float2(fermion_state[10][1], -fermion_state[10][0]);
        transformed_fermion_state[2] = float2(fermion_state[11][1], -fermion_state[11][0]);
        transformed_fermion_state[3] = float2(-fermion_state[6][1], fermion_state[6][0]);
        transformed_fermion_state[4] = float2(-fermion_state[7][1], fermion_state[7][0]);
        transformed_fermion_state[5] = float2(-fermion_state[8][1], fermion_state[8][0]);
        transformed_fermion_state[6] = float2(-fermion_state[3][1], fermion_state[3][0]);
        transformed_fermion_state[7] = float2(-fermion_state[4][1], fermion_state[4][0]);
        transformed_fermion_state[8] = float2(-fermion_state[5][1], fermion_state[5][0]);
        transformed_fermion_state[9] = float2(fermion_state[0][1], -fermion_state[0][0]);
        transformed_fermion_state[10] = float2(fermion_state[1][1], -fermion_state[1][0]);
        transformed_fermion_state[11] = float2(fermion_state[2][1], -fermion_state[2][0]);
    }

    // Apply the gamma-3 matrix to a fermion state
    // ψ' = γ³ψ
    void gamma3(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state[0] = fermion_state[6];
        transformed_fermion_state[1] = fermion_state[7];
        transformed_fermion_state[2] = fermion_state[8];
        transformed_fermion_state[3] = -fermion_state[9];
        transformed_fermion_state[4] = -fermion_state[10];
        transformed_fermion_state[5] = -fermion_state[11];
        transformed_fermion_state[6] = -fermion_state[0];
        transformed_fermion_state[7] = -fermion_state[1];
        transformed_fermion_state[8] = -fermion_state[2];
        transformed_fermion_state[9] = fermion_state[3];
        transformed_fermion_state[10] = fermion_state[4];
        transformed_fermion_state[11] = fermion_state[5];
    }

    // Apply the γ⁵ matrix to a fermion state
    // ψ' = γ⁵ψ
    void gamma5(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state[0] = fermion_state[6];
        transformed_fermion_state[1] = fermion_state[7];
        transformed_fermion_state[2] = fermion_state[8];
        transformed_fermion_state[3] = fermion_state[9];
        transformed_fermion_state[4] = fermion_state[10];
        transformed_fermion_state[5] = fermion_state[11];
        transformed_fermion_state[6] = fermion_state[0];
        transformed_fermion_state[7] = fermion_state[1];
        transformed_fermion_state[8] = fermion_state[2];
        transformed_fermion_state[9] = fermion_state[3];
        transformed_fermion_state[10] = fermion_state[4];
        transformed_fermion_state[11] = fermion_state[5];
    }

    // Apply the gamma matrix associated with a specified axis to a fermion state
    // ψ' = γᵘψ
    void apply_gamma(FermionFieldState fermion_state, uint axis, out FermionFieldState transformed_fermion_state)
    {
        switch (axis)
        {
            case 0: gamma0(fermion_state, transformed_fermion_state); break;
            case 1: gamma1(fermion_state, transformed_fermion_state); break;
            case 2: gamma2(fermion_state, transformed_fermion_state); break;
            case 3: gamma3(fermion_state, transformed_fermion_state); break;
        }
    }

    // Project out the left-chiral component of a fermion state
    // ψᴸ = ½(1 - γ⁵)ψ
    void project_left_chiral(FermionFieldState fermion_state, out FermionFieldState left_chiral_fermion_state)
    {
        gamma5(fermion_state, left_chiral_fermion_state);
        FermionFieldStateMath::sub(fermion_state, left_chiral_fermion_state, left_chiral_fermion_state);
        FermionFieldStateMath::rscl(left_chiral_fermion_state, 0.5, left_chiral_fermion_state);
    }

    // Project out the right-chiral component of a fermion state
    // ψᴿ = ½(1 + γ⁵)ψ
    void project_right_chiral(FermionFieldState fermion_state, out FermionFieldState right_chiral_fermion_state)
    {
        gamma5(fermion_state, right_chiral_fermion_state);
        FermionFieldStateMath::sum(fermion_state, right_chiral_fermion_state, right_chiral_fermion_state);
        FermionFieldStateMath::rscl(right_chiral_fermion_state, 0.5, right_chiral_fermion_state);
    }

    // Take the Dirac adjoint of a fermion state ψ̄ = ψ†γ⁰
    void dirac_adjoint(FermionFieldState fermion_state, out FermionFieldState adjoint_fermion_state)
    {
        adjoint_fermion_state[0] = ComplexNumbersMath::cnj(fermion_state[0]);
        adjoint_fermion_state[1] = ComplexNumbersMath::cnj(fermion_state[1]);
        adjoint_fermion_state[2] = ComplexNumbersMath::cnj(fermion_state[2]);
        adjoint_fermion_state[3] = ComplexNumbersMath::cnj(fermion_state[3]);
        adjoint_fermion_state[4] = ComplexNumbersMath::cnj(fermion_state[4]);
        adjoint_fermion_state[5] = ComplexNumbersMath::cnj(fermion_state[5]);
        adjoint_fermion_state[6] = -ComplexNumbersMath::cnj(fermion_state[6]);
        adjoint_fermion_state[7] = -ComplexNumbersMath::cnj(fermion_state[7]);
        adjoint_fermion_state[8] = -ComplexNumbersMath::cnj(fermion_state[8]);
        adjoint_fermion_state[9] = -ComplexNumbersMath::cnj(fermion_state[9]);
        adjoint_fermion_state[10] = -ComplexNumbersMath::cnj(fermion_state[10]);
        adjoint_fermion_state[11] = -ComplexNumbersMath::cnj(fermion_state[11]);
    }

    // Compute the Dirac norm of a fermion state
    // |ψ| = ψ̄ψ = ψ†γ⁰ψ
    float dirac_norm(FermionFieldState fermion_state)
    {
        float state_norm = 0;
        for (uint c = 0; c < 12; c++) state_norm += dot(fermion_state[c], fermion_state[c]) * (c > 5 ? -1 : 1);
        return state_norm;
    }

    // Construct a relativistic fermion state with a specified angular momentum vector, in an inertial frame given by a
    // specified momentum and mass
    void construct_spin_state(float3 spin_vector, float3 momentum, float mass, out FermionFieldState constructed_fermion_state)
    {
        FermionFieldStateOps::empty(constructed_fermion_state);
        float energy = sqrt(dot(momentum, momentum) + mass * mass);
        PauliSpinor upper_spinor;
        PauliFormalism::construct_pauli_spinor(spin_vector, upper_spinor);
        PauliSpinorMath::scl_rl(upper_spinor, sqrt((energy + mass) / (2 * mass)), upper_spinor);
        PauliSpinor lower_spinor;
        PauliFormalism::apply_pauli_vector(upper_spinor, momentum, lower_spinor);
        PauliSpinorMath::scl_rl(lower_spinor, 1 / (energy + mass), lower_spinor);
        constructed_fermion_state[0] = upper_spinor[0];
        constructed_fermion_state[3] = upper_spinor[1];
        constructed_fermion_state[6] = lower_spinor[0];
        constructed_fermion_state[9] = lower_spinor[1];
    }

    // Compute the angular momentum expectation value of a fermion field state
    float3 obtain_spin_state(FermionFieldState fermion_state)
    {
        float3 angular_momentum = float3(0, 0, 0);
        for (uint c = 0; c < 3; c++)
        {
            uint4 indices = FermionFieldStateOps::get_spinor_component_indices_for_color_index(c);
            float2 component_values[4] = { fermion_state[indices[0]], fermion_state[indices[1]], fermion_state[indices[2]], fermion_state[indices[3]] };
            angular_momentum[0] += component_values[0][0] * component_values[1][0] + component_values[0][1] * component_values[1][1] + component_values[2][0] * component_values[3][0] + component_values[2][1] * component_values[3][1];
            angular_momentum[1] += component_values[0][0] * component_values[1][1] - component_values[1][0] * component_values[0][1] + component_values[2][0] * component_values[3][1] - component_values[3][0] * component_values[2][1];
            angular_momentum[2] += 0.5 * (length(component_values[0]) - length(component_values[1]) + length(component_values[2]) - length(component_values[3]));
        }
        return angular_momentum;
    }
}

#endif
