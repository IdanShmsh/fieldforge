#ifndef FERMION_FIELD_STATE_MATH
#define FERMION_FIELD_STATE_MATH

#include "../structures/fermion_field_state.hlsl"
#include "../ops/fermion_field_state_ops.hlsl"
#include "complex_numbers_math.hlsl"
#include "common_math.hlsl"

/// This namespace implements functions used to perform basic mathematical operations on fermion field states.
namespace FermionFieldStateMath
{
    // Sum a pair of fermion states
    void sum(FermionFieldState fermion_state1, FermionFieldState fermion_state2, out FermionFieldState result)
    {
        result[0] = fermion_state1[0] + fermion_state2[0];
        result[1] = fermion_state1[1] + fermion_state2[1];
        result[2] = fermion_state1[2] + fermion_state2[2];
        result[3] = fermion_state1[3] + fermion_state2[3];
        result[4] = fermion_state1[4] + fermion_state2[4];
        result[5] = fermion_state1[5] + fermion_state2[5];
        result[6] = fermion_state1[6] + fermion_state2[6];
        result[7] = fermion_state1[7] + fermion_state2[7];
        result[8] = fermion_state1[8] + fermion_state2[8];
        result[9] = fermion_state1[9] + fermion_state2[9];
        result[10] = fermion_state1[10] + fermion_state2[10];
        result[11] = fermion_state1[11] + fermion_state2[11];
    }

    // Subtract a pair of fermion states
    void sub(FermionFieldState fermion_state1, FermionFieldState fermion_state2, out FermionFieldState result)
    {
        result[0] = fermion_state1[0] - fermion_state2[0];
        result[1] = fermion_state1[1] - fermion_state2[1];
        result[2] = fermion_state1[2] - fermion_state2[2];
        result[3] = fermion_state1[3] - fermion_state2[3];
        result[4] = fermion_state1[4] - fermion_state2[4];
        result[5] = fermion_state1[5] - fermion_state2[5];
        result[6] = fermion_state1[6] - fermion_state2[6];
        result[7] = fermion_state1[7] - fermion_state2[7];
        result[8] = fermion_state1[8] - fermion_state2[8];
        result[9] = fermion_state1[9] - fermion_state2[9];
        result[10] = fermion_state1[10] - fermion_state2[10];
        result[11] = fermion_state1[11] - fermion_state2[11];
    }

    // Take the norm squared of a fermion state
    float norm_sqrd(FermionFieldState fermion_state)
    {
        return dot(fermion_state[0], fermion_state[0]) +
                dot(fermion_state[1], fermion_state[1]) +
                dot(fermion_state[2], fermion_state[2]) +
                dot(fermion_state[3], fermion_state[3]) +
                dot(fermion_state[4], fermion_state[4]) +
                dot(fermion_state[5], fermion_state[5]) +
                dot(fermion_state[6], fermion_state[6]) +
                dot(fermion_state[7], fermion_state[7]) +
                dot(fermion_state[8], fermion_state[8]) +
                dot(fermion_state[9], fermion_state[9]) +
                dot(fermion_state[10], fermion_state[10]) +
                dot(fermion_state[11], fermion_state[11]);
    }

    // Scale a fermion state by a complex scalar
    void scl(FermionFieldState fermion_state, float2 scalar, out FermionFieldState result)
    {
        result[0] = ComplexNumbersMath::prd(fermion_state[0], scalar);
        result[1] = ComplexNumbersMath::prd(fermion_state[1], scalar);
        result[2] = ComplexNumbersMath::prd(fermion_state[2], scalar);
        result[3] = ComplexNumbersMath::prd(fermion_state[3], scalar);
        result[4] = ComplexNumbersMath::prd(fermion_state[4], scalar);
        result[5] = ComplexNumbersMath::prd(fermion_state[5], scalar);
        result[6] = ComplexNumbersMath::prd(fermion_state[6], scalar);
        result[7] = ComplexNumbersMath::prd(fermion_state[7], scalar);
        result[8] = ComplexNumbersMath::prd(fermion_state[8], scalar);
        result[9] = ComplexNumbersMath::prd(fermion_state[9], scalar);
        result[10] = ComplexNumbersMath::prd(fermion_state[10], scalar);
        result[11] = ComplexNumbersMath::prd(fermion_state[11], scalar);
    }

