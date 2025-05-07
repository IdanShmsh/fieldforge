#ifndef FERMION_STATE_SYMMETRY_TRANSFORMATIONS
#define FERMION_STATE_SYMMETRY_TRANSFORMATIONS

#include "dirac_formalism.hlsl"

namespace FermionStateSymmetryTransformations
{
    // TODO: consider switching a parameter pair of fermions into a single parameter representing a doublet (+ implement a function which automatically fetches the doublet associated with a fermion field at a position [elsewhere])
    // Apply σ^1 to spinor doublet (ψ1, ψ2): (ψ1 ↔ ψ2)
    void sigma1(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        FermionFieldState left_chiral_doublet_fermion1, left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state1, left_chiral_doublet_fermion1);
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state1, transformed_doublet_fermion1);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::sum(transformed_doublet_fermion1, left_chiral_doublet_fermion2, transformed_doublet_fermion1);
        FermionFieldStateMath::sum(transformed_doublet_fermion2, left_chiral_doublet_fermion1, transformed_doublet_fermion2);
    }

    // Apply σ^1 rotation to spinor doublet (ψ1, ψ2) by given angle
    void sigma1(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, float angle, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        FermionFieldState left_chiral_doublet_fermion1, left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state1, left_chiral_doublet_fermion1);
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state1, transformed_doublet_fermion1);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::scl_sum(left_chiral_doublet_fermion1, left_chiral_doublet_fermion2, float2(c, 0), float2(0, -s), left_chiral_doublet_fermion1);
        FermionFieldStateMath::scl_sum(left_chiral_doublet_fermion1, left_chiral_doublet_fermion2, float2(0, -s), float2(c, 0), left_chiral_doublet_fermion2);
        FermionFieldStateMath::sum(transformed_doublet_fermion1, left_chiral_doublet_fermion2, transformed_doublet_fermion1);
        FermionFieldStateMath::sum(transformed_doublet_fermion2, left_chiral_doublet_fermion1, transformed_doublet_fermion2);
    }

    // Apply σ^2 to spinor doublet: (ψ1 → -iψ2, ψ2 → iψ1)
    void sigma2(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        FermionFieldState left_chiral_doublet_fermion1, left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state1, left_chiral_doublet_fermion1);
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state1, transformed_doublet_fermion1);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::scl(left_chiral_doublet_fermion2, float2(0, -1), left_chiral_doublet_fermion1);
        FermionFieldStateMath::scl(left_chiral_doublet_fermion1, float2(0, +1), left_chiral_doublet_fermion2);
        FermionFieldStateMath::sum(transformed_doublet_fermion1, left_chiral_doublet_fermion1, transformed_doublet_fermion1);
        FermionFieldStateMath::sum(transformed_doublet_fermion2, left_chiral_doublet_fermion2, transformed_doublet_fermion2);
    }

    // Apply σ^2 to spinor doublet: (ψ1 → -iψ2, ψ2 → iψ1)
    void sigma2(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, float angle, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        FermionFieldState left_chiral_doublet_fermion1, left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state1, left_chiral_doublet_fermion1);
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state1, transformed_doublet_fermion1);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::rscl_sum(left_chiral_doublet_fermion1, left_chiral_doublet_fermion2, c, -s, left_chiral_doublet_fermion1);
        FermionFieldStateMath::rscl_sum(left_chiral_doublet_fermion1, left_chiral_doublet_fermion2, s, c, left_chiral_doublet_fermion2);
        FermionFieldStateMath::sum(transformed_doublet_fermion1, left_chiral_doublet_fermion1, transformed_doublet_fermion1);
        FermionFieldStateMath::sum(transformed_doublet_fermion2, left_chiral_doublet_fermion2, transformed_doublet_fermion2);
    }

    // Apply σ^3 to spinor doublet: (ψ1 → ψ1, ψ2 → -ψ2)
    void sigma3(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        transformed_doublet_fermion1 = doublet_fermion_state1;
        FermionFieldState left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::sub(transformed_doublet_fermion2, left_chiral_doublet_fermion2, transformed_doublet_fermion2);
    }

    // Apply σ^3 to spinor doublet: (ψ1 → ψ1, ψ2 → -ψ2)
    void sigma3(FermionFieldState doublet_fermion_state1, FermionFieldState doublet_fermion_state2, float angle, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        FermionFieldState left_chiral_doublet_fermion1, left_chiral_doublet_fermion2;
        DiracFormalism::project_left_chiral(doublet_fermion_state1, left_chiral_doublet_fermion1);
        DiracFormalism::project_left_chiral(doublet_fermion_state2, left_chiral_doublet_fermion2);
        DiracFormalism::project_right_chiral(doublet_fermion_state1, transformed_doublet_fermion1);
        DiracFormalism::project_right_chiral(doublet_fermion_state2, transformed_doublet_fermion2);
        FermionFieldStateMath::scl(left_chiral_doublet_fermion1, float2(c, -s), left_chiral_doublet_fermion1);
        FermionFieldStateMath::scl(left_chiral_doublet_fermion2, float2(c, s), left_chiral_doublet_fermion2);
        FermionFieldStateMath::sum(transformed_doublet_fermion1, left_chiral_doublet_fermion1, transformed_doublet_fermion1);
        FermionFieldStateMath::sum(transformed_doublet_fermion2, left_chiral_doublet_fermion2, transformed_doublet_fermion2);
    }

    // Apply σ^a by index: a ∈ {0: identity, 1, 2, 3}
    void apply_sigma(FermionFieldState left_chiral_doublet_fermion1, FermionFieldState doublet_fermion_state2, uint su2_symmetry_index, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        switch (su2_symmetry_index)
        {
            case 0: sigma1(left_chiral_doublet_fermion1, doublet_fermion_state2, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
            case 1: sigma2(left_chiral_doublet_fermion1, doublet_fermion_state2, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
            case 2: sigma3(left_chiral_doublet_fermion1, doublet_fermion_state2, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
        }
    }

    // Apply σ^a by index: a ∈ {0: identity, 1, 2, 3}
    void apply_sigma(FermionFieldState left_chiral_doublet_fermion1, FermionFieldState doublet_fermion_state2, uint su2_symmetry_index, float angle, out FermionFieldState transformed_doublet_fermion1, out FermionFieldState transformed_doublet_fermion2)
    {
        switch (su2_symmetry_index)
        {
            case 0: sigma1(left_chiral_doublet_fermion1, doublet_fermion_state2, angle, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
            case 1: sigma2(left_chiral_doublet_fermion1, doublet_fermion_state2, angle, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
            case 2: sigma3(left_chiral_doublet_fermion1, doublet_fermion_state2, angle, transformed_doublet_fermion1, transformed_doublet_fermion2); break;
        }
    }

    // Apply SU(3) generator λ^1 to a given spinor state
    void lambda1(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        [unroll] for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = fermion_state[3 * spinor_component + 1];
            transformed_fermion_state[3 * spinor_component + 1] = fermion_state[3 * spinor_component + 0];
            transformed_fermion_state[3 * spinor_component + 2] = 0;
        }
    }

    // Apply SU(3) generator λ^1 to a given spinor state
    void lambda1(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 1], float2(c, 0), float2(0, -s));
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 1], float2(0, -s), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^2 to a given spinor state
    void lambda2(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 1], float2(0, -1));
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 0], float2(0, 1));
            transformed_fermion_state[3 * spinor_component + 2] = 0;
        }
    }

    // Apply SU(3) generator λ^2 to a given spinor state
    void lambda2(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 1], float2(c, 0), float2(-s, 0));
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 1], float2(s, 0), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^3 to a given spinor state
    void lambda3(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = fermion_state[3 * spinor_component + 0];
            transformed_fermion_state[3 * spinor_component + 1] = -fermion_state[3 * spinor_component + 1];
            transformed_fermion_state[3 * spinor_component + 2] = 0;
        }
    }

    // Apply SU(3) generator λ^3 to a given spinor state
    void lambda3(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 0], float2(c, -s));
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 1], float2(c, s));
        }
    }

    // Apply SU(3) generator λ^4 to a given spinor state
    void lambda4(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = fermion_state[3 * spinor_component + 2];
            transformed_fermion_state[3 * spinor_component + 1] = 0;
            transformed_fermion_state[3 * spinor_component + 2] = fermion_state[3 * spinor_component + 0];
        }
    }

    // Apply SU(3) generator λ^4 to a given spinor state
    void lambda4(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 2], float2(c, 0), float2(0, -s));
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 2], float2(-s, 0), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^5 to a given spinor state
    void lambda5(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 2], float2(0, -1));
            transformed_fermion_state[3 * spinor_component + 1] = 0;
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 2], float2(0, 1));
        }
    }

    // Apply SU(3) generator λ^5 to a given spinor state
    void lambda5(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 2], float2(c, 0), float2(-s, 0));
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 0], fermion_state[3 * spinor_component + 2], float2(s, 0), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^6 to a given spinor state
    void lambda6(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = 0;
            transformed_fermion_state[3 * spinor_component + 1] = fermion_state[3 * spinor_component + 2];
            transformed_fermion_state[3 * spinor_component + 2] = fermion_state[3 * spinor_component + 1];
        }
    }

    // Apply SU(3) generator λ^6 to a given spinor state
    void lambda6(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 1], fermion_state[3 * spinor_component + 2], float2(c, 0), float2(0, -s));
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 1], fermion_state[3 * spinor_component + 2], float2(-s, 0), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^7 to a given spinor state
    void lambda7(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = 0;
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 2], float2(0, -1));
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::prd(fermion_state[3 * spinor_component + 1], float2(0, 1));
        }
    }

    // Apply SU(3) generator λ^7 to a given spinor state
    void lambda7(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float c = cos(0.5 * angle);
        float s = sin(0.5 * angle);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 1], fermion_state[3 * spinor_component + 2], float2(c, 0), float2(-s, 0));
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::scl_sum(fermion_state[3 * spinor_component + 1], fermion_state[3 * spinor_component + 2], float2(s, 0), float2(c, 0));
        }
    }

    // Apply SU(3) generator λ^8 to a given spinor state
    void lambda8(FermionFieldState fermion_state, out FermionFieldState transformed_fermion_state)
    {
        float invSqrt3 = 1.0 / sqrt(3.0);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = fermion_state[3 * spinor_component + 0] * invSqrt3;
            transformed_fermion_state[3 * spinor_component + 1] = fermion_state[3 * spinor_component + 1] * invSqrt3;
            transformed_fermion_state[3 * spinor_component + 2] = -2.0 * fermion_state[3 * spinor_component + 2] * invSqrt3;
        }
    }

    // Apply SU(3) generator λ^8 to a given spinor state
    void lambda8(FermionFieldState fermion_state, float angle, out FermionFieldState transformed_fermion_state)
    {
        transformed_fermion_state = fermion_state;
        float invSqrt3 = 1.0 / sqrt(3.0);
        for (uint spinor_component = 0; spinor_component < 4; spinor_component++) {
            transformed_fermion_state[3 * spinor_component + 0] = ComplexNumbersMath::rot(fermion_state[3 * spinor_component + 0], -angle * invSqrt3);
            transformed_fermion_state[3 * spinor_component + 1] = ComplexNumbersMath::rot(fermion_state[3 * spinor_component + 1], -angle * invSqrt3);
            transformed_fermion_state[3 * spinor_component + 2] = ComplexNumbersMath::rot(fermion_state[3 * spinor_component + 2], 2 * angle * invSqrt3);
        }
    }

    // Apply a specified SU(3) generator to a given spinor state
    void apply_lambda(FermionFieldState fermion_state, uint su3_symmetry_index, out FermionFieldState transformed_fermion_state)
    {
        switch (su3_symmetry_index)
        {
        case 0: lambda1(fermion_state, transformed_fermion_state); break;
        case 1: lambda2(fermion_state, transformed_fermion_state); break;
        case 2: lambda3(fermion_state, transformed_fermion_state); break;
        case 3: lambda4(fermion_state, transformed_fermion_state); break;
        case 4: lambda5(fermion_state, transformed_fermion_state); break;
        case 5: lambda6(fermion_state, transformed_fermion_state); break;
        case 6: lambda7(fermion_state, transformed_fermion_state); break;
        case 7: lambda8(fermion_state, transformed_fermion_state); break;
        }
    }

    // Apply a specified SU(3) generator to a given spinor state
    void apply_lambda(FermionFieldState fermion_state, uint su3_symmetry_index, float angle, out FermionFieldState transformed_fermion_state)
    {
        switch (su3_symmetry_index)
        {
        case 0: lambda1(fermion_state, angle, transformed_fermion_state); break;
        case 1: lambda2(fermion_state, angle, transformed_fermion_state); break;
        case 2: lambda3(fermion_state, angle, transformed_fermion_state); break;
        case 3: lambda4(fermion_state, angle, transformed_fermion_state); break;
        case 4: lambda5(fermion_state, angle, transformed_fermion_state); break;
        case 5: lambda6(fermion_state, angle, transformed_fermion_state); break;
        case 6: lambda7(fermion_state, angle, transformed_fermion_state); break;
        case 7: lambda8(fermion_state, angle, transformed_fermion_state); break;
        }
    }
}

#endif
