#ifndef RENDER_FERMION_DIRAC_NORM
#define RENDER_FERMION_DIRAC_NORM

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../core/simulation_globals.hlsl"


namespace FermionRendering
{
    namespace RenderFermionDiracNorm
    {
        half4 get_fermion_dirac_norm_color_at_position(half3 position, uint field_index)
        {
            if (!SimulationDataOps::is_fermion_field_active(field_index)) return half4(0, 0, 0, 0);
            FermionFieldState state;
            FieldInterpolations::get_fermion_state_in_position(position, field_index, rend_fermions_lattice_buffer, state);
            half state_norm = (half)DiracFormalism::dirac_norm(state);
            return state_norm * state_norm * (half4)fermion_field_properties[field_index].color;
        }
    }
}

#endif