    // Scale a fermion state by a real scalar
    void rscl(FermionFieldState fermion_state, float real_scalar, out FermionFieldState result)
    {
        result[0] = fermion_state[0] * real_scalar;
        result[1] = fermion_state[1] * real_scalar;
        result[2] = fermion_state[2] * real_scalar;
        result[3] = fermion_state[3] * real_scalar;
        result[4] = fermion_state[4] * real_scalar;
        result[5] = fermion_state[5] * real_scalar;
        result[6] = fermion_state[6] * real_scalar;
        result[7] = fermion_state[7] * real_scalar;
        result[8] = fermion_state[8] * real_scalar;
        result[9] = fermion_state[9] * real_scalar;
        result[10] = fermion_state[10] * real_scalar;
        result[11] = fermion_state[11] * real_scalar;
    }

    // Perform a linear combination of two fermion states (weighted by complex numbers)
    void scl_sum(FermionFieldState fermion_state1, FermionFieldState fermion_state2, float2 weight1, float2 weight2, out FermionFieldState result)
    {
        result[0] = ComplexNumbersMath::prd(fermion_state1[0], weight1) + ComplexNumbersMath::prd(fermion_state2[0], weight2);
        result[1] = ComplexNumbersMath::prd(fermion_state1[1], weight1) + ComplexNumbersMath::prd(fermion_state2[1], weight2);
        result[2] = ComplexNumbersMath::prd(fermion_state1[2], weight1) + ComplexNumbersMath::prd(fermion_state2[2], weight2);
        result[3] = ComplexNumbersMath::prd(fermion_state1[3], weight1) + ComplexNumbersMath::prd(fermion_state2[3], weight2);
        result[4] = ComplexNumbersMath::prd(fermion_state1[4], weight1) + ComplexNumbersMath::prd(fermion_state2[4], weight2);
        result[5] = ComplexNumbersMath::prd(fermion_state1[5], weight1) + ComplexNumbersMath::prd(fermion_state2[5], weight2);
        result[6] = ComplexNumbersMath::prd(fermion_state1[6], weight1) + ComplexNumbersMath::prd(fermion_state2[6], weight2);
        result[7] = ComplexNumbersMath::prd(fermion_state1[7], weight1) + ComplexNumbersMath::prd(fermion_state2[7], weight2);
        result[8] = ComplexNumbersMath::prd(fermion_state1[8], weight1) + ComplexNumbersMath::prd(fermion_state2[8], weight2);
        result[9] = ComplexNumbersMath::prd(fermion_state1[9], weight1) + ComplexNumbersMath::prd(fermion_state2[9], weight2);
        result[10] = ComplexNumbersMath::prd(fermion_state1[10], weight1) + ComplexNumbersMath::prd(fermion_state2[10], weight2);
        result[11] = ComplexNumbersMath::prd(fermion_state1[11], weight1) + ComplexNumbersMath::prd(fermion_state2[11], weight2);
    }

    // Perform a linear combination of two fermion states (weighted by real numbers)
    void rscl_sum(FermionFieldState fermion_state1, FermionFieldState fermion_state2, float weight1, float weight2, out FermionFieldState result)
    {
        result[0] = fermion_state1[0] * weight1 + fermion_state2[0] * weight2;
        result[1] = fermion_state1[1] * weight1 + fermion_state2[1] * weight2;
        result[2] = fermion_state1[2] * weight1 + fermion_state2[2] * weight2;
        result[3] = fermion_state1[3] * weight1 + fermion_state2[3] * weight2;
        result[4] = fermion_state1[4] * weight1 + fermion_state2[4] * weight2;
        result[5] = fermion_state1[5] * weight1 + fermion_state2[5] * weight2;
        result[6] = fermion_state1[6] * weight1 + fermion_state2[6] * weight2;
        result[7] = fermion_state1[7] * weight1 + fermion_state2[7] * weight2;
        result[8] = fermion_state1[8] * weight1 + fermion_state2[8] * weight2;
        result[9] = fermion_state1[9] * weight1 + fermion_state2[9] * weight2;
        result[10] = fermion_state1[10] * weight1 + fermion_state2[10] * weight2;
        result[11] = fermion_state1[11] * weight1 + fermion_state2[11] * weight2;
    }

