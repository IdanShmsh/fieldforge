#ifndef RENDER_FERMION_SPIN_DIAL
#define RENDER_FERMION_SPIN_DIAL

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/simulation_globals.hlsl"
#include "../../core/formalisms/dirac_formalism.hlsl"
#include "../_rendering/vector_dial_rendering.hlsl"


namespace FermionRendering
{
    namespace RenderFermionSpinDial
    {
        half4 get_fermion_spin_dial_color_at_position(float3 position, uint field_index, half granularity, half length_scale)
        {
            if (!SimulationDataOps::is_fermion_field_active(field_index)) return half4(0, 0, 0, 0);
            half3 rounded_position;
            half2 offset_coefficient;
            VectorDialRendering::calculate_position_offset_variables_xy(position, granularity, rounded_position, offset_coefficient);
            const uint buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(rounded_position, field_index);
            FermionFieldState state = rend_fermions_lattice_buffer[buffer_index];
            half state_norm = (half)FermionFieldStateMath::norm(state);
            if (state_norm == 0) return half4(0, 0, 0, 0);
            half4 spin_state = half4(0, DiracFormalism::obtain_spin_state(state));
            return state_norm * (half4)fermion_field_properties[field_index].color * VectorDialRendering::get_vector_dial_color_at_position_xy(spin_state, length_scale, offset_coefficient);
        }
    }
}

#endif
