#ifndef GUARDRAILS_PASSIVE_SCALING_ENERGY_DISSIPATION
#define GUARDRAILS_PASSIVE_SCALING_ENERGY_DISSIPATION

#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/math/fermion_field_state_math.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"

namespace Guardrails
{
    /// Implementation of passive energy dissipation capabilities.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace PassiveScaling
    {
        // This function is used to scale all fermion fields at a given position by a given scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void scale_fermion_fields_down(float3 position, float scale_reduction_factor, FermionLatticeBuffer lattice_buffer)
        {
            float scaling_factor = 1 - scale_reduction_factor;
            for (uint field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
            {
                if (!SimulationDataOps::is_fermion_field_active(field_index)) continue;
                uint bufferIndex = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
                FermionFieldStateMath::rscl(lattice_buffer[bufferIndex], scaling_factor, lattice_buffer[bufferIndex]);
            }
        }

        // This function is used to scale all gauge fields at a given position by a given scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void scale_gauge_fields_down(float3 position, float scale_reduction_factor, GaugeLatticeBuffer lattice_buffer)
        {
            float scaling_factor = 1 - scale_reduction_factor;
            uint bufferIndex = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPackMath::scl(lattice_buffer[bufferIndex], scaling_factor, lattice_buffer[bufferIndex]);
        }
    }
}

#endif