    // Interpolate between a pair of fermion states
    void lerp_states(FermionFieldState fermion_state1, FermionFieldState fermion_state2, float weight, out FermionFieldState result)
    {
        result[0] = lerp(fermion_state1[0], fermion_state2[0], weight);
        result[1] = lerp(fermion_state1[1], fermion_state2[1], weight);
        result[2] = lerp(fermion_state1[2], fermion_state2[2], weight);
        result[3] = lerp(fermion_state1[3], fermion_state2[3], weight);
        result[4] = lerp(fermion_state1[4], fermion_state2[4], weight);
        result[5] = lerp(fermion_state1[5], fermion_state2[5], weight);
        result[6] = lerp(fermion_state1[6], fermion_state2[6], weight);
        result[7] = lerp(fermion_state1[7], fermion_state2[7], weight);
        result[8] = lerp(fermion_state1[8], fermion_state2[8], weight);
        result[9] = lerp(fermion_state1[9], fermion_state2[9], weight);
        result[10] = lerp(fermion_state1[10], fermion_state2[10], weight);
        result[11] = lerp(fermion_state1[11], fermion_state2[11], weight);
    }

    // Take the adjoint of a fermion state
    void adjoint(FermionFieldState fermion_state, out FermionFieldState result)
    {
        result[0] = ComplexNumbersMath::cnj(fermion_state[0]);
        result[1] = ComplexNumbersMath::cnj(fermion_state[1]);
        result[2] = ComplexNumbersMath::cnj(fermion_state[2]);
        result[3] = ComplexNumbersMath::cnj(fermion_state[3]);
        result[4] = ComplexNumbersMath::cnj(fermion_state[4]);
        result[5] = ComplexNumbersMath::cnj(fermion_state[5]);
        result[6] = ComplexNumbersMath::cnj(fermion_state[6]);
        result[7] = ComplexNumbersMath::cnj(fermion_state[7]);
        result[8] = ComplexNumbersMath::cnj(fermion_state[8]);
        result[9] = ComplexNumbersMath::cnj(fermion_state[9]);
        result[10] = ComplexNumbersMath::cnj(fermion_state[10]);
        result[11] = ComplexNumbersMath::cnj(fermion_state[11]);
    }

    // Perform a polar sum between a pair of fermion states (see: complex_numbers_math.hlsl > ComplexNumbersMath > polar_sum)
    void polar_sum(FermionFieldState fermion_state1, FermionFieldState fermion_state2, out FermionFieldState result)
    {
        result[0] = ComplexNumbersMath::polar_sum(fermion_state1[0], fermion_state2[0]);
        result[1] = ComplexNumbersMath::polar_sum(fermion_state1[1], fermion_state2[1]);
        result[2] = ComplexNumbersMath::polar_sum(fermion_state1[2], fermion_state2[2]);
        result[3] = ComplexNumbersMath::polar_sum(fermion_state1[3], fermion_state2[3]);
        result[4] = ComplexNumbersMath::polar_sum(fermion_state1[4], fermion_state2[4]);
        result[5] = ComplexNumbersMath::polar_sum(fermion_state1[5], fermion_state2[5]);
        result[6] = ComplexNumbersMath::polar_sum(fermion_state1[6], fermion_state2[6]);
        result[7] = ComplexNumbersMath::polar_sum(fermion_state1[7], fermion_state2[7]);
        result[8] = ComplexNumbersMath::polar_sum(fermion_state1[8], fermion_state2[8]);
        result[9] = ComplexNumbersMath::polar_sum(fermion_state1[9], fermion_state2[9]);
        result[10] = ComplexNumbersMath::polar_sum(fermion_state1[10], fermion_state2[10]);
        result[11] = ComplexNumbersMath::polar_sum(fermion_state1[11], fermion_state2[11]);
    }

