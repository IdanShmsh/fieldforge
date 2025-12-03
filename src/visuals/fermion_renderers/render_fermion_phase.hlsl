#ifndef RENDER_FERMION_PHASE
#define RENDER_FERMION_PHASE

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../core/simulation_globals.hlsl"


namespace FermionRendering
{
    /// Implementation of fermion field rendering based on the phase of the fermion states.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace RenderFermionPhase
    {
        // Get the color at a given position based on the phase of the fermion state of the specified field.
        // • Reads directly from the simulation's lattice buffers
        half4 get_fermion_phase_color_at_position(half3 position, uint field_index)
        {
            if (!SimulationDataOps::is_fermion_field_active(field_index)) return half4(0, 0, 0, 0);
            FermionFieldState state;
            FieldInterpolations::get_fermion_state_in_position(position, field_index, rend_fermions_lattice_buffer, state);
            half state_norm = (half)FermionFieldStateMath::norm(state);
            half state_phase = (half)ComplexNumbersMath::phase(state[0]);
            half3 hsv = half3(state_phase / (2.0 * 3.14159265), 1.0, state_norm);
            return half4(CommonMath::hsv2rgb(hsv), 0);
        }
    }
}

#endif
