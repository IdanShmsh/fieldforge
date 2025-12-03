#ifndef RENDER_FERMION_NORMCONTOURS
#define RENDER_FERMION_NORMCONTOURS

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../core/simulation_globals.hlsl"


namespace FermionRendering
{
    /// Implementation of fermion field rendering based on the norm contours of the fermion states.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace RenderFermionNormContours
    {
        // Get the color at a given position based on the norm contours of the fermion state of the specified field.
        // • Reads directly from the simulation's lattice buffers
        half4 get_fermion_norm_contours_color_at_position(half3 position, uint field_index, half granularity)
        {
            if (!SimulationDataOps::is_fermion_field_active(field_index)) return half4(0, 0, 0, 0);
            FermionFieldState state;
            FieldInterpolations::get_fermion_state_in_position(position, field_index, rend_fermions_lattice_buffer, state);
            half state_norm = (half)FermionFieldStateMath::norm(state);
            half periodic = abs(frac(state_norm * granularity) * 2 - 1) * 2 - 1;
            return periodic * state_norm * (half4)fermion_field_properties[field_index].color;
        }
    }
}

#endif