    // Take the norm of a fermion state
    float norm(FermionFieldState f1)
    {
        return sqrt(norm_sqrd(f1));
    }

    // Perform a phase rotation on a fermion state
    void phase_rot(FermionFieldState fermion_state, float phase_angle, out FermionFieldState result)
    {
        result[0] = ComplexNumbersMath::rot(fermion_state[0], phase_angle);
        result[1] = ComplexNumbersMath::rot(fermion_state[1], phase_angle);
        result[2] = ComplexNumbersMath::rot(fermion_state[2], phase_angle);
        result[3] = ComplexNumbersMath::rot(fermion_state[3], phase_angle);
        result[4] = ComplexNumbersMath::rot(fermion_state[4], phase_angle);
        result[5] = ComplexNumbersMath::rot(fermion_state[5], phase_angle);
        result[6] = ComplexNumbersMath::rot(fermion_state[6], phase_angle);
        result[7] = ComplexNumbersMath::rot(fermion_state[7], phase_angle);
        result[8] = ComplexNumbersMath::rot(fermion_state[8], phase_angle);
        result[9] = ComplexNumbersMath::rot(fermion_state[9], phase_angle);
        result[10] = ComplexNumbersMath::rot(fermion_state[10], phase_angle);
        result[11] = ComplexNumbersMath::rot(fermion_state[11], phase_angle);
    }

    // Take the inner product between a pair of fermion states
    float2 inner_product(FermionFieldState fermion_state1, FermionFieldState fermion_state2)
    {
        float2 result = float2(0, 0);
        for (uint i = 0; i < 12; i++) result += ComplexNumbersMath::prd(ComplexNumbersMath::cnj(fermion_state1[i]), fermion_state2[i]);
        return result;
    }

    // Increase the norm of a fermion state by a specified amount (without changing its direction and phase)
    void add_norm(FermionFieldState fermion_state, float norm_addition, out FermionFieldState result)
    {
        float state_norm = norm(fermion_state);
        if (state_norm == 0)
        {
            FermionFieldStateOps::empty(result);
            result[0] = float2(norm_addition, 0);
            return;
        }
        scl(fermion_state, float2((state_norm + norm_addition) / state_norm, 0), result);
    }

    // Clamp the norm of a fermion state to a specified range (without changing its direction and phase)
    void clamp_norm(FermionFieldState state, float clamp_min, float clamp_max, out FermionFieldState result)
    {
        float stete_norm = norm(state);
        if (stete_norm == 0)
        {
            add_norm(state, clamp_min, result);
            return;
        }
        rscl(state, clamp(stete_norm, clamp_min, clamp_max) / stete_norm, result);
    }

    // Set the norm of a fermion state to a specified value (without changing its direction and phase)
    void set_norm(FermionFieldState state, float target_norm, out FermionFieldState result)
    {
        result = state;
        float stete_norm = norm_sqrd(state);
        if (stete_norm == 0)
        {
            add_norm(state, target_norm, result);
            return;
        }
        rscl(result, target_norm / stete_norm, result);
    }

    // Normalize a fermion state (without changing its direction and phase)
    void normalize(FermionFieldState state, out FermionFieldState result)
    {
        set_norm(state, 1, result);
    }

    // Take the sum of a pair of fermion states and set the result's norm to the first state's norm (performing a "unitary" change)
    void unitary_clamped_sum(FermionFieldState fermion_state1, FermionFieldState fermion_state2, out FermionFieldState result)
    {
        float initial_norm = norm(fermion_state1);
        sum(fermion_state1, fermion_state2, result);
        set_norm(result, initial_norm, result);
    }

    // Limit a state's norm using a harmonic limit (without changing its direction and phase)
    void harmonically_limit_norm(FermionFieldState fermion_state, float norm_limit, out FermionFieldState result)
    {
        result = fermion_state;
        float state_norm = norm(fermion_state);
        if (state_norm == 0) return;
        rscl(result, CommonMath::harmonic_mean(state_norm, norm_limit) / state_norm, result);
    }
}

#endif
